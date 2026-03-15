import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../model/resume_model.dart';

class ResumeViewModel {
  ResumeModel? resume;
  bool loading = false;
  String? error;
  String? statusMessage;

  final _supabase = Supabase.instance.client;

  Future<void> loadResume() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc =
        await FirebaseFirestore.instance.collection('resumes').doc(uid).get();
    if (doc.exists) {
      resume = ResumeModel.fromMap(doc.data()!);
    }
  }

  Future<void> uploadResumeBytes(
    Uint8List bytes,
    String fileName,
    VoidCallback onUpdate,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    loading = true;
    error = null;
    statusMessage = 'Uploading resume...';
    onUpdate();

    try {
      // 1. Upload to Supabase Storage
      final path = '$uid/$fileName';
      await _supabase.storage.from('resumes').uploadBinary(
            path,
            bytes,
            fileOptions:
                const FileOptions(contentType: 'application/pdf', upsert: true),
          );
      final downloadUrl = _supabase.storage.from('resumes').getPublicUrl(path);

      statusMessage = 'Embedding resume with AI...';
      onUpdate();

      // 2. Send bytes to backend for Qdrant embedding
      final formData = dio.FormData.fromMap({
        'resume': dio.MultipartFile.fromBytes(bytes, filename: fileName),
      });
      await ApiClient().dio.post(
            AppConstants.resumeEmbedEndpoint,
            data: formData,
            options: dio.Options(contentType: 'multipart/form-data'),
          );

      // 3. Save metadata to Firestore
      resume = ResumeModel(
        userId: uid,
        fileName: fileName,
        downloadUrl: downloadUrl,
        uploadedAt: DateTime.now(),
      );
      await FirebaseFirestore.instance
          .collection('resumes')
          .doc(uid)
          .set(resume!.toMap());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'hasResume': true});

      loading = false;
      statusMessage = null;
      onUpdate();
    } catch (e) {
      loading = false;
      error = e.toString();
      statusMessage = null;
      onUpdate();
    }
  }
}

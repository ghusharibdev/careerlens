import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../model/match_result_model.dart';

class MatchViewModel {
  bool loading = false;
  String? error;
  MatchResultModel? result;

  Future<void> loadExistingResult(String jobId, VoidCallback onUpdate) async {
    final doc = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
    if (doc.exists && doc.data()?['matchResult'] != null) {
      result = MatchResultModel.fromMap(doc.data()!['matchResult']);
      onUpdate();
    }
  }

  Future<void> analyzeMatch(String jobId, String jobDescription, VoidCallback onUpdate) async {
    loading = true;
    error = null;
    onUpdate();

    try {
      final response = await ApiClient().dio.post(
        AppConstants.matchEndpoint,
        data: {'jobDescription': jobDescription},
      );

      result = MatchResultModel.fromMap(response.data['result']);

      // Save result back to Firestore under this job
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
        'matchScore': result!.matchScore,
        'matchResult': result!.toMap(),
      });

      loading = false;
      onUpdate();
    } catch (e) {
      loading = false;
      error = e.toString();
      onUpdate();
    }
  }
}

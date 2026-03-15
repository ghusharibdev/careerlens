import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeModel {
  final String userId;
  final String fileName;
  final String downloadUrl;
  final DateTime uploadedAt;

  ResumeModel({
    required this.userId,
    required this.fileName,
    required this.downloadUrl,
    required this.uploadedAt,
  });

  factory ResumeModel.fromMap(Map<String, dynamic> map) {
    return ResumeModel(
      userId: map['userId'] ?? '',
      fileName: map['fileName'] ?? '',
      downloadUrl: map['downloadUrl'] ?? '',
      uploadedAt: map['uploadedAt'] != null
          ? (map['uploadedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'fileName': fileName,
        'downloadUrl': downloadUrl,
        'uploadedAt': uploadedAt,
      };
}
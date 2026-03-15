import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String userId;
  final String title;
  final String company;
  final String jobDescription;
  final String status;
  final int? matchScore;
  final DateTime createdAt;

  JobModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.company,
    required this.jobDescription,
    this.status = 'applied',
    this.matchScore,
    required this.createdAt,
  });

  factory JobModel.fromMap(Map<String, dynamic> map, String id) {
    return JobModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      company: map['company'] ?? '',
      jobDescription: map['jobDescription'] ?? '',
      status: map['status'] ?? 'applied',
      matchScore: map['matchScore'],
      // handle both Timestamp and null safely
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'title': title,
        'company': company,
        'jobDescription': jobDescription,
        'status': status,
        'matchScore': matchScore,
        'createdAt': createdAt,
      };

  JobModel copyWith({String? status, int? matchScore}) {
    return JobModel(
      id: id,
      userId: userId,
      title: title,
      company: company,
      jobDescription: jobDescription,
      status: status ?? this.status,
      matchScore: matchScore ?? this.matchScore,
      createdAt: createdAt,
    );
  }
}
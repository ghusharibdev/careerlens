import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/job_model.dart';

class JobsViewModel {
  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  Stream<List<JobModel>> jobsStream() {
    return FirebaseFirestore.instance
        .collection('jobs')
        .where('userId', isEqualTo: _uid)
        // No orderBy — avoids requiring a Firestore composite index
        .snapshots()
        .map((snap) {
          final jobs = snap.docs
              .map((d) => JobModel.fromMap(d.data(), d.id))
              .toList();
          // Sort in Dart instead — newest first
          jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return jobs;
        });
  }

  Future<void> addJob(String title, String company, String jd) async {
    await FirebaseFirestore.instance.collection('jobs').add({
      'userId': _uid,
      'title': title,
      'company': company,
      'jobDescription': jd,
      'status': 'applied',
      'matchScore': null,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateStatus(String jobId, String status) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .update({'status': status});
  }

  Future<void> updateMatchScore(String jobId, int score) async {
    await FirebaseFirestore.instance
        .collection('jobs')
        .doc(jobId)
        .update({'matchScore': score});
  }

  Future<void> deleteJob(String jobId) async {
    await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();
  }
}
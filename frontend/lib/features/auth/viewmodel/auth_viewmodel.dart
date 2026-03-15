import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthViewModel {
  User? currentUser = FirebaseAuth.instance.currentUser;

  Future<String?> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      currentUser = FirebaseAuth.instance.currentUser;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String?> signUp(String email, String password, String name) async {
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'uid': cred.user!.uid,
        'email': email,
        'displayName': name,
        'hasResume': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      currentUser = FirebaseAuth.instance.currentUser;
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    currentUser = null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserDataRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> saveUserDataToFirestore(String email, String username) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userData = {
        'uid': user.uid,
        'email': email,
        'username': username,
      };

      try {
        await firestore.collection('users').doc(user.uid).set(userData);
      } catch (e) {
        print("Error saving user data: $e");
      }
    }
  }

  Stream<QuerySnapshot> getUsers() {
    return firestore.collection('users').snapshots();
  }
}

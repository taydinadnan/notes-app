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
        'profilePictureURL': 'https://i.imgur.com/lRT3YNb.png'
      };

      try {
        await firestore.collection('users').doc(user.uid).set(userData);
      } catch (e) {
        // ignore: avoid_print
        print("Error saving user data: $e");
      }
    }
  }

  Stream<QuerySnapshot> getUsers() {
    return firestore.collection('users').snapshots();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final userDataDoc = await firestore.collection('users').doc(uid).get();
      if (userDataDoc.exists) {
        return userDataDoc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      // Handle errors, e.g., print or throw an exception
      return null;
    }
  }
}

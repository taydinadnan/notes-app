import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  Future<Map<String, dynamic>?> getUserData(String userUID) async {
    try {
      final userDocument =
          await firestore.collection('users').doc(userUID).get();
      if (userDocument.exists) {
        return userDocument.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error retrieving user data: $e");
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final usersCollection = firestore.collection('users');
      final querySnapshot = await usersCollection.get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error retrieving all users: $e");
      return [];
    }
  }

  Widget buildUserListItem(BuildContext context, Map<String, dynamic> user) {
    return Text('Owner: ${user['username']}');
  }
}

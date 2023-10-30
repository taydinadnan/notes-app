import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/repository/user_data_repository.dart';

StreamBuilder<QuerySnapshot<Object?>> getUserName(
    UserDataRepository userDataRepository, FirebaseAuth user) {
  return StreamBuilder<QuerySnapshot>(
    stream: userDataRepository.getUsers(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      }
      if (snapshot.hasData) {
        final users = snapshot.data!.docs;
        final currentUserUid = user.currentUser?.uid;
        if (currentUserUid != null) {
          final currentUserData = users.firstWhere(
            (userDoc) => userDoc.id == currentUserUid,
          );
          final username = currentUserData['username'];
          return Text(username);
        }
      }
      return const Text('User Name');
    },
  );
}

class UserProfilePictureCache {
  static final UserProfilePictureCache _instance =
      UserProfilePictureCache._internal();

  factory UserProfilePictureCache() {
    return _instance;
  }

  UserProfilePictureCache._internal();

  final Map<String, String> _cache = {};

  void updateCache(String userId, String profilePictureURL) {
    _cache[userId] = profilePictureURL;
  }

  String? getFromCache(String userId) {
    return _cache[userId];
  }
}

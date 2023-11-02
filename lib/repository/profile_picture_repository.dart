import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/user_data_repository.dart';

class ProfilePictureRepository {
  Future<void> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_images/${auth.currentUser!.uid}');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() {});
    } catch (e) {
      // ignore: avoid_print
      print("Error uploading image to Firebase Storage: $e");
    }
  }

  Widget getUserProfilePicture(
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
            final profilePicture = currentUserData['profilePictureURL'];

            final userProfilePictureCache = UserProfilePictureCache();

            if (profilePicture != null) {
              userProfilePictureCache.updateCache(
                  currentUserUid, profilePicture);
              return ClipOval(
                child: FadeInImage.assetNetwork(
                  fadeInDuration: const Duration(milliseconds: 10),
                  placeholder: "assets/placeHolder.png",
                  image: profilePicture,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              );
            }
          }
        }
        return ClipOval(
          child: Image.network(
            "https://i.imgur.com/lRT3YNb.png",
            fit: BoxFit.cover,
            width: 40,
            height: 40,
          ),
        );
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';

StreamBuilder<QuerySnapshot<Object?>> getUsersNoteLength(
    NoteRepository noteRepository) {
  return StreamBuilder<QuerySnapshot>(
    stream: noteRepository.getNotes(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (snapshot.hasData) {
        int numberOfNotes = snapshot.data!.docs.length;
        return ListTile(
          leading: const Icon(Icons.note),
          title: Text('$numberOfNotes Notes'),
        );
      }
      return const ListTile(
        leading: Icon(Icons.note),
        title: Text('Number of Notes: 0'),
      );
    },
  );
}

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

StreamBuilder<QuerySnapshot<Object?>> getUserProfilePicture(
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

          return ClipOval(
            child: Image.network(
              profilePicture,
              fit: BoxFit.cover,
              width: 40,
              height: 40,
            ),
          );
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

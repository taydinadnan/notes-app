import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/widget_tree.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseAuth user = FirebaseAuth.instance;
    final NoteRepository noteRepository = NoteRepository();
    final UserDataRepository userDataRepository = UserDataRepository();
    String userEmail = user.currentUser!.email ?? "Invalid";
    String initialEmailLetter = userEmail[0].toUpperCase();
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: getUserName(userDataRepository, user),
            accountEmail: Text(user.currentUser!.email!),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                initialEmailLetter,
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(color: AppStyle.noteAppColor),
          ),
          getUsersNoteLength(noteRepository),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () async {
              await UserDataRepository().signOut();
              // ignore: use_build_context_synchronously
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const WidgetTree()));
            },
          ),
        ],
      ),
    );
  }

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
}

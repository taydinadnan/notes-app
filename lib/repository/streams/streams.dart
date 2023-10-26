import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/screens/home_screen_widget.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/view/todo/screens/edit_todo.dart';

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
          leading: const Icon(MyFlutterApp.note),
          title: Text('Total Notes: $numberOfNotes'),
        );
      }
      return const ListTile(
        leading: Icon(Icons.note),
        title: Text('Number of Notes: 0'),
      );
    },
  );
}

StreamBuilder<QuerySnapshot<Object?>> getTodoListLength(
  ToDoRepository todoRepository,
) {
  return StreamBuilder<QuerySnapshot>(
    stream: todoRepository
        .getToDos(), // Replace with your method to fetch the to-do list
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (snapshot.hasData) {
        int numberOfItems = snapshot.data!.docs.length;
        return ListTile(
          leading: const Icon(Icons.checklist),
          title: Text('Total To-Do Items: $numberOfItems'),
        );
      }
      return const ListTile(
        leading: Icon(Icons.checklist),
        title: Text('Number of To-Do Items: 0'),
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

Widget getUserProfilePicture(
    UserDataRepository userDataRepository, FirebaseAuth user) {
  final userProfilePictureCache = UserProfilePictureCache();

  String? cachedProfilePicture =
      userProfilePictureCache.getFromCache(user.currentUser?.uid ?? "");

  if (cachedProfilePicture != null) {
    return ClipOval(
      child: FadeInImage.assetNetwork(
        fadeInDuration: const Duration(milliseconds: 10),
        placeholder: "assets/placeHolder.png",
        image: cachedProfilePicture,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }

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

          userProfilePictureCache.updateCache(currentUserUid, profilePicture);

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

StreamBuilder<QuerySnapshot<Object?>> getNoteNames(
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
        final notes = snapshot.data!.docs;
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final noteTitle = note['note_title'];
            return RecentNoteCard(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EditNoteScreen(note);
                    },
                  ),
                );
              },
              doc: note,
              title: noteTitle,
              bgAvailable: true,
            );
          },
        );
      }
      return const ListTile(
        leading: Icon(Icons.note),
        title: Text('No Notes Available'),
      );
    },
  );
}

StreamBuilder<QuerySnapshot<Object?>> getTodoNames(
    ToDoRepository toDoRepository) {
  return StreamBuilder<QuerySnapshot>(
    stream: toDoRepository.getToDos(),
    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }
      if (snapshot.hasData) {
        final todos = snapshot.data!.docs;
        final filteredTodos = todos.where((todo) {
          // Check if there is at least one 'false' value in the 'done' list
          final doneList = (todo['done'] as List).cast<bool>();
          return doneList.contains(false);
        }).toList();

        if (filteredTodos.isEmpty) {
          return const ListTile(
            leading: Icon(Icons.note),
            title: Text('No To-Do Items Available'),
          );
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: filteredTodos.length,
          itemBuilder: (context, index) {
            final todo = filteredTodos[index];
            final todoTitle = todo['title'];
            return RecentNoteCard(
              onTap: () {
                // Handle the onTap action here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return EditToDoScreen(
                        todo,
                      );
                    },
                  ),
                );
              },
              doc: todo,
              title: todoTitle,
              bgAvailable: false,
            );
          },
        );
      }
      return const ListTile(
        leading: Icon(MyFlutterApp.checklist),
        title: Text('No To-Do Items Available'),
      );
    },
  );
}

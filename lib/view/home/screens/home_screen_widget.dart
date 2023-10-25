import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final UserDataRepository userDataRepository = UserDataRepository();
  final NoteRepository noteRepository = NoteRepository();
  final ToDoRepository todoRepository = ToDoRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppStyle.bgColor,
      drawer: const MyDrawer(),
      appBar: AppBar(
        backgroundColor: AppStyle.bgColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState!.openDrawer(),
              child: getUserProfilePicture(userDataRepository, user),
            ),
          ],
        ),
        actions: const [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            homeScreenTitle,
            spacingBig,
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: buildCard(
                    MyFlutterApp.note,
                    getUsersNoteLength(noteRepository),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: buildCard(
                    MyFlutterApp.checklist,
                    getTodoListLength(todoRepository),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget buildCard(IconData iconData, StreamBuilder<QuerySnapshot> notesStream) {
  return SizedBox(
    width: 150,
    height: 200,
    child: Card(
      elevation: 4,
      color: AppStyle.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 25.0),
            child: Icon(
              iconData,
              size: 50,
            ),
          ),
          Container(
            width: 200,
            height: 90,
            decoration: BoxDecoration(
              color: AppStyle.buttonColor,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: StreamBuilder<QuerySnapshot>(
              stream: notesStream.stream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasData) {
                  int numberOfNotes = snapshot.data!.docs.length;
                  return Center(
                    child: Text(
                      '$numberOfNotes',
                      style: AppStyle.mainTitle
                          .copyWith(fontSize: 25, color: Colors.white),
                    ),
                  );
                }
                return Center(
                  child: Text(
                    'Number of Notes: 0',
                    style: AppStyle.mainTitle
                        .copyWith(fontSize: 25, color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

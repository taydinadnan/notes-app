import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final UserDataRepository userDataRepository = UserDataRepository();
  final NoteRepository noteRepository = NoteRepository();
  final ToDoRepository todoRepository = ToDoRepository();

  // Replace this with your actual list of notes or a FutureBuilder to fetch notes from Firestore
  final List<QueryDocumentSnapshot> noteList = [
    // Populate this list with QueryDocumentSnapshot containing note data
    // Example: QueryDocumentSnapshot data = ...;
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppStyle.bgColor,
      drawer: const MyDrawer(),
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            bottom: 16.0,
            top: 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState!.openDrawer(),
                      child: getUserProfilePicture(userDataRepository, user),
                    ),
                  ],
                ),
                spacingBig,
                homeScreenNoteTitle,
                spacingMedium,
                SizedBox(
                  height: 150,
                  child: getNoteNames(noteRepository),
                ),
                spacingMedium,
                homeScreenTodoTitle,
                spacingMedium,
                SizedBox(
                  height: 150,
                  child: getTodoNames(todoRepository),
                ),
                spacingMedium,
                homeScreenSavedTitle,
                spacingMedium,
                SizedBox(
                  height: 150,
                  child: getNoteNames(noteRepository),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class RecentNoteCard extends StatelessWidget {
  final Function()? onTap;
  final QueryDocumentSnapshot doc;
  final String title;
  final bool bgAvailable;

  const RecentNoteCard({
    super.key,
    required this.onTap,
    required this.doc,
    required this.title,
    required this.bgAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        color: bgAvailable
            ? AppStyle.cardsColor[doc['color_id']]
            : AppStyle.bgColor,
        margin: const EdgeInsets.all(8),
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            width: 150,
            child: Text(
              title,
              overflow: TextOverflow.fade,
              style: AppStyle.mainTitle,
            ),
          ),
        ),
      ),
    );
  }
}

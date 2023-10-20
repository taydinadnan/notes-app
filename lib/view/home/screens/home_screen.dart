import 'dart:math';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/view/home/widgets/drawer.dart';
import 'package:notes_app/view/note/note_card.dart';
import 'package:notes_app/view/note/note_editor.dart';
import 'package:notes_app/view/note/note_reader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  int colorId = Random().nextInt(AppStyle.cardsColor.length);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      backgroundColor: AppStyle.bgColor,
      appBar: buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your recent Notes",
              style: GoogleFonts.roboto(
                color: AppStyle.titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: noteRepository.getNotes(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      children: snapshot.data!.docs
                          .map((note) => OpenContainer(
                                closedElevation: 0,
                                transitionType: ContainerTransitionType.fade,
                                tappable: false,
                                closedColor: AppStyle.bgColor,
                                closedShape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                                closedBuilder: (context, action) {
                                  return noteCard(() {
                                    action();
                                  }, note);
                                },
                                openBuilder: (
                                  BuildContext _,
                                  CloseContainerActionCallback closeContainer,
                                ) {
                                  return NoteReaderScreen(note);
                                },
                              ))
                          .toList(),
                    );
                  }
                  return Text(
                    "there's no Notes",
                    style: GoogleFonts.nunito(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: OpenContainer(
        openElevation: 4,
        transitionType: ContainerTransitionType.fade,
        closedElevation: 0,
        tappable: false,
        closedColor: AppStyle.cardsColor[colorId],
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        closedBuilder: (context, action) {
          return FloatingActionButton(
            backgroundColor: AppStyle.buttonColor,
            onPressed: action,
            child: const Icon(Icons.add),
          );
        },
        openBuilder: (
          BuildContext _,
          CloseContainerActionCallback closeContainer,
        ) {
          return const NoteEditorScreen();
        },
      ),
    );
  }

  AppBar buildAppBar() {
    FirebaseAuth user = FirebaseAuth.instance;
    String userEmail = user.currentUser!.email ?? "Invalid";
    String initialEmailLetter = userEmail[0].toUpperCase();
    return AppBar(
      backgroundColor: AppStyle.bgColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState!.openDrawer(),
            child: CircleAvatar(
              child: Text(initialEmailLetter),
            ),
          ),
        ],
      ),
    );
  }
}

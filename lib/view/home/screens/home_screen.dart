import 'dart:math';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/add_note_button.dart';
import 'package:notes_app/view/home/widgets/drawer.dart';
import 'package:notes_app/view/home/widgets/empty_notes_state_screen.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/view/note/screens/note_card.dart';

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
  bool isTextFieldVisible = false;
  String filterText = "";
  bool notesFound = true;

  TextEditingController searchController = TextEditingController();

  void toggleTextFieldVisibility() {
    setState(() {
      isTextFieldVisible = !isTextFieldVisible;
    });
  }

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
            yourRecentNotes,
            spacingBig,
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: noteRepository.getNotes(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final filteredNotes = snapshot.data!.docs.where((note) {
                        String title = note['note_title'];
                        String content = note['note_content'];
                        return title.contains(filterText) ||
                            content.contains(filterText);
                      }).toList();

                      notesFound = filteredNotes.isNotEmpty;

                      if (filteredNotes.isEmpty) {
                        return const Center(
                          child: EmptyNotesStateScreen(),
                        );
                      }

                      return GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        children: filteredNotes
                            .map((note) => OpenContainer(
                                  closedElevation: 0,
                                  transitionType: ContainerTransitionType.fade,
                                  tappable: false,
                                  closedColor: AppStyle.bgColor,
                                  closedShape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero,
                                  ),
                                  closedBuilder: (context, action) {
                                    return noteCard(() {
                                      action();
                                    }, note);
                                  },
                                  openBuilder: (
                                    BuildContext _,
                                    CloseContainerActionCallback closeContainer,
                                  ) {
                                    return EditNoteScreen(note);
                                  },
                                ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: AddNoteButton(colorId: colorId),
    );
  }

  AppBar buildAppBar() {
    FirebaseAuth user = FirebaseAuth.instance;
    final UserDataRepository userDataRepository = UserDataRepository();
    return AppBar(
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
      actions: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width:
              isTextFieldVisible ? MediaQuery.of(context).size.width / 1.5 : 0,
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            maxLines: 1,
            onChanged: (text) {
              setState(() {
                filterText = text;
              });
            },
            decoration: const InputDecoration(
              labelText: 'Search',
              isDense: true,
            ),
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {
                toggleTextFieldVisibility();
                filterText = '';
              },
              icon: const Icon(Icons.search),
            ),
          ],
        ),
      ],
    );
  }
}

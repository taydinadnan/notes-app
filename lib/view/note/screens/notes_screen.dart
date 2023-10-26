import 'dart:math';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/view/note/screens/note_card.dart';
import 'package:notes_app/view/note/widgets/add_note_button.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';
import 'package:notes_app/view/note/widgets/empty_notes_state_screen.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final UserDataRepository userDataRepository = UserDataRepository();
  final NoteRepository noteRepository = NoteRepository();
  int colorId = Random().nextInt(AppStyle.cardsColor.length);
  bool isTextFieldVisible = false;
  String filterText = "";
  bool sortByDate = true;

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    getUserProfilePicture(userDataRepository, user);
    super.initState();
  }

  void toggleTextFieldVisibility() {
    setState(() {
      isTextFieldVisible = !isTextFieldVisible;
    });
  }

  void toggleSort() {
    setState(() {
      sortByDate = !sortByDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      backgroundColor: AppStyle.bgColor,
      body: CustomPaint(
          painter: BackgroundPainter(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 0.0, top: 0),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _scaffoldKey.currentState!.openDrawer(),
                        child: getUserProfilePicture(userDataRepository, user),
                      ),
                      buildSearchField(),
                      IconButton(
                        onPressed: toggleTextFieldVisibility,
                        icon: const Icon(Icons.search),
                      ),
                    ],
                  ),
                ),
                Expanded(child: buildBody()),
              ],
            ),
          )),
      floatingActionButton: AddNoteButton(colorId: colorId),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildNotes() {
    return StreamBuilder<QuerySnapshot>(
      stream: noteRepository.getNotes(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final filteredNotes = _filterNotes(snapshot.data, filterText);
        final sortedNotes = sortNotes(filteredNotes);

        if (sortedNotes.isEmpty) {
          return const Center(
            child: EmptyNotesStateScreen(),
          );
        }

        return _buildNoteGrid(sortedNotes);
      },
    );
  }

  List<QueryDocumentSnapshot> _filterNotes(
      QuerySnapshot? data, String filterText) {
    if (data == null) {
      return [];
    }

    return data.docs.where((note) {
      String title = note['note_title'];
      String content = note['note_content'];
      return title.contains(filterText) || content.contains(filterText);
    }).toList();
  }

  GridView _buildNoteGrid(List<QueryDocumentSnapshot> filteredNotes) {
    filteredNotes = sortNotes(filteredNotes);
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 2.2,
      ),
      itemCount: filteredNotes.length,
      itemBuilder: (BuildContext context, int index) {
        final note = filteredNotes[index];
        return OpenContainer(
          closedElevation: 0,
          transitionType: ContainerTransitionType.fade,
          tappable: false,
          closedColor: Colors.transparent,
          closedShape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          closedBuilder: (context, action) {
            return NoteCard(onTap: action, doc: note);
          },
          openBuilder:
              (BuildContext _, CloseContainerActionCallback closeContainer) {
            return EditNoteScreen(note);
          },
        );
      },
    );
  }

  Widget buildSearchField() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      width: isTextFieldVisible ? MediaQuery.of(context).size.width / 1.5 : 0,
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
    );
  }

  List<QueryDocumentSnapshot> sortNotes(List<QueryDocumentSnapshot> notes) {
    if (sortByDate) {
      notes.sort((a, b) {
        String dateAString = a['creation_date'];
        String dateBString = b['creation_date'];

        DateFormat format = DateFormat('dd/MMM/yy - HH:mm');
        DateTime dateA = format.parse(dateAString);
        DateTime dateB = format.parse(dateBString);

        return dateB.compareTo(dateA);
      });
    } else {
      notes.sort((a, b) {
        String titleA = a['note_title'];
        String titleB = b['note_title'];
        return titleA.compareTo(titleB);
      });
    }
    return notes;
  }

  Widget buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              yourRecentNotes,
              PopupMenuButton<bool>(
                icon: const Icon(Icons.sort),
                onSelected: (bool value) {
                  toggleSort();
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<bool>(
                      value: true,
                      child: ListTile(
                        title: Text("Date"),
                        leading: Icon(Icons.date_range),
                      ),
                    ),
                    const PopupMenuItem<bool>(
                      value: false,
                      child: ListTile(
                        leading: Icon(Icons.sort_by_alpha),
                        title: Text("A-Z"),
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
          spacingBig,
          Expanded(
            child: Stack(
              children: [
                buildNotes(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

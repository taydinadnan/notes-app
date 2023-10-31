import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/profile_picture_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/widgets/custom_app_bar.dart';
import 'package:notes_app/widgets/drawer.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final UserDataRepository userDataRepository = UserDataRepository();
  final NoteRepository noteRepository = NoteRepository();
  final ProfilePictureRepository profilePictureRepository =
      ProfilePictureRepository();
  int colorId = Random().nextInt(AppStyle.cardsColor.length);
  bool isTextFieldVisible = false;
  String filterText = "";
  bool sortByDate = true;
  List<QueryDocumentSnapshot> collections = [];

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    fetchCollections();
    profilePictureRepository.getUserProfilePicture(userDataRepository, user);
    super.initState();
  }

  Future<void> fetchCollections() async {
    final userCollectionsStream = noteRepository.getCollections();
    userCollectionsStream.listen((querySnapshot) {
      setState(() {
        collections = querySnapshot.docs;
      });
    });
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
              _buildAppBar(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomAppBar(scaffoldKey: _scaffoldKey),
          _buildSearchField(),
          IconButton(
            onPressed: toggleTextFieldVisibility,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
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

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: DefaultTabController(
        length: collections.length + 1, // +1 for the "All Notes" tab
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                yourRecentNotes,
                _buildSortPopupMenu(),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  _buildCollectionTabs(),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Add the "All Notes" tab
                        _buildCollectionNotesForAllNotes(),
                        // Other collection tabs
                        ...collections.map((collection) {
                          String collectionId = collection.id;
                          return _buildCollectionNotes(collectionId);
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuButton<bool> _buildSortPopupMenu() {
    return PopupMenuButton<bool>(
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
    );
  }

  TabBar _buildCollectionTabs() {
    return TabBar(
      isScrollable: true,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorColor: Colors.transparent,
      labelStyle:
          AppStyle.mainTitle.copyWith(color: AppStyle.white, fontSize: 15),
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: AppStyle.buttonColor,
        boxShadow: [
          BoxShadow(
            color: AppStyle.buttonColor,
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      tabs: [
        Tab(
          text: "All Notes",
        ),
        // Other collection tabs
        ...collections.map((collection) {
          String collectionName = collection.get('name');
          collectionName = collectionName[0].toUpperCase() +
              collectionName.substring(1).toLowerCase();
          return Tab(
            text: collectionName,
          );
        }).toList(),
      ],
    );
  }

  Stream<QuerySnapshot> getNotesForCollectionStream(String collectionId) {
    return FirebaseFirestore.instance
        .collection('Notes')
        .where("collection_id", isEqualTo: collectionId)
        // .where("creator_ids",
        //     arrayContains: FirebaseAuth.instance.currentUser!.email)
        .snapshots();
  }

  Stream<QuerySnapshot> getAllNotesStream() {
    return FirebaseFirestore.instance
        .collection('Notes')
        .where("creator_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Widget _buildCollectionNotes(String collectionId) {
    print("Collection ID: $collectionId");
    print("User's Email: ${FirebaseAuth.instance.currentUser!.email}");

    return StreamBuilder<QuerySnapshot>(
      stream: getNotesForCollectionStream(collectionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Notes"));
        }

        final notes = snapshot.data!.docs.where((note) {
          final title = note.get("note_title") as String;
          final content = note.get("note_content") as String;
          return title.toLowerCase().contains(filterText.toLowerCase()) ||
              content.toLowerCase().contains(filterText.toLowerCase());
        }).toList();

        if (notes.isEmpty) {
          return const Center(child: Text("No matching notes"));
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final title = note.get("note_title") as String;
            final content = note.get("note_content") as String;
            final date = note.get("creation_date") as String;
            final colorId = note.get("color_id");
            int colorIndex = colorId % AppStyle.cardsColor.length;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              margin: const EdgeInsets.all(8.0),
              color: AppStyle.cardsColor[colorIndex],
              child: GestureDetector(
                onTap: () {
                  // Navigate to EditNoteScreen when the note is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(
                        note,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: AppStyle.mainTitle,
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        content,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.mainContent.copyWith(
                            color: AppStyle.titleColor.withOpacity(1)),
                      ),
                      Text(formatFirestoreDate(date)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCollectionNotesForAllNotes() {
    return StreamBuilder<QuerySnapshot>(
      stream: getAllNotesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Notes"));
        }

        final notes = snapshot.data!.docs.where((note) {
          final title = note.get("note_title") as String;
          final content = note.get("note_content") as String;
          return title.toLowerCase().contains(filterText.toLowerCase()) ||
              content.toLowerCase().contains(filterText.toLowerCase());
        }).toList();

        if (notes.isEmpty) {
          return const Center(child: Text("No matching notes"));
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            final title = note.get("note_title") as String;
            final content = note.get("note_content") as String;
            final date = note.get("creation_date") as String;
            final colorId = note.get("color_id");
            int colorIndex = colorId % AppStyle.cardsColor.length;

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
              ),
              margin: const EdgeInsets.all(8.0),
              color: AppStyle.cardsColor[colorIndex],
              child: GestureDetector(
                onTap: () {
                  // Navigate to EditNoteScreen when the note is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditNoteScreen(
                        note,
                      ),
                    ),
                  );
                },
                child: Stack(
                  children: [
                    ListTile(
                      title: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: AppStyle.mainTitle,
                      ),
                      subtitle: SingleChildScrollView(
                        child: Text(
                          content,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.mainContent.copyWith(
                              color: AppStyle.titleColor.withOpacity(1)),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Text(
                        formatFirestoreDate(date),
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.dateTitle.copyWith(
                            color: AppStyle.titleColor.withOpacity(0.5)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String formatFirestoreDate(String firestoreDate) {
    final firestoreDateFormat = DateFormat("dd/MMM/yyyy - HH:mm");
    final desiredFormat = DateFormat("dd MMM");

    try {
      final date = firestoreDateFormat.parse(firestoreDate);
      return desiredFormat.format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }
}

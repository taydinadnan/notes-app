import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/collections_repository.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/profile_picture_repository.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/collections/screens/collection_screen.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/widgets/custom_app_bar.dart';
import 'package:notes_app/widgets/drawer.dart';

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
  final CollectionsRepository collectionsRepository = CollectionsRepository();
  final ProfilePictureRepository profilePictureRepository =
      ProfilePictureRepository();

  final List<QueryDocumentSnapshot> noteList = [];

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
                    CustomAppBar(scaffoldKey: _scaffoldKey),
                  ],
                ),
                spacingBig,
                homeScreenCollectionsTitle,
                spacingMedium,
                buildCollectionsList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  FutureBuilder<List<QueryDocumentSnapshot<Object?>>> buildCollectionsList() {
    return FutureBuilder<List<QueryDocumentSnapshot>>(
      future: collectionsRepository.showCollections(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading Collections...");
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.hasData) {
          final collections = snapshot.data;
          return Column(
            children: collections!.asMap().entries.map((entry) {
              final collection = entry.value;
              final collectionName = collection.get('name') as String;
              final collectionId = collection.id;
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: Icon(
                    Icons.folder,
                    color: AppStyle.cardsColor[1],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        collectionName,
                        style: AppStyle.mainTitle,
                      ),
                      IconButton(
                          onPressed: () {
                            _showDeleteConfirmationDialog(
                                context, collectionId);
                          },
                          icon: const Icon(MyFlutterApp.x))
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NotesListScreen(
                          collectionId: collectionId,
                          collectionName: collectionName,
                        ),
                      ),
                    );
                  },
                ),
              );
            }).toList(),
          );
        }
        return const Text("No Collections");
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String collectionId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this collection?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(dialogContext).pop();
                noteRepository.removeCollection(collectionId);
              },
            ),
          ],
        );
      },
    );
  }
}

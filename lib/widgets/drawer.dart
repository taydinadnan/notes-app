import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/collections_repository.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/profile_picture_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/collections/screens/collection_screen.dart';
import 'package:notes_app/view/note/widgets/color_picker.dart';
import 'package:notes_app/widget_tree.dart';
import 'package:notes_app/widgets/profile_picture_widget.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  final CollectionsRepository collectionsRepository = CollectionsRepository();
  final UserDataRepository userDataRepository = UserDataRepository();
  final ProfilePictureRepository profilePictureRepository =
      ProfilePictureRepository();
  List<QueryDocumentSnapshot>? collections;
  int colorId = 0;
  String newCollectionName = '';
  List<String> creatorIds = [];
  String profilePictureURL = '';

  @override
  void initState() {
    super.initState();
    loadUserProfileImage();
  }

  Future<void> loadUserProfileImage() async {
    final Reference storageRef = FirebaseStorage.instance
        .ref()
        .child('user_profile_images/${user.currentUser!.uid}');

    try {
      final String downloadURL = await storageRef.getDownloadURL();
      setState(() {
        profilePictureURL = downloadURL;
      });
    } catch (e) {
      print("Error loading profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilePicture =
        ProfilePictureWidget(profilePictureURL: profilePictureURL);
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          buildUserAccountsHeader(context, profilePicture),
          Column(
            children: [
              buildColorPickerRow(),
              buildNumberOfNotes(auth),
            ],
          ),
          buildCollectionsList(),
          buildCreateCollectionButton(context),
          buildLogoutButton(context),
        ],
      ),
    );
  }

  ListTile buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(MyFlutterApp.sign_out),
      title: const Text('Logout'),
      onTap: () async {
        await userDataRepository.signOut();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WidgetTree()),
        );
      },
    );
  }

  ListTile buildCreateCollectionButton(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add),
      title: const Text('Create New Collection'),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Enter Collection Name'),
              content: TextField(
                onChanged: (value) {
                  setState(() {
                    newCollectionName = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    if (newCollectionName.isNotEmpty &&
                        !isDuplicateCollectionName(
                            collections, newCollectionName)) {
                      creatorIds.add(user.currentUser!.email!);

                      noteRepository.createCollection(
                        newCollectionName,
                        creatorIds,
                      );

                      creatorIds = [];

                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool isDuplicateCollectionName(
    List<QueryDocumentSnapshot>? collections,
    String newCollectionName,
  ) {
    if (collections == null) return false;

    return collections.any((collection) =>
        collection['name'].toString().toLowerCase() ==
        newCollectionName.trim().toLowerCase());
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
              return ListTile(
                leading: const Icon(Icons.folder),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(collectionName),
                    IconButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, collectionId);
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
              );
            }).toList(),
          );
        }
        return const Text("No Collections");
      },
    );
  }

  FutureBuilder<int> buildNumberOfNotes(FirebaseAuth auth) {
    return FutureBuilder<int>(
      future: noteRepository.getColorIdCount(colorId, auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }
        if (snapshot.hasError) {
          return Text("Error: ${snapshot.error}");
        }
        if (snapshot.hasData) {
          return Text(
            "${snapshot.data} Notes",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          );
        }
        return const Text("No data");
      },
    );
  }

  ColorPicker buildColorPickerRow() {
    return ColorPicker(
      colors: AppStyle.cardsColor,
      selectedColorIndex: colorId,
      onColorSelected: (newColorId) {
        setState(() {
          colorId = newColorId;
        });
      },
    );
  }

  UserAccountsDrawerHeader buildUserAccountsHeader(
      BuildContext context, ProfilePictureWidget profilePicture) {
    return UserAccountsDrawerHeader(
      accountName: userDataRepository.getUserName(userDataRepository, user),
      accountEmail: Text(user.currentUser!.email!),
      currentAccountPicture: GestureDetector(
        onTap: () => _pickImage(context),
        child: Stack(
          children: [
            profilePicture,
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                decoration: BoxDecoration(
                    color: AppStyle.buttonColor, shape: BoxShape.circle),
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Icon(
                    Icons.file_upload,
                    size: 15,
                    color: AppStyle.titleColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      decoration: BoxDecoration(color: AppStyle.noteAppColor),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await profilePictureRepository.uploadImageToFirebaseStorage(imageFile);
      loadUserProfileImage();
    }
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

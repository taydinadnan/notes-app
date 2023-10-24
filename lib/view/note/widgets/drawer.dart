import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/note/widgets/color_picker.dart';
import 'package:notes_app/widget_tree.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key}) : super(key: key);

  @override
  State createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  final FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  final UserDataRepository userDataRepository = UserDataRepository();
  int colorId = 0;

  String profilePictureURL = ''; // Store profile picture URL

  @override
  void initState() {
    super.initState();

    getUserProfilePicture(profilePictureURL);
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
      // ignore: avoid_print
      print("Error loading profile picture: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilePicture = getUserProfilePicture(profilePictureURL);
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: getUserName(userDataRepository, user),
            accountEmail: Text(user.currentUser!.email!),
            currentAccountPicture: GestureDetector(
              onTap: () {
                _pickImage(context);
              },
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
          ),
          Column(
            children: [
              ColorPicker(
                colors: AppStyle.cardsColor,
                selectedColorIndex: colorId,
                onColorSelected: (newColorId) {
                  setState(() {
                    colorId = newColorId;
                  });
                },
              ),
              FutureBuilder<int>(
                future: noteRepository.getColorIdCount(
                    colorId, auth.currentUser!.uid),
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
              ),
            ],
          ),
          getUsersNoteLength(noteRepository),
          ListTile(
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
          ),
        ],
      ),
    );
  }

  Widget getUserProfilePicture(String profilePictureURL) {
    if (profilePictureURL.isNotEmpty) {
      return ClipOval(
        child: FadeInImage.assetNetwork(
          fadeInDuration: const Duration(milliseconds: 10),
          placeholder: "assets/placeHolder.png",
          image: profilePictureURL,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      await uploadImageToFirebaseStorage(imageFile);

      loadUserProfileImage();
    }
  }

  Future<void> uploadImageToFirebaseStorage(File imageFile) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final Reference storageRef = FirebaseStorage.instance
          .ref()
          .child('user_profile_images/${auth.currentUser!.uid}');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      await uploadTask.whenComplete(() {});
    } catch (e) {
      // ignore: avoid_print
      print("Error uploading image to Firebase Storage: $e");
    }
  }
}

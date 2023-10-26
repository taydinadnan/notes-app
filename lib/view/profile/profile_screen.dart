import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  final ToDoRepository todoRepository = ToDoRepository();
  UserDataRepository userDataRepository = UserDataRepository();

  String? email;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchUserData();
  }

  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await userDataRepository.getUserData(user.uid);
      if (userData != null) {
        setState(() {
          email = userData['email'];
          username = userData['username'];
        });
      }
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _scaffoldKey.currentState!.openDrawer(),
                      child: const Icon(MyFlutterApp.person),
                    ),
                  ],
                ),
                spacingMega,
                profileTitle,
                spacingMedium,
                const Center(
                  child: CircleAvatar(
                    backgroundImage:
                        NetworkImage('https://i.imgur.com/lRT3YNb.png'),
                    radius: 50, // Adjust the size as needed
                  ),
                ),
                spacingMedium,
                Text('Email: ${email ?? 'Loading...'}'),
                spacingMedium,
                Text('Username: ${username ?? 'Loading...'}'),
                spacingMedium,
                ElevatedButton(
                  onPressed: () {
                    // Navigate to an edit profile screen or show a dialog for editing
                    // You can pass the current email and username to the edit screen/dialog
                  },
                  child: const Text('Edit Profile'),
                ),
                spacingMedium,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

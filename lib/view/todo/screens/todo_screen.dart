import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/repository/profile_picture_repository.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/widgets/custom_app_bar.dart';
import 'package:notes_app/widgets/drawer.dart';
import 'package:notes_app/view/note/widgets/empty_notes_state_screen.dart';
import 'package:notes_app/view/todo/screens/edit_todo.dart';
import 'package:notes_app/view/todo/screens/todo_card.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final UserDataRepository userDataRepository = UserDataRepository();
  final ToDoRepository todos = ToDoRepository();
  final ProfilePictureRepository profilePictureRepository =
      ProfilePictureRepository();
  bool isTextFieldVisible = false;
  String filterText = "";

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
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomAppBar(scaffoldKey: _scaffoldKey),
                  buildSearchField(),
                  IconButton(
                    onPressed: toggleTextFieldVisibility,
                    icon: const Icon(Icons.search),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, top: 20),
              child: yourRecentTodos,
            ),
            Expanded(child: buildTodosList()),
          ],
        ),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildTodosList() {
    final user = FirebaseAuth.instance.currentUser;
    final currentUserId = user!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: todos.getToDosForUser(currentUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: EmptyNotesStateScreen());
        } else {
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return OpenContainer(
                closedElevation: 0,
                transitionType: ContainerTransitionType.fade,
                tappable: false,
                closedColor: Colors.transparent,
                closedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                closedBuilder: (context, action) {
                  return ToDoCard(onTap: action, doc: doc);
                },
                openBuilder: (BuildContext _,
                    CloseContainerActionCallback closeContainer) {
                  return EditToDoScreen(doc);
                },
              );
            }).toList(),
          );
        }
      },
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppStyle.bgColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState!.openDrawer(),
            child: profilePictureRepository.getUserProfilePicture(
                userDataRepository, user),
          ),
          buildSearchField(),
          IconButton(
            onPressed: toggleTextFieldVisibility,
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      actions: [
        buildSearchField(),
        IconButton(
          onPressed: toggleTextFieldVisibility,
          icon: const Icon(Icons.search),
        ),
      ],
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
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/note/screens/create_note.dart';
import 'package:notes_app/view/note/screens/notes_screen.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';
import 'package:notes_app/view/profile/profile_screen.dart';
import 'package:notes_app/view/todo/screens/create_todo.dart';
import 'package:notes_app/view/todo/screens/todo_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenWidget(),
    const NotesScreen(),
    const TodoScreen(),
    const ProfileScreen(),
  ];

  void triggerAddNoteButton() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const CreateNoteScreen();
    }));
  }

  void triggerAddToDoButton() {
    ToDoRepository todo = ToDoRepository();
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return CreateToDoPage(
        todoRepository: todo,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.bgColor,
      body: _screens[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavigationBar(
        barColor: AppStyle.bgColor,
        bottomBar: [
          BottomBarItem(
              icon: const Icon(Icons.home),
              iconSelected: Icon(
                Icons.home,
                color: AppStyle.buttonColor,
              ),
              title: "Home",
              dotColor: AppStyle.buttonColor,
              onTap: (value) {
                setState(() {
                  _currentIndex = 0;
                });
              }),
          BottomBarItem(
              icon: const Icon(Icons.note),
              iconSelected: Icon(
                Icons.note,
                color: AppStyle.buttonColor,
              ),
              title: "Notes",
              dotColor: AppStyle.buttonColor,
              onTap: (value) {
                setState(() {
                  _currentIndex = 1;
                });
              }),
          BottomBarItem(
              icon: const Icon(Icons.check),
              iconSelected: Icon(
                Icons.check,
                color: AppStyle.buttonColor,
              ),
              title: "Todo",
              dotColor: AppStyle.buttonColor,
              onTap: (value) {
                setState(() {
                  _currentIndex = 2;
                });
              }),
          BottomBarItem(
              icon: const Icon(Icons.person),
              iconSelected: Icon(
                Icons.person,
                color: AppStyle.buttonColor,
              ),
              title: "Profile",
              dotColor: AppStyle.buttonColor,
              onTap: (value) {
                setState(() {
                  _currentIndex = 3;
                });
              }),
        ],
        bottomBarCenterModel: BottomBarCenterModel(
          centerBackgroundColor: AppStyle.buttonColor,
          centerIcon: const FloatingCenterButton(
            child: Icon(
              Icons.add,
              color: AppColors.white,
            ),
          ),
          centerIconChild: [
            FloatingCenterButtonChild(
              onTap: triggerAddNoteButton,
              child: const Icon(
                Icons.plus_one,
                color: AppColors.white,
              ),
            ),
            FloatingCenterButtonChild(
              onTap: triggerAddToDoButton,
              child: const Icon(
                Icons.access_alarm,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreenWidget extends StatefulWidget {
  const HomeScreenWidget({super.key});

  @override
  State<HomeScreenWidget> createState() => _HomeScreenWidgetState();
}

class _HomeScreenWidgetState extends State<HomeScreenWidget> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuth user = FirebaseAuth.instance;
  final UserDataRepository userDataRepository = UserDataRepository();
  @override
  Widget build(BuildContext context) {
    // Your Home screen content here
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppStyle.bgColor,
      drawer: const MyDrawer(),
      appBar: AppBar(
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
        actions: [],
      ),
    );
  }
}

import 'package:floating_bottom_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/view/home/screens/home_screen_widget.dart';
import 'package:notes_app/view/note/screens/create_note.dart';
import 'package:notes_app/view/note/screens/notes_screen.dart';
import 'package:notes_app/view/profile/profile_screen.dart';
import 'package:notes_app/view/todo/screens/create_todo.dart';
import 'package:notes_app/view/todo/screens/todo_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({super.key});

  @override
  State createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
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
              icon: const Icon(MyFlutterApp.home),
              iconSelected: Icon(
                MyFlutterApp.home,
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
              icon: const Icon(MyFlutterApp.note),
              iconSelected: Icon(
                MyFlutterApp.note,
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
              icon: const Icon(MyFlutterApp.checklist),
              iconSelected: Icon(
                MyFlutterApp.checklist,
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
              icon: const Icon(Icons.person, size: 25),
              iconSelected: Icon(
                Icons.person,
                size: 25,
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
                MyFlutterApp.note,
                color: AppColors.white,
              ),
            ),
            FloatingCenterButtonChild(
              onTap: triggerAddToDoButton,
              child: const Icon(
                MyFlutterApp.checklist,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

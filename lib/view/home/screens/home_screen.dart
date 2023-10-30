import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/view/home/screens/home_screen_widget.dart';
import 'package:notes_app/view/note/screens/create_note.dart';
import 'package:notes_app/view/note/screens/notes_screen.dart';
import 'package:notes_app/view/profile/profile_screen.dart';
import 'package:notes_app/view/todo/screens/create_todo.dart';
import 'package:notes_app/view/todo/screens/todo_screen.dart';

class CustomNavigationBar extends StatefulWidget {
  const CustomNavigationBar({Key? key}) : super(key: key);

  @override
  State createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  final FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  String newCollectionName = '';
  List<String> creatorIds = [];
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const NotesScreen(),
    const TodoScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppStyle.bgColor,
        elevation: 0,
        currentIndex: _currentIndex,
        selectedItemColor: AppStyle.buttonColor,
        unselectedItemColor: AppStyle.black,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(
              MyFlutterApp.home,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.note,
            ),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.check,
            ),
            label: 'Todo',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
            ),
            label: 'Profile',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Collection'),
                    onTap: () {
                      buildCreateCollectionButton(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Add Note'),
                    onTap: () {
                      triggerAddNoteButton();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Add Todo'),
                    onTap: () {
                      triggerAddToDoButton();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

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

  AlertDialog buildCreateCollectionButton(BuildContext context) {
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
            if (newCollectionName.isNotEmpty) {
              creatorIds = [user.currentUser!.uid];
              noteRepository.createCollection(newCollectionName, creatorIds);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

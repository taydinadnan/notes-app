import 'package:cloud_firestore/cloud_firestore.dart';
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
      resizeToAvoidBottomInset: false,
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
                        Navigator.pop(context);
                        showModalBottomSheet(
                          elevation: 4,
                          isScrollControlled: true,
                          context: context,
                          builder: (context) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom),
                              child: const AddCollectionPage(),
                            );
                          },
                        );
                      }),
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
}

class AddCollectionPage extends StatefulWidget {
  const AddCollectionPage({Key? key}) : super(key: key);

  @override
  State createState() => _AddCollectionPageState();
}

class _AddCollectionPageState extends State<AddCollectionPage> {
  final FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  List<QueryDocumentSnapshot>? collections; // Initialize the collections list
  String newCollectionName = '';
  List<String> creatorIds = [];

  Stream<QuerySnapshot<Object?>>? collectionStream;
  @override
  void initState() {
    super.initState();
    collectionStream = noteRepository.getCollections();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.all(16),
      duration: const Duration(milliseconds: 100),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Enter Collection Name',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextField(
            onChanged: (value) {
              setState(() {
                newCollectionName = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
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
          ),
        ],
      ),
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
}

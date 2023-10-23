import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';
import 'package:notes_app/view/todo/screens/create_todo.dart';
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
      appBar: buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24.0, top: 20),
            child: yourRecentTodos,
          ),
          Expanded(child: buildListTodos()), // Change this line
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.buttonColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CreateToDoPage(todoRepository: todos)));
          CreateToDoPage(todoRepository: todos);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> buildTodosList() {
    return StreamBuilder<QuerySnapshot>(
      stream: todos.getToDos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No to-do items found.'));
        } else {
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return OpenContainer(
                closedElevation: 0,
                transitionType: ContainerTransitionType.fade,
                tappable: false,
                closedColor: AppStyle.bgColor,
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

  StreamBuilder<QuerySnapshot<Object?>> buildListTodos() {
    return StreamBuilder<QuerySnapshot>(
      stream: todos.getFilteredToDos(filterText),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No to-do items found.'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: snapshot.data!.docs.map((doc) {
                return OpenContainer(
                  closedElevation: 0,
                  transitionType: ContainerTransitionType.fade,
                  tappable: false,
                  closedColor: AppStyle.bgColor,
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
            ),
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
            child: getUserProfilePicture(userDataRepository, user),
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

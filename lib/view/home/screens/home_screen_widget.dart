import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/app_text.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/todo_repository.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/home/widgets/color_picker_column.dart';
import 'package:notes_app/view/note/widgets/drawer.dart';

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

  Stream<QuerySnapshot<Object?>> getUsersNoteLength(
      NoteRepository noteRepository) {
    return noteRepository.getNotes();
  }

  Stream<QuerySnapshot<Object?>> getTodoListLength(
      ToDoRepository todoRepository) {
    return todoRepository.getToDos();
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
          child: buildHomeCards(),
        ),
      ),
    );
  }

  Column buildHomeCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState!.openDrawer(),
              child: getUserProfilePicture(userDataRepository, user),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              homeScreenTitle,
              spacingBig,
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.start,
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Expanded(
              //       child: StreamBuilder<QuerySnapshot>(
              //         stream: getUsersNoteLength(noteRepository),
              //         builder: (context, noteSnapshot) {
              //           if (noteSnapshot.hasData) {}
              //           return buildCard(MyFlutterApp.note, true);
              //         },
              //       ),
              //     ),
              //     const SizedBox(width: 16),
              //     Expanded(
              //       child: StreamBuilder<QuerySnapshot>(
              //         stream: getTodoListLength(todoRepository),
              //         builder: (context, todoSnapshot) {
              //           if (todoSnapshot.hasData) {}
              //           return buildCard(MyFlutterApp.checklist, false);
              //         },
              //       ),
              //     ),
              //   ],
              // )
            ],
          ),
        ),
      ],
    );
  }
}

Stream<QuerySnapshot<Object?>> getTodoListStream(
    ToDoRepository todoRepository) {
  return todoRepository.getToDos();
}

StreamBuilder<QuerySnapshot<Object?>> buildTodoListStream(
    ToDoRepository todoRepository) {
  return StreamBuilder<QuerySnapshot<Object?>>(
    stream: getTodoListStream(todoRepository),
    builder: (context, todoSnapshot) {
      int numberOfTodos = 0;
      if (todoSnapshot.hasData) {
        numberOfTodos = todoSnapshot.data!.docs.length;
      }
      return Text(numberOfTodos.toString());
    },
  );
}

Widget buildCard(IconData iconData, bool noteOrTodo) {
  ToDoRepository toDoRepository = ToDoRepository();
  return SizedBox(
    width: 150,
    height: 200,
    child: Card(
      elevation: 3,
      color: AppStyle.white,
      child: Stack(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 8.0, right: 8.0),
                child: Icon(
                  MyFlutterApp.kebab_vertical,
                ),
              ),
            ],
          ),
          noteOrTodo
              ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ColorPickerColumn(
                    colors: AppStyle.cardsColor,
                    onColorSelected: (int value) {},
                  ),
                ])
              : StreamBuilder<QuerySnapshot>(
                  stream: getTodoListStream(toDoRepository),
                  builder: (context, todoSnapshot) {
                    int numberOfTodos = 0;
                    if (todoSnapshot.hasData) {
                      numberOfTodos = todoSnapshot.data!.docs.length;
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            numberOfTodos.toString(),
                            style: AppStyle.mainTitle.copyWith(fontSize: 25),
                          ),
                          Text(
                            "Todo List",
                            style: AppStyle.mainTitle.copyWith(fontSize: 25),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ],
      ),
    ),
  );
}

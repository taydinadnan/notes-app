import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/view/todo/widgets/todo_title_desc_card.dart';

class EditToDoScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const EditToDoScreen(this.doc, {Key? key}) : super(key: key);

  @override
  State createState() => _EditToDoScreenState();
}

class _EditToDoScreenState extends State<EditToDoScreen> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late List<bool> todoListStatus; // List of boolean to represent "done" status
  late List<String> todoList; // List of task descriptions
  late bool isEditing;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.doc["title"]);
    descriptionController =
        TextEditingController(text: widget.doc["description"]);
    todoListStatus = List<bool>.from(widget.doc["done"]);
    todoList = List<String>.from(widget.doc["todos"]);
    isEditing = false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void updateToDoInFirestore() {
    final docRef =
        FirebaseFirestore.instance.collection("ToDos").doc(widget.doc.id);

    final updatedData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "done": todoListStatus,
      "todos": todoList,
    };

    docRef.update(updatedData).then((_) {
      print("To-Do updated successfully.");
      toggleEditing();
    }).catchError((error) {
      print("Failed to update to-do: $error");
    });
  }

  void deleteToDoFromFirestore() {
    final docRef =
        FirebaseFirestore.instance.collection("ToDos").doc(widget.doc.id);

    docRef.delete().then((_) {
      print("To-Do deleted successfully.");
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to delete to-do: $error");
    });
  }

  void toggleToDoStatus(int index) {
    setState(() {
      todoListStatus[index] = !todoListStatus[index];
    });

    final newTodoList = <String>[];
    final newTodoListStatus = <bool>[];

    for (var i = 0; i < todoList.length; i++) {
      if (!todoListStatus[i]) {
        newTodoList.add(todoList[i]);
        newTodoListStatus.add(todoListStatus[i]);
      }
    }

    for (var i = 0; i < todoList.length; i++) {
      if (todoListStatus[i]) {
        newTodoList.add(todoList[i]);
        newTodoListStatus.add(todoListStatus[i]);
      }
    }

    setState(() {
      todoList = newTodoList;
      todoListStatus = newTodoListStatus;
    });

    final docRef =
        FirebaseFirestore.instance.collection("ToDos").doc(widget.doc.id);
    docRef.update({"done": todoListStatus}).then((_) {
      print("To-Do status updated in Firestore.");
    }).catchError((error) {
      print("Failed to update to-do status in Firestore: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.todoAppColor,
      appBar: AppBar(
        backgroundColor: AppStyle.todoAppColor,
        title: Text(
          titleController.text,
          style: AppStyle.mainTitle,
        ),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                updateToDoInFirestore();
              } else {
                toggleEditing();
              }
            },
          ),
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: deleteToDoFromFirestore,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            spacingMedium,
            if (isEditing)
              TodoTitleDescriptionCard(
                titleController: titleController,
                descriptionController: descriptionController,
              )
            else
              const SizedBox(),
            spacingMedium,
            if (!isEditing)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  descriptionController.text,
                  style: AppStyle.mainContent,
                ),
              ),
            spacingMedium,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: todoList.asMap().entries.map((entry) {
                final int index = entry.key;
                final String task = entry.value;

                return Card(
                  elevation: 4,
                  color: AppStyle.white,
                  child: CheckboxListTile(
                    title: Text(
                      task,
                      style: TextStyle(
                        decoration: todoListStatus[index]
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    value: todoListStatus[index],
                    onChanged: (value) {
                      toggleToDoStatus(index);
                    },
                  ),
                );
              }).toList(),
            ),
            spacingMedium,
            if (!isEditing)
              Text(
                widget.doc["creation_date"],
                style: AppStyle.dateTitle,
              ),
          ],
        ),
      ),
    );
  }
}

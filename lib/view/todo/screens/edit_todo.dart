import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/app_style.dart';

class EditToDoScreen extends StatefulWidget {
  final QueryDocumentSnapshot doc;

  const EditToDoScreen(this.doc, {super.key});

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
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("ToDos").doc(widget.doc.id);

    Map<String, dynamic> updatedData = {
      "title": titleController.text,
      "description": descriptionController.text,
      "done": todoListStatus,
      "todos": todoList,
    };

    docRef.update(updatedData).then((_) {
      print("To-Do updated successfully.");
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to update to-do: $error");
    });
  }

  void deleteToDoFromFirestore() {
    DocumentReference docRef =
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

    // Update the "done" field in Firestore to reflect the updated todoListStatus.
    DocumentReference docRef =
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
      backgroundColor: AppStyle.bgColor,
      appBar: AppBar(
        backgroundColor: AppStyle.bgColor,
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
              icon: Icon(Icons.delete),
              onPressed: deleteToDoFromFirestore,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            isEditing
                ? Card(
                    elevation: 4,
                    color: AppStyle.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: AppStyle.mainTitle,
                          labelText: "Title:",
                        ),
                        style: AppStyle.mainTitle,
                      ),
                    ),
                  )
                : Text(
                    titleController.text,
                    style: AppStyle.mainTitle.copyWith(color: AppStyle.white),
                  ),
            SizedBox(height: 16),
            isEditing
                ? Card(
                    elevation: 4,
                    color: AppStyle.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelStyle: AppStyle.mainTitle,
                          labelText: "Description:",
                        ),
                        style: AppStyle.mainContent,
                      ),
                    ),
                  )
                : Text(
                    descriptionController.text,
                    style: AppStyle.mainContent.copyWith(color: AppStyle.white),
                  ),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: todoList.asMap().entries.map((entry) {
                final int index = entry.key;
                final String task = entry.value;

                return CheckboxListTile(
                  title: Text(task),
                  value: todoListStatus[index],
                  onChanged: (value) {
                    toggleToDoStatus(index);
                  },
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            if (!isEditing)
              Text(
                widget.doc["creation_date"],
                style: AppStyle.mainTitle.copyWith(color: AppStyle.white),
              ),
          ],
        ),
      ),
    );
  }
}

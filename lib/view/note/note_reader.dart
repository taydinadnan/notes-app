import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteReaderScreen extends StatefulWidget {
  NoteReaderScreen(this.doc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot doc;

  @override
  _NoteReaderScreenState createState() => _NoteReaderScreenState();
}

class _NoteReaderScreenState extends State<NoteReaderScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.doc["note_title"];
    contentController.text = widget.doc["note_content"];
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  void toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void updateNoteInFirestore() {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("Notes").doc(widget.doc.id);

    Map<String, dynamic> updatedData = {
      "note_title": titleController.text,
      "note_content": contentController.text,
    };

    docRef.update(updatedData).then((_) {
      print("Document updated successfully.");
      toggleEditing();
    }).catchError((error) {
      print("Failed to update document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    int color_id = widget.doc['color_id'];
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color_id],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color_id],
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (isEditing) {
                // Save the changes to Firestore
                updateNoteInFirestore();
              }
              toggleEditing();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isEditing
                ? TextFormField(
                    controller: titleController,
                    style: AppStyle.mainTitle,
                  )
                : Text(
                    titleController.text,
                    style: AppStyle.mainTitle,
                  ),
            const SizedBox(
              height: 4.0,
            ),
            Text(
              widget.doc["creation_date"],
              style: AppStyle.dateTitle,
            ),
            const SizedBox(
              height: 28.0,
            ),
            isEditing
                ? TextFormField(
                    controller: contentController,
                    style: AppStyle.mainContent,
                    maxLines: null,
                  )
                : Text(
                    contentController.text,
                    style: AppStyle.mainContent,
                  ),
          ],
        ),
      ),
    );
  }
}

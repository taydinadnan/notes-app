import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/view/note/widgets/color_picker.dart';

class EditNoteScreen extends StatefulWidget {
  const EditNoteScreen(this.doc, {Key? key}) : super(key: key);
  final QueryDocumentSnapshot doc;

  @override
  State createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  late int colorId;
  bool isEditing = true;

  @override
  void initState() {
    super.initState();
    titleController.text = widget.doc["note_title"];
    contentController.text = widget.doc["note_content"];
    colorId = widget.doc['color_id'];
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
      "color_id": colorId, // Update color_id in Firestore
    };

    docRef.update(updatedData).then((_) {
      print("Document updated successfully.");
    }).catchError((error) {
      print("Failed to update document: $error");
    });
  }

  void deleteNoteFromFirestore() {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("Notes").doc(widget.doc.id);

    docRef.delete().then((_) {
      print("Document deleted successfully.");
      Navigator.pop(context);
    }).catchError((error) {
      print("Failed to delete document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[colorId],
      appBar: AppBar(
        title: Text(
          isEditing
              ? titleController.text.toUpperCase()
              : widget.doc["creation_date"],
          style: AppStyle.dateTitle,
        ),
        backgroundColor: AppStyle.cardsColor[colorId],
        elevation: 0.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: () {
                setState(() {
                  isEditing = !isEditing;
                });
              },
              icon: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    isEditing ? "Read Mode" : "",
                    style: TextStyle(fontSize: 11, color: AppStyle.titleColor),
                  ),
                  SizedBox(width: isEditing ? 8 : 0),
                  Icon(isEditing
                      ? Icons.remove_red_eye_outlined
                      : Icons.remove_red_eye_rounded),
                ],
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isEditing)
              Center(
                child: ColorPicker(
                  colors: AppStyle.cardsColor,
                  selectedColorIndex: colorId,
                  onColorSelected: (int newColorId) {
                    setState(() {
                      colorId = newColorId; // Update colorId
                      print('New selected index $newColorId');
                      print('Current color id $colorId');
                    });
                  },
                ),
              ),
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
            if (isEditing)
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (isEditing)
            FloatingActionButton(
              backgroundColor: AppStyle.buttonColor,
              onPressed: () {
                // Delete function here
                deleteNoteFromFirestore();
              },
              child: const Icon(Icons.delete),
            ),
          const SizedBox(
            height: 15,
          ),
          if (isEditing)
            FloatingActionButton(
              backgroundColor: isEditing ? Colors.green : AppStyle.buttonColor,
              onPressed: () {
                if (isEditing) {
                  final updatedTitle = titleController.text;
                  final updatedContent = contentController.text;

                  if (updatedTitle.isNotEmpty && updatedContent.isNotEmpty) {
                    updateNoteInFirestore();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Both the title and note content must be filled in to save.'),
                      ),
                    );
                  }
                }
                toggleEditing();
              },
              child: Icon(isEditing ? Icons.save : Icons.edit),
            )
        ],
      ),
    );
  }
}

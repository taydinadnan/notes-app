import 'package:flutter/material.dart';
import 'package:notes_app/app_spacing.dart';
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
      "color_id": colorId,
    };

    docRef.update(updatedData).then((_) {
      // ignore: avoid_print
      print("Document updated successfully.");
    }).catchError((error) {
      // ignore: avoid_print
      print("Failed to update document: $error");
    });
  }

  void deleteNoteFromFirestore() {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection("Notes").doc(widget.doc.id);

    docRef.delete().then((_) {
      // ignore: avoid_print
      print("Document deleted successfully.");
      Navigator.pop(context);
    }).catchError((error) {
      // ignore: avoid_print
      print("Failed to delete document: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isEditing ? AppStyle.cardsColor[colorId] : Colors.black,
      appBar: AppBar(
        title: Text(
          isEditing
              ? titleController.text.toUpperCase()
              : widget.doc["creation_date"],
          style: AppStyle.dateTitle
              .copyWith(color: isEditing ? AppStyle.titleColor : AppStyle.grey),
        ),
        backgroundColor:
            isEditing ? AppStyle.cardsColor[colorId] : Colors.black,
        elevation: 0.0,
        iconTheme: IconThemeData(
            color: isEditing ? AppStyle.titleColor : AppStyle.grey),
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
                  Icon(
                    isEditing
                        ? Icons.remove_red_eye_outlined
                        : Icons.remove_red_eye_rounded,
                    color: isEditing ? AppStyle.black : AppStyle.grey,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEditing)
                Center(
                  child: Card(
                    elevation: 4,
                    color: AppStyle.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ColorPicker(
                        colors: AppStyle.cardsColor,
                        selectedColorIndex: colorId,
                        onColorSelected: (int newColorId) {
                          setState(() {
                            colorId = newColorId;
                          });
                        },
                      ),
                    ),
                  ),
                ),
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
                              label: const Text("Title:")),
                          style: AppStyle.mainTitle,
                        ),
                      ),
                    )
                  : Text(
                      titleController.text,
                      style: AppStyle.mainTitle.copyWith(color: AppStyle.white),
                    ),
              spacingBig,
              isEditing
                  ? Card(
                      elevation: 4,
                      color: AppStyle.white,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 200,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: TextField(
                            controller: contentController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              label: const Text("Note Content:"),
                              labelStyle: AppStyle.mainTitle,
                            ),
                            style: AppStyle.mainContent,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      contentController.text,
                      style:
                          AppStyle.mainContent.copyWith(color: AppStyle.white),
                    ),
              spacingNormal,
              if (isEditing)
                Text(
                  widget.doc["creation_date"],
                  style: AppStyle.mainTitle.copyWith(color: AppStyle.white),
                ),
            ],
          ),
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

import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/view/note/widgets/color_picker.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({Key? key}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  int colorId = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateFormat("yy/MMM/dd - HH:mm").format(DateTime.now());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  final int newColorId = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[colorId],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[colorId],
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add a new Note',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              date,
              style: AppStyle.dateTitle,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ColorPicker(
                colors: AppStyle.cardsColor,
                selectedColorIndex:
                    colorId, // Pass the current colorId as the selectedColorIndex
                onColorSelected: (int newColorId) {
                  setState(() {
                    colorId =
                        newColorId; // Update the colorId when a new color is selected
                    print(newColorId);
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  labelStyle: AppStyle.mainTitle,
                  label: const Text("Title:")),
              style: AppStyle.mainTitle,
            ),
            const SizedBox(height: 28.0),
            TextField(
              controller: _mainController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                border: InputBorder.none,
                label: const Text("Note Content:"),
                labelStyle: AppStyle.mainTitle,
              ),
              style: AppStyle.mainContent,
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: FloatingActionButton(
              backgroundColor: AppStyle.accentColor,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.cancel),
            ),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            backgroundColor: AppStyle.accentColor,
            onPressed: () {
              final title = _titleController.text;
              final content = _mainController.text;

              if (title.isNotEmpty && content.isNotEmpty) {
                noteRepository.addNote(title, content, colorId);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please fill in both the title and note content.'),
                  ),
                );
              }
            },
            child: const Icon(Icons.save),
          )
        ],
      ),
    );
  }
}

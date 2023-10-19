import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_style.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({Key? key}) : super(key: key);

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  // ignore: non_constant_identifier_names
  int color_id = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateFormat("yy/MMM/dd - HH:mm").format(DateTime.now());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _mainController = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[color_id],
      appBar: AppBar(
        backgroundColor: AppStyle.cardsColor[color_id],
        elevation: 0.0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Add a new Note',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                  border: InputBorder.none, hintText: 'Note Title;'),
              style: AppStyle.mainTitle,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              date,
              style: AppStyle.dateTitle,
            ),
            const SizedBox(
              height: 28.0,
            ),
            TextField(
              controller: _mainController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Note Content',
              ),
              style: AppStyle.mainContent,
            )
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
                FirebaseFirestore.instance.collection("Notes").add({
                  "note_title": title,
                  "creation_date": date,
                  "note_content": content,
                  "color_id": color_id,
                  "creator_id": user.currentUser!.uid,
                }).then((value) {
                  Navigator.pop(context);
                }).catchError((error) {
                  // Handle the error
                  print("Failed to add new Note due to $error");
                });
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

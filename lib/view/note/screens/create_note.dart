import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/view/note/widgets/color_picker.dart';

class CreateNoteScreen extends StatefulWidget {
  const CreateNoteScreen({Key? key}) : super(key: key);

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  int colorId = Random().nextInt(AppStyle.cardsColor.length);
  String date = DateFormat("dd/MMM/yyyy - HH:mm").format(DateTime.now());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
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
              'Create Note',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              date,
              style: AppStyle.dateTitle,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              spacingNormal,
              Card(
                elevation: 4,
                color: AppStyle.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        labelStyle: AppStyle.mainTitle,
                        label: const Text("Title:")),
                    style: AppStyle.mainTitle,
                  ),
                ),
              ),
              const SizedBox(height: 28.0),
              Card(
                elevation: 4,
                color: AppStyle.white,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _contentController,
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
              ),
            ],
          ),
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
          spacingNormal,
          FloatingActionButton(
            backgroundColor: AppStyle.accentColor,
            onPressed: () {
              final title = _titleController.text;
              final content = _contentController.text;

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

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/view/note/widgets/color_picker_card.dart';

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
  final FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  String selectedCollectionId =
      ''; // Variable to store the selected collection ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[colorId],
      appBar: buildAppBar(),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      backgroundColor: AppStyle.cardsColor[colorId],
      elevation: 0.0,
      iconTheme: const IconThemeData(color: Colors.black),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Create Note', style: TextStyle(color: Colors.black)),
          Text(date, style: AppStyle.dateTitle),
        ],
      ),
    );
  }

  Future<void> showCollectionPopupMenu(BuildContext context) async {
    final collections = await fetchCollectionsFromFirestore();
    final selectedId = await showMenu<String>(
      context: context,
      position: RelativeRect.fill,
      items: collections.map((collection) {
        return PopupMenuItem<String>(
          value: collection.id,
          child: Text(collection.get('name')),
        );
      }).toList(),
    );

    if (selectedId != null) {
      setState(() {
        selectedCollectionId = selectedId;
      });
    }
  }

  // Function to fetch collections from Firestore
  Future<List<QueryDocumentSnapshot>> fetchCollectionsFromFirestore() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('Collections').get();
    return querySnapshot.docs;
  }

  Widget buildBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildColorPickerCard(),
            ElevatedButton(
              onPressed: () async {
                await showCollectionPopupMenu(context);
              },
              child: const Text('Select Collection'),
            ),
            spacingNormal,
            buildTitleCard(),
            const SizedBox(height: 28.0),
            buildContentCard(),
          ],
        ),
      ),
    );
  }

  ColorPickerCard buildColorPickerCard() {
    return ColorPickerCard(
      colors: AppStyle.cardsColor,
      selectedColorIndex: colorId,
      onColorSelected: (int newColorId) {
        setState(() {
          colorId = newColorId;
        });
      },
    );
  }

  Widget buildTitleCard() {
    return Card(
      elevation: 4,
      color: AppStyle.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: TextField(
          controller: _titleController,
          decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: AppStyle.mainTitle,
            label: const Text("Title:"),
          ),
          style: AppStyle.mainTitle,
        ),
      ),
    );
  }

  Widget buildContentCard() {
    return Card(
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
    );
  }

  Widget buildFloatingActionButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        buildFloatingActionButtonIcon(Icons.cancel, () {
          Navigator.pop(context);
        }),
        spacingNormal,
        buildFloatingActionButtonIcon(Icons.save, () {
          final title = _titleController.text;
          final content = _contentController.text;

          if (title.isNotEmpty &&
              content.isNotEmpty &&
              selectedCollectionId.isNotEmpty) {
            noteRepository.addNote(
              title,
              content,
              colorId,
              selectedCollectionId,
            );

            // Now, add the note to the selected collection
            addNoteToCollection(selectedCollectionId);

            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Please fill in both the title and note content and select a collection.'),
              ),
            );
          }
        }),
      ],
    );
  }

  void addNoteToCollection(String collectionId) {
    // Generate a unique note_id
    String noteId = FirebaseFirestore.instance.collection('Notes').doc().id;

    // Create the note and add it to the collection
    noteRepository.addNoteToCollection(collectionId, noteId);
  }

  Widget buildFloatingActionButtonIcon(IconData icon, Function() onPressed) {
    return SizedBox(
      height: 50,
      width: 50,
      child: FloatingActionButton(
        backgroundColor: AppStyle.accentColor,
        onPressed: onPressed,
        child: Icon(icon),
      ),
    );
  }
}

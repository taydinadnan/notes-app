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
  List<String> selectedCollectionIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyle.cardsColor[colorId],
      appBar: buildAppBar(),
      body: buildBody(),
      floatingActionButton: buildFloatingActionButton(),
    );
  }

  Future<List<QueryDocumentSnapshot>> fetchCollectionsForCurrentUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Collections')
          .where('creator_ids', isEqualTo: currentUser.uid)
          .get();
      return querySnapshot.docs;
    }
    return [];
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
            spacingMedium,
            buildCollectionChips(),
            spacingNormal,
            buildTitleCard(),
            const SizedBox(height: 28.0),
            buildContentCard(),
          ],
        ),
      ),
    );
  }

  Widget buildCollectionChips() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Collections')
          .where('creator_ids', arrayContains: user.currentUser!.email!)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          final collections = snapshot.data!.docs;
          List<Widget> chips = [];
          String newCollectionName = '';

          Widget newCollectionFilterChip =
              createNewCollectionChip(context, newCollectionName, collections);

          chips.addAll(
            collections.map((collection) {
              final collectionId = collection.id;
              final isSelected = selectedCollectionIds.contains(collectionId);

              return collectionNameChips(
                  context, collectionId, collection, isSelected);
            }).toList(),
          );
          chips.add(newCollectionFilterChip);
          return Wrap(
            spacing: 8.0,
            runSpacing: 8,
            children: chips,
          );
        } else {
          return const Text('No collections found.');
        }
      },
    );
  }

  FilterChip createNewCollectionChip(
      BuildContext context,
      String newCollectionName,
      List<QueryDocumentSnapshot<Object?>> collections) {
    return FilterChip(
      visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
      elevation: 4,
      backgroundColor: AppStyle.buttonColor.withOpacity(0.5),
      shape: const StadiumBorder(side: BorderSide()),
      label: Text(
        "Create new Collection",
        style: AppStyle.mainTitle.copyWith(fontSize: 15),
      ),
      onSelected: (selected) {
        showCreateNewCollectionDialog(
          context,
          newCollectionName,
          collections,
          user.currentUser!.email!,
        );
      },
    );
  }

  Wrap collectionNameChips(BuildContext context, String collectionId,
      QueryDocumentSnapshot<Object?> collection, bool isSelected) {
    return Wrap(
      children: [
        InkWell(
          onLongPress: () {
            _showDeleteConfirmationDialog(context, collectionId);
          },
          child: FilterChip(
            deleteIcon: const Icon(Icons.remove),
            visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
            elevation: 4,
            backgroundColor: Colors.transparent,
            shape: const StadiumBorder(side: BorderSide()),
            label: Text(
              collection['name'],
              style: AppStyle.mainTitle.copyWith(fontSize: 15),
            ),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                selectedCollectionIds.clear();
                if (selected) {
                  selectedCollectionIds.add(collectionId);
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Future<dynamic> showCreateNewCollectionDialog(
    BuildContext context,
    String newCollectionName,
    List<QueryDocumentSnapshot<Object?>> collections,
    String currentUserId, // Pass the current user ID
  ) {
    return showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter Collection Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        newCollectionName = value;
                      });
                    },
                    decoration: InputDecoration(
                      errorText: newCollectionName.isEmpty
                          ? 'Collection name cannot be empty'
                          : null,
                    ),
                  ),
                  if (isDuplicateCollectionName(collections, newCollectionName))
                    const Text(
                      'Collection name already exists',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Create'),
                  onPressed: () {
                    if (newCollectionName.isNotEmpty &&
                        !isDuplicateCollectionName(
                            collections, newCollectionName)) {
                      List<String> creatorIds = [
                        currentUserId
                      ]; // Add the current user's ID
                      noteRepository.createCollection(
                        newCollectionName,
                        creatorIds,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Press and hold the tag to delete it"),
                        ),
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(
      BuildContext context, String collectionId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this collection?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                noteRepository.removeCollection(collectionId);
              },
            ),
          ],
        );
      },
    );
  }

  bool isDuplicateCollectionName(
    List<QueryDocumentSnapshot> collections,
    String newCollectionName,
  ) {
    return collections.any((collection) =>
        collection['name'].toString().toLowerCase() ==
        newCollectionName.trim().toLowerCase());
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
              selectedCollectionIds.isNotEmpty) {
            for (final collectionId in selectedCollectionIds) {
              noteRepository.addNote(
                title,
                content,
                colorId,
                collectionId,
              );

              // Call addNoteToCollection for each selected collection
              addNoteToCollection(collectionId);
            }
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Please fill in both the title, note content, and select a collection.',
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  void addNoteToCollection(String collectionId) {
    String noteId = FirebaseFirestore.instance.collection('Notes').doc().id;

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

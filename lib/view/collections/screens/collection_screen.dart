import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/repository/collections_repository.dart';
import 'package:notes_app/view/collections/widgets/add_user_dialog.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/view/note/screens/note_card.dart';

class NotesListScreen extends StatefulWidget {
  final String collectionId;
  final String collectionName;

  const NotesListScreen({
    Key? key,
    required this.collectionId,
    required this.collectionName,
  }) : super(key: key);

  @override
  State createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final CollectionsRepository collectionsRepository = CollectionsRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: buildNotesList(context),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFff9f6b),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.collectionName),
          IconButton(
            onPressed: () => showAddUserDialog(context),
            icon: const Icon(Icons.add_moderator),
          )
        ],
      ),
    );
  }

  Widget buildNotesList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: collectionsRepository
          .getNotesForCollectionStream(widget.collectionId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No Notes"));
        }

        final notes = snapshot.data!.docs;

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
                note: note,
                onTap: () => navigateToEditNoteScreen(context, note));
          },
        );
      },
    );
  }

  void showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddUserDialog(
          collectionId: widget.collectionId,
          onAddUser: (userId) {
            // Handle adding the user ID to the collection here
          },
        );
      },
    );
  }

  void navigateToEditNoteScreen(
      BuildContext context, QueryDocumentSnapshot note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNoteScreen(note),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/view/home/widgets/background_painter.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/app_style.dart';

class NotesListScreen extends StatefulWidget {
  final String collectionId;
  final String collectionName;

  const NotesListScreen({
    super.key,
    required this.collectionId,
    required this.collectionName,
  });

  @override
  State createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFff9f6b),
        title: Text(widget.collectionName),
      ),
      body: CustomPaint(
        painter: BackgroundPainter(),
        child: StreamBuilder<QuerySnapshot>(
          stream: getNotesForCollectionStream(widget.collectionId),
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
                final title = note.get("note_title") as String;
                final content = note.get("note_content") as String;
                final date = note.get("creation_date") as String;
                final colorId = note.get("color_id");
                int colorIndex = colorId % AppStyle.cardsColor.length;

                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Card(
                    color: AppStyle.cardsColor[colorIndex],
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to EditNoteScreen when the note is tapped
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditNoteScreen(
                              note,
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        title: Text(title),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(content),
                            Text(date),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<QuerySnapshot> getNotesForCollectionStream(String collectionId) {
    return FirebaseFirestore.instance
        .collection('Notes')
        .where("collection_id", isEqualTo: collectionId)
        .where("creator_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }
}

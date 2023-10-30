import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/repository/user_data_repository.dart';
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
  UserDataRepository userDataRepository = UserDataRepository();

  TextEditingController _userIdController = TextEditingController();

  void showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add User ID"),
          content: TextField(
            controller: _userIdController,
            decoration: const InputDecoration(hintText: "Enter User ID"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () async {
                String userId = _userIdController.text;
                try {
                  // Assuming you have a reference to the Firestore document where you want to add the user ID
                  DocumentReference documentReference = FirebaseFirestore
                      .instance
                      .collection('Collections')
                      .doc(widget.collectionId);

                  // Use FieldValue.arrayUnion to add the user ID to the creator_ids list
                  await documentReference.update({
                    "creator_ids": FieldValue.arrayUnion([userId]),
                  });
                } catch (e) {
                  print("Error adding user ID: $e");
                }
                // ignore: use_build_context_synchronously
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFff9f6b),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.collectionName),
            IconButton(
              onPressed: () {
                showAddUserDialog(context);
              },
              icon: const Icon(Icons.add_moderator),
            )
          ],
        ),
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
                            Text(date), // Convert to readable date format
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
        .snapshots();
  }
}

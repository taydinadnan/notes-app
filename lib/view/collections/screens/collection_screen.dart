import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/my_flutter_app_icons.dart';
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
                bool emailExists = await checkEmailExists(userId);

                if (emailExists) {
                  try {
                    DocumentReference documentReference = FirebaseFirestore
                        .instance
                        .collection('Collections')
                        .doc(widget.collectionId);

                    await documentReference.update({
                      "creator_ids": FieldValue.arrayUnion([userId]),
                    });

                    showUserAddedNotification(userId); // Show the notification
                  } catch (e) {
                    print("Error adding user ID: $e");
                  }
                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                } else {
                  // Show an error message when the email doesn't exist
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      content: Text("Email does not exist."),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where("email", isEqualTo: email)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking email existence: $e");
      return false;
    }
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
            FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection('Collections')
                  .doc(widget.collectionId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  DocumentSnapshot<Map<String, dynamic>> collectionDocument =
                      snapshot.data!;
                  Map<String, dynamic>? data = collectionDocument.data();

                  if (data != null && data.containsKey("creator_ids")) {
                    List<String> creatorIds =
                        List<String>.from(data["creator_ids"]);
                    List<String> initials = extractInitials(creatorIds);
                    List<Widget> avatars =
                        generateAvatarWidgets(initials, creatorIds);

                    return Row(
                      children: avatars,
                    );
                  }
                }

                return Container(); // You can show a loading indicator or handle other cases
              },
            ),
            IconButton(
              onPressed: () {
                showAddUserDialog(context);
              },
              icon: const Icon(Icons.add_moderator),
            ),
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

  List<String> extractInitials(List<String> creatorIds) {
    List<String> initials = [];
    for (String creatorId in creatorIds) {
      List<String> nameParts = creatorId.split(' ');
      if (nameParts.isNotEmpty) {
        initials.add(nameParts[0][0].toUpperCase());
      }
    }
    return initials;
  }

  List<Widget> generateAvatarWidgets(
      List<String> initials, List<String> creatorIds) {
    List<Widget> avatars = [];
    for (int i = 0; i < initials.length; i++) {
      avatars.add(
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 15,
                child: Text(initials[i]),
              ),
            ),
            Positioned(
              top: -5,
              right: -5,
              child: GestureDetector(
                onTap: () {
                  showRemoveConfirmationMenu(context, creatorIds[i]);
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    MyFlutterApp.x,
                    color: Colors.red,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return avatars;
  }

  void removeCreatorId(String idToRemove) async {
    try {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('Collections')
          .doc(widget.collectionId);

      await documentReference.update({
        "creator_ids": FieldValue.arrayRemove([idToRemove]),
      });
    } catch (e) {
      print("Error removing user ID: $e");
    }
  }

  Future<void> showRemoveConfirmationMenu(
      BuildContext context, String idToRemove) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Remove $idToRemove?"),
          content: Text("Are you sure you want to remove $idToRemove?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Remove"),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (result == true) {
      // The user confirmed the removal, so you can proceed to remove the creator ID.
      removeCreatorId(idToRemove);
    }
  }

  void showUserAddedNotification(String userName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$userName has been added to the collection."),
      ),
    );
  }
}

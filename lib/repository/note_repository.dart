import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NoteRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String date = DateFormat("yy/MMM/dd - HH:mm").format(DateTime.now());

  // Get the user's UID
  String get currentUserUid => _auth.currentUser?.uid ?? '';

  // Reference to the Firestore collection of notes
  CollectionReference notesCollection =
      FirebaseFirestore.instance.collection("Notes");

  Future<void> addNote(String title, String content, int color) async {
    try {
      await notesCollection.add({
        "note_title": title,
        "creation_date": date,
        "note_content": content,
        "color_id": color,
        "creator_id": _auth.currentUser!.uid,
      });
    } catch (e) {
      print("Error adding note: $e");
    }
  }

  Stream<QuerySnapshot> getNotes() {
    return notesCollection
        .where("creator_id", isEqualTo: currentUserUid)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NoteRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String date = DateFormat("yy/MMM/dd - HH:mm").format(DateTime.now());

  String get currentUserUid => _auth.currentUser?.uid ?? '';

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
      // ignore: avoid_print
      print("Error adding note: $e");
    }
  }

  Stream<QuerySnapshot> getNotes() {
    return notesCollection
        .where("creator_id", isEqualTo: currentUserUid)
        .snapshots();
  }

  Stream<QuerySnapshot> getNotesColorId() {
    return notesCollection
        .where("color_id", isEqualTo: currentUserUid)
        .snapshots();
  }

  Future<int> getColorIdCount(int colorId, String currentUserUid) async {
    try {
      QuerySnapshot querySnapshot = await notesCollection
          .where("color_id", isEqualTo: colorId)
          .where("creator_id", isEqualTo: currentUserUid)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }
}

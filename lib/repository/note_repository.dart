import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NoteRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String date = DateFormat("dd/MMM/yyyy - HH:mm").format(DateTime.now());

  String get currentUserUid => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';

  CollectionReference notesCollection =
      FirebaseFirestore.instance.collection("Notes");

  Future<void> addNote(
      String title, String content, int color, String collectionId) async {
    try {
      await notesCollection.add({
        "note_title": title,
        "creation_date": date,
        "note_content": content,
        "color_id": color,
        "creator_id": _auth.currentUser!.uid,
        "collection_id": collectionId,
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

  CollectionReference collectionsCollection =
      FirebaseFirestore.instance.collection("Collections");

  Future<void> createCollection(
      String collectionName, List<String> creatorIds) async {
    try {
      await collectionsCollection.add({
        "name": collectionName,
        "creator_ids": creatorIds, // Change "creator_id" to "creator_ids"
        "created_date": date,
        "notes": [] // Initialize notes as an empty list
      });
    } catch (e) {
      print("Error creating collection: $e");
    }
  }

  Future<void> addNoteToCollection(String collectionId, String noteId) async {
    try {
      final collectionRef = collectionsCollection.doc(collectionId);
      final collectionDoc = await collectionRef.get();
      final notes = collectionDoc['notes'] as List;
      notes.add(noteId);

      await collectionRef.update({
        "notes": notes,
      });
    } catch (e) {
      print("Error adding note to collection: $e");
    }
  }

  Future<void> removeCollection(String collectionId) async {
    try {
      final collectionRef = collectionsCollection.doc(collectionId);
      await collectionRef.delete();
    } catch (e) {
      print("Error removing collection: $e");
    }
  }

  Stream<QuerySnapshot> getCollections() {
    return collectionsCollection
        .where("creator_ids", arrayContains: currentUserEmail)
        .snapshots();
  }

  Future<QuerySnapshot> getNotesForCollection(String collectionId) {
    return notesCollection
        .where("collection_id", isEqualTo: collectionId)
        .where("creator_ids", arrayContains: currentUserEmail)
        .get();
  }
}

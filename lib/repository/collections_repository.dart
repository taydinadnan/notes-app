import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CollectionsRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String date = DateFormat("dd/MMM/yyyy - HH:mm").format(DateTime.now());

  String get currentUserUid => _auth.currentUser?.uid ?? '';
  String get currentUserEmail => _auth.currentUser?.email ?? '';

  CollectionReference notesCollection =
      FirebaseFirestore.instance.collection("Notes");

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

  Future<List<QueryDocumentSnapshot>> showCollections() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Collections')
        .where("creator_ids", arrayContains: currentUserEmail)
        .get();
    return querySnapshot.docs;
  }

  Future<QuerySnapshot> getNotesForCollection(String collectionId) {
    return notesCollection
        .where("collection_id", isEqualTo: collectionId)
        .where("creator_ids", arrayContains: currentUserEmail)
        .get();
  }

  Stream<QuerySnapshot> getNotesForCollectionStream(String collectionId) {
    return FirebaseFirestore.instance
        .collection('Notes')
        .where("collection_id", isEqualTo: collectionId)
        .snapshots();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class ToDoRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String date = DateFormat("dd/MMM/yyyy - HH:mm").format(DateTime.now());

  String get currentUserUid => _auth.currentUser?.uid ?? '';

  CollectionReference todosCollection =
      FirebaseFirestore.instance.collection("ToDos");

  Future<void> addToDo(
    String title,
    String description,
    List<String> todoList,
  ) async {
    try {
      await todosCollection.add({
        "title": title,
        "description": description,
        "creation_date": date,
        "todos": todoList,
        "done": List.filled(todoList.length, false),
        "creator_id": _auth.currentUser!.uid,
      });
    } catch (e) {
      // Handle the error as per your requirements
      print("Error adding to-do: $e");
    }
  }

  Future<void> removeToDo(String todoId) async {
    try {
      await todosCollection.doc(todoId).delete();
    } catch (e) {
      print("Error removing to-do: $e");
    }
  }

  Stream<QuerySnapshot> getToDos() {
    return todosCollection
        .where("creator_id", isEqualTo: currentUserUid)
        .snapshots();
  }
}

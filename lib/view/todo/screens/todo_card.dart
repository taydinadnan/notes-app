import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_style.dart';

class ToDoCard extends StatelessWidget {
  const ToDoCard({
    Key? key,
    required this.doc,
    required this.onTap,
  }) : super(key: key);

  final QueryDocumentSnapshot doc;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    List<dynamic> doneList = doc["done"];

    int completed = doneList.where((item) => item == true).length;
    int remaining = doneList.where((item) => item == false).length;

    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc["title"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    doc["description"],
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        '$completed Done',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        "X",
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$remaining Left',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              buildCreationDate(),
            ],
          ),
        ),
      ),
    );
  }

  Positioned buildCreationDate() {
    return Positioned(
      bottom: 1,
      right: 1,
      child: Text(
        formatFirestoreDate(doc["creation_date"]),
        overflow: TextOverflow.ellipsis,
        style: AppStyle.dateTitle
            .copyWith(color: AppStyle.titleColor.withOpacity(0.5)),
      ),
    );
  }

  String formatFirestoreDate(String firestoreDate) {
    final firestoreDateFormat = DateFormat("dd/MMM/yyyy - HH:mm");
    final desiredFormat = DateFormat("dd MMM");

    try {
      final date = firestoreDateFormat.parse(firestoreDate);
      return desiredFormat.format(date);
    } catch (e) {
      return "Invalid Date";
    }
  }
}

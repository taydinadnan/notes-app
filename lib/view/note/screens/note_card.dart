import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';

class NoteCard extends StatelessWidget {
  final QueryDocumentSnapshot note;
  final VoidCallback onTap;

  const NoteCard({
    Key? key,
    required this.note,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = note.get("note_title") as String;
    final content = note.get("note_content") as String;
    final date = note.get("creation_date") as String;
    final colorId = note.get("color_id");
    final colorIndex = colorId % AppStyle.cardsColor.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: AppStyle.cardsColor[colorIndex],
        child: GestureDetector(
          onTap: onTap,
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
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/app_spacing.dart';
import 'package:notes_app/app_style.dart';

class NoteCard extends StatelessWidget {
  final Function()? onTap;
  final QueryDocumentSnapshot doc;

  const NoteCard({
    Key? key,
    required this.onTap,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: AppStyle.cardsColor[doc['color_id']],
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              buildNoteInfo(),
              buildCreationDate(),
            ],
          ),
        ),
      ),
    );
  }

  Column buildNoteInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildNoteTitle(),
        spacingWidthMini,
        buildNoteContent(),
      ],
    );
  }

  Flexible buildNoteTitle() {
    return Flexible(
      child: Text(
        doc["note_title"],
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
        style: AppStyle.mainTitle,
      ),
    );
  }

  SingleChildScrollView buildNoteContent() {
    return SingleChildScrollView(
      child: Text(
        doc["note_content"],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppStyle.mainContent
            .copyWith(color: AppStyle.titleColor.withOpacity(1)),
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

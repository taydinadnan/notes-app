import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/app_style.dart';

class NoteCard extends StatelessWidget {
  final Function()? onTap;
  final QueryDocumentSnapshot doc;

  const NoteCard({
    super.key,
    required this.onTap,
    required this.doc,
  });

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      doc["note_title"],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: AppStyle.mainTitle,
                    ),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  SingleChildScrollView(
                    child: Text(
                      doc["note_content"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.mainContent
                          .copyWith(color: AppStyle.titleColor.withOpacity(1)),
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Text(
                  doc["creation_date"],
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.dateTitle
                      .copyWith(color: AppStyle.titleColor.withOpacity(0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

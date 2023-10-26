import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notes_app/app_style.dart';

class ColorPickerColumn extends StatefulWidget {
  final List<Color> colors;
  final ValueChanged<int> onColorSelected;

  const ColorPickerColumn({
    Key? key,
    required this.colors,
    required this.onColorSelected,
  }) : super(key: key);

  @override
  State createState() => _ColorPickerColumnState();
}

class _ColorPickerColumnState extends State<ColorPickerColumn> {
  @override
  Widget build(BuildContext context) {
    final NoteRepository noteRepository = NoteRepository();
    final FirebaseAuth auth = FirebaseAuth.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.colors.length, (index) {
            final color = widget.colors[index];

            return Row(
              children: [
                const SizedBox(width: 16),
                Padding(
                  padding: const EdgeInsets.all(1.0),
                  child: Container(
                    width: 19,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: Border.all(
                        color: AppStyle.titleColor,
                        width: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                FutureBuilder<int>(
                  future: noteRepository.getColorIdCount(
                      index, auth.currentUser!.uid),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox();
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    if (snapshot.hasData) {
                      return Text(
                        "${snapshot.data}",
                        style: TextStyle(
                          color: AppStyle.titleColor,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            );
          }),
        ),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: getUsersNoteLength(noteRepository),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox();
                  }
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        Text(
                          "${snapshot.data?.docs.length}",
                          style: AppStyle.mainTitle.copyWith(fontSize: 20),
                        ),
                        Text(
                          "Note",
                          style: AppStyle.mainTitle.copyWith(fontSize: 20),
                        ),
                      ],
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  Stream<QuerySnapshot<Object?>> getUsersNoteLength(
      NoteRepository noteRepository) {
    return noteRepository.getNotes();
  }
}

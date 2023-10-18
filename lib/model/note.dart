import 'package:flutter/material.dart';

class NoteModel {
  String title;
  String note;
  Color color;
  String creatorId;

  NoteModel({
    required this.title,
    required this.note,
    required this.color,
    required this.creatorId,
  });
}

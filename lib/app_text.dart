import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/app_style.dart';

final yourRecentNotes = Text("Your recent Notes",
    style: GoogleFonts.roboto(
      color: AppStyle.titleColor,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ));

final yourRecentTodos = Text("To Do List",
    style: GoogleFonts.roboto(
      color: AppStyle.titleColor,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ));

final homeScreenNoteTitle = Text("Your Recent Notes",
    style: GoogleFonts.roboto(
      color: AppStyle.titleColor,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ));

final homeScreenTodoTitle = Text("Your Recent Todos",
    style: GoogleFonts.roboto(
      color: AppStyle.titleColor,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ));

final homeScreenSavedTitle = Text("Your Favorites",
    style: GoogleFonts.roboto(
      color: AppStyle.titleColor,
      fontWeight: FontWeight.bold,
      fontSize: 22,
    ));

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyle {
  static Color bgColor = const Color(0xFFf2f2f2);
  static Color mainColor = const Color(0xFFf5f5f5);
  static Color accentColor = const Color(0xFFf5f5f5);

  static Color titleColor = const Color(0xFF192a33);
  static Color textColor = const Color(0xFF4a6078);

  static Color buttonColor = const Color(0xFFff6e61);
  static Color noteAppColor = const Color(0xFFffad0f);

  ///setting the cards different color
  static List<Color> cardsColor = [
    const Color(0xFFFFB3BA),
    const Color(0xFFFFDEB8),
    const Color(0xFFffffb8),
    const Color(0xFFb8e0ff),
    const Color(0xFFb8ffc7),
    const Color(0xFFffca75),
    const Color(0xFFff9f6b),
  ];

  ///setting the text style
  static TextStyle mainTitle = GoogleFonts.roboto(
      fontSize: 18.0, fontWeight: FontWeight.bold, color: titleColor);
  static TextStyle mainContent = GoogleFonts.nunito(
      fontSize: 16.0, fontWeight: FontWeight.normal, color: textColor);
  static TextStyle dateTitle = GoogleFonts.roboto(
      fontSize: 13.0, fontWeight: FontWeight.w500, color: titleColor);
}

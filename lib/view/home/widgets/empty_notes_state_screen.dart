import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/view/home/screens/home_screen.dart';
import 'package:notes_app/view/home/widgets/curve_line_painter.dart';

class EmptyNotesStateScreen extends StatelessWidget {
  const EmptyNotesStateScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "You don't have any notes yet.\n Tap the '+' button to create your first note.",
          style: GoogleFonts.nunito(color: AppStyle.titleColor),
          textAlign: TextAlign.center,
        ),
        Container(
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width / 2 + 100),
          height: 200,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height),
            painter: CurveLinePainter(
              startY: 20.0,
              endX:
                  0.0, // Adjust this value to position the ending point of the curve
            ),
          ),
        )
      ],
    );
  }
}

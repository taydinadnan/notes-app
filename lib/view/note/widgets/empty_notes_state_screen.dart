import 'package:flutter/material.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/view/note/widgets/curve_line_painter.dart';

class EmptyNotesStateScreen extends StatelessWidget {
  const EmptyNotesStateScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: AppStyle.white,
            radius: 112,
            child: ClipOval(
              child: Image.asset(
                "assets/emptyState.png",
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                left: MediaQuery.of(context).size.width / 2 + 50),
            height: 190,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width,
                  MediaQuery.of(context).size.height),
              painter: CurveLinePainter(
                startY: 0.0,
                endX:
                    0.0, // Adjust this value to position the ending point of the curve
              ),
            ),
          )
        ],
      ),
    );
  }
}

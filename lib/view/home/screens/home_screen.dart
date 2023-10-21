import 'dart:math';

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/repository/note_repository.dart';
import 'package:notes_app/repository/streams/streams.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:notes_app/view/home/widgets/drawer.dart';
import 'package:notes_app/view/note/screens/edit_note.dart';
import 'package:notes_app/view/note/screens/note_card.dart';
import 'package:notes_app/view/note/screens/create_note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  FirebaseAuth user = FirebaseAuth.instance;
  final NoteRepository noteRepository = NoteRepository();
  int colorId = Random().nextInt(AppStyle.cardsColor.length);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const MyDrawer(),
      backgroundColor: AppStyle.bgColor,
      appBar: buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Your recent Notes",
              style: GoogleFonts.roboto(
                color: AppStyle.titleColor,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: noteRepository.getNotes(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                        return GridView(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          children: snapshot.data!.docs
                              .map((note) => OpenContainer(
                                    closedElevation: 0,
                                    transitionType:
                                        ContainerTransitionType.fade,
                                    tappable: false,
                                    closedColor: AppStyle.bgColor,
                                    closedShape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    closedBuilder: (context, action) {
                                      return noteCard(() {
                                        action();
                                      }, note);
                                    },
                                    openBuilder: (
                                      BuildContext _,
                                      CloseContainerActionCallback
                                          closeContainer,
                                    ) {
                                      return EditNoteScreen(note);
                                    },
                                  ))
                              .toList(),
                        );
                      } else {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "You don't have any notes yet.\n Tap the '+' button to create your first note.",
                              style: GoogleFonts.nunito(
                                  color: AppStyle.titleColor),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width / 2 +
                                      100),
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
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: OpenContainer(
        openElevation: 4,
        transitionType: ContainerTransitionType.fade,
        closedElevation: 0,
        tappable: false,
        closedColor: AppStyle.cardsColor[colorId],
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        closedBuilder: (context, action) {
          return FloatingActionButton(
            backgroundColor: AppStyle.buttonColor,
            onPressed: action,
            child: const Icon(Icons.add),
          );
        },
        openBuilder: (
          BuildContext _,
          CloseContainerActionCallback closeContainer,
        ) {
          return const CreateNoteScreen();
        },
      ),
    );
  }

  AppBar buildAppBar() {
    FirebaseAuth user = FirebaseAuth.instance;
    final UserDataRepository userDataRepository = UserDataRepository();
    return AppBar(
      backgroundColor: AppStyle.bgColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () => _scaffoldKey.currentState!.openDrawer(),
              child: getUserProfilePicture(userDataRepository, user)),
        ],
      ),
    );
  }
}

class CurveLinePainter extends CustomPainter {
  final double startY;
  final double endX;

  CurveLinePainter({required this.startY, required this.endX});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppStyle.titleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();

    // Start point
    path.moveTo(endX, startY);

    // Control point for the curve (you can adjust this for the desired curve)
    final controlPoint = Offset(endX + 50.0, startY + 50.0);

    // End point (center of the floating action button)
    final endPoint = Offset(endX, startY + 250.0);

    // Draw a quadratic Bézier curve
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    canvas.drawPath(path, paint);

    // Draw an arrowhead at the endpoint
    final arrowPaint = Paint()
      ..color = AppStyle.titleColor
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(endPoint.dx - 12.0, endPoint.dy);
    arrowPath.lineTo(endPoint.dx + 12.0, endPoint.dy);
    arrowPath.lineTo(endPoint.dx, endPoint.dy + 20.0);

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

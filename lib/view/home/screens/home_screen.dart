import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/app_style.dart';
import 'package:notes_app/provider/auth_provider.dart';
import 'package:notes_app/widget_tree.dart';
import 'package:notes_app/view/note/note_card.dart';
import 'package:notes_app/view/note/note_editor.dart';
import 'package:notes_app/view/note/note_reader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth user = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Notes")
                    .where("creator_id", isEqualTo: user.currentUser!.uid)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasData) {
                    return GridView(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      children: snapshot.data!.docs
                          .map((note) => noteCard(() {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NoteReaderScreen(note),
                                    ));
                              }, note))
                          .toList(),
                    );
                  }
                  return Text(
                    "there's no Notes",
                    style: GoogleFonts.nunito(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppStyle.buttonColor,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NoteEditorScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar buildAppBar() {
    // final UserDataRepository repository = UserDataRepository();
    FirebaseAuth user = FirebaseAuth.instance;
    String userEmail = user.currentUser!.email ?? "Invalid";
    String initialEmailLetter = userEmail[0].toUpperCase();
    return AppBar(
      backgroundColor: AppStyle.bgColor,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            child: Text(initialEmailLetter),
          ),
          _signOutButton(),
        ],
      ),
    );
  }

  Future<void> signOut() async {
    await Auth().signOut();
    // ignore: use_build_context_synchronously
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const WidgetTree()));
  }

  Widget _signOutButton() {
    return ElevatedButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color?>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.pressed)) {
              return Theme.of(context).colorScheme.primary.withOpacity(0.5);
            }
            return AppStyle.mainColor;
          },
        ),
      ),
      onPressed: signOut,
      child: Icon(Icons.exit_to_app),
    );
  }
}

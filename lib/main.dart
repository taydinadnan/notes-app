import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseOptions? firebaseOptions;

  // Check if the app is running in a web environment
  if (kIsWeb) {
    firebaseOptions = const FirebaseOptions(
        apiKey: "AIzaSyACYISNpCsCVyJhNws9hM7ti4oRy6tHVDQ",
        authDomain: "notes-40775.firebaseapp.com",
        projectId: "notes-40775",
        storageBucket: "notes-40775.appspot.com",
        messagingSenderId: "511203562858",
        appId: "1:511203562858:web:69584c33b3042fd7558113",
        measurementId: "G-VVPMDX2LNE");
  }

  try {
    await Firebase.initializeApp(options: firebaseOptions);
  } catch (e) {
    print("Error initializing Firebase: $e");
    // Handle the error, e.g., show an error dialog or exit gracefully.
  }

  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WidgetTree(),
    );
  }
}

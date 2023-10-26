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
      apiKey: "YourWebApiKey",
      authDomain: "YourWebAuthDomain",
      projectId: "YourWebProjectId",
      storageBucket: "YourWebStorageBucket",
      messagingSenderId: "YourWebMessagingSenderId",
      appId: "YourWebAppId",
      measurementId: "YourWebMeasurementId",
    );
  }

  await Firebase.initializeApp(options: firebaseOptions);
  runApp(
    const ProviderScope(
      child: MyApp(),
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod/riverpod.dart';

class User {
  final String username;
  final String email;
  final String profilePicture;

  User(
      {required this.username,
      required this.email,
      required this.profilePicture});
}

final authProvider = Provider((ref) {
  return FirebaseAuth.instance;
});

final userProvider = FutureProvider<User?>((ref) async {
  final auth = ref.read(authProvider);
  final user = auth.currentUser;

  if (user != null) {
    // Fetch additional user data (e.g., username and profile picture) from a database or other source
    // Create a User instance with the fetched data
    return User(
      username: "sample_username",
      email: user.email ?? "",
      profilePicture: "url_to_profile_picture",
    );
  }
  return null;
});

Future<void> registerUser({
  required String email,
  required String password,
  required String username,
  required String profilePictureURL,
}) async {
  try {
    final auth = FirebaseAuth.instance;
    final UserCredential userCredential =
        await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Create a User instance with the provided data and store it in your database
    // For example, you can use Firebase Firestore to store user profiles
    final User user = User(
      username: username,
      email: email,
      profilePicture: profilePictureURL,
    );

    // Store user data in your database (e.g., Firestore)
    // Example: firestoreInstance.collection('users').doc(user.uid).set(user.toJson());
  } on FirebaseAuthException catch (e) {
    // Handle registration errors (e.g., email already in use)
    print("Failed to create user: ${e.message}");
  }
}

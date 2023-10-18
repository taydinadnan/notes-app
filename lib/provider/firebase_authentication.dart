import 'package:firebase_auth/firebase_auth.dart';
import 'package:notes_app/repository/user_data_repository.dart';
import 'package:riverpod/riverpod.dart';

final authProvider = Provider((ref) {
  return FirebaseAuth.instance;
});

final userDataRepository = Provider((ref) {
  return UserDataRepository();
});

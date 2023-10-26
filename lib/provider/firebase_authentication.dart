import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/repository/user_data_repository.dart';

final authProvider = Provider((ref) {
  return FirebaseAuth.instance;
});

final userDataRepository = Provider((ref) {
  return UserDataRepository();
});

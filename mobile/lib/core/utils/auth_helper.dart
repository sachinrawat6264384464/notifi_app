import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

User? getCurrentUserSafely() {
  try {
    if (Firebase.apps.isNotEmpty) {
      return FirebaseAuth.instance.currentUser;
    }
  } catch (e) {
    debugPrint("Safe auth getter note: $e");
  }
  return null;
}

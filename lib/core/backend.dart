import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


/// Central gate that decides which backend is active for this app run.
///
/// Firebase is the primary backend.
class Backend {
  static FirebaseAuth? get auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? get firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  static String get backends {
    return 'firebase=active';
  }
}
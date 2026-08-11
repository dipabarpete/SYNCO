import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Central gate that decides which backend is active for this app run.
///
/// Firebase is the primary backend. If Firebase was not initialized at
/// startup (for example no platform config present), the Supabase backend
/// remains available as a fallback so the app keeps working.
class Backend {
  static bool? _firebaseAvailable;

  static bool get useFirebase {
    return _firebaseAvailable ??= _checkFirebase();
  }

  static bool _checkFirebase() {
    try {
      Firebase.app();
      return true;
    } catch (e) {
      debugPrint('[Backend] Firebase unavailable, falling back to Supabase: $e');
      return false;
    }
  }

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
    return 'firebase=${useFirebase ? "active" : "inactive"}';
  }
}
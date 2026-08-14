import 'package:firebase_auth/firebase_auth.dart' as fb;
/// Backend-agnostic representation of the currently authenticated user.
///
/// Bridges the Firebase and Supabase user objects into one small shape so
/// the rest of the app never needs to know which backend is active.
class AppUser {
  final String id;
  final String? email;
  final String? phone;
  final String? displayName;
  final String? photoUrl;
  final Map<String, dynamic> userMetadata;

  const AppUser({
    required this.id,
    this.email,
    this.phone,
    this.displayName,
    this.photoUrl,
    this.userMetadata = const {},
  });

  factory AppUser.fromFirebase(fb.User user) {
    return AppUser(
      id: user.uid,
      email: user.email,
      phone: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
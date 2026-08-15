import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/backend.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications
  await NotificationService().init();
  await NotificationService().requestPermissions();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ---------------------------------------------------------------------------
  // Firebase (primary backend)
  // ---------------------------------------------------------------------------
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[DIAGNOSTIC] Firebase initialized in main.dart.');
  } catch (e) {
    debugPrint('[DIAGNOSTIC] Firebase initialization FAILED: $e');
  }

  debugPrint('[DIAGNOSTIC] Backend state: ${Backend.backends}');

  runApp(
    const ProviderScope(
      child: HerSyncApp(),
    ),
  );
}
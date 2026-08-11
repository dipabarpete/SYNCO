import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'core/backend.dart';
import 'firebase_options.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

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

  // ---------------------------------------------------------------------------
  // Supabase remains initialized as a fallback until the migration is
  // confirmed working end-to-end.
  // ---------------------------------------------------------------------------
  try {
    await Supabase.initialize(
      url: 'https://kvebcttlyogilsimnywf.supabase.co',
      publishableKey: 'sb_publishable_6GrenvrBLCjhjmmEQsBKwQ_wHbi5_s7',
    );
    debugPrint('[DIAGNOSTIC] Supabase initialized in main.dart.');
  } catch (e) {
    debugPrint('[DIAGNOSTIC] Supabase initialization FAILED: $e');
  }

  debugPrint('[DIAGNOSTIC] Backend state: ${Backend.backends}');

  runApp(
    const ProviderScope(
      child: HerSyncApp(),
    ),
  );
}
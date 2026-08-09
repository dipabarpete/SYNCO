import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

Future<void> main() async {
 
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

try {
  final google = await InternetAddress.lookup('google.com');
  print('GOOGLE DNS RESULT: $google');
} catch (e) {
  print('GOOGLE DNS ERROR: $e');
}

try {
  final supabase = await InternetAddress.lookup(
    'kvebcttlyogilsimnywf.supabase.co',
  );
  print('SUPABASE DNS RESULT: $supabase');
} catch (e) {
  print('SUPABASE DNS ERROR: $e');
}

  await Supabase.initialize(
    url: 'https://kvebcttlyogilsimnywf.supabase.co',
    anonKey: 'sb_publishable_6GrenvrBLCjhjmmEQsBKwQ_wHbi5_s7',
  );

  runApp(
    const ProviderScope(
      child: HerSyncApp(),
    ),
  );
}
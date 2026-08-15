import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class KyraApiService {
  static const String _baseUrl = 'https://synco-backend.vercel.app/api';

  Future<String> sendMessage(String message, Map<String, dynamic> contextData) async {
    final user = FirebaseAuth.instance.currentUser;
    String? idToken;
    
    if (user != null) {
      try {
        idToken = await user.getIdToken();
      } catch (e) {
        debugPrint('Error getting ID token: $e');
      }
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/kyra'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          // Send an anonymized hash of the user ID instead of the raw UID to protect PII
          'userId': user != null ? 'anon_${user.uid.hashCode}' : 'anonymous_user',
          'prompt': message,
          // Context data (like health score) is already aggregated and contains no names/PII
          'context': contextData,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? data['response'] ?? data['text'] ?? data['answer'] ?? data['message'] ?? 'I received your message, but the response was empty.';
      } else {
        debugPrint('Error from Kyra API: ${response.statusCode} - ${response.body}');
        return 'I am having trouble connecting to my servers right now. Please try again later! (Error: ${response.statusCode})';
      }
    } catch (e) {
      debugPrint('Exception calling Kyra API: $e');
      return 'I am having trouble connecting to the network. Please check your connection and try again!';
    }
  }
}

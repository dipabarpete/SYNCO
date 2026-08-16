import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AiAnalysisService {
  static const String _baseUrl = 'https://synco-backend.vercel.app/api';

  Future<String> analyzeFood(String imageBase64, String prompt) async {
    return _sendPostRequest('/kyra', {
      'imageBase64': imageBase64,
      'prompt': prompt,
    });
  }

  Future<String> analyzeLabReport(String fileBase64, String fileName, String prompt) async {
    return _sendPostRequest('/kyra', {
      'fileBase64': fileBase64,
      'fileName': fileName,
      'prompt': prompt,
      'isPdf': true,
    });
  }

  Future<String> analyzeLabReportImage(String imageBase64, String fileName, String prompt) async {
    return _sendPostRequest('/kyra', {
      'imageBase64': imageBase64,
      'fileBase64': imageBase64,
      'fileName': fileName,
      'prompt': prompt,
      'isPdf': false,
    });
  }

  Future<String> _sendPostRequest(String endpoint, Map<String, dynamic> body) async {
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
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
        body: jsonEncode({
          'userId': user?.uid ?? 'anonymous_user',
          ...body,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'] ?? data['response'] ?? data['text'] ?? data['answer'] ?? data['message'] ?? 'Successfully analyzed, but response was empty.';
      } else {
        debugPrint('Error from AI API: ${response.statusCode} - ${response.body}');
        return 'I am having trouble connecting to my servers right now. Please try again later! (Error: ${response.statusCode})';
      }
    } catch (e) {
      debugPrint('Exception calling AI API: $e');
      return 'I am having trouble connecting to the network. Please check your connection and try again!';
    }
  }
}

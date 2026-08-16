import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'https://synco-backend.vercel.app/api';

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }
    
    // Force refresh token if needed to ensure validity
    final token = await user.getIdToken(); 
    
    // Clean the body to absolutely ensure no user ID fields are sent as per strict rules
    final cleanBody = Map<String, dynamic>.from(body);
    cleanBody.remove('userId');
    cleanBody.remove('patientId');
    cleanBody.remove('authorId');

    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(cleanBody),
    );
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return {};
      }
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('Error decoding JSON from $endpoint: $e');
        return {};
      }
    } else {
      throw Exception("API Error: ${response.statusCode} - ${response.body}");
    }
  }
}

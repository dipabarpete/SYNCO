import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class AiAnalysisService {
  Future<String> analyzeFood(String imageBase64, String prompt) async {
    try {
      final bytes = base64Decode(imageBase64);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'User not authenticated.';
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'uploads/${user.uid}/food/$timestamp.jpg';
      final ref = FirebaseStorage.instance.ref().child(path);
      
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      
      final response = await ApiService.post('food-scanner', {
        'imageUrl': url,
        'prompt': prompt,
      });
      
      return response['reply'] ?? response['response'] ?? response['analysis'] ?? 'Successfully analyzed food.';
    } catch (e) {
      debugPrint('Exception in analyzeFood: $e');
      return 'I am having trouble connecting. Please try again! ($e)';
    }
  }

  Future<String> analyzeLabReport(String fileBase64, String fileName, String prompt) async {
    try {
      final bytes = base64Decode(fileBase64);
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return 'User not authenticated.';
      
      final path = 'uploads/${user.uid}/reports/$fileName';
      final ref = FirebaseStorage.instance.ref().child(path);
      
      final isPdf = fileName.toLowerCase().endsWith('.pdf');
      await ref.putData(bytes, SettableMetadata(contentType: isPdf ? 'application/pdf' : 'image/jpeg'));
      
      // As per the contract, we pass the STORAGE PATH, not the download URL for process-report.
      final response = await ApiService.post('process-report', {
        'filePath': path,
        'prompt': prompt,
      });
      
      return response['explanation'] ?? response['response'] ?? 'Successfully processed report.';
    } catch (e) {
      debugPrint('Exception in analyzeLabReport: $e');
      return 'I am having trouble processing the report. Please try again! ($e)';
    }
  }
}

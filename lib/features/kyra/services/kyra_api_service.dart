import 'package:flutter/foundation.dart';
import '../../../core/services/api_service.dart';

class KyraApiService {
  Future<String> sendMessage(
    String message, 
    Map<String, dynamic> contextData, {
    String? imageBase64,
    String? fileBase64,
    bool isPdf = false,
  }) async {
    try {
      final response = await ApiService.post('kyra', {
        'prompt': message,
        'context': contextData,
        'imageBase64': ?imageBase64,
        'fileBase64': ?fileBase64,
        if (isPdf) 'isPdf': true,
      });

      return response['reply'] ?? 
             response['response'] ?? 
             response['text'] ?? 
             response['answer'] ?? 
             response['message'] ?? 
             'I received your message, but the response was empty.';
             
    } catch (e) {
      debugPrint('Exception calling Kyra API: $e');
      return 'I am having trouble connecting to the network or the API returned an error. Please check your connection and try again! ($e)';
    }
  }
}

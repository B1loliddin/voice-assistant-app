import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:voice_assistant_app/services/secrets/app_secrets.dart';

class OpenAIService {
  static const String baseUrl = 'api.openai.com';
  static const String apiChat = '/v1/chat/completions';
  static const String apiImages = '/v1/images/generations';

  List<Map<String, String>> messages = [];

  Future<String> isArtPromptApi(String prompt) async {
    try {
      final url = Uri.https(OpenAIService.baseUrl, OpenAIService.apiChat);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppSecrets.openAIApiKey}',
      };

      final String content =
          'Does this message want to generate and AI picture, image, art or anything similar? $prompt. Simply answer with yes or no in lowercase';
      final body = <String, Object?>{
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'user',
            'content': content,
          },
        ]
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        switch (content) {
          case 'yes':
            final result = await dallEApi(prompt);
            return result;
          default:
            final result = await chatGPTApi(prompt);
            return result;
        }
      }

      return 'An internal error occurred';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  Future<String> chatGPTApi(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    try {
      final url = Uri.https(OpenAIService.baseUrl, OpenAIService.apiChat);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppSecrets.openAIApiKey}',
      };
      final body = <String, Object?>{
        'model': 'gpt-3.5-turbo',
        'messages': messages
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        String content =
            jsonDecode(response.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });

        return content;
      }

      return 'An internal error occurred';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  Future<String> dallEApi(String prompt) async {
    messages.add({
      'role': 'user',
      'content': prompt,
    });

    try {
      final url = Uri.https(OpenAIService.baseUrl, OpenAIService.apiImages);
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppSecrets.openAIApiKey}',
      };
      final body = <String, Object?>{
        'model': 'dall-e-3',
        'prompt': prompt,
        'n': 1,
        'size': '1024x1024'
      };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        String imageUrl = jsonDecode(response.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });

        return imageUrl;
      }

      return 'An internal error occurred';
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}

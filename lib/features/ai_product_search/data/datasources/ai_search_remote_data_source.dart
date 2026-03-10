import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';

abstract class AiSearchRemoteDataSource {
  Future<List<String>> getSearchSuggestions(String query);
}

class AiSearchRemoteDataSourceImpl implements AiSearchRemoteDataSource {
  final GenerativeModel generativeModel;

  AiSearchRemoteDataSourceImpl({required this.generativeModel});

  @override
  Future<List<String>> getSearchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final prompt =
          '''
      You are an AI assistant for a retail shopping app. 
      The user is typing: "$query".
      Predict 5 related product names or categories they might be searching for.
      Return EXACTLY a valid JSON array of strings, nothing else. No markdown formatting.
      Example: ["laptop", "gaming laptop", "laptop stand", "laptop sleeve", "macbook"]
      ''';

      final content = [Content.text(prompt)];
      final response = await generativeModel.generateContent(content);
      final responseText = response.text ?? '[]';

      // Clean markdown if the AI accidentally included it
      final cleanText = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final List<dynamic> jsonList = jsonDecode(cleanText);
      return jsonList.map((e) => e.toString()).toList();
    } catch (e) {
      // In a real app we might map this to a specific AI exception, but ServerException works for now
      throw Exception('Failed to generate suggestions: $e');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/word.dart';
import '../config/api_config.dart';

class WordService {
  Future<bool> createWord(Word word) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/Word/create'),
        headers: ApiConfig.headers,
        body: jsonEncode(word.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error creating word: $e');
      return false;
    }
  }

  Future<List<Word>> getWordsInFolder(String folderId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/Word/folder/$folderId'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> wordList = jsonDecode(response.body);
        return wordList.map((json) => Word.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error loading words: $e');
      return [];
    }
  }

  Future<bool> updateWord(Word word) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/Word/update'),
        headers: ApiConfig.headers,
        body: jsonEncode(word.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating word: $e');
      return false;
    }
  }

  Future<String?> generateParagraph(
    List<String> words, {
    required String promptType,
    required String targetAudience,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/Word/generateparagraph'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'promptType': promptType,
          'targetAudience': targetAudience,
          'vocabList': words,
          'maxAttempts': 3,
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      }
      return null;
    } catch (e) {
      print('Error generating paragraph: $e');
      return null;
    }
  }
}

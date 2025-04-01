import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/paragraph_result.dart';

class StorageService {
  static const String _key = 'saved_paragraphs';
  static const String _spacedRepKey = 'word_spaced_rep';

  static Future<void> saveParagraph(ParagraphResult paragraph) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await getSavedParagraphs();

    final key = paragraph.words.join(", ");
    if (!saved.containsKey(key)) {
      saved[key] = [];
    }
    saved[key]!.add(paragraph);

    final jsonString = jsonEncode(
      saved.map(
        (key, value) => MapEntry(key, value.map((p) => p.toJson()).toList()),
      ),
    );

    await prefs.setString(_key, jsonString);
  }

  static Future<Map<String, List<ParagraphResult>>> getSavedParagraphs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    return decoded.map(
      (key, value) => MapEntry(
        key,
        (value as List).map((item) => ParagraphResult.fromJson(item)).toList(),
      ),
    );
  }

  static Future<void> deleteParagraph(
    String words,
    ParagraphResult paragraph,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = await getSavedParagraphs();

    if (saved.containsKey(words)) {
      saved[words]!.removeWhere((p) => p.id == paragraph.id);
      if (saved[words]!.isEmpty) {
        saved.remove(words);
      }

      final jsonString = jsonEncode(
        saved.map(
          (key, value) => MapEntry(key, value.map((p) => p.toJson()).toList()),
        ),
      );

      await prefs.setString(_key, jsonString);
    }
  }

  static Future<void> saveWordSpacing(
    String wordId,
    DateTime nextReview,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final spacedData = prefs.getString(_spacedRepKey) ?? '{}';
    final Map<String, dynamic> data = json.decode(spacedData);

    data[wordId] = nextReview.toIso8601String();
    await prefs.setString(_spacedRepKey, json.encode(data));
  }

  static Future<DateTime?> getWordNextReview(String wordId) async {
    final prefs = await SharedPreferences.getInstance();
    final spacedData = prefs.getString(_spacedRepKey) ?? '{}';
    final Map<String, dynamic> data = json.decode(spacedData);

    final dateStr = data[wordId];
    return dateStr != null ? DateTime.parse(dateStr) : null;
  }
}

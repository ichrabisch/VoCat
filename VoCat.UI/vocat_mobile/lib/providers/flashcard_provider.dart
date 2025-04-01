import 'package:flutter/foundation.dart';
import 'package:vocat_mobile/models/paragraph_result.dart';
import '../services/folder_service.dart';
import '../services/word_service.dart';
import '../services/auth_service.dart';
import '../models/folder.dart';
import '../models/word.dart';
import '../models/flashcard.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

enum SortOption { alphabetical, dateCreated }

class FlashcardProvider extends ChangeNotifier {
  final _folderService = FolderService();
  final _wordService = WordService();
  final _authService = AuthService();

  final List<Flashcard> _flashcards = [];
  List<Folder> _folders = [];
  final Map<String, List<Word>> _folderWords = {};
  SortOption _currentSort = SortOption.dateCreated;
  final List<ParagraphResult> _pendingParagraphs = [];

  List<Flashcard> get flashcards => _flashcards;
  List<Folder> get folders => _folders;
  SortOption get currentSort => _currentSort;
  List<ParagraphResult> get pendingParagraphs => _pendingParagraphs;
  bool get hasPendingParagraphs => _pendingParagraphs.isNotEmpty;

  // Get items (folders and flashcards) in a specific folder
  List<dynamic> getItemsInFolder(String? folderId) {
    final List<dynamic> items = [];

    // Add subfolders
    final subFolders =
        _folders.where((folder) => folder.parentFolderId == folderId).toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    items.addAll(subFolders);

    // Add words if they're loaded
    if (folderId != null && _folderWords.containsKey(folderId)) {
      var folderWords = _folderWords[folderId]!;

      // Sort based on current option
      switch (_currentSort) {
        case SortOption.alphabetical:
          folderWords.sort(
            (a, b) =>
                a.wordText.toLowerCase().compareTo(b.wordText.toLowerCase()),
          );
        case SortOption.dateCreated:
          folderWords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      items.addAll(folderWords);
    }

    return items;
  }

  int getItemCountInFolder(String folderId) {
    return _flashcards.where((card) => card.folderId == folderId).length;
  }

  Future<void> createFolder(String name, {String? parentFolderId}) async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) return;

      final folder = Folder(
        folderId: const Uuid().v4(),
        name: name,
        parentFolderId: parentFolderId,
        userId: userId.trim(),
        createdAt: DateTime.now(),
      );

      final success = await _folderService.createFolder(folder);
      if (success) {
        await loadFolders();
      }
    } catch (e) {
      print('Error creating folder: $e');
    }
  }

  Future<void> loadData() async {
    _folderWords.clear();
    await loadFolders();
  }

  Future<void> loadFolders() async {
    try {
      final userId = await _authService.getUserId();
      if (userId == null) return;

      _folders = await _folderService.getFolders(userId);
      notifyListeners();
    } catch (e) {
      print('Error loading folders: $e');
    }
  }

  void addFlashcard(Flashcard card) {
    _flashcards.add(card);
    notifyListeners();
  }

  void updateFlashcard(Flashcard card) {
    final index = _flashcards.indexWhere((f) => f.id == card.id);
    if (index != -1) {
      _flashcards[index] = card;
      notifyListeners();
    }
  }

  void deleteFlashcard(String id) {
    _flashcards.removeWhere((card) => card.id == id);
    notifyListeners();
  }

  List<Flashcard> getDueCards() {
    final now = DateTime.now();
    return _flashcards.where((card) {
      final daysElapsed = now.difference(card.lastReviewed).inDays;
      // Spaced repetition intervals: 1, 3, 7, 14, 30 days
      final intervals = [1, 3, 7, 14, 30];
      return daysElapsed >=
          (card.repetitionLevel < intervals.length
              ? intervals[card.repetitionLevel]
              : intervals.last);
    }).toList();
  }

  void setSortOption(SortOption option) {
    if (_currentSort != option) {
      _currentSort = option;
      notifyListeners();
    }
  }

  List<Folder> getSubFolders(String? parentFolderId) {
    return _folders
        .where((folder) => folder.parentFolderId == parentFolderId)
        .toList();
  }

  Future<bool> createWord(Word word) async {
    try {
      final success = await _wordService.createWord(word);
      if (success) {
        await loadData();
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error creating word: $e');
      return false;
    }
  }

  Future<List<Word>> getWordsInFolder(String folderId) async {
    if (!_folderWords.containsKey(folderId)) {
      final words = await _wordService.getWordsInFolder(folderId);
      _folderWords[folderId] = words;
      notifyListeners();
    }
    return _folderWords[folderId] ?? [];
  }

  Future<bool> updateWord(Word word) async {
    try {
      final nextReview = calculateNextReview(word.masteryLevel);
      final updatedWord = word.copyWith(lastReviewed: nextReview);

      final success = await _wordService.updateWord(updatedWord);
      if (success) {
        await StorageService.saveWordSpacing(word.wordId, nextReview);
        await NotificationService.scheduleWordReview(updatedWord);
        _folderWords.remove(word.folderId);
        await getWordsInFolder(word.folderId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      print('Error updating word: $e');
      return false;
    }
  }

  Future<bool> generateParagraph(
    List<String> words, {
    required String promptType,
    required String targetAudience,
  }) async {
    final paragraph = ParagraphResult(
      id: const Uuid().v4(),
      words: words,
      promptType: promptType,
      targetAudience: targetAudience,
      createdAt: DateTime.now(),
    );

    addPendingParagraph(paragraph);

    final response = await _wordService.generateParagraph(
      words,
      promptType: promptType,
      targetAudience: targetAudience,
    );

    if (response != null) {
      await StorageService.saveParagraph(
        paragraph.copyWith(paragraph: response),
      );
      updateParagraph(paragraph.id, response);
      return true;
    } else {
      _pendingParagraphs.removeWhere((p) => p.id == paragraph.id);
      notifyListeners();
      return false;
    }
  }

  void addPendingParagraph(ParagraphResult paragraph) {
    _pendingParagraphs.add(paragraph);
    notifyListeners();
  }

  void updateParagraph(String id, String paragraph) {
    final index = _pendingParagraphs.indexWhere((p) => p.id == id);
    if (index != -1) {
      _pendingParagraphs[index] = _pendingParagraphs[index].copyWith(
        paragraph: paragraph,
        isPending: false,
      );
      notifyListeners();
    }
  }

  Future<Word?> getWordByText(String wordText) async {
    try {
      for (var words in _folderWords.values) {
        final word = words.firstWhere(
          (w) => w.wordText.toLowerCase() == wordText.toLowerCase(),
          orElse: () => throw '',
        );
        return word;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Add this method to calculate next review date based on mastery level
  DateTime calculateNextReview(int masteryLevel) {
    final now = DateTime.now();
    switch (masteryLevel) {
      case 1:
        return now.add(const Duration(days: 1));
      case 2:
        return now.add(const Duration(days: 3));
      case 3:
        return now.add(const Duration(days: 7));
      case 4:
        return now.add(const Duration(days: 14));
      case 5:
        return now.add(const Duration(days: 30));
      default:
        return now.add(const Duration(days: 1));
    }
  }

  Future<void> refreshData() async {
    await loadData();
    notifyListeners();
  }
}

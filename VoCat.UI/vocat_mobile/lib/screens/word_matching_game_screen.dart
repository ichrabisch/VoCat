import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vocat_mobile/config/api_config.dart';
import 'package:vocat_mobile/models/word.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';

const double _cardHeight = 80.0;

class WordMatchingGameScreen extends StatefulWidget {
  final List<Word> words;

  const WordMatchingGameScreen({super.key, required this.words});

  @override
  State<WordMatchingGameScreen> createState() => _WordMatchingGameScreenState();
}

class _WordMatchingGameScreenState extends State<WordMatchingGameScreen> {
  late List<Word> _gameWords;
  Word? _selectedWord;
  String? _selectedTranslation;
  List<Word> _matchedWords = [];
  int _score = 0;
  late List<String> _translations;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Take random 6 words for the game
    final random = Random();
    _gameWords = List.from(widget.words)..shuffle(random);
    if (_gameWords.length > 6) {
      _gameWords = _gameWords.sublist(0, 6);
    }

    // Shuffle translations separately
    _translations =
        _gameWords.map((w) => w.translation).toList()..shuffle(random);

    setState(() {
      _matchedWords = [];
      _score = 0;
      _selectedWord = null;
      _selectedTranslation = null;
    });
  }

  void _onWordSelected(Word word) {
    if (_matchedWords.contains(word)) return;

    setState(() {
      if (_selectedTranslation != null) {
        _selectedTranslation = null;
      }
      _selectedWord = word;

      // Check if we have a match
      if (_selectedTranslation != null && _selectedWord != null) {
        if (_selectedWord!.translation == _selectedTranslation) {
          _matchedWords.add(_selectedWord!);
          _score += 10;
          _selectedWord = null;
          _selectedTranslation = null;
        }
      }
    });
  }

  void _onTranslationSelected(String translation) {
    if (_matchedWords.any((w) => w.translation == translation)) return;

    setState(() {
      if (_selectedWord != null) {
        _selectedTranslation = translation;

        // Check if we have a match
        if (_selectedWord!.translation == translation) {
          _matchedWords.add(_selectedWord!);
          _score += 10;
          _selectedWord = null;
          _selectedTranslation = null;
        } else {
          // Wrong match
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() {
                _selectedWord = null;
                _selectedTranslation = null;
              });
            }
          });
        }
      } else {
        _selectedTranslation = translation;
      }
    });
  }

  void _updateWordMasteryLevels() async {
    for (var word in _gameWords) {
      final isMatched = _matchedWords.contains(word);
      final masteryChange =
          isMatched ? 1 : -1; // Increase for correct, decrease for wrong

      final updatedWord = word.copyWith(
        masteryLevel: math.max(
          math.min(word.masteryLevel + masteryChange, 5),
          0,
        ), // Keep between 0-5
        lastReviewed: DateTime.now(),
      );

      await Provider.of<FlashcardProvider>(
        context,
        listen: false,
      ).updateWord(updatedWord);
    }
  }

  void _showGameCompleteDialog() {
    _updateWordMasteryLevels();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Game Complete! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Score: $_score'),
                const SizedBox(height: 16),
                const Text(
                  'Word mastery levels have been updated based on your matches!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // ... rest of dialog
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool gameCompleted = _matchedWords.length == _gameWords.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WordAppBar(
        title: 'Matching Game',
        onBackPressed: () => Navigator.pop(context),
        actions: [
          TextButton.icon(
            onPressed: _initializeGame,
            icon: const Icon(Icons.refresh),
            label: const Text('Restart'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Score and progress
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $_score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Matched: ${_matchedWords.length}/${_gameWords.length}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),

          if (gameCompleted)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'Congratulations!\nScore: $_score',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _initializeGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Row(
                children: [
                  // Words column
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _gameWords.length,
                      itemBuilder: (context, index) {
                        final word = _gameWords[index];
                        final bool isMatched = _matchedWords.contains(word);
                        final bool isSelected = _selectedWord == word;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SizedBox(
                            height: _cardHeight,
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isMatched
                                          ? Colors.green
                                          : isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                  width: isMatched || isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(8),
                                  leading:
                                      word.imageUrl != null
                                          ? Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  ApiConfig.getImageUrl(
                                                    word.imageUrl!,
                                                  ),
                                                ),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                          : null,
                                  title: Text(
                                    word.wordText,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          isMatched || isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isMatched
                                              ? Colors.green
                                              : isSelected
                                              ? Colors.blue
                                              : Colors.black87,
                                    ),
                                  ),
                                  tileColor:
                                      isMatched
                                          ? Colors.green.shade50
                                          : isSelected
                                          ? Colors.blue.shade50
                                          : null,
                                  onTap:
                                      isMatched
                                          ? null
                                          : () => _onWordSelected(word),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Translations column
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _translations.length,
                      itemBuilder: (context, index) {
                        final translation = _translations[index];
                        final bool isMatched = _matchedWords.any(
                          (w) => w.translation == translation,
                        );
                        final bool isSelected =
                            _selectedTranslation == translation;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: SizedBox(
                            height: _cardHeight,
                            child: Card(
                              elevation: isSelected ? 4 : 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color:
                                      isMatched
                                          ? Colors.green
                                          : isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                  width: isMatched || isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  title: Text(
                                    translation,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                          isMatched || isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                      color:
                                          isMatched
                                              ? Colors.green
                                              : isSelected
                                              ? Colors.blue
                                              : Colors.black87,
                                    ),
                                  ),
                                  tileColor:
                                      isMatched
                                          ? Colors.green.shade50
                                          : isSelected
                                          ? Colors.blue.shade50
                                          : null,
                                  onTap:
                                      isMatched
                                          ? null
                                          : () => _onTranslationSelected(
                                            translation,
                                          ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

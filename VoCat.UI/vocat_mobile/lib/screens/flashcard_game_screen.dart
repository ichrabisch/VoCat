import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:vocat_mobile/models/word.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';

class FlashcardGameScreen extends StatefulWidget {
  final List<Word> words;

  const FlashcardGameScreen({super.key, required this.words});

  @override
  State<FlashcardGameScreen> createState() => _FlashcardGameScreenState();
}

class _FlashcardGameScreenState extends State<FlashcardGameScreen> {
  late List<Word> _gameWords;
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final List<Word> _matchedWords = [];
  bool _showButtons = false;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    _gameWords = List.from(widget.words)..shuffle();
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _matchedWords.clear();
      _showButtons = false;
    });
  }

  void _handleAnswer(bool isCorrect) {
    if (isCorrect) {
      setState(() {
        _score += 10;
        _streak++;
        _bestStreak = math.max(_streak, _bestStreak);
        _matchedWords.add(_gameWords[_currentIndex]);
      });
    } else {
      setState(() {
        _streak = 0;
      });
    }

    // Move to next word
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentIndex < _gameWords.length - 1) {
        setState(() {
          _currentIndex++;
          _showButtons = false;
          cardKey = GlobalKey<FlipCardState>();
        });
      } else {
        _updateMasteryLevels();
        _showGameCompleteDialog();
      }
    });
  }

  void _updateMasteryLevels() async {
    for (var word in _gameWords) {
      final isMatched = _matchedWords.contains(word);
      final masteryChange = isMatched ? 1 : -1;

      final updatedWord = word.copyWith(
        masteryLevel: math.max(
          math.min(word.masteryLevel + masteryChange, 5),
          0,
        ),
        lastReviewed: DateTime.now(),
      );

      await Provider.of<FlashcardProvider>(
        context,
        listen: false,
      ).updateWord(updatedWord);
    }
  }

  void _showGameCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Game Complete! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Final Score: $_score'),
                Text('Best Streak: $_bestStreak'),
                const SizedBox(height: 16),
                const Text(
                  'Word mastery levels have been updated based on your performance!',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Finish'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  _initializeGame();
                },
                child: const Text('Play Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentWord = _gameWords[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: WordAppBar(
        title: 'Flashcard Game',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Score and progress section
          Padding(
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
                  'Card ${_currentIndex + 1}/${_gameWords.length}',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Streak indicator
          if (_streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'Streak: $_streak',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Flashcard
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FlipCard(
                  key: cardKey,
                  onFlip: () => setState(() => _showButtons = true),
                  front: _buildCardFace(
                    currentWord.wordText,
                    Colors.blue.shade100,
                  ),
                  back: _buildCardFace(
                    currentWord.translation,
                    Colors.green.shade100,
                  ),
                ),
              ),
            ),
          ),

          // Answer buttons
          if (_showButtons)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _handleAnswer(false),
                    icon: const Icon(Icons.close),
                    label: const Text('Incorrect'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade100,
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _handleAnswer(true),
                    icon: const Icon(Icons.check),
                    label: const Text('Correct'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Instructions
          if (!_showButtons)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tap the card to flip and reveal the translation',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardFace(String text, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vocat_mobile/models/word.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';

class SpeedVocabGameScreen extends StatefulWidget {
  final List<Word> words;

  const SpeedVocabGameScreen({super.key, required this.words});

  @override
  State<SpeedVocabGameScreen> createState() => _SpeedVocabGameScreenState();
}

class _SpeedVocabGameScreenState extends State<SpeedVocabGameScreen> {
  late List<Word> _gameWords;
  int _currentIndex = 0;
  int _score = 0;
  bool _isMemorizingPhase = true;
  bool _isShowingAnswer = false;
  final List<Word> _matchedWords = [];
  final _answerController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
      _isMemorizingPhase = true;
      _isShowingAnswer = false;
      _matchedWords.clear();
      _answerController.clear();
    });
    _startMemorizationTimer();
  }

  void _startMemorizationTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isMemorizingPhase) {
        setState(() {
          _isMemorizingPhase = false;
        });
      }
    });
  }

  void _checkAnswer() {
    if (_formKey.currentState!.validate()) {
      final isCorrect =
          _answerController.text.trim().toLowerCase() ==
          _gameWords[_currentIndex].translation.toLowerCase();

      setState(() {
        _isShowingAnswer = true;
        if (isCorrect) {
          _score += 10;
          _matchedWords.add(_gameWords[_currentIndex]);
        }
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          if (_currentIndex < _gameWords.length - 1) {
            setState(() {
              _currentIndex++;
              _isMemorizingPhase = true;
              _isShowingAnswer = false;
              _answerController.clear();
            });
            _startMemorizationTimer();
          } else {
            _updateMasteryLevels();
            _showGameCompleteDialog();
          }
        }
      });
    }
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
                Text(
                  'Final Score: $_score',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Correct Words: ${_matchedWords.length}/${_gameWords.length}',
                  style: const TextStyle(fontSize: 16),
                ),
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
        title: 'Speed Vocab',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: Column(
        children: [
          // Progress and score
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
                  'Word ${_currentIndex + 1}/${_gameWords.length}',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Main game area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isMemorizingPhase)
                    Column(
                      children: [
                        const Text(
                          'Memorize this word:',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                currentWord.wordText,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currentWord.translation,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const CircularProgressIndicator(),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Text(
                          currentWord.wordText,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _answerController,
                            decoration: InputDecoration(
                              labelText: 'Translation',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.send),
                                onPressed: _checkAnswer,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter the translation';
                              }
                              return null;
                            },
                            onFieldSubmitted: (_) => _checkAnswer(),
                          ),
                        ),
                        if (_isShowingAnswer) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color:
                                  _answerController.text.trim().toLowerCase() ==
                                          currentWord.translation.toLowerCase()
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _answerController.text.trim().toLowerCase() ==
                                          currentWord.translation.toLowerCase()
                                      ? 'Correct! 🎉'
                                      : 'Incorrect',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _answerController.text
                                                    .trim()
                                                    .toLowerCase() ==
                                                currentWord.translation
                                                    .toLowerCase()
                                            ? Colors.green
                                            : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Correct answer: ${currentWord.translation}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
}

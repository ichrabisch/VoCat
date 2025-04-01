import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vocat_mobile/models/word.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import 'dart:math';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';

class WordScrambleGameScreen extends StatefulWidget {
  final List<Word> words;

  const WordScrambleGameScreen({super.key, required this.words});

  @override
  State<WordScrambleGameScreen> createState() => _WordScrambleGameScreenState();
}

class _WordScrambleGameScreenState extends State<WordScrambleGameScreen>
    with SingleTickerProviderStateMixin {
  late Word _currentWord;
  late List<String> _scrambledLetters;
  List<String> _selectedLetters = [];
  int _score = 0;
  int _currentIndex = 0;
  bool _isCorrect = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showHint = false;
  int _hintsUsed = 0;
  int _wrongAttempts = 0;
  bool _isGameComplete = false;
  int _streak = 0;
  int _bestStreak = 0;
  Timer? _timer;
  int _timeLeft = 30; // 30 seconds per word
  final List<Word> _matchedWords = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _initializeGame();
    _startTimer();
  }

  void _initializeGame() {
    final shuffledWords = List<Word>.from(widget.words)..shuffle();
    _currentIndex = 0;
    _score = 0;
    _loadWord(shuffledWords[_currentIndex]);
  }

  void _loadWord(Word word) {
    _currentWord = word;
    _scrambledLetters = word.wordText.split('')..shuffle();
    _selectedLetters = [];
    _isCorrect = false;
    _showHint = false;
    _startTimer();
  }

  void _selectLetter(String letter, int index) {
    if (_isCorrect) return;

    setState(() {
      _selectedLetters.add(letter);
      _scrambledLetters[index] = '';

      final attempt = _selectedLetters.join();
      if (attempt.length == _currentWord.wordText.length) {
        if (attempt == _currentWord.wordText) {
          _isCorrect = true;
          _matchedWords.add(_currentWord);
          _streak++;
          _bestStreak = math.max(_streak, _bestStreak);
          _score += 10 + (_timeLeft * 0.5).round(); // Bonus points for speed
          _timer?.cancel();

          // Show success animation
          _controller.forward().then((_) => _controller.reverse());

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted && _currentIndex < widget.words.length - 1) {
                setState(() {
                  _currentIndex++;
                  _loadWord(widget.words[_currentIndex]);
                });
              } else {
                setState(() => _isGameComplete = true);
                _showGameCompleteDialog();
              }
            });
          });
        } else {
          _streak = 0;
          _wrongAttempts++;
          // Wrong attempt - reset letters
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                setState(() {
                  _scrambledLetters = _currentWord.wordText.split('')
                    ..shuffle();
                  _selectedLetters = [];
                });
              }
            });
          });
        }
      }
    });
  }

  void _resetCurrentWord() {
    setState(() {
      _scrambledLetters = _currentWord.wordText.split('')..shuffle();
      _selectedLetters = [];
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) {
          setState(() => _timeLeft--);
        }
      } else {
        _handleTimeUp();
      }
    });
  }

  void _handleTimeUp() {
    _timer?.cancel();
    if (!_isCorrect && mounted) {
      setState(() {
        _streak = 0;
        _wrongAttempts++;
      });
      _showTimeUpDialog();
    }
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Time\'s Up!'),
            content: Text('The correct word was: ${_currentWord.wordText}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    if (_currentIndex < widget.words.length - 1) {
                      _currentIndex++;
                      _loadWord(widget.words[_currentIndex]);
                      _startTimer();
                    } else {
                      _isGameComplete = true;
                    }
                  });
                },
                child: const Text('Next Word'),
              ),
            ],
          ),
    );
  }

  void _updateWordMasteryLevels() async {
    // Calculate performance metrics
    final accuracy =
        (_score / ((_wrongAttempts + _matchedWords.length) * 10)) * 100;
    final streakBonus = _bestStreak >= 3; // Bonus for maintaining streaks

    // Update mastery levels based on performance
    for (var word in _matchedWords) {
      int masteryIncrease = 0;

      // Basic mastery increase based on accuracy
      if (accuracy >= 90) {
        masteryIncrease = 2;
      } else if (accuracy >= 70) {
        masteryIncrease = 1;
      }

      // Bonus for streaks and quick answers
      if (streakBonus) masteryIncrease += 1;

      if (masteryIncrease > 0) {
        final updatedWord = word.copyWith(
          masteryLevel: math.min(
            word.masteryLevel + masteryIncrease,
            5,
          ), // Cap at level 5
          lastReviewed: DateTime.now(),
        );

        // Update word in provider
        await Provider.of<FlashcardProvider>(
          context,
          listen: false,
        ).updateWord(updatedWord);
      }
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
                Text('Final Score: $_score'),
                const SizedBox(height: 8),
                Text('Best Streak: $_bestStreak'),
                const SizedBox(height: 8),
                Text('Wrong Attempts: $_wrongAttempts'),
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
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text('Exit'),
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
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: WordAppBar(
          title: 'Word Scramble',
          onBackPressed: () => Navigator.pop(context),
          actions: [
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: _hintsUsed < 3 ? _showWordHint : null,
              tooltip: 'Use hint (${3 - _hintsUsed} left)',
            ),
            TextButton.icon(
              onPressed: _initializeGame,
              icon: const Icon(Icons.refresh),
              label: const Text('Restart'),
            ),
          ],
        ),
        body: Column(
          children: [
            // Add timer and streak indicators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildTimerIndicator(), _buildStreakIndicator()],
              ),
            ),
            // Stats bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Score', _score),
                  _buildStatItem(
                    'Word',
                    '${_currentIndex + 1}/${widget.words.length}',
                  ),
                  _buildStatItem('Hints', '${3 - _hintsUsed}'),
                ],
              ),
            ),

            // Translation with definition
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text(
                      _currentWord.translation,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (_currentWord.definition != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _currentWord.definition!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),

            // Selected letters with animation
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder:
                  (context, child) => Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      height: 80,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              _isCorrect ? Colors.green : Colors.grey.shade300,
                          width: _isCorrect ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isCorrect ? Colors.green : Colors.blue)
                                .withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _currentWord.wordText.length,
                            (index) => Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 20,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    index < _selectedLetters.length
                                        ? _isCorrect
                                            ? Colors.green.shade100
                                            : Colors.blue.shade100
                                        : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  index < _selectedLetters.length
                                      ? _selectedLetters[index]
                                      : '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        _isCorrect ? Colors.green : Colors.blue,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ),

            // Scrambled letters with haptic feedback
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      _scrambledLetters.length,
                      (index) =>
                          _scrambledLetters[index].isEmpty
                              ? const SizedBox(width: 50, height: 50)
                              : _buildLetterTile(index),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: _resetCurrentWord,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                  ),
                  if (_showHint)
                    Text(
                      'First letter: ${_currentWord.wordText[0]}',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLetterTile(int index) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _selectLetter(_scrambledLetters[index], index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            _scrambledLetters[index],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  void _showWordHint() {
    setState(() {
      _showHint = true;
      _hintsUsed++;
      _score -= 2; // Penalty for using hint
    });
  }

  Widget _buildTimerIndicator() {
    final color =
        _timeLeft > 10
            ? Colors.green
            : _timeLeft > 5
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        Icon(Icons.timer, color: color),
        const SizedBox(width: 4),
        Text(
          '$_timeLeft s',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakIndicator() {
    return Row(
      children: [
        const Icon(Icons.local_fire_department, color: Colors.orange),
        const SizedBox(width: 4),
        Text(
          'Streak: $_streak',
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}

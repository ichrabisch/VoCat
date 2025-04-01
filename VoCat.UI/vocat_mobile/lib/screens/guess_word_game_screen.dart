import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vocat_mobile/models/word.dart';
import 'package:vocat_mobile/widgets/word_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/providers/flashcard_provider.dart';
import 'package:vocat_mobile/config/api_config.dart';

class GuessWordGameScreen extends StatefulWidget {
  final List<Word> words;

  const GuessWordGameScreen({super.key, required this.words});

  @override
  State<GuessWordGameScreen> createState() => _GuessWordGameScreenState();
}

class _GuessWordGameScreenState extends State<GuessWordGameScreen> {
  late List<Word> _gameWords;
  late Word currentWord;
  int _currentIndex = 0;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  final List<Word> _matchedWords = [];
  bool _showFeedback = false;
  String? _selectedAnswer;
  late List<String> _currentChoices;
  bool _isAnimatingScore = false;
  double _scoreOpacity = 1.0;
  bool _isHintShown = false;
  int _hintsRemaining = 3;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    await Provider.of<FlashcardProvider>(context, listen: false).refreshData();
    _initializeGame();
  }

  Future<void> _onRefresh() async {
    await _refreshData();
  }

  void _initializeGame() {
    _gameWords = List.from(widget.words)..shuffle();
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _matchedWords.clear();
      _showFeedback = false;
      _selectedAnswer = null;
    });
    _generateChoices();
  }

  void _generateChoices() {
    currentWord = _gameWords[_currentIndex];
    final random = math.Random();

    // Get 3 random wrong answers from other words
    final otherWords = List<Word>.from(widget.words)
      ..removeWhere((w) => w.wordId == currentWord.wordId);
    otherWords.shuffle(random);

    _currentChoices = [
      currentWord.translation,
      ...otherWords.take(3).map((w) => w.translation),
    ]..shuffle(random);
  }

  void _animateScore() {
    setState(() => _isAnimatingScore = true);
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _scoreOpacity = 0.0);
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          _scoreOpacity = 1.0;
          _isAnimatingScore = false;
        });
      });
    });
  }

  void _handleAnswer(String answer) {
    if (_showFeedback || _isPaused) return;

    final isCorrect = answer == currentWord.translation;
    _animateScore();

    setState(() {
      _selectedAnswer = answer;
      _showFeedback = true;

      if (isCorrect) {
        _score += 10;
        _streak++;
        _bestStreak = math.max(_streak, _bestStreak);
        _matchedWords.add(currentWord);
      } else {
        _streak = 0;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentIndex < _gameWords.length - 1) {
          setState(() {
            _currentIndex++;
            _showFeedback = false;
            _selectedAnswer = null;
            _isHintShown = false;
          });
          _generateChoices();
        } else {
          _updateMasteryLevels();
          _showGameCompleteDialog();
        }
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

  void _showHint() {
    if (_hintsRemaining > 0) {
      setState(() {
        _hintsRemaining--;
        _isHintShown = true;
      });
    }
  }

  void _togglePause() {
    setState(() => _isPaused = !_isPaused);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isPaused) {
          setState(() => _isPaused = false);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: WordAppBar(
          title: 'Guess the Word',
          onBackPressed: () => Navigator.pop(context),
          actions: [
            IconButton(
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              onPressed: _togglePause,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: Stack(
            children: [
              Column(
                children: [
                  // Score and progress section with animation
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _scoreOpacity,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Score: $_score',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_isAnimatingScore)
                                const Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Icon(
                                    Icons.add_circle,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb,
                                color:
                                    _hintsRemaining > 0
                                        ? Colors.amber
                                        : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text('$_hintsRemaining'),
                              const SizedBox(width: 16),
                              Text(
                                'Word ${_currentIndex + 1}/${_gameWords.length}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Streak indicator
                  if (_streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                          ),
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

                  // Question section with hint button
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: Stack(
                      children: [
                        Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (currentWord.imageUrl != null)
                                Expanded(
                                  flex: 3,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(20),
                                            ),
                                        child: Image.network(
                                          ApiConfig.getImageUrl(
                                            currentWord.imageUrl!,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => const SizedBox(),
                                        ),
                                      ),
                                      if (_isHintShown)
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Definition: ${currentWord.definition ?? "No definition available"}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(
                                      currentWord.wordText,
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_hintsRemaining > 0 && !_isHintShown)
                          Positioned(
                            right: 24,
                            top: 24,
                            child: FloatingActionButton.small(
                              onPressed: _showHint,
                              backgroundColor: Colors.amber,
                              child: const Icon(Icons.lightbulb),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Answers section - remaining space
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: _currentChoices.length,
                        itemBuilder:
                            (context, index) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 300),
                                opacity:
                                    _showFeedback &&
                                            _selectedAnswer !=
                                                _currentChoices[index] &&
                                            _currentChoices[index] !=
                                                currentWord.translation
                                        ? 0.5
                                        : 1.0,
                                child: ElevatedButton(
                                  onPressed:
                                      _showFeedback
                                          ? null
                                          : () => _handleAnswer(
                                            _currentChoices[index],
                                          ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _getButtonColor(
                                      _currentChoices[index],
                                    ),
                                    foregroundColor: _getTextColor(
                                      _currentChoices[index],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    _currentChoices[index],
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),

              // Pause overlay
              if (_isPaused)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Card(
                      margin: const EdgeInsets.all(32),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Game Paused',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _togglePause,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Resume'),
                            ),
                            TextButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.exit_to_app),
                              label: const Text('Exit Game'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(String choice) {
    if (!_showFeedback) return Colors.white;
    if (choice == currentWord.translation) {
      return Colors.green.shade100;
    }
    if (choice == _selectedAnswer) {
      return Colors.red.shade100;
    }
    return Colors.white;
  }

  Color _getTextColor(String choice) {
    if (!_showFeedback) return Colors.black87;
    if (choice == currentWord.translation) {
      return Colors.green;
    }
    if (choice == _selectedAnswer) {
      return Colors.red;
    }
    return Colors.black87;
  }
}

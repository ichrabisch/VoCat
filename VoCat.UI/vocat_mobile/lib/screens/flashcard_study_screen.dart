import 'package:flutter/material.dart';
import '../models/flashcard.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';

class FlashcardStudyScreen extends StatefulWidget {
  final List<Flashcard> cards;

  const FlashcardStudyScreen({super.key, required this.cards});

  @override
  State<FlashcardStudyScreen> createState() => _FlashcardStudyScreenState();
}

class _FlashcardStudyScreenState extends State<FlashcardStudyScreen> {
  late List<Flashcard> _studyCards;
  int _currentIndex = 0;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _studyCards = List.from(widget.cards)..shuffle();
  }

  void _nextCard(bool wasCorrect) {
    final provider = Provider.of<FlashcardProvider>(context, listen: false);
    final currentCard = _studyCards[_currentIndex];

    // Update repetition level based on performance
    final updatedCard = currentCard.copyWith(
      repetitionLevel:
          wasCorrect
              ? currentCard.repetitionLevel + 1
              : (currentCard.repetitionLevel > 0
                  ? currentCard.repetitionLevel - 1
                  : 0),
      lastReviewed: DateTime.now(),
    );

    provider.updateFlashcard(updatedCard);

    setState(() {
      _showAnswer = false;
      if (_currentIndex < _studyCards.length - 1) {
        _currentIndex++;
      } else {
        // End of study session
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Study Session Complete!'),
            content: const Text('Great job! Would you like to study again?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to previous screen
                },
                child: const Text('Finish'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _studyCards.shuffle();
                    _currentIndex = 0;
                    _showAnswer = false;
                  });
                },
                child: const Text('Study Again'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study Flashcards')),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentIndex + 1) / _studyCards.length,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showAnswer = !_showAnswer),
              child: Card(
                margin: const EdgeInsets.all(16),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _showAnswer
                          ? _studyCards[_currentIndex].back
                          : _studyCards[_currentIndex].front,
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_showAnswer)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _nextCard(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Incorrect'),
                  ),
                  ElevatedButton(
                    onPressed: () => _nextCard(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Correct'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

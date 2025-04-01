import 'package:flutter/material.dart';
import 'package:vocat_mobile/models/word.dart';
import 'package:vocat_mobile/screens/word_matching_game_screen.dart';
import 'package:vocat_mobile/screens/word_scramble_game_screen.dart';
import 'package:vocat_mobile/screens/flashcard_game_screen.dart';
import 'package:vocat_mobile/screens/speed_vocab_game_screen.dart';
import 'package:vocat_mobile/screens/guess_word_game_screen.dart';

class GameSelectionSheet extends StatelessWidget {
  final List<Word> words;

  const GameSelectionSheet({super.key, required this.words});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Select Game',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.compare_arrows, color: Colors.blue),
              ),
              title: const Text('Word Matching'),
              subtitle: const Text('Match words with their translations'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordMatchingGameScreen(words: words),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shuffle, color: Colors.purple),
              ),
              title: const Text('Word Scramble'),
              subtitle: const Text('Unscramble letters to form words'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WordScrambleGameScreen(words: words),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.flip, color: Colors.green),
              ),
              title: const Text('Flashcards'),
              subtitle: const Text('Test your memory with flashcards'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FlashcardGameScreen(words: words),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.speed, color: Colors.orange),
              ),
              title: const Text('Speed Vocab'),
              subtitle: const Text('Quick memorization challenge'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpeedVocabGameScreen(words: words),
                  ),
                );
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.quiz, color: Colors.pink),
              ),
              title: const Text('Guess the Word'),
              subtitle: const Text('Multiple choice vocabulary quiz'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GuessWordGameScreen(words: words),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

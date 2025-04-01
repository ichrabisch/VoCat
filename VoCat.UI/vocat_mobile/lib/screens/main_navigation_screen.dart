import 'package:flutter/material.dart';
import 'flashcard_list_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: FlashcardListScreen());
  }
}

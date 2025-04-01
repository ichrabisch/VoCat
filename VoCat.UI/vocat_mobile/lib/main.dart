import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocat_mobile/screens/flashcard_list_screen.dart';
import 'theme/app_theme.dart';
import 'providers/flashcard_provider.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  await NotificationService.startPeriodicReminders();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FlashcardProvider()..loadData(),
      child: MaterialApp(
        title: 'Language Flashcards',
        theme: AppTheme.lightTheme,
        home: FutureBuilder<bool>(
          future: _authService.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return snapshot.data == true
                ? const FlashcardListScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}

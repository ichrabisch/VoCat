import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/word.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // Request permissions
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleWordReview(Word word) async {
    final nextReview = word.lastReviewed;

    await _notifications.zonedSchedule(
      word.wordId.hashCode, // Unique ID for each word
      'Time to Review!',
      'Practice the word: ${word.wordText}',
      tz.TZDateTime.from(nextReview, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'word_review',
          'Word Review Notifications',
          channelDescription: 'Notifications for word review reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> showTestNotification() async {
    await _notifications.show(
      0,
      'Test Notification',
      'This is a test notification',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'word_review',
          'Word Review Notifications',
          channelDescription: 'Notifications for word review reminders',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'Test notification',
          icon: '@mipmap/ic_launcher',
          enableLights: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  static Future<void> scheduleTestNotification(Word word) async {
    final testTime = DateTime.now().add(
      const Duration(seconds: 5),
    ); // 5 seconds from now

    await _notifications.zonedSchedule(
      word.wordId.hashCode,
      'Time to Review!',
      'Practice the word: ${word.wordText}',
      tz.TZDateTime.from(testTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'word_review',
          'Word Review Notifications',
          channelDescription: 'Notifications for word review reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> startPeriodicReminders() async {
    final now = DateTime.now();
    final scheduledTime = now.add(const Duration(seconds: 30));

    await _notifications.zonedSchedule(
      999, // Unique ID for periodic reminder
      'Time to Practice! 📚',
      'Keep your vocabulary growing - practice your words now!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'practice_reminders',
          'Practice Reminders',
          channelDescription: 'Periodic reminders to practice vocabulary',
          importance: Importance.high,
          priority: Priority.high,
          enableLights: true,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

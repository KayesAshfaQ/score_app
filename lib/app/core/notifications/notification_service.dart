import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../router/app_router.dart';

/// Top-level background message handler required by FirebaseMessaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Already initialized or platform default
  }
  debugPrint(
    '[FCM-Background] Received: ${message.messageId} | data: ${message.data}',
  );
}

class NotificationService {
  NotificationService._internal();

  static final NotificationService instance = NotificationService._internal();

  final _localNotifications = FlutterLocalNotificationsPlugin();
  FirebaseMessaging? _fcmInstance;

  FirebaseMessaging? get _fcm {
    if (Firebase.apps.isEmpty) return null;
    return _fcmInstance ??= FirebaseMessaging.instance;
  }

  bool _isInitialized = false;

  // Notification Channel Constants
  static const String liveScoresChannelId = 'live_scores_channel';
  static const String liveScoresChannelName = 'Live Scores & Goals';
  static const String liveScoresChannelDesc =
      'Instant heads-up notifications for goals, red cards, and score changes.';

  static const String matchEventsChannelId = 'match_events_channel';
  static const String matchEventsChannelName = 'Match Events';
  static const String matchEventsChannelDesc =
      'Kickoff, half-time, and full-time updates.';

  static const String leagueUpdatesChannelId = 'league_updates_channel';
  static const String leagueUpdatesChannelName = 'League Updates';
  static const String leagueUpdatesChannelDesc =
      'Daily fixtures summaries and standings updates.';

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
      );

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          if (response.payload != null && response.payload!.isEmpty) {
            _handlePayloadString(response.payload!);
          }
        },
      );

      // 3. Request Notification Permissions via FCM
      final fcm = _fcm;
      if (fcm != null) {
        final settings = await fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        debugPrint(
          '[NotificationService] Permission status: ${settings.authorizationStatus}',
        );

        // 4. Foreground presentation options on Apple platforms
        await fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

        // 5. Register Background Handler
        FirebaseMessaging.onBackgroundMessage(
          firebaseMessagingBackgroundHandler,
        );

        // 6. Listen for Foreground Messages -> show local heads-up notification
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint(
            '[FCM-Foreground] Received: ${message.notification?.title}',
          );
          _showLocalNotification(message);
        });

        // 7. Handle Notification Tap when App opened from Background
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint(
            '[FCM-OpenedApp] User tapped notification from background',
          );
          _handleRemoteMessageData(message.data);
        });

        // 8. Handle Notification Tap that launched App from Terminated state
        final initialMessage = await fcm.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('[FCM-Terminated] App launched via notification tap');
          // Slight delay to allow router to be mounted
          Future.delayed(const Duration(milliseconds: 600), () {
            _handleRemoteMessageData(initialMessage.data);
          });
        }
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully.');
      // print fcm token
      final token = await fcm?.getToken();
      debugPrint('[NotificationService] FCM Token: $token');
    } catch (e, stack) {
      debugPrint('[NotificationService] Init error: $e\n$stack');
    }
  }

  /// Display a heads-up banner when a message arrives while app is in the foreground.
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['title'] ?? 'Scora Live Alert';
    final body = notification?.body ?? data['body'] ?? '';
    final channelId = data['channelId'] ?? liveScoresChannelId;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelId == matchEventsChannelId
          ? matchEventsChannelName
          : (channelId == leagueUpdatesChannelId
                ? leagueUpdatesChannelName
                : liveScoresChannelName),
      channelDescription: liveScoresChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      showWhen: true,
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final payloadString = jsonEncode(data);

    await _localNotifications.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payloadString,
    );
  }

  /// Deep link tap handling from JSON string payload
  void _handlePayloadString(String payloadString) {
    try {
      final Map<String, dynamic> data = jsonDecode(payloadString);
      _handleRemoteMessageData(data);
    } catch (e) {
      debugPrint('[NotificationService] Error parsing payload: $e');
    }
  }

  /// Deep link routing based on notification data payload
  void _handleRemoteMessageData(Map<String, dynamic> data) {
    debugPrint('[NotificationService] Routing from data: $data');
    final type = data['type']?.toString();
    final matchIdStr = data['matchId'] ?? data['match_id'] ?? data['id'];
    final competitionCode =
        data['competitionCode'] ?? data['league_code'] ?? data['code'];

    if (type == 'match' || (matchIdStr != null && type != 'competition')) {
      final matchId = int.tryParse(matchIdStr.toString());
      if (matchId != null && matchId > 0) {
        AppRouter.router.push('/match/$matchId');
        return;
      }
    }

    if (type == 'competition' || competitionCode != null) {
      if (competitionCode != null) {
        AppRouter.router.push(
          '/competition/$competitionCode',
          extra: data['name'] ?? competitionCode,
        );
        return;
      }
    }
  }

  // -------------------------------------------------------------
  // Topic Broadcast Pub/Sub Methods
  // -------------------------------------------------------------

  /// Subscribe to any arbitrary FCM topic (broadcast channel)
  Future<void> subscribeToTopic(String topic) async {
    try {
      final fcm = _fcm;
      if (fcm == null) return;
      final safeTopic = _sanitizeTopic(topic);
      await fcm.subscribeToTopic(safeTopic);
      debugPrint('[NotificationService] Subscribed to topic: $safeTopic');
    } catch (e) {
      debugPrint('[NotificationService] Failed to subscribe to $topic: $e');
    }
  }

  /// Unsubscribe from any arbitrary FCM topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      final fcm = _fcm;
      if (fcm == null) return;
      final safeTopic = _sanitizeTopic(topic);
      await fcm.unsubscribeFromTopic(safeTopic);
      debugPrint('[NotificationService] Unsubscribed from topic: $safeTopic');
    } catch (e) {
      debugPrint('[NotificationService] Failed to unsubscribe from $topic: $e');
    }
  }

  /// Subscribe to a specific match channel (e.g. "match_330299")
  Future<void> subscribeToMatch(int matchId) async {
    await subscribeToTopic('match_$matchId');
  }

  /// Unsubscribe from a specific match channel
  Future<void> unsubscribeFromMatch(int matchId) async {
    await unsubscribeFromTopic('match_$matchId');
  }

  /// Subscribe to a competition channel (e.g. "league_PL")
  Future<void> subscribeToCompetition(String competitionCode) async {
    await subscribeToTopic('league_${competitionCode.toUpperCase()}');
  }

  /// Unsubscribe from a competition channel
  Future<void> unsubscribeFromCompetition(String competitionCode) async {
    await unsubscribeFromTopic('league_${competitionCode.toUpperCase()}');
  }

  /// Subscribe to all live goals broadcast
  Future<void> subscribeToLiveGoals() async {
    await subscribeToTopic('live_goals_all');
  }

  /// Unsubscribe from all live goals broadcast
  Future<void> unsubscribeFromLiveGoals() async {
    await unsubscribeFromTopic('live_goals_all');
  }

  /// FCM topics must match regex [a-zA-Z0-9-_.~%]{1,900}
  String _sanitizeTopic(String topic) {
    return topic.replaceAll(RegExp(r'[^a-zA-Z0-9-_.~%]'), '_');
  }
}

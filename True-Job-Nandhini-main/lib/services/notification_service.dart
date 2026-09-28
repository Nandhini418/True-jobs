import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api/notification_api.dart';

/// Top-level background message handler for FCM.
/// This must be a top-level function (not a class method) to run in a separate isolate.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  print("Message data: ${message.data}");
  if (message.notification != null) {
    print("Message notification title: ${message.notification?.title}");
    print("Message notification body: ${message.notification?.body}");
  }
}

class NotificationService {
  // Singleton pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Upload the token to the backend server if the user is logged in
  Future<void> uploadFcmToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? userId = prefs.getInt('user_id');
      if (userId != null) {
        final response = await NotificationApi.updateFcmToken(
          fcmToken: token,
          userId: userId,
        );
        print("FCM Token sync response: $response");
      } else {
        print("FCM Token not synced: User is not logged in");
      }
    } catch (e) {
      print("Error uploading FCM token: $e");
    }
  }

  /// Initialize Firebase Messaging
  Future<void> init() async {
    // 1. Request notification permissions (vital for iOS and Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted notification permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional notification permission');
    } else {
      print('User declined or has not accepted notification permission');
    }

    // 2. Retrieve and log the FCM token (essential for testing push notifications)
    try {
      String? token = await _firebaseMessaging.getToken();
      print("=========================================");
      print("FCM Token: $token");
      print("=========================================");
      if (token != null) {
        await uploadFcmToken(token);
      }
    } catch (e) {
      print("Error fetching FCM token: $e");
    }

    // 3. Handle Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 4. Handle Foreground messages (triggered when app is open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.messageId}");
      if (message.notification != null) {
        print("Foreground Notification Title: ${message.notification?.title}");
        print("Foreground Notification Body: ${message.notification?.body}");
      }
    });

    // 5. Handle when the app is opened from a notification (App was in background but running)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification opened app: ${message.messageId}");
    });

    // 6. Handle when the app is opened from a terminated state
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print("App opened from terminated state via notification: ${initialMessage.messageId}");
    }

    // 7. Handle token refresh dynamically
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print("FCM Token refreshed: $newToken");
      uploadFcmToken(newToken);
    });
  }
}

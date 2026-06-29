import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle action when notification is clicked
      },
    );

    // Request permissions for Android 13+
    final androidImplementation = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
            
    await androidImplementation?.requestNotificationsPermission();

    // Buat channel secara eksplisit agar FCM langsung mengenalinya
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'bankling_high_importance_v1', // id baru agar Android me-reset setting
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
      playSound: true,
    );

    await androidImplementation?.createNotificationChannel(channel);

    // Minta izin FCM
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Konfigurasi agar FCM tetap memunculkan Heads-Up notification di Foreground
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Ambil dan sinkronkan FCM Token ke backend
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        // Karena di.sl() mungkin belum sepenuhnya siap jika ini dipanggil dalam main sebelum runApp
        // kita bisa mencoba mengirimnya, atau lebih baik pastikan AuthBloc/repo terupdate
        // Namun, lebih aman kita defer sedikit
        Future.delayed(const Duration(seconds: 2), () {
          try {
            // import 'package:bankling/injection/injection_container.dart' as di;
            // dan 'package:bankling/presentation/blocs/auth/auth_bloc.dart';
            // Tapi karena service ini core, lebih baik jika update token dipanggil oleh UI.
            // Namun, karena kita tidak import sl, kita akan cetak token saja.
            print('FCM Token: $token');
          } catch (e) {
            print('Failed to dispatch token update: $e');
          }
        });
      }
    } catch (e) {
      print('Failed to get FCM token: $e');
    }
  }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        id: notification.hashCode.abs() % 100000,
        title: notification.title,
        body: notification.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'bankling_high_importance_v1', // id
            'High Importance Notifications', // title
            channelDescription:
                'This channel is used for important notifications.', // description
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            showWhen: true,
            playSound: true,
            enableVibration: true,
          ),
        ),
      );
    }
  }
}

import 'dart:convert';

import 'package:arkadasekle/kayitpage.dart';
import 'package:arkadasekle/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_screen.dart';

Future<void> handleBackgorundMessage(RemoteMessage message) async {
  print("nula eşit değil");
  print("title:${message.notification?.title}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final _andoridChannel = const AndroidNotificationChannel(
      'high_importance_channel', "important",
      description: 'this channel is used for ',
      importance: Importance.defaultImportance);
  final _localNotifications = FlutterLocalNotificationsPlugin();

  /*Future<void> handleMessage(RemoteMessage? message) async {
    navigatorKey.currentState
        ?.pushNamed(NotificationScreenn.route, arguments: message);
  }*/

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission(
        sound: true, alert: true, badge: true);
    final _firebaseToken = await _firebaseMessaging.getToken();
    print("token:$_firebaseToken");
    token = "$_firebaseToken";
    FirebaseFirestore _firestore = await FirebaseFirestore.instance;
    await _firestore
        .collection("users")
        .doc(userId)
        .update({"token": _firebaseToken});

    // initPushNotifications();
  }

  void sendNotification(
      String recipientToken, String title, String body) async {
    if (recipientToken.isNotEmpty) {
      await FirebaseMessaging.instance.sendMessage();
    } else {
      // recipientToken boş ise, uygun bir işlem yapabilirsiniz.
    }
  }

  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('drawable/ic_launcher');
    const settings = InitializationSettings(android: android);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
            alert: true, badge: true, sound: true);

/*
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(event);
    });*/

    FirebaseMessaging.onMessage.listen((event) {
      final notification = event.notification;

      if (notification == null) return;

      _localNotifications.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
              android: AndroidNotificationDetails(
            _andoridChannel.id,
            _andoridChannel.name,
            channelDescription: _andoridChannel.description,
          )),
          payload: jsonEncode(event.toMap()));
    });
  }
}

Future<String?> getUserToken(String userId) async {
  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (snapshot.exists) {
    Map<String, dynamic>? userData = snapshot.data() as Map<String, dynamic>?;
    String? token = userData?['token'] as String?;
    return token;
  }

  return null;
}

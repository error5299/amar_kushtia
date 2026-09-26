import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_notification.dart';

/// Provider for notification permission state
final notificationPermissionProvider = StateNotifierProvider<NotificationPermissionNotifier, bool>((ref) {
  return NotificationPermissionNotifier();
});

class NotificationPermissionNotifier extends StateNotifier<bool> {
  static const String _prefKey = 'notifications_enabled';

  NotificationPermissionNotifier() : super(false) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefKey) ?? false;
  }

  Future<bool> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
    return state;
  }
}

/// Provider for read notification IDs
final readNotificationIdsProvider = StateNotifierProvider<ReadNotificationsNotifier, Set<String>>((ref) {
  return ReadNotificationsNotifier();
});

class ReadNotificationsNotifier extends StateNotifier<Set<String>> {
  static const String _prefKey = 'read_notification_ids';

  ReadNotificationsNotifier() : super(<String>{}) {
    _loadReadIds();
  }

  Future<void> _loadReadIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefKey) ?? [];
    state = list.toSet();
  }

  Future<void> markAsRead(String id) async {
    if (state.contains(id)) return;
    final updated = Set<String>.from(state)..add(id);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, updated.toList());
  }

  Future<void> markAllAsRead(List<String> ids) async {
    final updated = Set<String>.from(state)..addAll(ids);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, updated.toList());
  }
}

/// Real-time stream of notifications from Firestore with local fallback
final notificationsStreamProvider = StreamProvider<List<AppNotification>>((ref) {
  final firestore = FirebaseFirestore.instance;
  final readIds = ref.watch(readNotificationIdsProvider);

  try {
    return firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return _defaultInitialNotifications(readIds);
          }
          return snapshot.docs.map((doc) {
            final data = doc.data();
            final isRead = readIds.contains(doc.id);
            return AppNotification.fromMap(data, docId: doc.id, isRead: isRead);
          }).toList();
        })
        .handleError((e) {
          debugPrint('[NotificationService] Firestore error: $e. Returning default notices.');
          return _defaultInitialNotifications(readIds);
        });
  } catch (e) {
    debugPrint('[NotificationService] Setup error: $e');
    return Stream.value(_defaultInitialNotifications(readIds));
  }
});

/// Unread notification count provider
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifsAsync = ref.watch(notificationsStreamProvider);
  return notifsAsync.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});

/// Service class for sending notifications
class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Broadcast a notification to all users
  static Future<void> sendNotification({
    required String titleBn,
    required String titleEn,
    required String bodyBn,
    required String bodyEn,
    required NotificationType type,
    String? targetRoute,
    String? recordId,
    String? imageUrl,
  }) async {
    try {
      final docRef = _firestore.collection('notifications').doc();
      final notif = AppNotification(
        id: docRef.id,
        titleBn: titleBn,
        titleEn: titleEn,
        bodyBn: bodyBn,
        bodyEn: bodyEn,
        type: type,
        targetRoute: targetRoute,
        recordId: recordId,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await docRef.set(notif.toMap());
      debugPrint('[NotificationService] Notification broadcasted: ${docRef.id}');
    } catch (e) {
      debugPrint('[NotificationService] Failed to send notification: $e');
      rethrow;
    }
  }
}

/// Fallback canonical notifications
List<AppNotification> _defaultInitialNotifications(Set<String> readIds) {
  final baseList = [
    AppNotification(
      id: 'welcome_notice',
      titleBn: 'আমার কুষ্টিয়া অ্যাপে আপনাকে স্বাগতম!',
      titleEn: 'Welcome to Amar Kushtia App!',
      bodyBn: 'কুষ্টিয়ার সকল জরুরি সেবা, স্বাস্থ্যসেবা ও পরিবহন তথ্য এখন আপনার হাতের মুঠোয়।',
      bodyEn: 'All emergency services, healthcare, and transport info of Kushtia are at your fingertips.',
      type: NotificationType.general,
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    AppNotification(
      id: 'travel_guide_launch',
      titleBn: 'নতুন ফিচার: ভ্রমণ গাইড চালু হয়েছে',
      titleEn: 'New Feature: Travel Guide Launched',
      bodyBn: 'কুষ্টিয়ার লোকাল বাসের সঠিক ভাড়া তালিকা ও দূরপাল্লার বাসের টিকিট কাউন্টার সহজে খুঁজুন।',
      bodyEn: 'Easily check standard local bus fares and find long-distance bus ticket counters.',
      type: NotificationType.travel,
      targetRoute: 'travel_guide',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppNotification(
      id: 'emergency_reminder',
      titleBn: 'জরুরি রক্তের প্রয়োজন বা অ্যাম্বুলেন্স?',
      titleEn: 'Need emergency blood or ambulance?',
      bodyBn: 'জরুরি সেবা ট্যাব থেকে ২৪/৭ কুষ্টিয়ার অ্যাম্বুলেন্স ও রক্তদাতাদের সাথে যোগাযোগ করুন।',
      bodyEn: 'Contact Kushtia ambulance drivers and blood donors 24/7 directly from Emergency tab.',
      type: NotificationType.emergency,
      targetRoute: 'emergency',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  return baseList.map((n) => n.copyWith(isRead: readIds.contains(n.id))).toList();
}

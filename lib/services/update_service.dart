import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_update_info.dart';
import 'firebase_service.dart';

/// Current installed version metadata of the Amar Kushtia application.
/// Prepared for Beta 1 release.
class AppVersion {
  static const String versionName = '1.0.0-beta.1';
  static const int buildNumber = 1;
  static const String releaseTag = 'Beta v1.0';
  static const String releaseDate = '2026-09-26';

  static String get formattedVersionBn => '১.০.০-বেটা.১ (বিল্ড ১)';
  static String get formattedVersionEn => '1.0.0-beta.1 (Build 1)';
}

/// Provider streaming latest update release info from Firestore
final appUpdateInfoProvider = StreamProvider<AppUpdateInfo?>((ref) {
  if (!FirebaseService.instance.isInitialized) {
    return Stream.value(null);
  }

  return FirebaseService.instance.firestore
      .collection('app_config')
      .doc('version_info')
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) {
      return null;
    }
    return AppUpdateInfo.fromMap(doc.data()!);
  }).handleError((e) {
    debugPrint('[UpdateService] Update stream note: $e');
    return null;
  });
});

/// Service class handling app updates, manual checking, and download actions.
class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  /// Check if a given update info indicates a newer version than currently installed
  bool isUpdateAvailable(AppUpdateInfo? updateInfo) {
    if (updateInfo == null) return false;
    return updateInfo.latestBuildNumber > AppVersion.buildNumber;
  }

  /// Check if an update is mandatory
  bool isMandatory(AppUpdateInfo? updateInfo) {
    if (updateInfo == null) return false;
    return updateInfo.isForceUpdate ||
        AppVersion.buildNumber < updateInfo.minSupportedBuildNumber;
  }

  /// Launch update URL (APK download link or Play Store)
  Future<bool> launchUpdateUrl(AppUpdateInfo updateInfo) async {
    final targetUrl = updateInfo.apkDownloadUrl.isNotEmpty
        ? updateInfo.apkDownloadUrl
        : updateInfo.playStoreUrl;

    if (targetUrl.isEmpty) return false;

    try {
      final uri = Uri.parse(targetUrl);
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[UpdateService] Launch error: $e');
    }
    return false;
  }

  /// One-click method to fetch latest update info from Firestore
  Future<AppUpdateInfo?> fetchLatestUpdate() async {
    if (!FirebaseService.instance.isInitialized) return null;
    try {
      final doc = await FirebaseService.instance.firestore
          .collection('app_config')
          .doc('version_info')
          .get();

      if (doc.exists && doc.data() != null) {
        return AppUpdateInfo.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('[UpdateService] Check update error: $e');
    }
    return null;
  }
}

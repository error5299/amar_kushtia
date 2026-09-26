import 'package:cloud_firestore/cloud_firestore.dart';

/// AppUpdateInfo represents the update release metadata published from Admin Portal.
/// Stored in Firestore doc: `app_config/version_info` or `system_updates/latest`
class AppUpdateInfo {
  final String latestVersion;       // e.g. "1.0.0-beta.1" or "1.0.0"
  final int latestBuildNumber;      // e.g. 1
  final String releaseDate;         // e.g. "2026-09-26"
  final String releaseTitleBn;      // e.g. "আমার কুষ্টিয়া বেটা ১.০ রিলিজ"
  final String releaseTitleEn;      // e.g. "Amar Kushtia Beta 1.0 Release"
  final String releaseNotesBn;      // Changelog / কী কী নতুন
  final String releaseNotesEn;      // Changelog in English
  final String apkDownloadUrl;      // Direct APK or Drive/Storage URL
  final String playStoreUrl;        // Play Store link if published
  final bool isForceUpdate;         // Mandatory update for older versions
  final int minSupportedBuildNumber;// Below this, app prompts mandatory update
  final String channel;             // "beta", "stable", etc.

  const AppUpdateInfo({
    required this.latestVersion,
    required this.latestBuildNumber,
    required this.releaseDate,
    required this.releaseTitleBn,
    required this.releaseTitleEn,
    required this.releaseNotesBn,
    required this.releaseNotesEn,
    this.apkDownloadUrl = '',
    this.playStoreUrl = '',
    this.isForceUpdate = false,
    this.minSupportedBuildNumber = 1,
    this.channel = 'beta',
  });

  factory AppUpdateInfo.fromMap(Map<String, dynamic> map) {
    return AppUpdateInfo(
      latestVersion: (map['latestVersion'] ?? map['versionName'] ?? '1.0.0-beta.1').toString(),
      latestBuildNumber: (map['latestBuildNumber'] ?? map['versionCode'] ?? 1) is int
          ? (map['latestBuildNumber'] ?? map['versionCode'] ?? 1) as int
          : int.tryParse(map['latestBuildNumber']?.toString() ?? '1') ?? 1,
      releaseDate: (map['releaseDate'] ?? '').toString(),
      releaseTitleBn: (map['releaseTitleBn'] ?? map['titleBn'] ?? 'নতুন আপডেট উপলব্ধ').toString(),
      releaseTitleEn: (map['releaseTitleEn'] ?? map['titleEn'] ?? 'New Update Available').toString(),
      releaseNotesBn: (map['releaseNotesBn'] ?? map['changelogBn'] ?? '').toString(),
      releaseNotesEn: (map['releaseNotesEn'] ?? map['changelogEn'] ?? '').toString(),
      apkDownloadUrl: (map['apkDownloadUrl'] ?? map['downloadUrl'] ?? '').toString(),
      playStoreUrl: (map['playStoreUrl'] ?? '').toString(),
      isForceUpdate: map['isForceUpdate'] == true || map['forceUpdate'] == true,
      minSupportedBuildNumber: (map['minSupportedBuildNumber'] ?? 1) is int
          ? (map['minSupportedBuildNumber'] ?? 1) as int
          : int.tryParse(map['minSupportedBuildNumber']?.toString() ?? '1') ?? 1,
      channel: (map['channel'] ?? 'beta').toString(),
    );
  }

  String getTitle(bool isBn) {
    if (isBn) {
      return releaseTitleBn.isNotEmpty ? releaseTitleBn : releaseTitleEn;
    }
    return releaseTitleEn.isNotEmpty ? releaseTitleEn : releaseTitleBn;
  }

  String getNotes(bool isBn) {
    if (isBn) {
      return releaseNotesBn.isNotEmpty ? releaseNotesBn : releaseNotesEn;
    }
    return releaseNotesEn.isNotEmpty ? releaseNotesEn : releaseNotesBn;
  }

  Map<String, dynamic> toMap() {
    return {
      'latestVersion': latestVersion,
      'latestBuildNumber': latestBuildNumber,
      'releaseDate': releaseDate,
      'releaseTitleBn': releaseTitleBn,
      'releaseTitleEn': releaseTitleEn,
      'releaseNotesBn': releaseNotesBn,
      'releaseNotesEn': releaseNotesEn,
      'apkDownloadUrl': apkDownloadUrl,
      'playStoreUrl': playStoreUrl,
      'isForceUpdate': isForceUpdate,
      'minSupportedBuildNumber': minSupportedBuildNumber,
      'channel': channel,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

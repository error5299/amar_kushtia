library;

import 'package:cloud_firestore/cloud_firestore.dart';

/// Notification types supported in Amar Kushtia
enum NotificationType {
  general,
  emergency,
  contentUpdate,
  travel,
  healthcare,
}

class AppNotification {
  final String id;
  final String titleBn;
  final String titleEn;
  final String bodyBn;
  final String bodyEn;
  final NotificationType type;
  final String? targetRoute; // e.g. 'travel_guide', 'emergency', 'record_detail'
  final String? recordId;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    required this.bodyBn,
    required this.bodyEn,
    this.type = NotificationType.general,
    this.targetRoute,
    this.recordId,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
  });

  String getTitle(bool isBn) => isBn ? titleBn : titleEn;
  String getBody(bool isBn) => isBn ? bodyBn : bodyEn;

  AppNotification copyWith({
    String? id,
    String? titleBn,
    String? titleEn,
    String? bodyBn,
    String? bodyEn,
    NotificationType? type,
    String? targetRoute,
    String? recordId,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return AppNotification(
      id: id ?? this.id,
      titleBn: titleBn ?? this.titleBn,
      titleEn: titleEn ?? this.titleEn,
      bodyBn: bodyBn ?? this.bodyBn,
      bodyEn: bodyEn ?? this.bodyEn,
      type: type ?? this.type,
      targetRoute: targetRoute ?? this.targetRoute,
      recordId: recordId ?? this.recordId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'titleBn': titleBn,
        'titleEn': titleEn,
        'bodyBn': bodyBn,
        'bodyEn': bodyEn,
        'type': type.name,
        'targetRoute': targetRoute,
        'recordId': recordId,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory AppNotification.fromMap(Map<String, dynamic> map, {String? docId, bool isRead = false}) {
    DateTime parsedDate;
    final createdVal = map['createdAt'];
    if (createdVal is Timestamp) {
      parsedDate = createdVal.toDate();
    } else if (createdVal is String) {
      parsedDate = DateTime.tryParse(createdVal) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    NotificationType parsedType = NotificationType.general;
    final typeStr = map['type'] as String?;
    if (typeStr != null) {
      for (final t in NotificationType.values) {
        if (t.name == typeStr) {
          parsedType = t;
          break;
        }
      }
    }

    return AppNotification(
      id: docId ?? (map['id'] as String? ?? ''),
      titleBn: map['titleBn'] as String? ?? '',
      titleEn: map['titleEn'] as String? ?? '',
      bodyBn: map['bodyBn'] as String? ?? '',
      bodyEn: map['bodyEn'] as String? ?? '',
      type: parsedType,
      targetRoute: map['targetRoute'] as String?,
      recordId: map['recordId'] as String?,
      imageUrl: map['imageUrl'] as String?,
      createdAt: parsedDate,
      isRead: isRead,
    );
  }
}

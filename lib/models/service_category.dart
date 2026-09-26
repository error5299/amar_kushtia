import 'package:flutter/material.dart';

/// Represents a civic service category / division in Amar Kushtia
class ServiceCategory {
  final String id;
  final String titleBn;
  final String titleEn;
  final String subtitleBn;
  final String subtitleEn;
  final String iconName;
  final String colorHex;
  final String bgColorHex;
  final int sortOrder;
  final bool isActive;

  const ServiceCategory({
    required this.id,
    required this.titleBn,
    required this.titleEn,
    this.subtitleBn = '',
    this.subtitleEn = '',
    this.iconName = 'category',
    this.colorHex = '#1E5638',
    this.bgColorHex = '#E2F0E8',
    this.sortOrder = 0,
    this.isActive = true,
  });

  String getTitle(bool isBn) => isBn ? titleBn : (titleEn.isNotEmpty ? titleEn : titleBn);
  String getSubtitle(bool isBn) => isBn ? subtitleBn : (subtitleEn.isNotEmpty ? subtitleEn : subtitleBn);

  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFF0B5233);
  }

  Color get bgColor {
    try {
      final hex = bgColorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      }
    } catch (_) {}
    return const Color(0xFFE2F0E8);
  }

  IconData get icon {
    switch (iconName.toLowerCase().replaceAll('fa-', '').replaceAll('fas ', '').replaceAll('far ', '')) {
      case 'emergency':
      case 'ambulance':
      case 'kit-medical':
        return Icons.emergency_rounded;
      case 'hospital':
      case 'heartbeat':
      case 'stethoscope':
      case 'medical':
        return Icons.local_hospital_rounded;
      case 'police':
      case 'shield':
      case 'shield-alt':
      case 'user-shield':
        return Icons.shield_rounded;
      case 'fire':
      case 'fire-extinguisher':
      case 'flame':
        return Icons.fire_extinguisher_rounded;
      case 'train':
      case 'subway':
        return Icons.train_rounded;
      case 'bus':
        return Icons.directions_bus_rounded;
      case 'car':
      case 'taxi':
        return Icons.local_taxi_rounded;
      case 'tourism':
      case 'camera':
      case 'landmark':
      case 'monument':
      case 'place':
        return Icons.photo_camera_rounded;
      case 'government':
      case 'building':
      case 'bank':
      case 'landmark-dome':
        return Icons.account_balance_rounded;
      case 'education':
      case 'school':
      case 'graduation-cap':
      case 'book':
        return Icons.school_rounded;
      case 'food':
      case 'utensils':
      case 'hamburger':
        return Icons.restaurant_rounded;
      case 'craft':
      case 'paint-brush':
      case 'palette':
        return Icons.palette_rounded;
      case 'agriculture':
      case 'seedling':
      case 'leaf':
      case 'wheat-awn':
        return Icons.agriculture_rounded;
      case 'blood':
      case 'blood-drop':
      case 'tint':
        return Icons.bloodtype_rounded;
      case 'bolt':
      case 'electricity':
      case 'power':
        return Icons.bolt_rounded;
      case 'map':
      case 'atlas':
        return Icons.map_rounded;
      case 'phone':
      case 'headset':
        return Icons.phone_in_talk_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleBn': titleBn,
      'titleEn': titleEn,
      'subtitleBn': subtitleBn,
      'subtitleEn': subtitleEn,
      'iconName': iconName,
      'colorHex': colorHex,
      'bgColorHex': bgColorHex,
      'sortOrder': sortOrder,
      'isActive': isActive,
    };
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map) {
    return ServiceCategory(
      id: map['id']?.toString() ?? '',
      titleBn: (map['titleBn'] ?? map['nameBn'] ?? '')?.toString() ?? '',
      titleEn: (map['titleEn'] ?? map['nameEn'] ?? '')?.toString() ?? '',
      subtitleBn: map['subtitleBn']?.toString() ?? '',
      subtitleEn: map['subtitleEn']?.toString() ?? '',
      iconName: (map['iconName'] ?? map['icon'] ?? 'category')?.toString() ?? 'category',
      colorHex: (map['colorHex'] ?? map['color'] ?? '#1E5638')?.toString() ?? '#1E5638',
      bgColorHex: (map['bgColorHex'] ?? map['bgColor'] ?? '#E2F0E8')?.toString() ?? '#E2F0E8',
      sortOrder: int.tryParse(map['sortOrder']?.toString() ?? '0') ?? 0,
      isActive: map['isActive'] is bool ? map['isActive'] as bool : (map['isActive']?.toString().toLowerCase() != 'false'),
    );
  }

  factory ServiceCategory.fromFirestoreRest(Map<String, dynamic> doc) {
    final fields = doc['fields'] as Map<String, dynamic>? ?? {};
    final map = <String, dynamic>{};

    if (fields.containsKey('id') && fields['id']['stringValue'] != null) {
      map['id'] = fields['id']['stringValue'];
    } else if (doc.containsKey('name')) {
      final name = doc['name'] as String;
      map['id'] = name.split('/').last;
    }

    for (final entry in fields.entries) {
      final key = entry.key;
      final val = entry.value as Map<String, dynamic>?;
      if (val == null) continue;
      if (val.containsKey('stringValue')) {
        map[key] = val['stringValue'];
      } else if (val.containsKey('booleanValue')) {
        map[key] = val['booleanValue'];
      } else if (val.containsKey('integerValue')) {
        map[key] = int.tryParse(val['integerValue'].toString()) ?? 0;
      }
    }
    return ServiceCategory.fromMap(map);
  }
}

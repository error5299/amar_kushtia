/// Central Master Record representing MD-0001 to MD-0080.
/// Adheres strictly to the 29-field CMS Schema from Master Data Document v2.0.
class MasterRecord {
  final String id; // e.g. "MD-0001"
  final String categoryId; // emergency, police, fire, healthcare, etc.
  final String? subcategoryId;
  final String nameBn;
  final String? nameEn;
  final String? shortDescriptionBn;
  final String? shortDescriptionEn;
  final String? descriptionBn;
  final String? descriptionEn;
  final String? upazilaId; // UPZ-001 to UPZ-006 or area name
  final String? addressBn;
  final String? addressEn;
  final String? phonePrimary;
  final String? phoneSecondary;
  final String? email;
  final String? website;
  final String? directionsUrl;
  final String? mapEmbedUrl;
  final double? latitude;
  final double? longitude;
  final String? coordinateStatus; // Verified, Secondary map source, etc.
  final String? openingHours;
  final String? offDays;
  final String? feeType; // Free, Fixed, Per km, Variable
  final double? feeAmount;
  final List<String> imageUrls;
  final String templateId; // TPL-01 to TPL-07
  final bool isActive;
  final bool isFeatured;
  final int sortOrder;
  final String verificationStatus; // Verified, Partially Verified, Needs Verification
  final String? sourceDocument;
  final String? sourceUrl;
  final String? lastVerifiedAt;
  final String? notes;
  final List<String> searchKeywordsBn;
  final List<String> searchKeywordsEn;
  final DateTime createdAt;
  final DateTime updatedAt;

  MasterRecord({
    required this.id,
    required this.categoryId,
    this.subcategoryId,
    required this.nameBn,
    this.nameEn,
    this.shortDescriptionBn,
    this.shortDescriptionEn,
    this.descriptionBn,
    this.descriptionEn,
    this.upazilaId,
    this.addressBn,
    this.addressEn,
    this.phonePrimary,
    this.phoneSecondary,
    this.email,
    this.website,
    this.directionsUrl,
    this.mapEmbedUrl,
    this.latitude,
    this.longitude,
    this.coordinateStatus,
    this.openingHours,
    this.offDays,
    this.feeType,
    this.feeAmount,
    this.imageUrls = const [],
    this.templateId = 'TPL-01',
    this.isActive = true,
    this.isFeatured = false,
    this.sortOrder = 0,
    required this.verificationStatus,
    this.sourceDocument,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.notes,
    this.searchKeywordsBn = const [],
    this.searchKeywordsEn = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Helper getters for localized presentation
  String getName(bool isBn) => isBn ? nameBn : (nameEn ?? nameBn);
  String getShortDescription(bool isBn) =>
      isBn ? (shortDescriptionBn ?? '') : (shortDescriptionEn ?? shortDescriptionBn ?? '');
  String getDescription(bool isBn) =>
      isBn ? (descriptionBn ?? '') : (descriptionEn ?? descriptionBn ?? '');
  String getAddress(bool isBn) =>
      isBn ? (addressBn ?? '') : (addressEn ?? addressBn ?? '');

  bool get hasCoordinates =>
      latitude != null && longitude != null && latitude != 0 && longitude != 0;

  bool get isVerified => verificationStatus.toLowerCase().startsWith('verified');
  bool get isPartiallyVerified =>
      verificationStatus.toLowerCase().contains('partially');

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'nameBn': nameBn,
      'titleBn': nameBn,
      'nameEn': nameEn,
      'titleEn': nameEn,
      'shortDescriptionBn': shortDescriptionBn,
      'shortDescriptionEn': shortDescriptionEn,
      'descriptionBn': descriptionBn,
      'descriptionEn': descriptionEn,
      'upazilaId': upazilaId,
      'addressBn': addressBn,
      'addressEn': addressEn,
      'phonePrimary': phonePrimary,
      'phoneSecondary': phoneSecondary,
      'email': email,
      'website': website,
      'directionsUrl': directionsUrl,
      'mapEmbedUrl': mapEmbedUrl,
      'latitude': latitude,
      'longitude': longitude,
      'coordinateStatus': coordinateStatus,
      'openingHours': openingHours,
      'offDays': offDays,
      'feeType': feeType,
      'feeAmount': feeAmount,
      'imageUrls': imageUrls,
      'templateId': templateId,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'sortOrder': sortOrder,
      'verificationStatus': verificationStatus,
      'sourceDocument': sourceDocument,
      'sourceUrl': sourceUrl,
      'lastVerifiedAt': lastVerifiedAt,
      'notes': notes,
      'searchKeywordsBn': searchKeywordsBn,
      'searchKeywordsEn': searchKeywordsEn,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory MasterRecord.fromMap(Map<String, dynamic> map) {
    return MasterRecord(
      id: map['id'] as String? ?? '',
      categoryId: map['categoryId'] as String? ?? '',
      subcategoryId: map['subcategoryId'] as String?,
      nameBn: (map['nameBn'] ?? map['titleBn'] ?? '') as String,
      nameEn: (map['nameEn'] ?? map['titleEn']) as String?,
      shortDescriptionBn: map['shortDescriptionBn'] as String?,
      shortDescriptionEn: map['shortDescriptionEn'] as String?,
      descriptionBn: map['descriptionBn'] as String?,
      descriptionEn: map['descriptionEn'] as String?,
      upazilaId: map['upazilaId'] as String?,
      addressBn: map['addressBn'] as String?,
      addressEn: map['addressEn'] as String?,
      phonePrimary: (map['phonePrimary'] ?? (map['contactNumbers'] is List && (map['contactNumbers'] as List).isNotEmpty ? map['contactNumbers'][0] : null)) as String?,
      phoneSecondary: map['phoneSecondary'] as String?,
      email: map['email'] as String?,
      website: map['website'] as String?,
      directionsUrl: map['directionsUrl'] as String?,
      mapEmbedUrl: (map['mapEmbedUrl'] ??
              map['mapEmbed'] ??
              map['mapEmbedHtml'] ??
              map['googleMapEmbed'] ??
              map['mapIframe'] ??
              map['mapUrl']) as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      coordinateStatus: map['coordinateStatus'] as String?,
      openingHours: (map['openingHours'] ?? map['openingHoursBn']) as String?,
      offDays: map['offDays'] as String?,
      feeType: map['feeType'] as String?,
      feeAmount: (map['feeAmount'] as num?)?.toDouble(),
      imageUrls: () {
        final raw = map['imageUrls'] ?? map['photos'] ?? map['images'];
        if (raw is List) {
          return raw
              .map((e) => e.toString().trim())
              .where((s) => s.isNotEmpty)
              .toList();
        } else if (raw is String && raw.trim().isNotEmpty) {
          return raw
              .split(RegExp(r'[\n,]'))
              .map((e) => e.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
        return <String>[];
      }(),
      templateId: map['templateId'] as String? ?? 'TPL-01',
      isActive: map['isActive'] as bool? ?? true,
      isFeatured: map['isFeatured'] as bool? ?? false,
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      verificationStatus: (map['verificationStatus'] ?? map['verifiedBadgeStatus']) as String? ?? 'Needs Verification',
      sourceDocument: map['sourceDocument'] as String?,
      sourceUrl: map['sourceUrl'] as String?,
      lastVerifiedAt: map['lastVerifiedAt'] as String?,
      notes: map['notes'] as String?,
      searchKeywordsBn: (map['searchKeywordsBn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      searchKeywordsEn: (map['searchKeywordsEn'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt'].toString()) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt'].toString()) : null,
    );
  }

  /// Parses a document returned by Firestore REST API
  factory MasterRecord.fromFirestoreRest(Map<String, dynamic> doc) {
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
      } else if (val.containsKey('doubleValue')) {
        map[key] = (val['doubleValue'] as num).toDouble();
      } else if (val.containsKey('arrayValue')) {
        final arr = val['arrayValue'] as Map<String, dynamic>?;
        final list = arr?['values'] as List<dynamic>? ?? [];
        map[key] = list.map((item) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey('stringValue')) return item['stringValue'];
            if (item.containsKey('integerValue')) return item['integerValue'];
            if (item.containsKey('doubleValue')) return item['doubleValue'];
            if (item.containsKey('booleanValue')) return item['booleanValue'];
          }
          return item.toString();
        }).toList();
      } else if (val.containsKey('timestampValue')) {
        map[key] = val['timestampValue'];
      }
    }
    return MasterRecord.fromMap(map);
  }

  MasterRecord copyWith({
    String? id,
    String? categoryId,
    String? subcategoryId,
    String? nameBn,
    String? nameEn,
    String? shortDescriptionBn,
    String? shortDescriptionEn,
    String? descriptionBn,
    String? descriptionEn,
    String? upazilaId,
    String? addressBn,
    String? addressEn,
    String? phonePrimary,
    String? phoneSecondary,
    String? email,
    String? website,
    String? directionsUrl,
    String? mapEmbedUrl,
    double? latitude,
    double? longitude,
    String? coordinateStatus,
    String? openingHours,
    String? offDays,
    String? feeType,
    double? feeAmount,
    List<String>? imageUrls,
    String? templateId,
    bool? isActive,
    bool? isFeatured,
    int? sortOrder,
    String? verificationStatus,
    String? sourceDocument,
    String? sourceUrl,
    String? lastVerifiedAt,
    String? notes,
    List<String>? searchKeywordsBn,
    List<String>? searchKeywordsEn,
    DateTime? updatedAt,
  }) {
    return MasterRecord(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      nameBn: nameBn ?? this.nameBn,
      nameEn: nameEn ?? this.nameEn,
      shortDescriptionBn: shortDescriptionBn ?? this.shortDescriptionBn,
      shortDescriptionEn: shortDescriptionEn ?? this.shortDescriptionEn,
      descriptionBn: descriptionBn ?? this.descriptionBn,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      upazilaId: upazilaId ?? this.upazilaId,
      addressBn: addressBn ?? this.addressBn,
      addressEn: addressEn ?? this.addressEn,
      phonePrimary: phonePrimary ?? this.phonePrimary,
      phoneSecondary: phoneSecondary ?? this.phoneSecondary,
      email: email ?? this.email,
      website: website ?? this.website,
      directionsUrl: directionsUrl ?? this.directionsUrl,
      mapEmbedUrl: mapEmbedUrl ?? this.mapEmbedUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      coordinateStatus: coordinateStatus ?? this.coordinateStatus,
      openingHours: openingHours ?? this.openingHours,
      offDays: offDays ?? this.offDays,
      feeType: feeType ?? this.feeType,
      feeAmount: feeAmount ?? this.feeAmount,
      imageUrls: imageUrls ?? this.imageUrls,
      templateId: templateId ?? this.templateId,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      sortOrder: sortOrder ?? this.sortOrder,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      sourceDocument: sourceDocument ?? this.sourceDocument,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
      notes: notes ?? this.notes,
      searchKeywordsBn: searchKeywordsBn ?? this.searchKeywordsBn,
      searchKeywordsEn: searchKeywordsEn ?? this.searchKeywordsEn,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}

/// National Hotlines model representing HT-001 to HT-017.
class NationalHotline {
  final String id; // HT-001 to HT-017
  final String category;
  final String serviceNameBn;
  final String serviceNameEn;
  final String hotline;
  final String? secondary;
  final String purposeBn;
  final String purposeEn;
  final String coverage;
  final String verificationStatus;
  final String sourceUrl;

  NationalHotline({
    required this.id,
    required this.category,
    required this.serviceNameBn,
    required this.serviceNameEn,
    required this.hotline,
    this.secondary,
    required this.purposeBn,
    required this.purposeEn,
    this.coverage = 'Nationwide',
    this.verificationStatus = 'Verified',
    required this.sourceUrl,
  });

  String getServiceName(bool isBn) => isBn ? serviceNameBn : serviceNameEn;
  String getPurpose(bool isBn) => isBn ? purposeBn : purposeEn;

  String get dialNumber => hotline;
  String get availability => coverage;
  String get description => purposeBn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'serviceNameBn': serviceNameBn,
        'serviceNameEn': serviceNameEn,
        'hotline': hotline,
        'secondary': secondary,
        'purposeBn': purposeBn,
        'purposeEn': purposeEn,
        'coverage': coverage,
        'verificationStatus': verificationStatus,
        'sourceUrl': sourceUrl,
      };

  factory NationalHotline.fromMap(Map<String, dynamic> map) => NationalHotline(
        id: map['id'] as String? ?? '',
        category: map['category'] as String? ?? '',
        serviceNameBn: map['serviceNameBn'] as String? ?? '',
        serviceNameEn: map['serviceNameEn'] as String? ?? '',
        hotline: map['hotline'] as String? ?? '',
        secondary: map['secondary'] as String?,
        purposeBn: map['purposeBn'] as String? ?? '',
        purposeEn: map['purposeEn'] as String? ?? '',
        coverage: map['coverage'] as String? ?? 'Nationwide',
        verificationStatus: map['verificationStatus'] as String? ?? 'Verified',
        sourceUrl: map['sourceUrl'] as String? ?? '',
      );
}

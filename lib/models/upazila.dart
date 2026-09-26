/// Upazila profile model representing UPZ-001 to UPZ-006.
class Upazila {
  final String id; // UPZ-001 to UPZ-006
  final String nameBn;
  final String nameEn;
  final String adminStatus;
  final double areaSqKm;
  final int population2022;
  final int unionCount;
  final String municipality;
  final String identityNotes;
  final String source;
  final String verificationStatus;

  Upazila({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.adminStatus,
    required this.areaSqKm,
    required this.population2022,
    required this.unionCount,
    required this.municipality,
    required this.identityNotes,
    required this.source,
    required this.verificationStatus,
  });

  String getName(bool isBn) => isBn ? nameBn : nameEn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameBn': nameBn,
        'nameEn': nameEn,
        'adminStatus': adminStatus,
        'areaSqKm': areaSqKm,
        'population2022': population2022,
        'unionCount': unionCount,
        'municipality': municipality,
        'identityNotes': identityNotes,
        'source': source,
        'verificationStatus': verificationStatus,
      };

  factory Upazila.fromMap(Map<String, dynamic> map) => Upazila(
        id: map['id'] as String? ?? '',
        nameBn: map['nameBn'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
        adminStatus: map['adminStatus'] as String? ?? '',
        areaSqKm: (map['areaSqKm'] as num?)?.toDouble() ?? 0.0,
        population2022: (map['population2022'] as num?)?.toInt() ?? 0,
        unionCount: (map['unionCount'] as num?)?.toInt() ?? 0,
        municipality: map['municipality'] as String? ?? '',
        identityNotes: map['identityNotes'] as String? ?? '',
        source: map['source'] as String? ?? '',
        verificationStatus: map['verificationStatus'] as String? ?? 'Needs Verification',
      );
}

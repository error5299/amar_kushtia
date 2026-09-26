/// Education institution and Islamic University residential halls models.
library;

class IUHallRecord {
  final String id; // IUH-001 to IUH-009
  final String hallName;
  final String institution;
  final String source;
  final String verificationStatus;

  IUHallRecord({
    required this.id,
    required this.hallName,
    this.institution = 'Islamic University',
    this.source = 'https://iu.ac.bd/',
    this.verificationStatus = 'Verified',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'hallName': hallName,
    'institution': institution,
    'source': source,
    'verificationStatus': verificationStatus,
  };

  factory IUHallRecord.fromMap(Map<String, dynamic> map) => IUHallRecord(
    id: map['id'] as String? ?? '',
    hallName: map['hallName'] as String? ?? '',
    institution: map['institution'] as String? ?? 'Islamic University',
    source: map['source'] as String? ?? 'https://iu.ac.bd/',
    verificationStatus: map['verificationStatus'] as String? ?? 'Verified',
  );
}

class EducationInstitution {
  final String id; // EDU-001 to EDU-003
  final String type; // University / College
  final String institution;
  final String location;
  final String profile;
  final String founded;
  final String operationalStart;
  final String source;
  final String verificationStatus;

  EducationInstitution({
    required this.id,
    required this.type,
    required this.institution,
    required this.location,
    required this.profile,
    required this.founded,
    required this.operationalStart,
    required this.source,
    required this.verificationStatus,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type,
    'institution': institution,
    'location': location,
    'profile': profile,
    'founded': founded,
    'operationalStart': operationalStart,
    'source': source,
    'verificationStatus': verificationStatus,
  };

  factory EducationInstitution.fromMap(Map<String, dynamic> map) =>
      EducationInstitution(
        id: map['id'] as String? ?? '',
        type: map['type'] as String? ?? '',
        institution: map['institution'] as String? ?? '',
        location: map['location'] as String? ?? '',
        profile: map['profile'] as String? ?? '',
        founded: map['founded'] as String? ?? '',
        operationalStart: map['operationalStart'] as String? ?? '',
        source: map['source'] as String? ?? '',
        verificationStatus:
            map['verificationStatus'] as String? ?? 'Partially Verified',
      );
}

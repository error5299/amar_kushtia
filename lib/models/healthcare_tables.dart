/// Healthcare fee and surgery schedule models from Master Data Document v2.0.
library;

class BedFeeRecord {
  final String id; // FEE-001 to FEE-005
  final String bedType;
  final String capacityUnit;
  final double dailyRentBdt;
  final String dietNotes;
  final String source;
  final String verificationStatus;

  BedFeeRecord({
    required this.id,
    required this.bedType,
    required this.capacityUnit,
    required this.dailyRentBdt,
    required this.dietNotes,
    required this.source,
    required this.verificationStatus,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'bedType': bedType,
    'capacityUnit': capacityUnit,
    'dailyRentBdt': dailyRentBdt,
    'dietNotes': dietNotes,
    'source': source,
    'verificationStatus': verificationStatus,
  };

  factory BedFeeRecord.fromMap(Map<String, dynamic> map) => BedFeeRecord(
    id: map['id'] as String? ?? '',
    bedType: map['bedType'] as String? ?? '',
    capacityUnit: map['capacityUnit'] as String? ?? '',
    dailyRentBdt: (map['dailyRentBdt'] as num?)?.toDouble() ?? 0.0,
    dietNotes: map['dietNotes'] as String? ?? '',
    source: map['source'] as String? ?? '',
    verificationStatus:
        map['verificationStatus'] as String? ?? 'Partially Verified',
  );
}

class SurgeryRecord {
  final String id; // SUR-001 to SUR-005
  final String department;
  final String surgeryDays;
  final String minorFee;
  final String majorFee;

  SurgeryRecord({
    required this.id,
    required this.department,
    required this.surgeryDays,
    required this.minorFee,
    required this.majorFee,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'department': department,
    'surgeryDays': surgeryDays,
    'minorFee': minorFee,
    'majorFee': majorFee,
  };

  factory SurgeryRecord.fromMap(Map<String, dynamic> map) => SurgeryRecord(
    id: map['id'] as String? ?? '',
    department: map['department'] as String? ?? '',
    surgeryDays: map['surgeryDays'] as String? ?? '',
    minorFee: map['minorFee'] as String? ?? '',
    majorFee: map['majorFee'] as String? ?? '',
  );
}

class AmbulanceModel {
  final String model; // "Intra-Municipality" or "Inter-District"
  final double amount;
  final String method;
  final String contact;

  AmbulanceModel({
    required this.model,
    required this.amount,
    required this.method,
    required this.contact,
  });

  Map<String, dynamic> toMap() => {
    'model': model,
    'amount': amount,
    'method': method,
    'contact': contact,
  };

  factory AmbulanceModel.fromMap(Map<String, dynamic> map) => AmbulanceModel(
    model: map['model'] as String? ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
    method: map['method'] as String? ?? '',
    contact: map['contact'] as String? ?? '',
  );
}

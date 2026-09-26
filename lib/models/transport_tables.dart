/// Rail and transport connectivity models from Master Data Document v2.0.
library;

class TrainRecord {
  final String id; // TRN-001 to TRN-004
  final String trainName;
  final String category; // Intercity
  final String departurePoradah;
  final String arrivalCourt;
  final String offDay;
  final String sourceUrl;
  final String verificationStatus;

  TrainRecord({
    required this.id,
    required this.trainName,
    required this.category,
    required this.departurePoradah,
    required this.arrivalCourt,
    required this.offDay,
    required this.sourceUrl,
    required this.verificationStatus,
  });

  String get trainNameBn => trainName;
  String get trainNameEn => trainName;
  String get trainNumber => id;
  String get trainType => category;
  String get origin => 'পোড়াদহ ($departurePoradah)';
  String get destination => 'কুষ্টিয়া কোর্ট ($arrivalCourt)';
  String get departureTime => departurePoradah;
  String get arrivalTime => arrivalCourt;
  String get offDayBn => offDay;

  Map<String, dynamic> toMap() => {
    'id': id,
    'trainName': trainName,
    'category': category,
    'departurePoradah': departurePoradah,
    'arrivalCourt': arrivalCourt,
    'offDay': offDay,
    'sourceUrl': sourceUrl,
    'verificationStatus': verificationStatus,
  };

  factory TrainRecord.fromMap(Map<String, dynamic> map) => TrainRecord(
    id: map['id'] as String? ?? '',
    trainName: map['trainName'] as String? ?? '',
    category: map['category'] as String? ?? '',
    departurePoradah: map['departurePoradah'] as String? ?? '',
    arrivalCourt: map['arrivalCourt'] as String? ?? '',
    offDay: map['offDay'] as String? ?? '',
    sourceUrl: map['sourceUrl'] as String? ?? '',
    verificationStatus:
        map['verificationStatus'] as String? ?? 'Partially Verified',
  );
}

class TransportSetting {
  final String distance; // "11.1 km"
  final String avgTransit; // "12-15 minutes"
  final String onlineTicket; // "eticket.railway.gov.bd"
  final String trackingInstruction; // "SMS: TR [Train Number] -> 16318"
  final String dhakaRoadDistance; // "118 km"
  final String primaryNode1; // "Mojampur Gate"
  final String primaryNode2; // "Chourahas Terminal"
  final String operators; // "New SB Super Deluxe; Shyamoli"

  TransportSetting({
    this.distance = '11.1 km',
    this.avgTransit = '12–15 minutes',
    this.onlineTicket = 'https://eticket.railway.gov.bd',
    this.trackingInstruction = 'SMS: TR [Train Number] → 16318',
    this.dhakaRoadDistance = '118 km',
    this.primaryNode1 = 'Mojampur Gate',
    this.primaryNode2 = 'Chourahas Terminal',
    this.operators = 'New SB Super Deluxe; Shyamoli',
  });

  Map<String, dynamic> toMap() => {
    'distance': distance,
    'avgTransit': avgTransit,
    'onlineTicket': onlineTicket,
    'trackingInstruction': trackingInstruction,
    'dhakaRoadDistance': dhakaRoadDistance,
    'primaryNode1': primaryNode1,
    'primaryNode2': primaryNode2,
    'operators': operators,
  };
}

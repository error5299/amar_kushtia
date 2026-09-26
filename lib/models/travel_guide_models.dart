library;

/// Data models for the "Travel Guide (ভ্রমণ গাইড)" feature in Amar Kushtia.
/// Strictly separates Local Bus (stops, sequence, fares, reverse direction)
/// and Long-Distance Bus (destinations, operators, counters, contacts).

// ==========================================
// 1. LOCAL BUS MODELS
// ==========================================

class RouteStop {
  final String id;
  final String nameBn;
  final String nameEn;
  final int sequence;
  final double? latitude;
  final double? longitude;
  final bool isActive;

  const RouteStop({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.sequence,
    this.latitude,
    this.longitude,
    this.isActive = true,
  });

  String getName(bool isBn) => isBn ? nameBn : nameEn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameBn': nameBn,
        'nameEn': nameEn,
        'sequence': sequence,
        'latitude': latitude,
        'longitude': longitude,
        'isActive': isActive,
      };

  factory RouteStop.fromMap(Map<String, dynamic> map) => RouteStop(
        id: map['id'] as String? ?? '',
        nameBn: map['nameBn'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
        sequence: (map['sequence'] as num?)?.toInt() ?? 0,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        isActive: map['isActive'] as bool? ?? true,
      );
}

class SegmentFare {
  final String fromStopId;
  final String toStopId;
  final double fare;
  final double? reverseFare;

  const SegmentFare({
    required this.fromStopId,
    required this.toStopId,
    required this.fare,
    this.reverseFare,
  });

  Map<String, dynamic> toMap() => {
        'fromStopId': fromStopId,
        'toStopId': toStopId,
        'fare': fare,
        'reverseFare': reverseFare,
      };

  factory SegmentFare.fromMap(Map<String, dynamic> map) => SegmentFare(
        fromStopId: map['fromStopId'] as String? ?? '',
        toStopId: map['toStopId'] as String? ?? '',
        fare: (map['fare'] as num?)?.toDouble() ?? 0.0,
        reverseFare: (map['reverseFare'] as num?)?.toDouble(),
      );
}

class LocalRoute {
  final String id;
  final String nameBn;
  final String nameEn;
  final String origin;
  final String destination;
  final List<RouteStop> stops;
  final List<SegmentFare> fares;
  final bool sameReverseFare;
  final bool isActive;
  final bool isPublished;
  final String? notes;

  const LocalRoute({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.origin,
    required this.destination,
    required this.stops,
    required this.fares,
    this.sameReverseFare = true,
    this.isActive = true,
    this.isPublished = true,
    this.notes,
  });

  String getTitle(bool isBn) => isBn ? nameBn : nameEn;

  /// Returns sorted list of stops according to sequence
  List<RouteStop> get sortedStops {
    final list = List<RouteStop>.from(stops);
    list.sort((a, b) => a.sequence.compareTo(b.sequence));
    return list;
  }

  /// Calculates fare between any two stops on this route
  double? calculateFare(String fromStopId, String toStopId) {
    if (fromStopId == toStopId) return 0.0;

    final sorted = sortedStops;
    final fromIdx = sorted.indexWhere((s) => s.id == fromStopId);
    final toIdx = sorted.indexWhere((s) => s.id == toStopId);

    if (fromIdx == -1 || toIdx == -1) return null;

    final isForward = fromIdx < toIdx;
    final startIdx = isForward ? fromIdx : toIdx;
    final endIdx = isForward ? toIdx : fromIdx;

    // 1. Direct pair check first
    for (final sf in fares) {
      if (isForward && sf.fromStopId == fromStopId && sf.toStopId == toStopId) {
        return sf.fare;
      }
      if (!isForward) {
        if (sf.fromStopId == fromStopId && sf.toStopId == toStopId && sf.reverseFare != null) {
          return sf.reverseFare;
        }
        if (sameReverseFare && sf.fromStopId == toStopId && sf.toStopId == fromStopId) {
          return sf.fare;
        }
      }
    }

    // 2. Cumulative consecutive segments sum
    double totalFare = 0.0;
    bool allSegmentsResolved = true;

    for (int i = startIdx; i < endIdx; i++) {
      final sFrom = sorted[i].id;
      final sTo = sorted[i + 1].id;

      double? segFare;
      for (final sf in fares) {
        if (sf.fromStopId == sFrom && sf.toStopId == sTo) {
          if (isForward) {
            segFare = sf.fare;
          } else {
            segFare = sameReverseFare ? sf.fare : (sf.reverseFare ?? sf.fare);
          }
          break;
        } else if (sf.fromStopId == sTo && sf.toStopId == sFrom && sameReverseFare) {
          segFare = sf.fare;
          break;
        }
      }

      if (segFare != null) {
        totalFare += segFare;
      } else {
        allSegmentsResolved = false;
        break;
      }
    }

    if (allSegmentsResolved && totalFare > 0) {
      return totalFare;
    }

    return null;
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameBn': nameBn,
        'nameEn': nameEn,
        'origin': origin,
        'destination': destination,
        'stops': stops.map((s) => s.toMap()).toList(),
        'fares': fares.map((f) => f.toMap()).toList(),
        'sameReverseFare': sameReverseFare,
        'isActive': isActive,
        'isPublished': isPublished,
        'notes': notes,
      };

  factory LocalRoute.fromMap(Map<String, dynamic> map) => LocalRoute(
        id: map['id'] as String? ?? '',
        nameBn: map['nameBn'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
        origin: map['origin'] as String? ?? '',
        destination: map['destination'] as String? ?? '',
        stops: (map['stops'] as List<dynamic>?)
                ?.map((s) => RouteStop.fromMap(Map<String, dynamic>.from(s as Map)))
                .toList() ??
            [],
        fares: (map['fares'] as List<dynamic>?)
                ?.map((f) => SegmentFare.fromMap(Map<String, dynamic>.from(f as Map)))
                .toList() ??
            [],
        sameReverseFare: map['sameReverseFare'] as bool? ?? true,
        isActive: map['isActive'] as bool? ?? true,
        isPublished: map['isPublished'] as bool? ?? true,
        notes: map['notes'] as String?,
      );
}

// ==========================================
// 2. LONG-DISTANCE BUS MODELS
// ==========================================

class TravelDestination {
  final String id;
  final String nameBn;
  final String nameEn;
  final String normalizedName;
  final String? division;
  final int sortOrder;
  final bool isActive;
  final bool isPublished;

  const TravelDestination({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    required this.normalizedName,
    this.division,
    this.sortOrder = 0,
    this.isActive = true,
    this.isPublished = true,
  });

  String getName(bool isBn) => isBn ? nameBn : nameEn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameBn': nameBn,
        'nameEn': nameEn,
        'normalizedName': normalizedName,
        'division': division,
        'sortOrder': sortOrder,
        'isActive': isActive,
        'isPublished': isPublished,
      };

  factory TravelDestination.fromMap(Map<String, dynamic> map) => TravelDestination(
        id: map['id'] as String? ?? '',
        nameBn: map['nameBn'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
        normalizedName: map['normalizedName'] as String? ?? '',
        division: map['division'] as String?,
        sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
        isActive: map['isActive'] as bool? ?? true,
        isPublished: map['isPublished'] as bool? ?? true,
      );
}

class BusCounter {
  final String id;
  final String operatorId;
  final String name;
  final String addressBn;
  final String addressEn;
  final String phonePrimary;
  final String? phoneSecondary;
  final double? latitude;
  final double? longitude;
  final String? mapUrl;
  final String? upazilaId;
  final bool isStartingPoint;
  final bool isActive;

  const BusCounter({
    required this.id,
    required this.operatorId,
    required this.name,
    required this.addressBn,
    required this.addressEn,
    required this.phonePrimary,
    this.phoneSecondary,
    this.latitude,
    this.longitude,
    this.mapUrl,
    this.upazilaId,
    this.isStartingPoint = false,
    this.isActive = true,
  });

  String getAddress(bool isBn) => isBn ? addressBn : addressEn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'operatorId': operatorId,
        'name': name,
        'addressBn': addressBn,
        'addressEn': addressEn,
        'phonePrimary': phonePrimary,
        'phoneSecondary': phoneSecondary,
        'latitude': latitude,
        'longitude': longitude,
        'mapUrl': mapUrl,
        'upazilaId': upazilaId,
        'isStartingPoint': isStartingPoint,
        'isActive': isActive,
      };

  factory BusCounter.fromMap(Map<String, dynamic> map) => BusCounter(
        id: map['id'] as String? ?? '',
        operatorId: map['operatorId'] as String? ?? '',
        name: map['name'] as String? ?? map['nameBn'] as String? ?? 'কাউন্টার',
        addressBn: map['addressBn'] as String? ?? map['address'] as String? ?? '',
        addressEn: map['addressEn'] as String? ?? '',
        phonePrimary: map['phonePrimary'] as String? ?? map['phone'] as String? ?? '',
        phoneSecondary: map['phoneSecondary'] as String?,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
        mapUrl: map['mapUrl'] as String? ?? map['googleMapsUrl'] as String? ?? map['directionsUrl'] as String?,
        upazilaId: map['upazilaId'] as String? ?? 'UPZ-002',
        isStartingPoint: map['isStartingPoint'] as bool? ?? (map['isStartingPoint']?.toString() == 'true'),
        isActive: map['isActive'] as bool? ?? true,
      );
}

class OperatorDestinationRoute {
  final String id;
  final String operatorId;
  final String destinationId;
  final String origin;
  final String direction; // 'bidirectional', 'kushtia_to_dest', 'dest_to_kushtia'
  final String serviceStatus; // 'Regular AC & Non-AC', 'Non-AC', 'AC Only'
  final String? startingCounterName;
  final String? counterId;
  final BusCounter? counter;
  final bool isActive;
  final bool isPublished;

  const OperatorDestinationRoute({
    required this.id,
    required this.operatorId,
    required this.destinationId,
    this.origin = 'কুষ্টিয়া',
    this.direction = 'bidirectional',
    this.serviceStatus = 'Regular',
    this.startingCounterName,
    this.counterId,
    this.counter,
    this.isActive = true,
    this.isPublished = true,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'operatorId': operatorId,
        'destinationId': destinationId,
        'origin': origin,
        'direction': direction,
        'serviceStatus': serviceStatus,
        'startingCounterName': startingCounterName,
        'counterId': counterId,
        'counter': counter?.toMap(),
        'isActive': isActive,
        'isPublished': isPublished,
      };

  factory OperatorDestinationRoute.fromMap(Map<String, dynamic> map) => OperatorDestinationRoute(
        id: map['id'] as String? ?? '',
        operatorId: map['operatorId'] as String? ?? '',
        destinationId: map['destinationId'] as String? ?? '',
        origin: map['origin'] as String? ?? 'কুষ্টিয়া',
        direction: map['direction'] as String? ?? 'bidirectional',
        serviceStatus: map['serviceStatus'] as String? ?? 'Regular',
        startingCounterName: map['startingCounterName'] as String?,
        counterId: map['counterId'] as String?,
        counter: map['counter'] != null
            ? BusCounter.fromMap(Map<String, dynamic>.from(map['counter'] as Map))
            : null,
        isActive: map['isActive'] as bool? ?? true,
        isPublished: map['isPublished'] as bool? ?? true,
      );
}

class BusOperator {
  final String id;
  final String nameBn;
  final String nameEn;
  final String? busType;
  final String? contactPrimary;
  final String? serviceStatus;
  final String? startingPoint;
  final String? logoUrl;
  final String? descriptionBn;
  final String? descriptionEn;
  final String? websiteUrl;
  final String? facebookUrl;
  final List<String> destinationIds;
  final List<BusCounter> counters;
  final bool isActive;
  final bool isPublished;

  const BusOperator({
    required this.id,
    required this.nameBn,
    required this.nameEn,
    this.busType,
    this.contactPrimary,
    this.serviceStatus,
    this.startingPoint,
    this.logoUrl,
    this.descriptionBn,
    this.descriptionEn,
    this.websiteUrl,
    this.facebookUrl,
    this.destinationIds = const [],
    this.counters = const [],
    this.isActive = true,
    this.isPublished = true,
  });

  String getName(bool isBn) => isBn ? nameBn : nameEn;
  String? getDescription(bool isBn) => isBn ? descriptionBn : descriptionEn;

  Map<String, dynamic> toMap() => {
        'id': id,
        'nameBn': nameBn,
        'nameEn': nameEn,
        'busType': busType,
        'contactPrimary': contactPrimary,
        'serviceStatus': serviceStatus,
        'startingPoint': startingPoint,
        'logoUrl': logoUrl,
        'descriptionBn': descriptionBn,
        'descriptionEn': descriptionEn,
        'websiteUrl': websiteUrl,
        'facebookUrl': facebookUrl,
        'destinationIds': destinationIds,
        'counters': counters.map((c) => c.toMap()).toList(),
        'isActive': isActive,
        'isPublished': isPublished,
      };

  factory BusOperator.fromMap(Map<String, dynamic> map) => BusOperator(
        id: map['id'] as String? ?? '',
        nameBn: map['nameBn'] as String? ?? '',
        nameEn: map['nameEn'] as String? ?? '',
        busType: map['busType'] as String?,
        contactPrimary: map['contactPrimary'] as String? ?? map['phonePrimary'] as String?,
        serviceStatus: map['serviceStatus'] as String? ?? 'নিয়মিত চলাচল (Regular)',
        startingPoint: map['startingPoint'] as String? ?? map['startingCounterName'] as String?,
        logoUrl: map['logoUrl'] as String?,
        descriptionBn: map['descriptionBn'] as String?,
        descriptionEn: map['descriptionEn'] as String?,
        websiteUrl: map['websiteUrl'] as String?,
        facebookUrl: map['facebookUrl'] as String?,
        destinationIds: (map['destinationIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        counters: (map['counters'] as List<dynamic>?)
                ?.map((c) => BusCounter.fromMap(Map<String, dynamic>.from(c as Map)))
                .toList() ??
            const [],
        isActive: map['isActive'] as bool? ?? true,
        isPublished: map['isPublished'] as bool? ?? true,
      );
}

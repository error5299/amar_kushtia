import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/seed_master_data.dart';
import '../models/education_tables.dart';
import '../models/healthcare_tables.dart';
import '../models/master_record.dart';
import '../models/national_hotline.dart';
import '../models/service_category.dart';
import '../models/transport_tables.dart';
import '../models/travel_guide_models.dart';
import '../models/upazila.dart';
import '../services/firebase_service.dart';

final recordsRepositoryProvider = Provider<RecordsRepository>((ref) {
  return RecordsRepository(FirebaseService.instance);
});

/// Riverpod stream provider for all active master records
final masterRecordsStreamProvider = StreamProvider<List<MasterRecord>>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  return repo.watchActiveRecords();
});

/// Riverpod stream provider for dynamic service categories / divisions
final categoriesStreamProvider = StreamProvider<List<ServiceCategory>>((ref) {
  final repo = ref.watch(recordsRepositoryProvider);
  return repo.watchCategories();
});

/// Riverpod provider for Upazilas
final upazilasProvider = Provider<List<Upazila>>((ref) {
  return SeedMasterData.upazilas;
});

/// Riverpod provider for Local Bus Routes (streams from Firestore merged with seed)
final localRoutesProvider = StreamProvider<List<LocalRoute>>((ref) async* {
  yield SeedMasterData.localRoutes;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('travel_local_routes')
        .snapshots()) {
      final firestoreMap = <String, LocalRoute>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = LocalRoute.fromMap(data);
      }
      final merged = <LocalRoute>[];
      final seen = <String>{};
      for (final item in SeedMasterData.localRoutes) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for Travel Destinations (streams from Firestore merged with seed)
final travelDestinationsProvider = StreamProvider<List<TravelDestination>>((ref) async* {
  yield SeedMasterData.travelDestinations;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('travel_destinations')
        .snapshots()) {
      final firestoreMap = <String, TravelDestination>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = TravelDestination.fromMap(data);
      }
      final merged = <TravelDestination>[];
      final seen = <String>{};
      for (final item in SeedMasterData.travelDestinations) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for Bus Operators (streams from Firestore merged with seed)
final busOperatorsProvider = StreamProvider<List<BusOperator>>((ref) async* {
  yield SeedMasterData.busOperators;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('travel_bus_operators')
        .snapshots()) {
      final firestoreMap = <String, BusOperator>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = BusOperator.fromMap(data);
      }
      final merged = <BusOperator>[];
      final seen = <String>{};
      for (final item in SeedMasterData.busOperators) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for Operator-Destination Routes (streams from Firestore merged with seed)
final operatorDestinationRoutesProvider =
    StreamProvider<List<OperatorDestinationRoute>>((ref) async* {
  yield SeedMasterData.operatorDestinationRoutes;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('travel_operator_destinations')
        .snapshots()) {
      final firestoreMap = <String, OperatorDestinationRoute>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = OperatorDestinationRoute.fromMap(data);
      }
      final merged = <OperatorDestinationRoute>[];
      final seen = <String>{};
      for (final item in SeedMasterData.operatorDestinationRoutes) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for National Hotlines — streams from Firestore merged with seed
final nationalHotlinesProvider = StreamProvider<List<NationalHotline>>((ref) async* {
  yield SeedMasterData.nationalHotlines;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('national_hotlines')
        .snapshots()) {
      final firestoreMap = <String, NationalHotline>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = NationalHotline.fromMap(data);
      }
      final merged = <NationalHotline>[];
      final seen = <String>{};
      for (final item in SeedMasterData.nationalHotlines) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for Bed Fees — streams from Firestore merged with seed
final bedFeesProvider = StreamProvider<List<BedFeeRecord>>((ref) async* {
  yield SeedMasterData.bedFees;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('healthcare_fees')
        .snapshots()) {
      final firestoreMap = <String, BedFeeRecord>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = BedFeeRecord.fromMap(data);
      }
      final merged = <BedFeeRecord>[];
      final seen = <String>{};
      for (final item in SeedMasterData.bedFees) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for Surgery Schedules — streams from Firestore merged with seed
final surgerySchedulesProvider = StreamProvider<List<SurgeryRecord>>((ref) async* {
  yield SeedMasterData.surgerySchedules;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('surgery_schedules')
        .snapshots()) {
      final firestoreMap = <String, SurgeryRecord>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = SurgeryRecord.fromMap(data);
      }
      final merged = <SurgeryRecord>[];
      final seen = <String>{};
      for (final item in SeedMasterData.surgerySchedules) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for Ambulance Models
final ambulanceModelsProvider = Provider<List<AmbulanceModel>>((ref) {
  return SeedMasterData.ambulanceModels;
});

/// Riverpod provider for Train Schedules — streams from Firestore merged with seed
final trainSchedulesProvider = StreamProvider<List<TrainRecord>>((ref) async* {
  yield SeedMasterData.trainSchedules;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('transport_schedules')
        .snapshots()) {
      final firestoreMap = <String, TrainRecord>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = TrainRecord.fromMap(data);
      }
      final merged = <TrainRecord>[];
      final seen = <String>{};
      for (final item in SeedMasterData.trainSchedules) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

/// Riverpod provider for IU Halls — streams from Firestore merged with seed
final iuHallsProvider = StreamProvider<List<IUHallRecord>>((ref) async* {
  yield SeedMasterData.iuHalls;
  if (FirebaseService.instance.isInitialized) {
    await for (final snap in FirebaseService.instance.firestore
        .collection('iu_halls')
        .snapshots()) {
      final firestoreMap = <String, IUHallRecord>{};
      final deletedIds = <String>{};
      for (final d in snap.docs) {
        final data = d.data();
        if (data['_deleted'] == true || data['isDeleted'] == true) {
          deletedIds.add(d.id);
          continue;
        }
        data['id'] = d.id;
        firestoreMap[d.id] = IUHallRecord.fromMap(data);
      }
      final merged = <IUHallRecord>[];
      final seen = <String>{};
      for (final item in SeedMasterData.iuHalls) {
        if (deletedIds.contains(item.id)) continue;
        if (firestoreMap.containsKey(item.id)) {
          merged.add(firestoreMap[item.id]!);
        } else {
          merged.add(item);
        }
        seen.add(item.id);
      }
      for (final entry in firestoreMap.entries) {
        if (!seen.contains(entry.key)) {
          merged.add(entry.value);
        }
      }
      yield merged;
    }
  }
});

class RecordsRepository {
  final FirebaseService _firebaseService;

  RecordsRepository(this._firebaseService);

  List<MasterRecord> _mergeWithSeed(List<MasterRecord> cloudRecords, {bool activeOnly = true}) {
    final Map<String, MasterRecord> map = {
      for (final r in SeedMasterData.masterRecords) r.id: r,
    };
    for (final r in cloudRecords) {
      map[r.id] = r;
    }
    final all = map.values.toList();
    if (activeOnly) {
      return all.where((r) => r.isActive).toList();
    }
    return all;
  }

  Future<List<MasterRecord>> _fetchRecordsFromRest() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/amar-kushtia-419ec/databases/(default)/documents/records?pageSize=300&t=$timestamp',
      );
      final response = await http.get(url, headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      }).timeout(const Duration(seconds: 7));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = data['documents'] as List<dynamic>? ?? [];
        return docs
            .map((d) => MasterRecord.fromFirestoreRest(d as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[RecordsRepository] REST records sync notice: $e');
    }
    return [];
  }

  Future<List<ServiceCategory>> _fetchCategoriesFromRest() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/amar-kushtia-419ec/databases/(default)/documents/categories?pageSize=100&t=$timestamp',
      );
      final response = await http.get(url, headers: {
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        'Pragma': 'no-cache',
      }).timeout(const Duration(seconds: 7));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final docs = data['documents'] as List<dynamic>? ?? [];
        return docs
            .map((d) => ServiceCategory.fromFirestoreRest(d as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('[RecordsRepository] REST categories sync notice: $e');
    }
    return [];
  }

  static List<ServiceCategory>? _inMemoryCategories;
  static List<MasterRecord>? _inMemoryActiveRecords;

  /// Streams dynamic service categories / divisions with persistent caching and in-memory optimization
  Stream<List<ServiceCategory>> watchCategories() async* {
    if (_inMemoryCategories != null && _inMemoryCategories!.isNotEmpty) {
      yield _inMemoryCategories!;
    } else {
      // 1. Initial canonical state merged with local cache
      final Map<String, ServiceCategory> categoryMap = {
        for (final c in SeedMasterData.defaultCategories) c.id: c,
      };

      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString('cached_service_categories_v2');
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final List<dynamic> list = jsonDecode(cachedJson);
          for (final item in list) {
            final c = ServiceCategory.fromMap(item as Map<String, dynamic>);
            categoryMap[c.id] = c;
          }
        }
      } catch (_) {}

      final initialList = categoryMap.values.where((c) => c.isActive).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      _inMemoryCategories = initialList;
      yield initialList;
    }

    // 2. Real-time updates via Firestore SDK (if initialized), or fallback to REST
    if (_firebaseService.isInitialized) {
      try {
        await for (final snapshot in _firebaseService.firestore
            .collection('categories')
            .snapshots()) {
          final Map<String, ServiceCategory> categoryMap = {
            for (final c in SeedMasterData.defaultCategories) c.id: c,
          };
          for (final doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            categoryMap[doc.id] = ServiceCategory.fromMap(data);
          }
          final sorted = categoryMap.values.where((c) => c.isActive).toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          _inMemoryCategories = sorted;
          yield sorted;

          // Save to local cache in background without blocking UI
          SharedPreferences.getInstance().then((prefs) {
            final rawList = categoryMap.values.map((c) => c.toMap()).toList();
            prefs.setString('cached_service_categories_v2', jsonEncode(rawList));
          }).catchError((_) {});
        }
      } catch (e) {
        debugPrint('[RecordsRepository] Firestore categories listener notice: $e');
      }
    } else {
      // Offline / fallback REST sync
      final restCats = await _fetchCategoriesFromRest();
      if (restCats.isNotEmpty) {
        final Map<String, ServiceCategory> categoryMap = {
          for (final c in SeedMasterData.defaultCategories) c.id: c,
        };
        for (final c in restCats) {
          categoryMap[c.id] = c;
        }
        final sorted = categoryMap.values.where((c) => c.isActive).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
        _inMemoryCategories = sorted;
        yield sorted;

        SharedPreferences.getInstance().then((prefs) {
          final rawList = categoryMap.values.map((c) => c.toMap()).toList();
          prefs.setString('cached_service_categories_v2', jsonEncode(rawList));
        }).catchError((_) {});
      }
    }
  }

  /// Streams active (published) master records with persistent cache and zero-jank in-memory state
  Stream<List<MasterRecord>> watchActiveRecords() async* {
    if (_inMemoryActiveRecords != null && _inMemoryActiveRecords!.isNotEmpty) {
      yield _inMemoryActiveRecords!;
    } else {
      // 1. Initial instant local state from memory & disk cache
      List<MasterRecord> current = _mergeWithSeed([], activeOnly: true);

      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedJson = prefs.getString('cached_master_records_v2');
        if (cachedJson != null && cachedJson.isNotEmpty) {
          final List<dynamic> list = jsonDecode(cachedJson);
          final diskRecords = list.map((item) => MasterRecord.fromMap(item as Map<String, dynamic>)).toList();
          current = _mergeWithSeed(diskRecords, activeOnly: true);
        }
      } catch (_) {}

      _inMemoryActiveRecords = current;
      yield current;
    }

    // 2. Real-time updates via Firestore SDK (if initialized), or fallback to REST
    if (_firebaseService.isInitialized) {
      try {
        await for (final snapshot in _firebaseService.firestore
            .collection('records')
            .snapshots()) {
          final cloudRecords = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return MasterRecord.fromMap(data);
          }).toList();
          final updated = _mergeWithSeed(cloudRecords, activeOnly: true);
          _inMemoryActiveRecords = updated;
          yield updated;

          SharedPreferences.getInstance().then((prefs) {
            final rawList = updated.map((r) => r.toMap()).toList();
            prefs.setString('cached_master_records_v2', jsonEncode(rawList));
          }).catchError((_) {});
        }
      } catch (e) {
        debugPrint('[RecordsRepository] Firestore snapshot listener note: $e');
      }
    } else {
      // Offline / fallback REST sync
      final restRecords = await _fetchRecordsFromRest();
      if (restRecords.isNotEmpty) {
        final updated = _mergeWithSeed(restRecords, activeOnly: true);
        _inMemoryActiveRecords = updated;
        yield updated;

        SharedPreferences.getInstance().then((prefs) {
          final rawList = updated.map((r) => r.toMap()).toList();
          prefs.setString('cached_master_records_v2', jsonEncode(rawList));
        }).catchError((_) {});
      }
    }
  }

  /// Streams ALL records for the Admin panel (both active and draft)
  Stream<List<MasterRecord>> watchAllRecordsForAdmin() async* {
    List<MasterRecord> current = _mergeWithSeed([], activeOnly: false);
    yield current;

    final restRecords = await _fetchRecordsFromRest();
    if (restRecords.isNotEmpty) {
      current = _mergeWithSeed(restRecords, activeOnly: false);
      yield current;
    }

    if (_firebaseService.isInitialized) {
      try {
        await for (final snapshot in _firebaseService.firestore
            .collection('records')
            .snapshots()) {
          final cloudRecords =
              snapshot.docs.map((doc) => MasterRecord.fromMap(doc.data())).toList();
          current = _mergeWithSeed(cloudRecords, activeOnly: false);
          yield current;
        }
      } catch (e) {
        debugPrint('[RecordsRepository] Admin snapshot listener note: $e');
      }
    }
  }

  /// Get records filtered by category
  List<MasterRecord> filterByCategory(List<MasterRecord> all, String categoryId) {
    if (categoryId.isEmpty || categoryId == 'all') return all;
    return all.where((r) => r.categoryId.toLowerCase() == categoryId.toLowerCase()).toList();
  }

  /// Get records filtered by upazila
  List<MasterRecord> filterByUpazila(List<MasterRecord> all, String upazilaId) {
    if (upazilaId.isEmpty || upazilaId == 'all') return all;
    return all.where((r) => r.upazilaId == upazilaId).toList();
  }

  /// Normalizes Bengali text to handle Unicode variations and common alternate spellings
  static String _normalizeText(String text) {
    return text
        .toLowerCase()
        .replaceAll('\u200C', '') // Zero Width Non-Joiner
        .replaceAll('\u200D', '') // Zero Width Joiner
        .replaceAll('য়', 'য়')     // Canonical Bengali ya
        .replaceAll('ৎ', 'ত')     // Khanda Ta to Ta for matching
        .replaceAll('ঢ়', 'ড়')     // Rha to Rra
        .trim();
  }

  /// Bidirectional semantic dictionary mapping Bangla <-> English categories, keywords, and upazilas
  static final Map<String, List<String>> _synonymMap = {
    // Healthcare
    'হাসপাতাল': ['hospital', 'clinic', 'healthcare', 'medical', 'doctor', 'স্বাস্থ্য', 'বেড', 'কেবিন'],
    'hospital': ['হাসপাতাল', 'স্বাস্থ্য', 'ক্লিনিক', 'ডাক্তার', 'medical', 'clinic'],
    'ডাক্তার': ['doctor', 'surgeon', 'physician', 'চিকিৎসক'],
    'doctor': ['ডাক্তার', 'চিকিৎসক', 'সার্জন', 'surgeon'],
    'ক্লিনিক': ['clinic', 'hospital', 'diagnostic'],
    'clinic': ['ক্লিনিক', 'হাসপাতাল', 'ডায়াগনস্টিক'],
    'অ্যাম্বুলেন্স': ['ambulance', 'জরুরি', 'ভাড়া'],
    'ambulance': ['অ্যাম্বুলেন্স', 'রোগীবাহী', 'জরুরি'],

    // Police & Law
    'থানা': ['police', 'thana', 'ফাঁড়ি', 'পুলিশ'],
    'পুলিশ': ['police', 'thana', 'আইনশৃঙ্খলা', 'কন্ট্রোল'],
    'police': ['পুলিশ', 'থানা', 'ফাঁড়ি', 'সার্কেল', 'এসপি', 'sp', 'oc'],
    'thana': ['থানা', 'পুলিশ', 'police'],

    // Fire & Rescue
    'ফায়ার': ['fire', 'দমকল', 'অগ্নি', 'রেসকিউ', 'rescue'],
    'fire': ['ফায়ার', 'দমকল', 'অগ্নি নির্বাপক', 'rescue'],

    // Transport
    'ট্রেন': ['train', 'railway', 'রেলওয়ে', 'স্টেশন', 'আন্তঃনগর', 'টিকিট'],
    'train': ['ট্রেন', 'রেল', 'স্টেশন', 'railway', 'ticket'],
    'বাস': ['bus', 'পরিবহন', 'টার্মিনাল', 'কাউন্টার'],
    'bus': ['বাস', 'পরিবহন', 'coach'],
    'পরিবহন': ['transport', 'bus', 'train', 'যোগাযোগ'],
    'transport': ['পরিবহন', 'বাস', 'ট্রেন', 'টিকেট', 'ticket'],

    // Tourism & Heritage
    'শিলাইদহ': ['shilaidaha', 'kuthibari', 'রবীন্দ্রনাথ', 'tagore', 'কুঠিবাড়ি'],
    'shilaidaha': ['শিলাইদহ', 'কুঠিবাড়ি', 'kuthibari', 'tagore', 'রবীন্দ্রনাথ'],
    'লালন': ['lalon', 'মাজার', 'আখড়া', 'shah', 'বাউল'],
    'lalon': ['লালন', 'মাজার', 'fakir', 'আখড়া'],
    'হরিনাথ': ['harinath', 'কাঙাল', 'kangal', 'প্রেস'],
    'kangal': ['কাঙাল', 'হরিনাথ', 'প্রেস', 'harinath'],
    'মীর মশাররফ': ['mir mosharraf', 'সাহিত্যিক', 'লাহিনীপাড়া'],
    'হোটেল': ['hotel', 'resort', 'আবাসিক', 'tourism', 'পর্যটন'],
    'hotel': ['হোটেল', 'আবাসিক', 'resort', 'পর্যটন'],
    'পর্যটন': ['tourism', 'tourist', 'দর্শনীয়', 'হেরিটেজ', 'heritage'],
    'tourism': ['পর্যটন', 'দর্শনীয়', 'হেরিটেজ', 'স্থান'],

    // Upazilas
    'কুষ্টিয়া': ['kushtia', 'সদর', 'sadar'],
    'kushtia': ['কুষ্টিয়া', 'সদর', 'sadar'],
    'কুমারখালী': ['kumarkhali', 'শিলাইদহ'],
    'kumarkhali': ['কুমারখালী'],
    'খোকসা': ['khoksha'],
    'khoksha': ['খোকসা'],
    'ভেড়ামারা': ['bheramara', 'হার্ডিঞ্জ', 'hardinge', 'লালন শাহ সেতু'],
    'bheramara': ['ভেড়ামারা', 'ভেড়ামারা', 'hardinge'],
    'দৌলতপুর': ['daulatpur'],
    'daulatpur': ['দৌলতপুর'],
    'মিরপুর': ['mirpur', 'পোড়াদহ', 'poradaha'],
    'mirpur': ['মিরপুর', 'পোড়াদহ', 'poradaha'],

    // Education
    'শিক্ষা': ['education', 'school', 'college', 'বিশ্ববিদ্যালয়', 'university'],
    'education': ['শিক্ষা', 'স্কুল', 'কলেজ', 'বিশ্ববিদ্যালয়'],
    'স্কুল': ['school', 'বিদ্যালয়'],
    'school': ['স্কুল', 'বিদ্যালয়'],
    'কলেজ': ['college', 'মহাবিদ্যালয়'],
    'college': ['কলেজ', 'মহাবিদ্যালয়'],
    'বিশ্ববিদ্যালয়': ['university', 'ভার্সিটি', 'ইবি'],
    'university': ['বিশ্ববিদ্যালয়', 'university', 'iu'],

    // Administration
    'সরকারি': ['government', 'gov', 'অফিস', 'ডিসি', 'ইউএনও'],
    'government': ['সরকারি', 'অফিস', 'dc', 'uno', 'মন্ত্রণালয়'],
    'জরুরি': ['emergency', 'হটলাইন', 'hotline', 'সাহায্য', 'help'],
    'emergency': ['জরুরি', 'হটলাইন', 'সাহায্য', 'hotline'],

    // Food & Craft
    'খাজা': ['khaja', 'তিলের খাজা', 'মিষ্টি', 'food'],
    'khaja': ['খাজা', 'তিলের খাজা', 'sweets'],
    'তাঁত': ['tat', 'loom', 'কুটির শিল্প', 'craft', 'weaving'],
    'craft': ['তাঁত', 'হস্তশিল্প', 'weaving', 'কুটির শিল্প'],
  };

  /// Search records across Bangla, English, and transliterated queries with semantic matching
  List<MasterRecord> searchRecords(List<MasterRecord> all, String query) {
    final rawQuery = query.trim();
    if (rawQuery.isEmpty) return all;

    final normalizedQuery = _normalizeText(rawQuery);
    final tokens = normalizedQuery.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();

    // Expand search terms with synonyms and translations
    final Set<String> searchTerms = {normalizedQuery, ...tokens};
    for (final token in tokens) {
      if (_synonymMap.containsKey(token)) {
        searchTerms.addAll(_synonymMap[token]!.map(_normalizeText));
      }
      // Check partial synonym key matches
      _synonymMap.forEach((key, synonyms) {
        if (key.contains(token) || token.contains(key)) {
          searchTerms.addAll(synonyms.map(_normalizeText));
        }
      });
    }

    return all.where((record) {
      final nameBn = _normalizeText(record.nameBn);
      final nameEn = _normalizeText(record.nameEn ?? '');
      final cat = _normalizeText(record.categoryId);
      final subcat = _normalizeText(record.subcategoryId ?? '');
      final shortBn = _normalizeText(record.shortDescriptionBn ?? '');
      final shortEn = _normalizeText(record.shortDescriptionEn ?? '');
      final descBn = _normalizeText(record.descriptionBn ?? '');
      final descEn = _normalizeText(record.descriptionEn ?? '');
      final addressBn = _normalizeText(record.addressBn ?? '');
      final addressEn = _normalizeText(record.addressEn ?? '');
      final upazila = _normalizeText(record.upazilaId ?? '');
      final phone = record.phonePrimary?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
      final keywordsBn = record.searchKeywordsBn.map(_normalizeText).toList();
      final keywordsEn = record.searchKeywordsEn.map(_normalizeText).toList();

      // Combined searchable corpus for this record
      final recordText = '$nameBn $nameEn $cat $subcat $shortBn $shortEn $descBn $descEn $addressBn $addressEn $upazila ${keywordsBn.join(" ")} ${keywordsEn.join(" ")}';

      // 1. Direct match with any expanded search term
      for (final term in searchTerms) {
        if (recordText.contains(term)) {
          return true;
        }
      }

      // 2. Phone number match
      final queryDigits = rawQuery.replaceAll(RegExp(r'[^0-9]'), '');
      if (queryDigits.isNotEmpty && queryDigits.length >= 3 && phone.contains(queryDigits)) {
        return true;
      }

      // 3. Multi-token match: all original tokens present somewhere in the record
      if (tokens.length > 1) {
        final allTokensMatch = tokens.every((token) {
          if (recordText.contains(token)) return true;
          // Check if any synonym of this token matches
          if (_synonymMap.containsKey(token)) {
            return _synonymMap[token]!.any((syn) => recordText.contains(_normalizeText(syn)));
          }
          return false;
        });
        if (allTokensMatch) return true;
      }

      return false;
    }).toList();
  }

  /// Save or update a record
  Future<void> saveRecord(MasterRecord record) async {
    await _firebaseService.saveMasterRecord(record);
  }

  /// Delete a record
  Future<void> deleteRecord(String recordId) async {
    await _firebaseService.deleteMasterRecord(recordId);
  }
}

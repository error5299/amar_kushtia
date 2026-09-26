import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/seed_master_data.dart';
import '../firebase_options.dart';
import '../models/master_record.dart';

/// FirebaseService manages Firebase initializations, Firestore offline persistence,
/// and automated canonical data seeding.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  FirebaseFirestore get firestore => _firestore ?? FirebaseFirestore.instance;
  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ).timeout(
        const Duration(milliseconds: 2500),
        onTimeout: () {
          throw Exception('Firebase initialization timed out. Proceeding in offline mode.');
        },
      );
      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;

      if (!kIsWeb) {
        // Enable offline persistence on mobile/desktop platforms
        _firestore!.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }

      _isInitialized = true;
      debugPrint('[FirebaseService] Firebase initialized successfully.');
    } catch (e) {

      debugPrint('[FirebaseService] Note: Firebase initialization skipped or using local fallback: $e');
      _isInitialized = false;
    }
  }

  /// Seeds all 80 master records and relational tables if the Firestore 'records' collection is empty.
  Future<void> seedDatabaseIfEmpty() async {
    if (!_isInitialized || _firestore == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('db_seeded_flag_v1') == true) {
        return; // Fast path: already verified, zero network calls on launch!
      }

      final snapshot = await _firestore!.collection('records').limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint('[FirebaseService] Database already contains records. Skipping initial seeding.');
        await prefs.setBool('db_seeded_flag_v1', true);
        return;
      }

      debugPrint('[FirebaseService] Seeding canonical Master Data v2.0 to Firestore...');
      final batch = _firestore!.batch();

      // Seed 80 Master Records
      for (final record in SeedMasterData.masterRecords) {
        final docRef = _firestore!.collection('records').doc(record.id);
        batch.set(docRef, record.toMap());
      }

      // Seed Upazilas
      for (final upz in SeedMasterData.upazilas) {
        final docRef = _firestore!.collection('upazilas').doc(upz.id);
        batch.set(docRef, upz.toMap());
      }

      // Seed Bed Fees
      for (final fee in SeedMasterData.bedFees) {
        final docRef = _firestore!.collection('healthcare_fees').doc(fee.id);
        batch.set(docRef, fee.toMap());
      }

      // Seed Surgeries
      for (final sur in SeedMasterData.surgerySchedules) {
        final docRef = _firestore!.collection('surgery_schedules').doc(sur.id);
        batch.set(docRef, sur.toMap());
      }

      // Seed Trains
      for (final train in SeedMasterData.trainSchedules) {
        final docRef = _firestore!.collection('transport_schedules').doc(train.id);
        batch.set(docRef, train.toMap());
      }

      // Seed IU Halls
      for (final hall in SeedMasterData.iuHalls) {
        final docRef = _firestore!.collection('iu_halls').doc(hall.id);
        batch.set(docRef, hall.toMap());
      }

      // Seed Hotlines
      for (final hl in SeedMasterData.nationalHotlines) {
        final docRef = _firestore!.collection('national_hotlines').doc(hl.id);
        batch.set(docRef, hl.toMap());
      }

      await batch.commit();
      await prefs.setBool('db_seeded_flag_v1', true);
      debugPrint('[FirebaseService] All canonical records seeded successfully to Firestore.');
    } catch (e) {
      debugPrint('[FirebaseService] Error during seeding: $e');
    }
  }

  /// Save or update a single master record (Admin function)
  Future<void> saveMasterRecord(MasterRecord record) async {
    if (!_isInitialized || _firestore == null) return;
    await _firestore!.collection('records').doc(record.id).set(
          record.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Delete or unpublish a master record
  Future<void> deleteMasterRecord(String recordId) async {
    if (!_isInitialized || _firestore == null) return;
    await _firestore!.collection('records').doc(recordId).delete();
  }
}

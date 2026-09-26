import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_service.dart';

/// StreamProvider tracking Firebase Authentication state changes in real time
final authStateProvider = StreamProvider<User?>((ref) {
  return AuthService.instance.authStateChanges;
});

/// FutureProvider that checks if the logged-in user has admin privileges.
/// Verified against Firestore 'admins' collection or 'users' doc with role == 'admin'.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  if (authUser == null) return false;

  try {
    final firestore = FirebaseFirestore.instance;

    // 1. Check 'admins' collection by UID or Email
    final uidDoc = await firestore.collection('admins').doc(authUser.uid).get();
    if (uidDoc.exists) return true;

    if (authUser.email != null && authUser.email!.isNotEmpty) {
      final emailDoc = await firestore
          .collection('admins')
          .doc(authUser.email!.toLowerCase().trim())
          .get();
      if (emailDoc.exists) return true;
    }

    // 2. Check 'users' collection for role == 'admin'
    final userDoc = await firestore.collection('users').doc(authUser.uid).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      if (data != null && data['role'] == 'admin') {
        return true;
      }
    }
  } catch (_) {
    // If offline or permission check fails, deny admin access
    return false;
  }

  return false;
});


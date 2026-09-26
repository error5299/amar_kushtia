import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(FirebaseService.instance);
});

final authStateProvider = StreamProvider<User?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

class AuthRepository {
  final FirebaseService _firebaseService;

  AuthRepository(this._firebaseService);

  Stream<User?> get authStateChanges {
    if (!_firebaseService.isInitialized) {
      return Stream.value(null);
    }
    return _firebaseService.auth.authStateChanges();
  }

  User? get currentUser {
    if (!_firebaseService.isInitialized) return null;
    return _firebaseService.auth.currentUser;
  }

  bool get isAdminLoggedIn => currentUser != null;

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    if (!_firebaseService.isInitialized) {
      throw Exception('Firebase is not initialized. Please configure Firebase credentials.');
    }
    return await _firebaseService.auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> signOut() async {
    if (!_firebaseService.isInitialized) return;
    await _firebaseService.auth.signOut();
  }
}

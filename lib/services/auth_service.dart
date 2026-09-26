import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Perform Google Sign-In on both Web & Mobile (Android/iOS)
  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        final userCredential = await _auth.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          _syncUserToFirestore(userCredential.user!);
        }
        return userCredential;
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          // User cancelled
          return null;
        }

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          _syncUserToFirestore(userCredential.user!);
        }
        return userCredential;
      }
    } catch (e) {
      debugPrint('[AuthService] Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Silently sync or update user information in Firestore 'users' collection
  Future<void> _syncUserToFirestore(User user) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final doc = await docRef.get();
      final now = FieldValue.serverTimestamp();

      final data = <String, dynamic>{
        'uid': user.uid,
        'email': user.email ?? '',
        'displayName': user.displayName ?? (user.email != null ? user.email!.split('@')[0] : 'Kushtia Citizen'),
        'photoURL': user.photoURL ?? '',
        'phoneNumber': user.phoneNumber ?? '',
        'lastLoginAt': now,
        'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      };

      if (!doc.exists) {
        data['createdAt'] = now;
        data['role'] = 'citizen';
      }

      await docRef.set(data, SetOptions(merge: true));
      debugPrint('[AuthService] Synced user ${user.uid} (${user.email}) to Firestore users collection.');
    } catch (err) {
      debugPrint('[AuthService] Note: Failed to sync user to Firestore: $err');
    }
  }

  /// Sign out from both Firebase and GoogleSignIn client
  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      debugPrint('[AuthService] Sign Out Error: $e');
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await user.delete();
    }
  }
}

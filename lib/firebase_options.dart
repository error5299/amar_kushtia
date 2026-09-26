// File generated for Amar Kushtia Firebase configuration.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBu0wkC-2XDL2x1ysoWS9otqE4cViOWtrU',
    appId: '1:873618382819:web:04cc5a7d519cfcc9474ad6',
    messagingSenderId: '873618382819',
    projectId: 'amar-kushtia-419ec',
    authDomain: 'amar-kushtia-419ec.firebaseapp.com',
    storageBucket: 'amar-kushtia-419ec.firebasestorage.app',
    measurementId: 'G-5CP3WH5BDB',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAM9NErSU1yXd-CzyXRqbLYQdpEcvQq3NA',
    appId: '1:873618382819:android:68b77ca055c1479e474ad6',
    messagingSenderId: '873618382819',
    projectId: 'amar-kushtia-419ec',
    storageBucket: 'amar-kushtia-419ec.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBu0wkC-2XDL2x1ysoWS9otqE4cViOWtrU',
    appId: '1:873618382819:ios:04cc5a7d519cfcc9474ad6',
    messagingSenderId: '873618382819',
    projectId: 'amar-kushtia-419ec',
    storageBucket: 'amar-kushtia-419ec.firebasestorage.app',
  );
}

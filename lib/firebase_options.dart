import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBK0a_4wYDCiD44x4ZnmD72JewPY-P5Dnk',
    appId: '1:813646770042:web:f501b3b1a16bcb179fb0c3',
    messagingSenderId: '813646770042',
    projectId: 'fapbuilder-a27a8',
    authDomain: 'fapbuilder-a27a8.firebaseapp.com',
    storageBucket: 'fapbuilder-a27a8.firebasestorage.app',
    measurementId: 'G-MBK3TZTJJF',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBK0a_4wYDCiD44x4ZnmD72JewPY-P5Dnk',
    appId: '1:813646770042:android:mock_id', // Web ID fallback if testing native
    messagingSenderId: '813646770042',
    projectId: 'fapbuilder-a27a8',
    storageBucket: 'fapbuilder-a27a8.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBK0a_4wYDCiD44x4ZnmD72JewPY-P5Dnk',
    appId: '1:813646770042:ios:mock_id', // Web ID fallback
    messagingSenderId: '813646770042',
    projectId: 'fapbuilder-a27a8',
    storageBucket: 'fapbuilder-a27a8.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBK0a_4wYDCiD44x4ZnmD72JewPY-P5Dnk',
    appId: '1:813646770042:ios:mock_id', // Web ID fallback
    messagingSenderId: '813646770042',
    projectId: 'fapbuilder-a27a8',
    storageBucket: 'fapbuilder-a27a8.firebasestorage.app',
    iosBundleId: 'com.example.app',
  );
}

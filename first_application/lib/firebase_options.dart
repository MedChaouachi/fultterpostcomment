// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyB2Q4nceNr0by_KrmECXyyz78DebS_vNBg',
    appId: '1:1972486594:web:2ad3d1c0f68c71eaa0565b',
    messagingSenderId: '1972486594',
    projectId: 'postcommentteam',
    authDomain: 'postcommentteam.firebaseapp.com',
    storageBucket: 'postcommentteam.appspot.com',
    measurementId: 'G-L1QJ2HMQTN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD_cV0tWco7LI6jEhsVvnya3ejxSv3vH8E',
    appId: '1:1972486594:android:c3147202810ef0d2a0565b',
    messagingSenderId: '1972486594',
    projectId: 'postcommentteam',
    storageBucket: 'postcommentteam.appspot.com',
  );
}

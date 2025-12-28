// File generated manually from google-services.json
// This file provides Firebase configuration for the app

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

  // TODO: Lấy Web App ID từ Firebase Console
  // Vào Firebase Console > Project Settings > Your apps > Web app
  // Copy appId (có dạng: 1:595631319099:web:xxxxx)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA1d1tk-pIaibVVZ97XgImmsEkjsXwrKXs',
    appId: '1:595631319099:web:ffc6f6b025e6634733941e',
    messagingSenderId: '595631319099',
    projectId: 'sarah-learn-english',
    authDomain: 'sarah-learn-english.firebaseapp.com',
    storageBucket: 'sarah-learn-english.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA1d1tk-pIaibVVZ97XgImmsEkjsXwrKXs',
    appId: '1:595631319099:android:09e616c17e0b5d7433941e',
    messagingSenderId: '595631319099',
    projectId: 'sarah-learn-english',
    storageBucket: 'sarah-learn-english.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForIOS',
    appId: '1:595631319099:ios:dummy',
    messagingSenderId: '595631319099',
    projectId: 'sarah-learn-english',
    storageBucket: 'sarah-learn-english.firebasestorage.app',
    iosBundleId: 'com.learnenglish.withsarah.sarahLearnEnglish',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDummyKeyForMacOS',
    appId: '1:595631319099:ios:dummy',
    messagingSenderId: '595631319099',
    projectId: 'sarah-learn-english',
    storageBucket: 'sarah-learn-english.firebasestorage.app',
    iosBundleId: 'com.learnenglish.withsarah.sarahLearnEnglish',
  );
}


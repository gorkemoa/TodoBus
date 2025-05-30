// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
    apiKey: 'AIzaSyBddvSdsypHnkXD29UYw6Mp7z-COleQNAA',
    appId: '1:812571563857:web:e3b529504f4c117405a570',
    messagingSenderId: '812571563857',
    projectId: 'todobus-3fc9b',
    authDomain: 'todobus-3fc9b.firebaseapp.com',
    storageBucket: 'todobus-3fc9b.firebasestorage.app',
    measurementId: 'G-FXZ605WF2V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBHhKuIMgjCPYD37scHvbPZWKT-ayAJr8w',
    appId: '1:812571563857:android:64967c9b7dcc45fc05a570',
    messagingSenderId: '812571563857',
    projectId: 'todobus-3fc9b',
    storageBucket: 'todobus-3fc9b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDi1-znh1cRBGU677rpqNOWWd672hsWdD8',
    appId: '1:812571563857:ios:b1dc616fc624b00a05a570',
    messagingSenderId: '812571563857',
    projectId: 'todobus-3fc9b',
    storageBucket: 'todobus-3fc9b.firebasestorage.app',
    iosBundleId: 'com.rivorya.todobus',
  );
}

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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyCQIDddC0R_iinIsT-eoM2Ol-btJWaMZQA',
    appId: '1:705181133142:web:b7a6fcbac4e2f2e56ccef7',
    messagingSenderId: '705181133142',
    projectId: 'proj2-2971f',
    authDomain: 'proj2-2971f.firebaseapp.com',
    storageBucket: 'proj2-2971f.firebasestorage.app',
    measurementId: 'G-0F205HDCCL',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9JThZSN7GhaOKaJS7ZXqOeZL1Du351f4',
    appId: '1:705181133142:android:e4e72efa47a6434d6ccef7',
    messagingSenderId: '705181133142',
    projectId: 'proj2-2971f',
    storageBucket: 'proj2-2971f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA2r2YK9keyAB2eMxUf1fathb0IplRR_0g',
    appId: '1:705181133142:ios:5be9fff3b10997d46ccef7',
    messagingSenderId: '705181133142',
    projectId: 'proj2-2971f',
    storageBucket: 'proj2-2971f.firebasestorage.app',
    iosBundleId: 'com.example.proj1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA2r2YK9keyAB2eMxUf1fathb0IplRR_0g',
    appId: '1:705181133142:ios:5be9fff3b10997d46ccef7',
    messagingSenderId: '705181133142',
    projectId: 'proj2-2971f',
    storageBucket: 'proj2-2971f.firebasestorage.app',
    iosBundleId: 'com.example.proj1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCQIDddC0R_iinIsT-eoM2Ol-btJWaMZQA',
    appId: '1:705181133142:web:505f6d509e85ed816ccef7',
    messagingSenderId: '705181133142',
    projectId: 'proj2-2971f',
    authDomain: 'proj2-2971f.firebaseapp.com',
    storageBucket: 'proj2-2971f.firebasestorage.app',
    measurementId: 'G-DH36G46CPP',
  );
}

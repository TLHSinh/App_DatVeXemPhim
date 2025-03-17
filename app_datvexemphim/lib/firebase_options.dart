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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCGuFW1_hxxsID-jXmsvuwE7EvQrWT4Z8U',
    appId: '1:557818924060:android:f7c5bae06f342c4604a3d9',
    messagingSenderId: '557818924060',
    projectId: 'app-datvexemphim',
    storageBucket: 'app-datvexemphim.firebasestorage.app',
    // apiKey: "AIzaSyA6VZwLnAp9RAvYyMculf1kqW05FD6pHJI",
    // appId: "1:35934640622:android:fcd12bf46bebf4141d56ff",
    // messagingSenderId: "35934640622",
    // projectId: "fir-15597",
    // storageBucket: "fir-15597.appspot.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBgA61P5iGC_zWVstiI0E6uaZLkVDJ0bTU',
    appId: '1:557818924060:ios:587a779001609ce804a3d9',
    messagingSenderId: '557818924060',
    projectId: 'app-datvexemphim',
    storageBucket: 'app-datvexemphim.firebasestorage.app',
    iosBundleId: 'com.example.appDatvexemphim',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDAXKi8D-dk66QSO73rccUUzUpXBgyT8bY',
    appId: '1:557818924060:web:a3d59bf0fea5a30f04a3d9',
    messagingSenderId: '557818924060',
    projectId: 'app-datvexemphim',
    authDomain: 'app-datvexemphim.firebaseapp.com',
    storageBucket: 'app-datvexemphim.firebasestorage.app',
    measurementId: 'G-QNQVGH161G',
    // apiKey: "AIzaSyCWSVsnl9Vh-fsf2RjG2rioZjBw-M4X38s",
    // appId: "1:35934640622:web:3b69657a3e63b4f01d56ff",
    // messagingSenderId: "35934640622",
    // projectId: "fir-15597",
    // storageBucket: "fir-15597.appspot.com",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBgA61P5iGC_zWVstiI0E6uaZLkVDJ0bTU',
    appId: '1:557818924060:ios:587a779001609ce804a3d9',
    messagingSenderId: '557818924060',
    projectId: 'app-datvexemphim',
    storageBucket: 'app-datvexemphim.firebasestorage.app',
    iosBundleId: 'com.example.appDatvexemphim',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDAXKi8D-dk66QSO73rccUUzUpXBgyT8bY',
    appId: '1:557818924060:web:177d42a9068381f004a3d9',
    messagingSenderId: '557818924060',
    projectId: 'app-datvexemphim',
    authDomain: 'app-datvexemphim.firebaseapp.com',
    storageBucket: 'app-datvexemphim.firebasestorage.app',
    measurementId: 'G-RB6G1R7ECJ',
  );
}

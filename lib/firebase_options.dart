// Generated from `android/app/google-services.json` and
// `ios/Runner/GoogleService-Info.plist`. If the Firebase project changes, run:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
// or update this file to match the new config files.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with `Firebase.initializeApp`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAIL6Ha3THBqnKrGcyb3UA21xa4aED9U-I',
    appId: '1:566752074529:android:8af408ee8e697288757c60',
    messagingSenderId: '566752074529',
    projectId: 'buoy-e145c',
    storageBucket: 'buoy-e145c.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBbokvUecLzsja7fO-PEyS7jABD7AvLs90',
    appId: '1:566752074529:ios:719ace21f0fa8671757c60',
    messagingSenderId: '566752074529',
    projectId: 'buoy-e145c',
    storageBucket: 'buoy-e145c.firebasestorage.app',
    iosBundleId: 'com.drifterbuoy.app',
  );
}

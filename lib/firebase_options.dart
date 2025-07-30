import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA_bKbDAQyipRkHmt7tuiSi2NgZ0DrJZ0Y',
    appId: '1:238571619654:android:f1ab8d0ed7da2e701a9147',
    messagingSenderId: '238571619654',
    projectId: 'eventmanager-mkx',
    storageBucket: 'eventmanager-mkx.firebasestorage.app',
  );
}

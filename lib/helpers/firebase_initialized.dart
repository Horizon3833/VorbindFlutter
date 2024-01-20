import 'package:firebase_core/firebase_core.dart';
import 'package:vorbind/firebase_options.dart';

class FirebaseInitialized {
  bool _connected = false;
  bool _initialized = false;

  bool get connected => _connected;
  bool get initialized => _initialized;

  set connected(bool value) {
    _connected = value;
  }

  Future<void> initializeFirebase() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
    _initialized = true;
  }

  static final FirebaseInitialized _instance = FirebaseInitialized._internal();

  factory FirebaseInitialized() {
    return _instance;
  }

  FirebaseInitialized._internal();
}

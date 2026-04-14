import 'package:drifter_buoy/app.dart';
import 'package:drifter_buoy/core/services/firebase_notification_service.dart';
import 'package:drifter_buoy/core/storage/auth_session_store.dart';
import 'package:drifter_buoy/core/utils/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await FirebaseNotificationService.instance.initialize();
  // Populate role cache before UI so bottom nav does not flicker on API rebuilds.
  try {
    final store = sl<AuthSessionStore>();
    final token = await store.getAccessToken();
    if (token != null && token.trim().isNotEmpty) {
      await store.getLoginResponse();
    }
  } catch (_) {
    // Non-fatal: bottom bar falls back to cachedIsAdmin ?? false.
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((value) {
    runApp(DrifterBuoyApp());}
  );
}

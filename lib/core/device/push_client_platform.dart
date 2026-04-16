import 'package:flutter/foundation.dart';

/// Values expected by the backend `platform` field for device token registration.
class PushClientPlatform {
  const PushClientPlatform._();

  static String apiValue() {
    if (kIsWeb) {
      return 'web';
    }
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      _ => 'web',
    };
  }
}

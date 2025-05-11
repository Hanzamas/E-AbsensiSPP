import 'package:flutter/foundation.dart';

class Assets {
  static String getAssetPath(String asset) {
    if (kIsWeb) {
      return asset.replaceFirst('assets/', '');
    } else {
      return 'assets/$asset';
    }
  }

  // Penggunaan asset
  static String get logo => getAssetPath('images/illustrations/logo.png');
  static String get splash => getAssetPath('images/splash.png');
  static String get absensi => getAssetPath('images/absensi.png');
  static String get spp => getAssetPath('images/spp.png');
  static String get profile => getAssetPath('images/profile_sample.jpg');
}
import 'dart:ui';

import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';

import 'marketing_audience.dart';

enum StoreDestination {
  macAppStore('mac-app-store'),
  iosAppStoreIphone('ios-app-store-iphone-6-9'),
  iosAppStoreIpad('ios-app-store-ipad-13'),
  googlePlayPhone('google-play-phone'),
  googlePlayFeatureGraphic('google-play-feature-graphic');

  final String directoryName;

  const StoreDestination(this.directoryName);
}

final class ScreenshotTarget {
  final StoreDestination destination;
  final MarketingAudience audience;
  final Size pixelSize;
  final double rasterScale;
  final Size appLogicalSize;
  final AppThemeMode themeMode;
  final int maxScreenshotsPerListing;

  const ScreenshotTarget({
    required this.destination,
    required this.audience,
    required this.pixelSize,
    required this.rasterScale,
    required this.appLogicalSize,
    required this.themeMode,
    required this.maxScreenshotsPerListing,
  });

  Size get frameLogicalSize => pixelSize / rasterScale;
}

final class FeatureGraphicTarget {
  final StoreDestination destination;
  final MarketingAudience audience;
  final Size pixelSize;
  final double rasterScale;
  final AppThemeMode themeMode;

  const FeatureGraphicTarget({
    required this.destination,
    required this.audience,
    required this.pixelSize,
    required this.rasterScale,
    required this.themeMode,
  });

  Size get frameLogicalSize => pixelSize / rasterScale;
}

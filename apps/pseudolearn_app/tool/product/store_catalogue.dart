import 'dart:ui';

import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import 'marketing_audience.dart';
import 'store_target.dart';

const List<UiLanguageId> productLanguages = <UiLanguageId>[
  UiLanguageId.spanish,
  UiLanguageId.english,
];

const int appleScreenshotsPerListing = 10;
const int googlePlayScreenshotsPerListing = 8;
const int googlePlayMinimumScreenshots = 2;
const int googlePlayMinimumSide = 320;
const int googlePlayMaximumSide = 3840;
const double googlePlayMaximumSideRatio = 2.0;

const List<Size> appleMacScreenshotSizes = <Size>[
  Size(1280, 800),
  Size(1440, 900),
  Size(2560, 1600),
  Size(2880, 1800),
];

const double appleMacAspectRatio = 16 / 10;

const List<ScreenshotTarget> screenshotTargets = <ScreenshotTarget>[
  ScreenshotTarget(
    destination: StoreDestination.macAppStore,
    audience: MarketingAudience.appleStore,
    pixelSize: Size(2880, 1800),
    rasterScale: 2.0,
    appLogicalSize: Size(1440, 900),
    themeMode: AppThemeMode.light,
    maxScreenshotsPerListing: appleScreenshotsPerListing,
  ),
  ScreenshotTarget(
    destination: StoreDestination.iosAppStoreIphone,
    audience: MarketingAudience.appleStore,
    pixelSize: Size(1320, 2868),
    rasterScale: 3.0,
    appLogicalSize: Size(393, 852),
    themeMode: AppThemeMode.light,
    maxScreenshotsPerListing: appleScreenshotsPerListing,
  ),
  ScreenshotTarget(
    destination: StoreDestination.iosAppStoreIpad,
    audience: MarketingAudience.appleStore,
    pixelSize: Size(2064, 2752),
    rasterScale: 2.0,
    appLogicalSize: Size(1024, 1366),
    themeMode: AppThemeMode.light,
    maxScreenshotsPerListing: appleScreenshotsPerListing,
  ),
  ScreenshotTarget(
    destination: StoreDestination.googlePlayPhone,
    audience: MarketingAudience.googlePlay,
    pixelSize: Size(1080, 1920),
    rasterScale: 2.0,
    appLogicalSize: Size(393, 852),
    themeMode: AppThemeMode.light,
    maxScreenshotsPerListing: googlePlayScreenshotsPerListing,
  ),
];

const FeatureGraphicTarget googlePlayFeatureGraphic = FeatureGraphicTarget(
  destination: StoreDestination.googlePlayFeatureGraphic,
  audience: MarketingAudience.googlePlay,
  pixelSize: Size(1024, 500),
  rasterScale: 2.0,
  themeMode: AppThemeMode.light,
);

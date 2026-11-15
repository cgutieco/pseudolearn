import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/settings/app_theme_mode.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../product/app_stage.dart';
import '../product/product_dependencies.dart';
import 'plate_agent.dart';

const Map<String, AppThemeMode> plateThemes = <String, AppThemeMode>{
  'light': AppThemeMode.light,
  'dark': AppThemeMode.dark,
};

const Map<UiLanguageId, String> plateLocaleTags = <UiLanguageId, String>{
  UiLanguageId.spanish: 'es',
  UiLanguageId.english: 'en',
};

final GlobalKey plateBoundaryKey = GlobalKey();

final class PlateStageSetup {
  final UiLanguageId language;
  final AppThemeMode themeMode;
  final Size logicalSize;

  const PlateStageSetup({
    required this.language,
    required this.logicalSize,
    this.themeMode = AppThemeMode.light,
  });
}

Future<void> pumpPlateStage(WidgetTester tester, PlateStageSetup setup) async {
  tester.view.physicalSize = setup.logicalSize;
  tester.view.devicePixelRatio = 1.0;
  tester.platformDispatcher.localesTestValue = <Locale>[
    Locale(plateLocaleTags[setup.language]!),
  ];
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    RepaintBoundary(
      key: plateBoundaryKey,
      child: AppStage(
        logicalSize: setup.logicalSize,
        dependencies: buildProductDependencies(
          language: setup.language,
          themeMode: setup.themeMode,
          agent: scriptedNodo(setup.language),
          authGateway: signedInGateway(),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<T> selectedByName<T>(List<T> all, String filter, String Function(T) name) {
  final wanted = filter.split(',').where((entry) => entry.isNotEmpty).toSet();
  return wanted.isEmpty
      ? all
      : all.where((entry) => wanted.contains(name(entry))).toList();
}

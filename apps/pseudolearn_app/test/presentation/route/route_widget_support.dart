import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pseudolearn_app/data/route/bundled_route_repository.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_edition.dart';
import 'package:pseudolearn_app/domain/model/route/route_exercise.dart';
import 'package:pseudolearn_app/domain/model/route/route_lesson.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/route/lesson_scope.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

const ReferenceEdition routeTestEdition = ReferenceEdition(
  language: UiLanguageId.spanish,
  profile: SyntaxProfileId.classicSpanish,
);

final BundledRouteRepository _repository = BundledRouteRepository(
  assetLoader: (path) => File(path).readAsString(),
);

Future<RouteLesson> bundledLesson(String id) async {
  final loaded = await _repository.loadLesson(routeTestEdition, id);
  return (loaded as ContentLoaded<RouteLesson>).value;
}

Future<RouteExercise> bundledExercise(String id) async {
  final loaded = await _repository.loadExercise(routeTestEdition, id);
  return (loaded as ContentLoaded<RouteExercise>).value;
}

LessonScope scopeRecording(List<String> opened) => LessonScope(
  edition: routeTestEdition,
  onOpenLink: opened.add,
  onOpenExercise: (id) => opened.add('ejercicio:$id'),
);

Widget routeTestApp(Widget child, {bool dark = false}) => MaterialApp(
  theme: dark ? AppTheme.dark() : AppTheme.light(),
  locale: const Locale('es'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  builder: (context, c) => DesignCanvas(child: c ?? const SizedBox.shrink()),
  home: Scaffold(body: child),
);

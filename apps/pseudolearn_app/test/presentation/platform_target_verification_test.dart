import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/shell/destinations.dart';
import 'package:pseudolearn_app/presentation/shell/device_class.dart';
import '../fakes/test_dependencies.dart';

void _setWindowSize(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

const List<String> _platformQueryTerms = [
  'Platform.isIOS',
  'Platform.isMacOS',
  'Platform.isAndroid',
  'defaultTargetPlatform',
  'TargetPlatform.',
];

const List<String> _adaptiveConstructorTerms = [
  'Switch.adaptive',
  'Slider.adaptive',
  'CircularProgressIndicator.adaptive',
  'showAdaptiveDialog',
];

List<String> platformQueryAllowedPaths(String packageRoot) {
  final file = File(p.join(packageRoot, 'architecture.yaml'));
  final yaml = loadYaml(file.readAsStringSync()) as YamlMap;
  final declared = yaml['platform_query_allowed_paths'] as YamlList?;
  return declared?.map((entry) => entry.toString()).toList() ?? const [];
}

List<String> validatePlatformQueries({
  required String sourceRoot,
  required List<String> allowedPaths,
}) {
  final directory = Directory(sourceRoot);
  final violations = <String>[];
  if (!directory.existsSync()) return violations;

  for (final entity in directory.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final relative =
        p.relative(entity.path, from: sourceRoot).split(p.separator).join('/');
    final content = entity.readAsStringSync();
    final terms = allowedPaths.contains(relative)
        ? _adaptiveConstructorTerms
        : [..._platformQueryTerms, ..._adaptiveConstructorTerms];
    for (final term in terms) {
      if (content.contains(term)) {
        violations.add('$relative contains forbidden platform check "$term"');
      }
    }
  }
  return violations;
}

void main() {
  group('CIE-F2 · Platform Target and Window Resizing Verification', () {
    testWidgets(
        'Narrowing macOS window below 600 dp dynamically produces compact tree and bottom bar',
        (tester) async {
      _setWindowSize(tester, const Size(540, 800));
      final deps = buildTestDependencies();

      await tester.pumpWidget(CubitScope(dependencies: deps));
      await tester.pumpAndSettle();

      final canvasContext = tester.element(find.byType(Scaffold).first);
      final canvasData = DesignCanvasScope.of(canvasContext);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);

      expect(canvasData.deviceClass, equals(DeviceClass.compact));
      expect(canvasData.size.width, equals(540.0));

      expect(scaffold.bottomNavigationBar, isNotNull);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(NavigationRail), findsNothing);

      expect(find.byIcon(appDestinations.first.selectedIcon), findsOneWidget);
      for (final destination in appDestinations.skip(1)) {
        expect(find.byIcon(destination.icon), findsOneWidget);
      }
    });

    testWidgets(
        'Expanding window to medium (750 dp) switches to Navigation Rail',
        (tester) async {
      _setWindowSize(tester, const Size(750, 900));
      final deps = buildTestDependencies();

      await tester.pumpWidget(CubitScope(dependencies: deps));
      await tester.pumpAndSettle();

      final canvasContext = tester.element(find.byType(Scaffold).first);
      final canvasData = DesignCanvasScope.of(canvasContext);

      expect(canvasData.deviceClass, equals(DeviceClass.medium));
      expect(canvasData.size.width, equals(750.0));
      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets(
        'Expanding window to expanded (1200 dp) keeps Navigation Rail and the whole window',
        (tester) async {
      _setWindowSize(tester, const Size(1200, 900));
      final deps = buildTestDependencies();

      await tester.pumpWidget(CubitScope(dependencies: deps));
      await tester.pumpAndSettle();

      final canvasContext = tester.element(find.byType(Scaffold).first);
      final canvasData = DesignCanvasScope.of(canvasContext);

      expect(canvasData.deviceClass, equals(DeviceClass.expanded));
      expect(canvasData.size.width, equals(1200.0));
      expect(find.byType(NavigationRail), findsOneWidget);
    });

    test(
        'Architectural check: platform queries live only where architecture.yaml allows',
        () {
      final violations = validatePlatformQueries(
        sourceRoot: 'lib',
        allowedPaths: platformQueryAllowedPaths(Directory.current.path),
      );

      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('Negative fixture: an adapter outside the allowed path is caught', () {
      final violations = validatePlatformQueries(
        sourceRoot: p.join(
          Directory.current.path,
          'test',
          'architecture',
          'fixtures',
          'data_querying_platform',
        ),
        allowedPaths: const ['data/platform/platform_text_entry_modality.dart'],
      );

      expect(violations, isNotEmpty);
    });
  });
}

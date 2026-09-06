import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import '../fakes/test_dependencies.dart';

void main() {
  group('Composition and Startup Tests (CIM-F4)', () {
    test('buildTestDependencies builds complete dependency container', () {
      final dependencies = buildTestDependencies();

      expect(dependencies.clock, isNotNull);
      expect(dependencies.identifiers, isNotNull);
      expect(dependencies.preferences, isNotNull);
      expect(dependencies.documentRepository, isNotNull);
      expect(dependencies.programAnalyzer, isNotNull);
      expect(dependencies.createProgramExecution(), isNotNull);
    });

    testWidgets('CubitScope renders initial frame cleanly without network or blocking', (tester) async {
      final dependencies = buildTestDependencies();
      final widget = CubitScope(dependencies: dependencies);

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      expect(find.byType(CubitScope), findsOneWidget);
    });

    testWidgets('CubitScope reacts to language change and updates MaterialApp locale', (tester) async {
      final dependencies = buildTestDependencies();
      final widget = CubitScope(dependencies: dependencies);

      await tester.pumpWidget(widget);
      await tester.pumpAndSettle();

      final materialAppBefore = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialAppBefore.locale, isNull);

      final settingsCubit = tester.element(find.byType(MaterialApp)).read<SettingsCubit>();
      await settingsCubit.setLanguage(UiLanguageId.english);
      await tester.pumpAndSettle();

      final materialAppAfter = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialAppAfter.locale, equals(const Locale('en')));
    });
  });
}

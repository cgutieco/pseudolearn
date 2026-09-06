import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/cubit_scope.dart';
import 'package:pseudolearn_app/domain/model/settings/app_preferences.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/onboarding/widgets/welcome_step_view.dart';
import 'package:pseudolearn_app/presentation/routing/app_router.dart';

import '../../fakes/slow_preferences_store.dart';
import '../../fakes/test_dependencies.dart';

void main() {
  testWidgets(
    'restarting the introduction from settings reaches the first step, not the library',
    (tester) async {
      final preferences = SlowPreferencesStore(
        const AppPreferences.defaults().copyWith(hasSeenOnboarding: true),
      );

      await tester.pumpWidget(CubitScope(
        dependencies: buildTestDependencies(preferences: preferences),
        router: buildAppRouter(initialLocation: '/ajustes'),
      ));
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpAndSettle();

      await tester.tap(find.byWidgetPredicate(
        (widget) => widget is AppListItem && widget.icon == Icons.restart_alt,
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 30));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeStepView), findsOneWidget);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_cubit.dart';
import 'package:pseudolearn_app/presentation/document/components/simulated_scenario_panel.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../../../fakes/fake_program_execution.dart';

void main() {
  testWidgets('keeps the simulated label visible and explains the boundary', (
    tester,
  ) async {
    final cubit = ExecutionCubit(execution: FakeProgramExecution());
    addTearDown(cubit.close);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('es'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) =>
            DesignCanvas(child: child ?? const SizedBox.shrink()),
        home: BlocProvider.value(
          value: cubit,
          child: const Scaffold(bottomNavigationBar: SimulatedScenarioPanel()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Simulado'), findsOneWidget);
    await tester.tap(find.byTooltip('Ayuda sobre escenarios simulados'));
    await tester.pumpAndSettle();

    expect(find.text('Escenario simulado'), findsOneWidget);
    expect(
      find.textContaining('No se consultan archivos, red ni reloj del equipo.'),
      findsOneWidget,
    );
  });
}

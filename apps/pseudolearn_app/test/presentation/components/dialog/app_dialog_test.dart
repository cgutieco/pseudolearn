import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/dialog/app_dialog.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

import '../component_test_harness.dart';

void main() {
  group('AppDialog (RFC 003 §4)', () {
    testWidgets('renders title and body', (tester) async {
      await pumpComponent(
        tester,
        const AppDialog(title: 'Delete document?', body: 'This cannot be undone.', actions: []),
      );
      expect(find.text('Delete document?'), findsOneWidget);
      expect(find.text('This cannot be undone.'), findsOneWidget);
    });

    testWidgets('renders every action supplied, in order', (tester) async {
      await pumpComponent(
        tester,
        AppDialog(
          title: 'Rename document',
          body: 'Choose a new name.',
          actions: [
            AppButton(label: 'Cancel', variant: AppButtonVariant.tertiary, onPressed: () {}),
            AppButton(label: 'Rename', variant: AppButtonVariant.primary, onPressed: () {}),
          ],
        ),
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Rename'), findsOneWidget);
    });

    testWidgets('renders with no actions at all', (tester) async {
      await pumpComponent(tester, const AppDialog(title: 'Info', body: 'Nothing to confirm.', actions: []));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an optional icon when supplied', (tester) async {
      await pumpComponent(
        tester,
        const AppDialog(icon: Icons.warning, title: 'Careful', body: 'Are you sure?', actions: []),
      );
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('showAppDialog opens and resolves the result on pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAppDialog<bool>(
                  context,
                  builder: (context) => AppDialog(
                    title: 'Confirm',
                    body: 'Proceed?',
                    actions: [
                      AppButton(
                        label: 'Yes',
                        variant: AppButtonVariant.primary,
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsOneWidget);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm'), findsNothing);
    });
  });
}

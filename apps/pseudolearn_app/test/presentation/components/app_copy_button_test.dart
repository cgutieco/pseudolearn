import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_copy_button.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      theme: AppTheme.light(),
      locale: const Locale('es'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, c) =>
          DesignCanvas(child: c ?? const SizedBox.shrink()),
      home: Scaffold(body: Center(child: child)),
    );
  }

  group('AppCopyButton Tests (RFC 003 #25)', () {
    testWidgets(
        'Renders copy icon initially and transitions to check icon upon tap',
        (tester) async {
      final log = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      var copiedCallbackCalled = false;
      const testText = 'algoritmo prueba\nfin_algoritmo';

      await tester.pumpWidget(
        buildTestWidget(
          child: AppCopyButton(
            textToCopy: testText,
            onCopied: () => copiedCallbackCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);

      await tester.tap(find.byType(AppCopyButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(copiedCallbackCalled, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      expect(log.any((call) => call.method == 'Clipboard.setData'), isTrue);

      await tester.pump(const Duration(milliseconds: 1700));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsNothing);
    });
  });
}

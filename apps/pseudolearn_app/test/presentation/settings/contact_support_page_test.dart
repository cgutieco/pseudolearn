import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/presentation/components/card/app_card_surface.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/contact/contact_support_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildContactSupportTestApp({
  List<ContentBlock> blocks = const [],
  bool isLoading = false,
  String? errorMessage,
  VoidCallback? onRetry,
  VoidCallback? onBack,
}) {
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
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(
      body: ContactSupportView(
        blocks: blocks,
        isLoading: isLoading,
        errorMessage: errorMessage,
        onRetry: onRetry ?? () {},
        onBack: onBack ?? () {},
      ),
    ),
  );
}

void main() {
  group('ContactSupportView Interaction Tests (PANT-05-F4)', () {
    testWidgets('Renders empty message when blocks list is empty', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp(blocks: const []));
      await tester.pumpAndSettle();

      expect(find.text('Contacto y soporte'), findsOneWidget);
      expect(find.text('No hay información de contacto disponible.'), findsOneWidget);
    });

    testWidgets('Renders content blocks when provided', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp(
        blocks: const [
          HeadingBlock(level: 2, text: 'Canales de soporte'),
          ParagraphBlock(text: 'Escríbenos a support@pseudolearn.com'),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Contacto y soporte'), findsOneWidget);
      expect(find.text('Canales de soporte'), findsOneWidget);
      expect(find.text('Escríbenos a support@pseudolearn.com'), findsOneWidget);
    });

    testWidgets('Renders channel items with copy affordances', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp(
        blocks: const [
          HeadingBlock(level: 2, text: 'Canales de comunicación'),
          ListBlock(items: [
            'Correo electrónico: support@pseudolearn.com',
            'Sitio web oficial: https://pseudolearn.app',
            'Asistencia y soporte web: https://pseudolearn.app/contact',
          ]),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('support@pseudolearn.com'), findsOneWidget);
      expect(find.text('https://pseudolearn.app'), findsOneWidget);
      expect(find.text('https://pseudolearn.app/contact'), findsOneWidget);
    });

    testWidgets('Renders the error state with a retry action', (tester) async {
      var retried = false;
      await tester.pumpWidget(_buildContactSupportTestApp(
        errorMessage: 'Fallo al leer el documento',
        onRetry: () => retried = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Fallo al leer el documento'), findsOneWidget);

      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('Back affordance invokes onBack', (tester) async {
      var returned = false;
      await tester.pumpWidget(_buildContactSupportTestApp(onBack: () => returned = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
    });

    testWidgets('Shares the page frame with the settings index', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp(
        blocks: const [ParagraphBlock(text: 'Escríbenos')],
      ));
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
      expect(find.byType(AppCardSurface), findsWidgets);
    });

    testWidgets('Wraps content in SafeArea to respect device notches and insets', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(ContactSupportView), matching: find.byType(SafeArea)), findsOneWidget);
    });
  });
}

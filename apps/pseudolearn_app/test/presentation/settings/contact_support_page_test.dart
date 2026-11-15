import 'package:cupertino_ui/cupertino_ui.dart' show GlobalCupertinoLocalizations;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart' show GlobalWidgetsLocalizations;
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/card/app_card_surface.dart';
import 'package:pseudolearn_app/presentation/components/layout/app_page.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/settings/contact/contact_support_view.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';

Widget _buildContactSupportTestApp({VoidCallback? onBack, String locale = 'es'}) {
  return MaterialApp(
    theme: AppTheme.light(),
    locale: Locale(locale),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => DesignCanvas(child: child ?? const SizedBox.shrink()),
    home: Scaffold(body: ContactSupportView(onBack: onBack ?? () {})),
  );
}

void main() {
  group('ContactSupportView', () {
    testWidgets('renders the localized introduction and pedagogical card', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Contacto y soporte'), findsOneWidget);
      expect(find.text('Sugerencias pedagógicas'), findsOneWidget);
    });

    testWidgets('renders the channel items with their values', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp());
      await tester.pumpAndSettle();

      expect(find.text('support@pseudolearn.app'), findsOneWidget);
      expect(find.text('https://pseudolearn.app'), findsOneWidget);
      expect(find.text('https://pseudolearn.app/contact'), findsOneWidget);
    });

    testWidgets('renders the English edition too', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp(locale: 'en'));
      await tester.pumpAndSettle();

      expect(find.text('Teaching suggestions'), findsOneWidget);
      expect(find.text('support@pseudolearn.app'), findsOneWidget);
    });

    testWidgets('back affordance invokes onBack', (tester) async {
      var returned = false;
      await tester.pumpWidget(_buildContactSupportTestApp(onBack: () => returned = true));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(returned, isTrue);
    });

    testWidgets('shares the page frame with the settings index', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(AppPage), findsOneWidget);
      expect(find.byType(AppCardSurface), findsWidgets);
    });

    testWidgets('wraps content in SafeArea to respect device insets', (tester) async {
      await tester.pumpWidget(_buildContactSupportTestApp());
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(ContactSupportView), matching: find.byType(SafeArea)), findsOneWidget);
    });
  });
}

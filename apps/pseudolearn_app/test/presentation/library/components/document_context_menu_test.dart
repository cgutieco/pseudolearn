import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations.dart';
import 'package:pseudolearn_app/presentation/library/components/document_context_menu.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';
import 'package:pseudolearn_app/presentation/theme/app_theme.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/radii.dart';

void main() {
  Widget buildTestApp({
    required VoidCallback onRename,
    required VoidCallback onDelete,
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
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showDocumentContextMenu(
                context: context,
                onRename: onRename,
                onDelete: onDelete,
              ),
              child: const Text('Open Menu'),
            ),
          ),
        ),
      ),
    );
  }

  group('showDocumentContextMenu', () {
    testWidgets('configures bottom sheet with antiAlias clip behavior and rounded top borders', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onRename: () {},
        onDelete: () {},
      ));

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      final bottomSheetFinder = find.byType(BottomSheet);
      expect(bottomSheetFinder, findsOneWidget);

      final bottomSheet = tester.widget<BottomSheet>(bottomSheetFinder);
      expect(bottomSheet.clipBehavior, equals(Clip.antiAlias));
      expect(bottomSheet.shape, isA<RoundedRectangleBorder>());

      final shape = bottomSheet.shape! as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        equals(const BorderRadius.vertical(top: Radius.circular(RadiusTokens.radiusXl))),
      );

      final materialFinder = find.descendant(
        of: bottomSheetFinder,
        matching: find.byType(Material),
      );
      expect(materialFinder, findsOneWidget);
      final material = tester.widget<Material>(materialFinder);
      expect(material.clipBehavior, equals(Clip.antiAlias));
    });

    testWidgets('triggers onRename and closes bottom sheet when rename is tapped', (tester) async {
      var renameCalled = false;
      await tester.pumpWidget(buildTestApp(
        onRename: () => renameCalled = true,
        onDelete: () {},
      ));

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Renombrar'));
      await tester.pumpAndSettle();

      expect(renameCalled, isTrue);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('triggers onDelete and closes bottom sheet when delete is tapped', (tester) async {
      var deleteCalled = false;
      await tester.pumpWidget(buildTestApp(
        onRename: () {},
        onDelete: () => deleteCalled = true,
      ));

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
      expect(find.byType(BottomSheet), findsNothing);
    });

    testWidgets('keeps antiAlias clip behavior intact when hovering first item', (tester) async {
      await tester.pumpWidget(buildTestApp(
        onRename: () {},
        onDelete: () {},
      ));

      await tester.tap(find.text('Open Menu'));
      await tester.pumpAndSettle();

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      final renameItem = find.widgetWithText(AppListItem, 'Renombrar');
      expect(renameItem, findsOneWidget);

      await gesture.moveTo(tester.getCenter(renameItem));
      await tester.pumpAndSettle();

      final bottomSheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(bottomSheet.clipBehavior, equals(Clip.antiAlias));
    });
  });
}

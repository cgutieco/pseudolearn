import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/presentation/components/button/app_button.dart';
import 'package:pseudolearn_app/presentation/components/button/app_icon_button.dart';
import 'package:pseudolearn_app/presentation/components/field/app_text_field.dart';
import 'package:pseudolearn_app/presentation/components/list/app_list_item.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/button_metrics.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/spacing.dart';

import 'component_test_harness.dart';

void main() {
  group('Touch target minimums (RFC 001 §3.3, RFC 003 §5.4)', () {
    testWidgets('AppButton reaches target.touch.min in height', (tester) async {
      await pumpComponent(tester, AppButton(label: 'Save', variant: AppButtonVariant.primary, onPressed: () {}));
      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
    });

    testWidgets('AppIconButton reaches its minimum square size', (tester) async {
      await pumpComponent(
        tester,
        AppIconButton(icon: Icons.close, semanticLabel: 'Close', variant: AppButtonVariant.tertiary, onPressed: () {}),
      );
      final size = tester.getSize(find.byType(AppIconButton));
      expect(size.width, greaterThanOrEqualTo(ButtonMetricsTokens.buttonIconOnlyMinSize));
      expect(size.height, greaterThanOrEqualTo(ButtonMetricsTokens.buttonIconOnlyMinSize));
    });

    testWidgets('AppListItem reaches target.touch.min in height', (tester) async {
      await pumpComponent(tester, const AppListItem(label: 'Item'));
      final size = tester.getSize(find.byType(AppListItem));
      expect(size.height, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
    });

    testWidgets('AppTextField reaches target.touch.min in height', (tester) async {
      await pumpComponent(tester, const AppTextField(label: 'Name'));
      final field = tester.getSize(find.byType(TextField));
      expect(field.height, greaterThanOrEqualTo(SpacingTokens.targetTouchMin));
    });

    testWidgets('two adjacent buttons keep at least target.spacing.min between them', (tester) async {
      await pumpComponent(
        tester,
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(label: 'Cancel', variant: AppButtonVariant.tertiary, onPressed: () {}),
            const SizedBox(width: SpacingTokens.targetSpacingMin),
            AppButton(label: 'Ok', variant: AppButtonVariant.primary, onPressed: () {}),
          ],
        ),
      );
      final buttons = find.byType(AppButton);
      final firstRect = tester.getRect(buttons.at(0));
      final secondRect = tester.getRect(buttons.at(1));
      expect(secondRect.left - firstRect.right, greaterThanOrEqualTo(SpacingTokens.targetSpacingMin));
    });
  });
}

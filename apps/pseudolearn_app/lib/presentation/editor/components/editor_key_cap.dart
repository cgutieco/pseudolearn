import 'package:flutter/material.dart';
import '../../../domain/model/editor/editor_key.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

String _semanticLabelOf(AppLocalizations l10n, EditorKey key) {
  return switch (key.kind) {
    EditorKeyKind.indent => l10n.editorKeyIndent,
    EditorKeyKind.dedent => l10n.editorKeyDedent,
    EditorKeyKind.assignment => l10n.editorKeyAssignment,
    EditorKeyKind.quote => l10n.editorKeyQuote,
    EditorKeyKind.openParenthesis => l10n.editorKeyOpenParenthesis,
    EditorKeyKind.closeParenthesis => l10n.editorKeyCloseParenthesis,
    EditorKeyKind.greaterOrEqual => l10n.editorKeyGreaterOrEqual,
    EditorKeyKind.lessOrEqual => l10n.editorKeyLessOrEqual,
    EditorKeyKind.template => key.label,
  };
}

final class EditorKeyCap extends StatelessWidget {
  final EditorKey editorKey;
  final VoidCallback onPressed;

  const EditorKeyCap({
    super.key,
    required this.editorKey,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: _semanticLabelOf(l10n, editorKey),
      onTap: onPressed,
      child: InkWell(
        onTap: onPressed,
        child: Center(child: _KeyCapFace(label: editorKey.label)),
      ),
    );
  }
}

final class _KeyCapFace extends StatelessWidget {
  final String label;

  const _KeyCapFace({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      height: ComponentMetricsTokens.editorKeyCapHeight,
      margin: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space1,
        vertical: SpacingTokens.space1,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.codeInline,
        color: theme.colors.text.primary,
        maxLines: 1,
      ),
    );
  }
}

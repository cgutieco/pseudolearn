import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class MemoryBoxesIllustration extends StatelessWidget {
  const MemoryBoxesIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      label: l10n.illustrationMemoryBoxesSemanticLabel,
      child: Wrap(
        spacing: SpacingTokens.space4,
        runSpacing: SpacingTokens.space4,
        children: [
          _MemoryBox(name: l10n.illustrationMemoryBoxesVariable1, value: l10n.illustrationMemoryBoxesValue1),
          _MemoryBox(name: l10n.illustrationMemoryBoxesVariable2, value: l10n.illustrationMemoryBoxesValue2),
          _MemoryBox(name: l10n.illustrationMemoryBoxesVariable3, value: l10n.illustrationMemoryBoxesValue3),
        ],
      ),
    );
  }
}

final class _MemoryBox extends StatelessWidget {
  final String name;
  final String value;

  const _MemoryBox({required this.name, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(name, variant: AppTextVariant.codeCaption, color: theme.colors.text.secondary),
        const SizedBox(height: SpacingTokens.space1),
        _MemoryBoxValue(value: value),
      ],
    );
  }
}

final class _MemoryBoxValue extends StatelessWidget {
  final String value;

  const _MemoryBoxValue({required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Container(
      constraints: const BoxConstraints(minWidth: SpacingTokens.space16),
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.raised,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.defaultBorder,
          width: BorderMetricsTokens.widthEmphasis,
        ),
      ),
      child: AppText(
        value,
        variant: AppTextVariant.codeInline,
        color: theme.colors.text.primary,
        textAlign: TextAlign.center,
      ),
    );
  }
}

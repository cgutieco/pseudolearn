import 'package:flutter/material.dart';
import '../../../domain/model/onboarding/guided_demo_surface.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

String _labelOf(AppLocalizations l10n, GuidedDemoSurface surface) {
  return switch (surface) {
    GuidedDemoSurface.diagrams => l10n.onboardingLabSurfaceDiagrams,
    GuidedDemoSurface.trace => l10n.onboardingLabSurfaceTrace,
    GuidedDemoSurface.output => l10n.onboardingLabSurfaceOutput,
  };
}

final class DemoSurfaceSelector extends StatelessWidget {
  final GuidedDemoSurface surface;
  final ValueChanged<GuidedDemoSurface> onSelected;

  const DemoSurfaceSelector({
    super.key,
    required this.surface,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space1),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: Row(
        children: [
          for (final option in GuidedDemoSurface.values)
            _SurfaceOption(
              label: _labelOf(l10n, option),
              isSelected: surface == option,
              onTap: () => onSelected(option),
            ),
        ],
      ),
    );
  }
}

final class _SurfaceOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SurfaceOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
          child: _SurfaceOptionFace(label: label, isSelected: isSelected),
        ),
      ),
    );
  }
}

final class _SurfaceOptionFace extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _SurfaceOptionFace({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final background = isSelected
        ? theme.colors.surfaces.defaultSurface
        : theme.colors.surfaces.subtle;
    final foreground =
        isSelected ? theme.colors.text.link : theme.colors.text.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.space2,
        horizontal: SpacingTokens.space1,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.label,
        color: foreground,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

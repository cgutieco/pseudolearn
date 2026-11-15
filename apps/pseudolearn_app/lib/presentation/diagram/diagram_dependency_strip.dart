import 'package:material_ui/material_ui.dart';
import '../../domain/model/analysis/program_dependency.dart';
import '../../domain/model/analysis/source_range.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/component_metrics.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';

final class DiagramDependencyStrip extends StatelessWidget {
  final List<ProgramDependency> dependencies;
  final ValueChanged<SourceRange>? onSourceSelected;

  const DiagramDependencyStrip({
    super.key,
    required this.dependencies,
    this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space2),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border.all(color: theme.colors.borders.subtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final dependency in dependencies)
            _DependencyRow(
              dependency: dependency,
              l10n: l10n,
              onSourceSelected: onSourceSelected,
            ),
        ],
      ),
    );
  }
}

String dependencyLabel(AppLocalizations l10n, ProgramDependency dependency) {
  final alias = dependency.alias;
  final path = dependency.qualifiedPath;
  return switch (dependency.kind) {
    ProgramDependencyKind.importation =>
      alias == null
          ? l10n.diagramDependencyImport(path)
          : l10n.diagramDependencyImportAlias(path, alias),
    ProgramDependencyKind.exportation => l10n.diagramDependencyExport(path),
  };
}

final class _DependencyRow extends StatelessWidget {
  final ProgramDependency dependency;
  final AppLocalizations l10n;
  final ValueChanged<SourceRange>? onSourceSelected;

  const _DependencyRow({
    required this.dependency,
    required this.l10n,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    final select = onSourceSelected;
    final label = '${dependencyLabel(l10n, dependency)}. '
        '${l10n.diagramDependencyUnlinked}';
    return Semantics(
      container: true,
      button: select != null,
      label: label,
      onTap: select == null ? null : () => select(dependency.range),
      child: InkWell(
        onTap: select == null ? null : () => select(dependency.range),
        child: ExcludeSemantics(
          child: _DependencyText(dependency: dependency, l10n: l10n),
        ),
      ),
    );
  }
}

final class _DependencyText extends StatelessWidget {
  final ProgramDependency dependency;
  final AppLocalizations l10n;

  const _DependencyText({required this.dependency, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: SpacingTokens.space1,
        horizontal: SpacingTokens.space2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            dependencyLabel(l10n, dependency),
            variant: AppTextVariant.label,
          ),
          AppText(
            l10n.diagramDependencyUnlinked,
            variant: AppTextVariant.caption,
            color: theme.colors.text.secondary,
          ),
        ],
      ),
    );
  }
}

final class DiagramDependencyOverlay extends StatelessWidget {
  final List<ProgramDependency> dependencies;
  final ValueChanged<SourceRange>? onSourceSelected;

  const DiagramDependencyOverlay({
    super.key,
    required this.dependencies,
    required this.onSourceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: ComponentMetricsTokens.flowCanvasZoomControlsInset,
      bottom: ComponentMetricsTokens.flowCanvasZoomControlsInset,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: ComponentMetricsTokens.flowCanvasDependencyStripMaxWidth,
        ),
        child: DiagramDependencyStrip(
          dependencies: dependencies,
          onSourceSelected: onSourceSelected,
        ),
      ),
    );
  }
}

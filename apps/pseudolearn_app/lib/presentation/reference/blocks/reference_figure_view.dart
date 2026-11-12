import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_figure.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../reference_runs_text.dart';
import '../reference_svg.dart';
import 'reference_figure_panels.dart';

final class ReferenceFigureView extends StatefulWidget {
  final ReferenceFigure figure;
  final ValueChanged<String> onOpenSection;

  const ReferenceFigureView({
    super.key,
    required this.figure,
    required this.onOpenSection,
  });

  @override
  State<ReferenceFigureView> createState() => _ReferenceFigureViewState();
}

final class _ReferenceFigureViewState extends State<ReferenceFigureView> {
  int _step = 1;

  void _move(int delta) =>
      setState(() => _step = (_step + delta).clamp(1, widget.figure.stepCount));

  @override
  Widget build(BuildContext context) {
    final figure = widget.figure;
    final stepped = figure.stepCount > 0;
    return Semantics(
      label: figure.description,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ReferenceSvg(
            svg: stepped ? figure.svgAt(_step) : figure.svg,
            label: figure.alt,
          ),
          if (stepped)
            ReferenceFigureSteps(
              figure: figure,
              step: _step,
              onMove: _move,
              onOpenSection: widget.onOpenSection,
            ),
          ReferenceFigureCaption(
            figure: figure,
            onOpenSection: widget.onOpenSection,
          ),
        ],
      ),
    );
  }
}

final class ReferenceFigureCaption extends StatelessWidget {
  final ReferenceFigure figure;
  final ValueChanged<String> onOpenSection;

  const ReferenceFigureCaption({
    super.key,
    required this.figure,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            AppLocalizations.of(context)!.referenceFigureLabel(figure.number),
            variant: AppTextVariant.label,
            color: theme.colors.text.secondary,
          ),
          ReferenceRunsText(
            runs: figure.caption,
            variant: AppTextVariant.bodySmall,
            color: theme.colors.text.secondary,
            onOpenSection: onOpenSection,
          ),
        ],
      ),
    );
  }
}

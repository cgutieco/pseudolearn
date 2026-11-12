import 'package:material_ui/material_ui.dart';
import '../../../domain/model/agent/reply_block.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_copy_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'reply_code_text.dart';
import 'reply_flowchart_canvas.dart';

final class ReplyDiagramView extends StatefulWidget {
  final ReplyDiagram diagram;

  const ReplyDiagramView({super.key, required this.diagram});

  @override
  State<ReplyDiagramView> createState() => _ReplyDiagramViewState();
}

final class _ReplyDiagramViewState extends State<ReplyDiagramView> {
  bool _showSource = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final flowchart = widget.diagram.flowchart;
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.space2),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border.all(color: theme.colors.borders.subtle),
        borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusMd)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DiagramHeader(source: widget.diagram.source),
          if (flowchart == null) _UnsupportedNote(source: widget.diagram.source),
          if (flowchart != null && !_showSource) ReplyFlowchartCanvas(flowchart: flowchart),
          if (flowchart != null && _showSource) ReplyCodeText(source: widget.diagram.source),
          if (flowchart != null) _SourceToggle(showingSource: _showSource, onToggle: _toggle),
        ],
      ),
    );
  }

  void _toggle() => setState(() => _showSource = !_showSource);
}

final class _DiagramHeader extends StatelessWidget {
  final String source;

  const _DiagramHeader({required this.source});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Row(
      children: [
        Icon(Icons.account_tree_outlined, size: IconMetricsTokens.iconXs, color: theme.colors.text.secondary),
        const SizedBox(width: SpacingTokens.space1),
        Expanded(child: AppText(l10n.agentDiagramTitle, variant: AppTextVariant.caption, color: theme.colors.text.secondary)),
        AppCopyButton(textToCopy: source),
      ],
    );
  }
}

final class _UnsupportedNote extends StatelessWidget {
  final String source;

  const _UnsupportedNote({required this.source});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      key: const ValueKey('agent-diagram-unsupported'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(l10n.agentDiagramUnsupported, variant: AppTextVariant.bodySmall, color: theme.colors.text.secondary),
        const SizedBox(height: SpacingTokens.space2),
        ReplyCodeText(source: source),
      ],
    );
  }
}

final class _SourceToggle extends StatelessWidget {
  final bool showingSource;
  final VoidCallback onToggle;

  const _SourceToggle({required this.showingSource, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Align(
      alignment: Alignment.centerLeft,
      child: AppButton(
        key: const ValueKey('agent-diagram-toggle'),
        label: showingSource ? l10n.agentDiagramShowDiagram : l10n.agentDiagramShowSource,
        icon: showingSource ? Icons.account_tree_outlined : Icons.code,
        variant: AppButtonVariant.tertiary,
        onPressed: onToggle,
      ),
    );
  }
}

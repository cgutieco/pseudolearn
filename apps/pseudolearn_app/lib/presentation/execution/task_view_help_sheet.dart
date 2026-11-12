import 'package:material_ui/material_ui.dart';
import '../../application/execution/execution_history_state.dart';
import '../components/typography/app_text.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/spacing.dart';

final class TaskViewHelpButton extends StatelessWidget {
  final ExecutionHistorySurface surface;

  const TaskViewHelpButton({super.key, required this.surface});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context)!.executionHelpOpen,
    icon: const Icon(Icons.help_outline),
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => TaskViewHelpSheet(surface: surface),
    ),
  );
}

final class TaskViewHelpSheet extends StatelessWidget {
  final ExecutionHistorySurface surface;

  const TaskViewHelpSheet({super.key, required this.surface});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.space6,
        SpacingTokens.space1,
        SpacingTokens.space6,
        SpacingTokens.space6,
      ),
      child: _HelpContent(surface: surface),
    ),
  );
}

final class _HelpContent extends StatelessWidget {
  final ExecutionHistorySurface surface;

  const _HelpContent({required this.surface});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.executionHelpTitle, variant: AppTextVariant.heading4),
        _HelpParagraph(
          title: l10n.executionProjectionFlow,
          body: l10n.executionHelpTimeline,
          isActive: surface == ExecutionHistorySurface.flow,
        ),
        _HelpParagraph(
          title: l10n.executionProjectionStructure,
          body: l10n.executionHelpStatus,
          isActive: surface == ExecutionHistorySurface.structure,
        ),
        _HelpParagraph(
          title: l10n.executionProjectionEvents,
          body: l10n.executionHelpVariables,
          isActive: surface == ExecutionHistorySurface.events,
        ),
        _HelpParagraph(
          title: l10n.executionLive,
          body: l10n.executionHelpNavigation,
          isActive: false,
        ),
      ],
    );
  }
}

final class _HelpParagraph extends StatelessWidget {
  final String title;
  final String body;
  final bool isActive;

  const _HelpParagraph({
    required this.title,
    required this.body,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: SpacingTokens.space4),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: isActive ? AppTextVariant.heading4 : AppTextVariant.label,
        ),
        const SizedBox(height: SpacingTokens.space1),
        AppText(body, variant: AppTextVariant.bodyDefault),
      ],
    ),
  );
}

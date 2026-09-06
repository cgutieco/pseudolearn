import 'package:flutter/material.dart';
import '../../application/export/export_state.dart';
import '../../domain/model/export/target_language_id.dart';
import '../components/button/app_copy_button.dart';
import '../components/empty/app_empty_state.dart';
import '../components/typography/app_text.dart';
import '../editor/components/code_preview.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/border_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'components/target_language_selector.dart';

final class ExportTabView extends StatelessWidget {
  final ExportState state;
  final ValueChanged<TargetLanguageId> onLanguageSelected;

  const ExportTabView({
    super.key,
    required this.state,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (state.status) {
      ExportStatus.unavailable => AppEmptyState(
          icon: Icons.ios_share_outlined,
          title: l10n.tabEquivalentCode,
          description: state.unavailableReason.isNotEmpty
              ? state.unavailableReason
              : l10n.exportComingSoon,
        ),
      ExportStatus.analysisError => AppEmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.exportAnalysisErrorTitle,
          description: l10n.exportAnalysisErrorDescription,
        ),
      ExportStatus.initial || ExportStatus.ready => state.exportedCode.isEmpty
          ? AppEmptyState(
              icon: Icons.code_rounded,
              title: l10n.tabEquivalentCode,
              description: l10n.exportEmptySourceDescription,
            )
          : _ExportContent(
              state: state,
              onLanguageSelected: onLanguageSelected,
            ),
    };
  }
}

final class _ExportContent extends StatelessWidget {
  final ExportState state;
  final ValueChanged<TargetLanguageId> onLanguageSelected;

  const _ExportContent({
    required this.state,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ExportTopBar(
          selectedLanguage: state.selectedLanguage,
          onLanguageSelected: onLanguageSelected,
          codeToCopy: state.exportedCode,
        ),
        Expanded(
          child: CodePreview(
            key: ValueKey('${state.selectedLanguage.id}_${state.exportedCode.hashCode}'),
            text: state.exportedCode,
            activeLines: state.focusedLines,
          ),
        ),
        if (state.notes.isNotEmpty) _ExportNotesPanel(notes: state.notes),
      ],
    );
  }
}

final class _ExportNotesPanel extends StatelessWidget {
  final List<String> notes;

  const _ExportNotesPanel({required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.space3),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        border: Border(
          top: BorderSide(
            color: theme.colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      ),
      child: AppText(
        notes.join('\n'),
        variant: AppTextVariant.caption,
        color: theme.colors.text.secondary,
      ),
    );
  }
}

final class _ExportTopBar extends StatelessWidget {
  final TargetLanguageId selectedLanguage;
  final ValueChanged<TargetLanguageId> onLanguageSelected;
  final String codeToCopy;

  const _ExportTopBar({
    required this.selectedLanguage,
    required this.onLanguageSelected,
    required this.codeToCopy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space4,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.defaultSurface,
        border: Border(
          bottom: BorderSide(
            color: theme.colors.borders.subtle,
            width: BorderMetricsTokens.widthHairline,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TargetLanguageSelector(
            selectedLanguage: selectedLanguage,
            onLanguageSelected: onLanguageSelected,
          ),
          AppCopyButton(textToCopy: codeToCopy),
        ],
      ),
    );
  }
}

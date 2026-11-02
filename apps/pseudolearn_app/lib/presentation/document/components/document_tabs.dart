import 'package:flutter/material.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';

enum DocumentTabKind { editor, flowchart, tasks, trace, equivalentCode }

final class DocumentTabs extends StatelessWidget {
  final DocumentTabKind activeTab;
  final ValueChanged<DocumentTabKind> onTabSelected;

  const DocumentTabs({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        for (final tab in DocumentTabKind.values)
          _DocumentTabItem(
            label: _tabLabel(l10n, tab),
            isSelected: activeTab == tab,
            onTap: () => onTabSelected(tab),
          ),
      ],
    );
  }
}

final class _DocumentTabItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DocumentTabItem({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: InkWell(
      onTap: onTap,
      child: _DocumentTabContent(label: label, isSelected: isSelected),
    ),
  );
}

final class _DocumentTabContent extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _DocumentTabContent({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final color = isSelected
        ? theme.colors.text.link
        : theme.colors.text.secondary;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.space1,
            right: SpacingTokens.space1,
            bottom: SpacingTokens.space2,
          ),
          child: AppText(
            label,
            variant: AppTextVariant.label,
            color: color,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isSelected) _DocumentTabIndicator(color: color),
      ],
    );
  }
}

final class _DocumentTabIndicator extends StatelessWidget {
  final Color color;

  const _DocumentTabIndicator({required this.color});

  @override
  Widget build(BuildContext context) => Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: Container(height: 3, color: color),
  );
}

String _tabLabel(AppLocalizations l10n, DocumentTabKind tab) => switch (tab) {
  DocumentTabKind.editor => l10n.tabEditor,
  DocumentTabKind.flowchart => l10n.tabDiagrams,
  DocumentTabKind.tasks => l10n.tabTasks,
  DocumentTabKind.trace => l10n.tabTrace,
  DocumentTabKind.equivalentCode => l10n.tabEquivalentCode,
};

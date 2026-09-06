import 'package:flutter/material.dart';
import '../../components/empty/app_empty_state.dart';
import '../../l10n/generated/app_localizations.dart';

final class KnowledgeSectionEmptyView extends StatelessWidget {
  final String searchQuery;

  const KnowledgeSectionEmptyView.content({super.key}) : searchQuery = '';

  const KnowledgeSectionEmptyView.search({super.key, required this.searchQuery});

  bool get _isSearch => searchQuery.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isSearch) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: l10n.knowledgeEmptySearchTitle,
        description: l10n.knowledgeEmptySearchDescription(searchQuery),
      );
    }
    return AppEmptyState(
      icon: Icons.menu_book_outlined,
      title: l10n.knowledgeEmptyTitle,
      description: l10n.knowledgeEmptyDescription,
    );
  }
}

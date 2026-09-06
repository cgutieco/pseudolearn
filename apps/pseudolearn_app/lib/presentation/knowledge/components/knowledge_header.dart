import 'package:flutter/material.dart';
import '../../components/field/app_search_field.dart';
import '../../l10n/generated/app_localizations.dart';

final class KnowledgeHeader extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  const KnowledgeHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppSearchField(
      controller: searchController,
      hintText: l10n.knowledgeSearchPlaceholder,
      onChanged: onSearchChanged,
    );
  }
}

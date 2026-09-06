import 'package:flutter/material.dart';
import '../../components/list/app_list_item.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';

void showDocumentContextMenu({
  required BuildContext context,
  required VoidCallback onRename,
  required VoidCallback onDelete,
}) {
  final theme = AppThemeExtension.of(context);
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: theme.colors.surfaces.raised,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.radiusXl)),
    ),
    builder: (sheetContext) => _ContextMenuSheet(
      onRename: onRename,
      onDelete: onDelete,
    ),
  );
}

final class _ContextMenuSheet extends StatelessWidget {
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const _ContextMenuSheet({
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RenameListItem(onRename: onRename),
          _DeleteListItem(onDelete: onDelete),
        ],
      ),
    );
  }
}

final class _RenameListItem extends StatelessWidget {
  final VoidCallback onRename;

  const _RenameListItem({required this.onRename});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppListItem(
      label: l10n.actionRename,
      icon: Icons.edit_outlined,
      onTap: () {
        Navigator.of(context).pop();
        onRename();
      },
    );
  }
}

final class _DeleteListItem extends StatelessWidget {
  final VoidCallback onDelete;

  const _DeleteListItem({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AppListItem(
      label: l10n.actionDelete,
      icon: Icons.delete_outline,
      onTap: () {
        Navigator.of(context).pop();
        onDelete();
      },
    );
  }
}

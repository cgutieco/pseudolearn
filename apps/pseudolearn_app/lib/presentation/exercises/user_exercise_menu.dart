import 'package:material_ui/material_ui.dart';
import '../components/list/app_list_item.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';

void showUserExerciseMenu({
  required BuildContext context,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppThemeExtension.of(context).colors.surfaces.raised,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(RadiusTokens.radiusXl)),
    ),
    builder: (sheetContext) => _MenuSheet(onEdit: onEdit, onDelete: onDelete),
  );
}

final class _MenuSheet extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuSheet({required this.onEdit, required this.onDelete});

  void _closeThen(BuildContext context, VoidCallback action) {
    Navigator.of(context).pop();
    action();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppListItem(
            key: const ValueKey('user-exercise-edit'),
            label: l10n.userExercisesEdit,
            icon: Icons.edit_outlined,
            onTap: () => _closeThen(context, onEdit),
          ),
          AppListItem(
            key: const ValueKey('user-exercise-delete'),
            label: l10n.userExercisesDelete,
            icon: Icons.delete_outline,
            onTap: () => _closeThen(context, onDelete),
          ),
        ],
      ),
    );
  }
}

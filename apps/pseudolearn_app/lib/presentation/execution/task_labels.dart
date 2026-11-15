import '../l10n/generated/app_localizations.dart';

String taskShortLabel(AppLocalizations l10n, int taskId) =>
    l10n.executionTaskShort(taskId);

String taskNamedLabel(AppLocalizations l10n, int taskId, String? name) {
  final resolved = taskId == 0 ? l10n.executionRootTaskName : name;
  return resolved == null
      ? l10n.executionTaskShort(taskId)
      : l10n.executionTaskNamed(taskId, resolved);
}

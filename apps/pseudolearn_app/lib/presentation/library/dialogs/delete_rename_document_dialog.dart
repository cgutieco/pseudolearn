import 'package:flutter/material.dart';
import '../../../domain/model/documents/document_title_policy.dart';
import '../../components/button/app_button.dart';
import '../../components/dialog/app_dialog.dart';
import '../../components/field/app_text_field.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/dialog_metrics.dart';
import '../../theme/tokens/spacing.dart';

void showRenameDocumentDialog({
  required BuildContext context,
  required String currentTitle,
  required ValueChanged<String> onConfirm,
  Iterable<String> existingTitles = const [],
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) => _RenameDialogContent(
      currentTitle: currentTitle,
      onConfirm: onConfirm,
      existingTitles: existingTitles,
    ),
  );
}

void showDeleteDocumentDialog({
  required BuildContext context,
  required String documentTitle,
  required VoidCallback onConfirm,
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext)!;
      return AppDialog(
        title: l10n.dialogDeleteDocTitle,
        body: l10n.dialogDeleteDocMessage(documentTitle),
        actions: [
          AppButton(
            label: l10n.actionCancel,
            variant: AppButtonVariant.tertiary,
            onPressed: () => Navigator.of(dialogContext).pop(),
          ),
          AppButton(
            label: l10n.actionDelete,
            variant: AppButtonVariant.primary,
            destructive: true,
            onPressed: () {
              onConfirm();
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      );
    },
  );
}

final class _RenameDialogContent extends StatefulWidget {
  final String currentTitle;
  final ValueChanged<String> onConfirm;
  final Iterable<String> existingTitles;

  const _RenameDialogContent({
    required this.currentTitle,
    required this.onConfirm,
    this.existingTitles = const [],
  });

  @override
  State<_RenameDialogContent> createState() => _RenameDialogContentState();
}

final class _RenameDialogContentState extends State<_RenameDialogContent> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final validation = validateDocumentTitle(
      _controller.text,
      widget.existingTitles,
      currentTitle: widget.currentTitle,
    );
    final l10n = AppLocalizations.of(context)!;
    switch (validation) {
      case DocumentTitleValidation.empty:
        setState(() => _errorText = l10n.validationNameEmpty);
        return;
      case DocumentTitleValidation.duplicate:
        setState(() => _errorText = l10n.validationNameDuplicate);
        return;
      case DocumentTitleValidation.valid:
        final normalized = normalizeDocumentTitle(_controller.text);
        widget.onConfirm(normalized);
        Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Dialog(
      backgroundColor: theme.colors.surfaces.overlay,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DialogMetricsTokens.radius)),
      constraints: const BoxConstraints(
        minWidth: DialogMetricsTokens.minWidth,
        maxWidth: DialogMetricsTokens.maxWidth,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DialogMetricsTokens.padding),
        child: _RenameDialogBody(
          controller: _controller,
          errorText: _errorText,
          onSubmit: _handleSubmit,
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
        ),
      ),
    );
  }
}

final class _RenameDialogBody extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback onSubmit;
  final ValueChanged<String> onChanged;

  const _RenameDialogBody({
    required this.controller,
    required this.errorText,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.dialogRenameDocTitle, variant: AppTextVariant.heading2, color: theme.colors.text.primary),
        const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
        AppTextField(controller: controller, label: l10n.dialogNewDocNameLabel, errorText: errorText, onChanged: onChanged),
        const SizedBox(height: DialogMetricsTokens.gapBodyToActions),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(label: l10n.actionCancel, variant: AppButtonVariant.tertiary, onPressed: () => Navigator.of(context).pop()),
            const SizedBox(width: SpacingTokens.space2),
            AppButton(label: l10n.actionRename, variant: AppButtonVariant.primary, onPressed: onSubmit),
          ],
        ),
      ],
    );
  }
}

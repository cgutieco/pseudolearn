import 'package:flutter/material.dart';
import '../../components/button/app_button.dart';
import '../../components/dialog/app_dialog.dart';
import '../../components/field/app_text_field.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/dialog_metrics.dart';
import '../../theme/tokens/spacing.dart';

void showDataInputDialog({
  required BuildContext context,
  String? prompt,
  required ValueChanged<String> onSubmit,
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) => _DataInputDialogContent(
      prompt: prompt,
      onSubmit: onSubmit,
    ),
  );
}

final class _DataInputDialogContent extends StatefulWidget {
  final String? prompt;
  final ValueChanged<String> onSubmit;

  const _DataInputDialogContent({
    this.prompt,
    required this.onSubmit,
  });

  @override
  State<_DataInputDialogContent> createState() => _DataInputDialogContentState();
}

final class _DataInputDialogContentState extends State<_DataInputDialogContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onSubmit(_controller.text);
    Navigator.of(context).pop();
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
        child: _InputBody(prompt: widget.prompt, controller: _controller, onSubmit: _submit),
      ),
    );
  }
}

final class _InputBody extends StatelessWidget {
  final String? prompt;
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _InputBody({required this.prompt, required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.inputDialogTitle, variant: AppTextVariant.heading2, color: theme.colors.text.primary),
        const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
        AppText(prompt ?? l10n.inputDialogPrompt, variant: AppTextVariant.bodyDefault, color: theme.colors.text.primary),
        const SizedBox(height: SpacingTokens.space3),
        AppTextField(controller: controller, onChanged: (_) {}),
        const SizedBox(height: DialogMetricsTokens.gapBodyToActions),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(label: l10n.inputDialogSubmit, variant: AppButtonVariant.primary, onPressed: onSubmit),
          ],
        ),
      ],
    );
  }
}

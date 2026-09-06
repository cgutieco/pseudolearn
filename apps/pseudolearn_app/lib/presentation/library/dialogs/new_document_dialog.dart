import 'package:flutter/material.dart';
import '../../../domain/model/documents/document_title_policy.dart';
import '../../../domain/model/profiles/syntax_profile_id.dart';
import '../../components/button/app_button.dart';
import '../../components/dialog/app_dialog.dart';
import '../../components/field/app_text_field.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/dialog_metrics.dart';
import '../../theme/tokens/spacing.dart';

void showNewDocumentDialog({
  required BuildContext context,
  required void Function(String title, SyntaxProfileId profileId) onConfirm,
  Iterable<String> existingTitles = const [],
  String initialTitle = '',
  SyntaxProfileId initialProfile = SyntaxProfileId.classicSpanish,
}) {
  showAppDialog<void>(
    context,
    builder: (dialogContext) => _NewDocumentDialogContent(
      onConfirm: onConfirm,
      existingTitles: existingTitles,
      initialTitle: initialTitle,
      initialProfile: initialProfile,
    ),
  );
}

final class _NewDocumentDialogContent extends StatefulWidget {
  final void Function(String title, SyntaxProfileId profileId) onConfirm;
  final Iterable<String> existingTitles;
  final String initialTitle;
  final SyntaxProfileId initialProfile;

  const _NewDocumentDialogContent({
    required this.onConfirm,
    this.existingTitles = const [],
    this.initialTitle = '',
    this.initialProfile = SyntaxProfileId.classicSpanish,
  });

  @override
  State<_NewDocumentDialogContent> createState() => _NewDocumentDialogContentState();
}

final class _NewDocumentDialogContentState extends State<_NewDocumentDialogContent> {
  late final TextEditingController _controller;
  late SyntaxProfileId _selectedProfile;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialTitle);
    _selectedProfile = widget.initialProfile;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final validation = validateDocumentTitle(_controller.text, widget.existingTitles);
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
        widget.onConfirm(normalized, _selectedProfile);
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
        child: _NewDocBody(
          controller: _controller,
          errorText: _errorText,
          selectedProfile: _selectedProfile,
          onProfileChanged: (p) => setState(() => _selectedProfile = p),
          onChanged: (_) {
            if (_errorText != null) setState(() => _errorText = null);
          },
          onSubmit: _handleSubmit,
        ),
      ),
    );
  }
}

final class _NewDocBody extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final SyntaxProfileId selectedProfile;
  final ValueChanged<SyntaxProfileId> onProfileChanged;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  const _NewDocBody({
    required this.controller,
    required this.errorText,
    required this.selectedProfile,
    required this.onProfileChanged,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.dialogNewDocTitle, variant: AppTextVariant.heading2, color: theme.colors.text.primary),
        const SizedBox(height: DialogMetricsTokens.gapTitleToBody),
        _NewDocFields(
          controller: controller,
          errorText: errorText,
          selectedProfile: selectedProfile,
          onProfileChanged: onProfileChanged,
          onChanged: onChanged,
        ),
        const SizedBox(height: DialogMetricsTokens.gapBodyToActions),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(label: l10n.actionCancel, variant: AppButtonVariant.tertiary, onPressed: () => Navigator.of(context).pop()),
            const SizedBox(width: SpacingTokens.space2),
            AppButton(label: l10n.actionCreate, variant: AppButtonVariant.primary, onPressed: onSubmit),
          ],
        ),
      ],
    );
  }
}

final class _NewDocFields extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final SyntaxProfileId selectedProfile;
  final ValueChanged<SyntaxProfileId> onProfileChanged;
  final ValueChanged<String> onChanged;

  const _NewDocFields({
    required this.controller,
    required this.errorText,
    required this.selectedProfile,
    required this.onProfileChanged,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(controller: controller, label: l10n.dialogNewDocNameLabel, errorText: errorText, onChanged: onChanged),
        const SizedBox(height: SpacingTokens.space4),
        _ProfileSelector(selectedProfile: selectedProfile, onProfileChanged: onProfileChanged),
      ],
    );
  }
}

final class _ProfileSelector extends StatelessWidget {
  final SyntaxProfileId selectedProfile;
  final ValueChanged<SyntaxProfileId> onProfileChanged;

  const _ProfileSelector({
    required this.selectedProfile,
    required this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(l10n.dialogNewDocProfileLabel, variant: AppTextVariant.label),
        const SizedBox(height: SpacingTokens.space2),
        Row(
          children: [
            ChoiceChip(
              label: Text(l10n.profileSpanish),
              selected: selectedProfile == SyntaxProfileId.classicSpanish,
              onSelected: (selected) {
                if (selected) onProfileChanged(SyntaxProfileId.classicSpanish);
              },
            ),
            const SizedBox(width: SpacingTokens.space2),
            ChoiceChip(
              label: Text(l10n.profileEnglish),
              selected: selectedProfile == SyntaxProfileId.english,
              onSelected: (selected) {
                if (selected) onProfileChanged(SyntaxProfileId.english);
              },
            ),
          ],
        ),
      ],
    );
  }
}

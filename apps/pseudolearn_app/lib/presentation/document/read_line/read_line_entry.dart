import 'package:material_ui/material_ui.dart';

import '../../../domain/model/execution/read_request.dart';
import '../../../domain/model/execution/read_value_type.dart';
import '../../components/button/app_button.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'read_line_target.dart';

final class ReadLineEntry extends StatelessWidget {
  final ReadRequest? request;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  const ReadLineEntry({
    super.key,
    required this.request,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final designator = request?.designator ?? '';
    return Row(
      children: [
        if (designator.isNotEmpty) _AssignmentPrefix(designator: designator),
        Expanded(
          child: _ReadLineField(
            request: request,
            controller: controller,
            onSubmit: onSubmit,
          ),
        ),
        const SizedBox(width: SpacingTokens.space2),
        AppButton(
          label: l10n.readLineAssign,
          variant: AppButtonVariant.primary,
          icon: Icons.keyboard_return,
          onPressed: () => onSubmit(controller.text),
        ),
      ],
    );
  }
}

final class _AssignmentPrefix extends StatelessWidget {
  final String designator;

  const _AssignmentPrefix({required this.designator});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: SpacingTokens.space2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReadLineTarget(designator: designator),
          const SizedBox(width: SpacingTokens.space2),
          AppText(
            '<-',
            variant: AppTextVariant.codeEditor,
            color: theme.colors.text.link,
          ),
        ],
      ),
    );
  }
}

final class _ReadLineField extends StatelessWidget {
  final ReadRequest? request;
  final TextEditingController controller;
  final ValueChanged<String> onSubmit;

  const _ReadLineField({
    required this.request,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return Semantics(
      label: l10n.readLineFieldLabel(request?.designator ?? ''),
      textField: true,
      child: TextField(
        controller: controller,
        autofocus: true,
        keyboardType: _keyboardFor(request?.valueType),
        textInputAction: TextInputAction.done,
        autocorrect: false,
        enableSuggestions: false,
        onSubmitted: onSubmit,
        cursorColor: theme.colors.borders.focus,
        style: resolveAppTextStyle(
          context,
          AppTextVariant.codeEditor,
          color: theme.colors.text.primary,
        ),
        decoration: const InputDecoration.collapsed(hintText: null),
      ),
    );
  }

  static TextInputType _keyboardFor(ReadValueType? type) => switch (type) {
    ReadValueType.integer => const TextInputType.numberWithOptions(
      signed: true,
    ),
    ReadValueType.real => const TextInputType.numberWithOptions(
      signed: true,
      decimal: true,
    ),
    _ => TextInputType.text,
  };
}

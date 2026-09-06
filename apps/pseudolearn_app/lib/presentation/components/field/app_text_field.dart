import 'package:flutter/material.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/field_metrics.dart';
import '../typography/app_text.dart';

OutlineInputBorder _borderWith(Color color, double width, double radius) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );

final class _FieldBorders {
  final InputBorder rest;
  final InputBorder focus;
  final InputBorder error;

  const _FieldBorders({required this.rest, required this.focus, required this.error});

  static _FieldBorders from(AppThemeExtension theme) {
    const radius = FieldMetricsTokens.radius;
    return _FieldBorders(
      rest: _borderWith(theme.colors.borders.strong, BorderMetricsTokens.widthHairline, radius),
      focus: _borderWith(theme.colors.borders.focus, BorderMetricsTokens.widthEmphasis, radius),
      error: _borderWith(theme.colors.severities.error.fg, BorderMetricsTokens.widthEmphasis, radius),
    );
  }
}

final class _ClearButton extends StatelessWidget {
  final VoidCallback onClear;
  final String? tooltip;
  final Color color;

  const _ClearButton({required this.onClear, required this.tooltip, required this.color});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.clear, size: FieldMetricsTokens.iconTrailingClearSize),
      color: color,
      onPressed: onClear,
      tooltip: tooltip,
    );
  }
}

enum AppTextFieldSize { standard, compact }

InputDecoration _decorationFor(
  BuildContext context, {
  required AppTextField field,
  required double horizontalPadding,
  required double verticalPadding,
  required bool hasError,
}) {
  final theme = AppThemeExtension.of(context);
  final borders = _FieldBorders.from(theme);
  final leadingIcon = field.leadingIcon;
  final onClear = field.onClear;

  return InputDecoration(
    isDense: field.size == AppTextFieldSize.compact,
    filled: true,
    fillColor: theme.colors.surfaces.defaultSurface,
    hintText: field.placeholder,
    hintStyle: resolveAppTextStyle(context, AppTextVariant.bodyDefault, color: theme.colors.text.tertiary),
    contentPadding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
    prefixIcon: leadingIcon == null
        ? null
        : Icon(leadingIcon, size: FieldMetricsTokens.iconLeadingSize, color: theme.colors.text.tertiary),
    suffixIcon: onClear == null
        ? null
        : _ClearButton(onClear: onClear, tooltip: field.semanticLabel ?? field.label, color: theme.colors.text.tertiary),
    border: borders.rest,
    enabledBorder: hasError ? borders.error : borders.rest,
    disabledBorder: borders.rest,
    focusedBorder: borders.focus,
    errorBorder: borders.error,
    focusedErrorBorder: borders.focus,
  );
}

final class AppTextField extends StatelessWidget {
  final String? label;
  final String? semanticLabel;
  final String? placeholder;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool autofocus;
  final AppTextFieldSize size;
  final IconData? leadingIcon;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TapRegionCallback? onTapOutside;
  final TextStyle? textStyle;

  const AppTextField({
    super.key,
    this.label,
    this.semanticLabel,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.autofocus = false,
    this.size = AppTextFieldSize.standard,
    this.leadingIcon,
    this.onClear,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onTapOutside,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final hasError = (errorText ?? '').isNotEmpty;
    final helperMessage = hasError ? errorText : helperText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          AppText(label!, variant: AppTextVariant.label, color: theme.colors.text.secondary),
          const SizedBox(height: FieldMetricsTokens.gapLabelToField),
        ],
        _FieldInput(field: this, hasError: hasError),
        if (helperMessage != null && helperMessage.isNotEmpty) ...[
          const SizedBox(height: FieldMetricsTokens.gapFieldToHelper),
          AppText(
            helperMessage,
            variant: AppTextVariant.caption,
            color: hasError ? theme.colors.severities.error.fg : theme.colors.text.tertiary,
          ),
        ],
      ],
    );
  }
}

final class _FieldInput extends StatelessWidget {
  final AppTextField field;
  final bool hasError;

  const _FieldInput({required this.field, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final isCompact = field.size == AppTextFieldSize.compact;
    final rawHeight = isCompact ? FieldMetricsTokens.heightCompact : FieldMetricsTokens.height;

    return SizedBox(
      height: canvas.scaled(rawHeight),
      child: Semantics(
        label: field.semanticLabel ?? field.label,
        textField: true,
        child: _RawField(field: field, hasError: hasError),
      ),
    );
  }
}

final class _RawField extends StatelessWidget {
  final AppTextField field;
  final bool hasError;

  const _RawField({required this.field, required this.hasError});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final canvas = DesignCanvasScope.of(context);
    final isCompact = field.size == AppTextFieldSize.compact;
    final rawVertical = isCompact ? FieldMetricsTokens.paddingVerticalCompact : FieldMetricsTokens.paddingVertical;

    return TextField(
      controller: field.controller,
      enabled: field.enabled,
      autofocus: field.autofocus,
      onChanged: field.onChanged,
      onSubmitted: field.onSubmitted,
      onTapOutside: field.onTapOutside,
      style: field.textStyle ?? resolveAppTextStyle(context, AppTextVariant.bodyDefault, color: theme.colors.text.primary),
      cursorColor: theme.colors.borders.focus,
      cursorWidth: 2.0,
      decoration: _decorationFor(
        context,
        field: field,
        horizontalPadding: canvas.scaled(FieldMetricsTokens.paddingHorizontal),
        verticalPadding: canvas.scaled(rawVertical),
        hasError: hasError,
      ),
    );
  }
}

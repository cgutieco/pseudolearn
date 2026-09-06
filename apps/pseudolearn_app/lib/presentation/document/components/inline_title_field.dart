import 'package:flutter/material.dart';
import '../../components/field/app_text_field.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/icon_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class InlineTitleField extends StatefulWidget {
  final String title;
  final ValueChanged<String> onTitleChanged;

  const InlineTitleField({
    super.key,
    required this.title,
    required this.onTitleChanged,
  });

  @override
  State<InlineTitleField> createState() => _InlineTitleFieldState();
}

final class _InlineTitleFieldState extends State<InlineTitleField> {
  late final TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.title);
  }

  @override
  void didUpdateWidget(InlineTitleField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing && oldWidget.title != widget.title) {
      _controller.text = widget.title;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() => _isEditing = false);
    final text = _controller.text.trim();
    if (text.isNotEmpty && text != widget.title) {
      widget.onTitleChanged(text);
    } else {
      _controller.text = widget.title;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return _TitleEditorBox(
        controller: _controller,
        onSubmit: _submit,
      );
    }

    return _TitleDisplayChip(
      title: widget.title,
      onTap: () => setState(() => _isEditing = true),
    );
  }
}

final class _TitleEditorBox extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _TitleEditorBox({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ComponentMetricsTokens.inlineTitleFieldWidth,
      child: AppTextField(
        controller: controller,
        size: AppTextFieldSize.compact,
        autofocus: true,
        onSubmitted: (_) => onSubmit(),
        onTapOutside: (_) => onSubmit(),
      ),
    );
  }
}

final class _TitleDisplayChip extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _TitleDisplayChip({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2, vertical: SpacingTokens.space1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AppText(
                title,
                variant: AppTextVariant.heading3,
                color: theme.colors.text.primary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: SpacingTokens.space1),
            Icon(Icons.edit, size: IconMetricsTokens.iconXs, color: theme.colors.text.tertiary),
          ],
        ),
      ),
    );
  }
}

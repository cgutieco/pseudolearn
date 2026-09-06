import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/editor/editor_cubit.dart';
import '../../../application/editor/editor_state.dart';
import '../../components/button/app_button.dart';
import '../../components/button/app_icon_button.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'inline_title_field.dart';

final class DocumentHeader extends StatelessWidget {
  final VoidCallback onBack;
  final ValueChanged<String> onTitleChanged;

  const DocumentHeader({
    super.key,
    required this.onBack,
    required this.onTitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return BlocBuilder<EditorCubit, EditorState>(
      builder: (context, state) {
        final title = state.document?.title ?? '...';
        return Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
          decoration: BoxDecoration(
            color: theme.colors.surfaces.raised,
            border: Border(bottom: BorderSide(color: theme.colors.borders.subtle, width: 1)),
          ),
          child: Row(
            children: [
              AppIconButton(icon: Icons.arrow_back, semanticLabel: 'Volver', variant: AppButtonVariant.tertiary, onPressed: onBack),
              const SizedBox(width: SpacingTokens.space2),
              Expanded(child: InlineTitleField(title: title, onTitleChanged: onTitleChanged)),
              if (state.isSaving)
                AppText('Guardando...', variant: AppTextVariant.caption, color: theme.colors.text.tertiary),
            ],
          ),
        );
      },
    );
  }
}

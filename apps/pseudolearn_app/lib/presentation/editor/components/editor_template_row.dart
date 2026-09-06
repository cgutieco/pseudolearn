import 'package:flutter/material.dart';
import '../../../domain/model/completion/completion_item.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/border_metrics.dart';
import '../../theme/tokens/component_metrics.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class EditorTemplateRow extends StatelessWidget {
  final List<CompletionItem> templates;
  final ValueChanged<CompletionItem> onTemplateSelected;

  const EditorTemplateRow({
    super.key,
    required this.templates,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ComponentMetricsTokens.editorTemplateRowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space3),
        itemCount: templates.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: SpacingTokens.space2),
        itemBuilder: (context, index) => _TemplateChip(
          template: templates[index],
          onTap: () => onTemplateSelected(templates[index]),
        ),
      ),
    );
  }
}

final class _TemplateChip extends StatelessWidget {
  final CompletionItem template;
  final VoidCallback onTap;

  const _TemplateChip({required this.template, required this.onTap});

  Color _chipColor(AppThemeExtension theme) => switch (template.family) {
        CompletionFamily.structured => theme.syntax.keywordStructured,
        CompletionFamily.procedural => theme.syntax.keywordProcedural,
        CompletionFamily.oop => theme.syntax.keywordOop,
      };

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final radius = BorderRadius.circular(RadiusTokens.radiusSm);
    final chipBorder = Border.all(
      color: theme.colors.borders.subtle,
      width: BorderMetricsTokens.widthHairline,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: radius,
      child: Center(
        child: Container(
          height: ComponentMetricsTokens.editorTemplateChipHeight,
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.space2),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colors.surfaces.defaultSurface,
            borderRadius: radius,
            border: chipBorder,
          ),
          child: AppText(template.label,
              variant: AppTextVariant.codeInline, color: _chipColor(theme)),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../domain/model/knowledge/content_block.dart';
import '../../../../components/typography/app_text.dart';
import '../../../../diagram/diagram_structure_painter.dart';
import '../../../../editor/components/code_preview.dart';
import '../../../../theme/app_theme.dart';
import '../../../../theme/tokens/border_metrics.dart';
import '../../../../theme/tokens/radii.dart';
import '../../../../theme/tokens/spacing.dart';

final class CodeBlockView extends StatelessWidget {
  final CodeBlock block;

  const CodeBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final title = block.title;
    return _BlockBox(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) _CodeBlockHeader(title: title, theme: theme),
          CodePreview(
            text: block.code,
            highlightSpans: block.highlightSpans,
          ),
        ],
      ),
    );
  }
}

final class DiagramBlockView extends StatelessWidget {
  final DiagramBlock block;

  const DiagramBlockView({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block.scene.isEmpty) {
      return CodeBlockView(
        block: CodeBlock(code: block.code, title: block.title),
      );
    }
    final theme = AppThemeExtension.of(context);
    final title = block.title;
    return _BlockBox(
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) _CodeBlockHeader(title: title, theme: theme),
          Padding(
            padding: const EdgeInsets.all(SpacingTokens.space3),
            child: _DiagramSceneView(block: block),
          ),
        ],
      ),
    );
  }
}

final class _BlockBox extends StatelessWidget {
  final Widget child;
  final AppThemeExtension theme;

  const _BlockBox({required this.child, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingTokens.space4),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
        border: Border.all(
          color: theme.colors.borders.subtle,
          width: BorderMetricsTokens.widthHairline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

final class _CodeBlockHeader extends StatelessWidget {
  final String title;
  final AppThemeExtension theme;

  const _CodeBlockHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    final border = BorderSide(
      color: theme.colors.borders.subtle,
      width: BorderMetricsTokens.widthHairline,
    );
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.space3,
        vertical: SpacingTokens.space2,
      ),
      decoration: BoxDecoration(
        color: theme.colors.surfaces.canvas,
        border: Border(bottom: border),
      ),
      child: Row(
        children: [
          Icon(Icons.code_rounded, size: 16, color: theme.colors.text.secondary),
          const SizedBox(width: SpacingTokens.space2),
          Expanded(
            child: AppText(title, variant: AppTextVariant.label, color: theme.colors.text.primary),
          ),
        ],
      ),
    );
  }
}

final class _DiagramSceneView extends StatelessWidget {
  final DiagramBlock block;

  const _DiagramSceneView({required this.block});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: SizedBox(
          width: block.scene.width,
          height: block.scene.height,
          child: CustomPaint(
            painter: structurePainterFor(block.notation, block.scene, theme.colors),
          ),
        ),
      ),
    );
  }
}

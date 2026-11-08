import 'package:flutter/material.dart';
import '../../../domain/model/agent/reply_run.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';

final class ReplyRunsText extends StatelessWidget {
  final List<ReplyRun> runs;
  final AppTextVariant variant;
  final TextAlign textAlign;

  const ReplyRunsText({
    super.key,
    required this.runs,
    this.variant = AppTextVariant.bodyDefault,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final code = resolveAppTextStyle(context, AppTextVariant.codeInline).copyWith(
      backgroundColor: theme.colors.surfaces.raised,
      color: theme.syntax.literalText,
    );
    return Text.rich(
      TextSpan(children: [for (final run in runs) TextSpan(text: run.text, style: _styleOf(run, code, theme))]),
      style: resolveAppTextStyle(context, variant, color: theme.colors.text.primary),
      textAlign: textAlign,
      textScaler: resolveAppTextScaler(variant),
    );
  }
}

TextStyle _styleOf(ReplyRun run, TextStyle code, AppThemeExtension theme) {
  final base = run.has(ReplyMark.code) ? code : const TextStyle();
  final linked = run.target != null;
  return base.copyWith(
    fontWeight: run.has(ReplyMark.strong) ? FontWeight.w600 : null,
    fontStyle: run.has(ReplyMark.emphasis) ? FontStyle.italic : null,
    color: linked ? theme.colors.text.link : base.color,
    decoration: TextDecoration.combine([
      if (run.has(ReplyMark.strikethrough)) TextDecoration.lineThrough,
      if (linked) TextDecoration.underline,
    ]),
  );
}

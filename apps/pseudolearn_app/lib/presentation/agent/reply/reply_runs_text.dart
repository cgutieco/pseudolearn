import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/agent/reply_link_policy.dart';
import '../../../domain/model/agent/reply_run.dart';
import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';

final class ReplyRunsText extends StatefulWidget {
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
  State<ReplyRunsText> createState() => _ReplyRunsTextState();
}

final class _ReplyRunsTextState extends State<ReplyRunsText> {
  final List<TapGestureRecognizer> _recognizers = [];

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  void _disposeRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  TapGestureRecognizer? _recognizerFor(ReplyRun run) {
    if (openableReplyLink(run.target) == null) return null;
    final recognizer = TapGestureRecognizer()
      ..onTap = () => context.read<ReplyLinkOpener>().open(run.target);
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final theme = AppThemeExtension.of(context);
    final code = resolveAppTextStyle(context, AppTextVariant.codeInline).copyWith(
      backgroundColor: theme.colors.surfaces.raised,
      color: theme.syntax.literalText,
    );
    return Text.rich(
      TextSpan(
        children: [
          for (final run in widget.runs)
            TextSpan(
              text: run.text,
              style: _styleOf(run, code, theme),
              recognizer: _recognizerFor(run),
            ),
        ],
      ),
      style: resolveAppTextStyle(context, widget.variant, color: theme.colors.text.primary),
      textAlign: widget.textAlign,
      textScaler: resolveAppTextScaler(widget.variant),
    );
  }
}

TextStyle _styleOf(ReplyRun run, TextStyle code, AppThemeExtension theme) {
  final base = run.has(ReplyMark.code) ? code : const TextStyle();
  final linked = openableReplyLink(run.target) != null;
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

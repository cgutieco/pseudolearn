import 'package:material_ui/material_ui.dart';
import '../../../domain/model/analysis/highlight_span.dart';
import '../../components/typography/app_text.dart';
import '../../editor/help/help_code_spans.dart';
import '../../theme/app_theme.dart';

final class ReplyCodeText extends StatelessWidget {
  final String source;
  final List<HighlightSpan> highlightSpans;

  const ReplyCodeText({super.key, required this.source, this.highlightSpans = const []});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Text.rich(
        TextSpan(children: highlightedCodeSpans(source, highlightSpans, theme.syntax)),
        style: resolveAppTextStyle(context, AppTextVariant.codeEditor, color: theme.syntax.ink),
        textScaler: resolveAppTextScaler(AppTextVariant.codeEditor),
        softWrap: false,
      ),
    );
  }
}

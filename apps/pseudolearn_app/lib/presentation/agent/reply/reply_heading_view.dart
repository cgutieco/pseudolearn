import 'package:flutter/material.dart';
import '../../../domain/model/agent/reply_block.dart';
import '../../components/typography/app_text.dart';
import 'reply_runs_text.dart';

const List<AppTextVariant> _variantsByLevel = [
  AppTextVariant.heading3,
  AppTextVariant.heading4,
  AppTextVariant.label,
];

final class ReplyHeadingView extends StatelessWidget {
  final ReplyHeading heading;

  const ReplyHeadingView({super.key, required this.heading});

  @override
  Widget build(BuildContext context) {
    final level = heading.level.clamp(1, _variantsByLevel.length);
    return Semantics(
      header: true,
      child: ReplyRunsText(runs: heading.runs, variant: _variantsByLevel[level - 1]),
    );
  }
}

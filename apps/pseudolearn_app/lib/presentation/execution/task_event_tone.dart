import 'package:material_ui/material_ui.dart';
import '../../domain/model/execution/task_event_kind.dart';
import '../theme/tokens/color_semantic.dart';

final class TaskEventTone {
  final IconData icon;
  final Color color;

  const TaskEventTone({required this.icon, required this.color});

  factory TaskEventTone.of(TaskEventKind kind, AppSemanticColors colors) =>
      switch (kind) {
        TaskEventKind.spawn => TaskEventTone(
          icon: Icons.call_split,
          color: colors.text.link,
        ),
        TaskEventKind.ready => TaskEventTone(
          icon: Icons.hourglass_top,
          color: colors.severities.info.fg,
        ),
        TaskEventKind.resume => TaskEventTone(
          icon: Icons.play_arrow,
          color: colors.text.link,
        ),
        TaskEventKind.suspend => TaskEventTone(
          icon: Icons.pause,
          color: colors.severities.warning.fg,
        ),
        TaskEventKind.complete || TaskEventKind.join => TaskEventTone(
          icon: Icons.check,
          color: colors.severities.success.fg,
        ),
        TaskEventKind.cancelRequest || TaskEventKind.failure => TaskEventTone(
          icon: Icons.error_outline,
          color: colors.severities.error.fg,
        ),
        TaskEventKind.channelCreate ||
        TaskEventKind.channelSend ||
        TaskEventKind.channelReceive ||
        TaskEventKind.channelEmpty ||
        TaskEventKind.channelClose => TaskEventTone(
          icon: Icons.swap_horiz,
          color: colors.severities.info.fg,
        ),
        _ => TaskEventTone(icon: Icons.east, color: colors.text.tertiary),
      };
}

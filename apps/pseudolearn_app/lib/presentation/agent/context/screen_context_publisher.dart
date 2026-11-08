import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/agent/screen_context_board.dart';
import '../../../domain/model/agent/screen_context_snapshot.dart';

final class ScreenContextPublisher extends StatefulWidget {
  final ScreenContextSnapshot snapshot;
  final String Function()? fullText;
  final Widget child;

  const ScreenContextPublisher({
    super.key,
    required this.snapshot,
    required this.child,
    this.fullText,
  });

  @override
  State<ScreenContextPublisher> createState() => _ScreenContextPublisherState();
}

final class _ScreenContextPublisherState extends State<ScreenContextPublisher> {
  ScreenContextBoard? _board;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _board = context.read<ScreenContextBoard?>();
    _publish();
  }

  @override
  void didUpdateWidget(ScreenContextPublisher oldWidget) {
    super.didUpdateWidget(oldWidget);
    _publish();
  }

  @override
  void dispose() {
    _board?.withdraw(widget.snapshot.screen);
    super.dispose();
  }

  void _publish() => _board?.publish(widget.snapshot, fullText: widget.fullText);

  @override
  Widget build(BuildContext context) => widget.child;
}

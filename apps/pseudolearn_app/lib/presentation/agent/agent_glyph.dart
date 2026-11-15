import 'package:flutter/widgets.dart';
import '../shell/design_canvas.dart';
import '../theme/tokens/motion.dart';
import 'agent_glyph_painter.dart';

final class AgentGlyph extends StatefulWidget {
  final AgentGlyphState state;
  final Color color;
  final double size;

  const AgentGlyph({super.key, required this.state, required this.color, this.size = 24});

  @override
  State<AgentGlyph> createState() => _AgentGlyphState();
}

final class _AgentGlyphState extends State<AgentGlyph> with SingleTickerProviderStateMixin {
  late final AnimationController _turn = AnimationController(
    vsync: this,
    duration: MotionTokens.motionScreen * 4,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(AgentGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    final reduced = DesignCanvasScope.of(context).reduceMotion;
    final spinning = widget.state == AgentGlyphState.thinking && !reduced;
    if (spinning && !_turn.isAnimating) {
      _turn.repeat();
    } else if (!spinning && _turn.isAnimating) {
      _turn.stop();
      _turn.value = 0;
    }
  }

  @override
  void dispose() {
    _turn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _turn,
      builder: (context, _) => CustomPaint(
        size: Size.square(widget.size),
        painter: AgentGlyphPainter(state: widget.state, color: widget.color, turn: _turn.value),
      ),
    );
  }
}

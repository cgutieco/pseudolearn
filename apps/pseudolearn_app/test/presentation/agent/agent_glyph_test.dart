import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/agent/agent_session_state.dart';
import 'package:pseudolearn_app/domain/model/credits/credit_failure.dart';
import 'package:pseudolearn_app/presentation/agent/agent_glyph.dart';
import 'package:pseudolearn_app/presentation/agent/agent_glyph_painter.dart';
import 'package:pseudolearn_app/presentation/agent/agent_launcher.dart';
import 'package:pseudolearn_app/presentation/shell/design_canvas.dart';

const Color _ink = Color(0xFFFFFFFF);

Widget _canvas(Widget child, {bool reduceMotion = false}) => MediaQuery(
  data: MediaQueryData(size: const Size(400, 400), disableAnimations: reduceMotion),
  child: Directionality(textDirection: TextDirection.ltr, child: DesignCanvas(child: Center(child: child))),
);

void main() {
  testWidgets('idle paints the node, eyes, connector and a filled spark', (tester) async {
    await tester.pumpWidget(_canvas(const AgentGlyph(state: AgentGlyphState.idle, color: _ink)));
    expect(
      find.byType(CustomPaint),
      paints
        ..circle(x: 9, y: 15, radius: 5, style: PaintingStyle.stroke)
        ..circle(x: 7.25, y: 14.5)
        ..circle(x: 10.75, y: 14.5)
        ..path()
        ..path(style: PaintingStyle.fill),
    );
  });

  testWidgets('without credits the spark is hollow and a new reply adds a dot', (tester) async {
    await tester.pumpWidget(_canvas(const AgentGlyph(state: AgentGlyphState.noCredits, color: _ink)));
    expect(find.byType(CustomPaint), paints..path()..path(style: PaintingStyle.stroke));
    await tester.pumpWidget(_canvas(const AgentGlyph(state: AgentGlyphState.newReply, color: _ink)));
    expect(find.byType(CustomPaint), paints..path()..path(style: PaintingStyle.fill)..circle(x: 20.5, y: 18, radius: 2));
  });

  testWidgets('thinking spins and reduced motion keeps it still', (tester) async {
    await tester.pumpWidget(_canvas(const AgentGlyph(state: AgentGlyphState.thinking, color: _ink)));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(_canvas(const AgentGlyph(state: AgentGlyphState.thinking, color: _ink), reduceMotion: true));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  test('the painter repaints only when its inputs change', () {
    const base = AgentGlyphPainter(state: AgentGlyphState.idle, color: _ink);
    expect(base.shouldRepaint(const AgentGlyphPainter(state: AgentGlyphState.idle, color: _ink)), isFalse);
    expect(base.shouldRepaint(const AgentGlyphPainter(state: AgentGlyphState.idle, color: _ink, turn: 0.5)), isTrue);
  });

  test('the launcher glyph follows the session state', () {
    expect(glyphStateOf(const AgentSessionState()), AgentGlyphState.idle);
    expect(glyphStateOf(const AgentSessionState(status: AgentSessionStatus.thinking)), AgentGlyphState.thinking);
    expect(glyphStateOf(const AgentSessionState(failure: CreditFailure.creditsExhausted)), AgentGlyphState.noCredits);
    expect(glyphStateOf(const AgentSessionState(hasUnseenReply: true)), AgentGlyphState.newReply);
  });
}

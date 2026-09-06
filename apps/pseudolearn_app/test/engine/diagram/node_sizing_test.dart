import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_metrics.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/engine/diagram/node_sizing.dart';
import 'package:pseudolearn_app/engine/diagram/text_metrics.dart';

void main() {
  const sizing = NodeSizing(TextMetrics());

  test('a longer text produces a wider box', () {
    final short = sizing.measure('a', DiagramShape.process);
    final long = sizing.measure('contador acumulado total', DiagramShape.process);
    expect(long.width, greaterThan(short.width));
  });

  test('a decision is wider and taller than a process holding the same text', () {
    const text = 'contador > 0';
    final process = sizing.measure(text, DiagramShape.process);
    final decision = sizing.measure(text, DiagramShape.decision);
    expect(decision.width, greaterThan(process.width));
    expect(decision.height, greaterThan(process.height));
  });

  test('a decision wraps its text narrower than a process, so it stays readable', () {
    const text = 'contador acumulado > limite maximo permitido';
    final process = sizing.measure(text, DiagramShape.process);
    final decision = sizing.measure(text, DiagramShape.decision);
    expect(decision.lines.length, greaterThanOrEqualTo(process.lines.length));
    expect(decision.height, greaterThan(process.height));
  });

  test('a preparation symbol reserves room for its cut corners', () {
    const text = 'indice <- 1 Hasta limite';
    final process = sizing.measure(text, DiagramShape.process);
    final preparation = sizing.measure(text, DiagramShape.preparation);
    expect(preparation.width, greaterThan(process.width));
  });

  test('an input output symbol reserves room for its skew', () {
    const text = 'Leer contador, acumulado';
    final process = sizing.measure(text, DiagramShape.process);
    final io = sizing.measure(text, DiagramShape.inputOutput);
    expect(io.width, greaterThan(process.width));
  });

  test('a connector is a fixed circle carrying no text', () {
    final connector = sizing.measure('', DiagramShape.connector);
    expect(connector.width, DiagramMetrics.connectorDiameter);
    expect(connector.height, DiagramMetrics.connectorDiameter);
    expect(connector.lines, isEmpty);
  });

  test('no box falls below the minimum size', () {
    final tiny = sizing.measure('x', DiagramShape.process);
    expect(tiny.width, greaterThanOrEqualTo(DiagramMetrics.nodeMinWidth));
    expect(tiny.height, greaterThanOrEqualTo(DiagramMetrics.nodeMinHeight));
  });

  test('a very long text wraps instead of growing without bound', () {
    final long = sizing.measure('n' * 400, DiagramShape.process);
    expect(long.lines.length, DiagramMetrics.maxTextLines);
    expect(long.width, lessThanOrEqualTo(DiagramMetrics.nodeMaxWidth));
  });

  test('an empty text still yields a usable box', () {
    final empty = sizing.measure('', DiagramShape.process);
    expect(empty.width, greaterThanOrEqualTo(DiagramMetrics.nodeMinWidth));
    expect(empty.height, greaterThanOrEqualTo(DiagramMetrics.nodeMinHeight));
  });

  test('the same text measures the same twice', () {
    expect(
      sizing.measure('f <- f * i', DiagramShape.process).width,
      sizing.measure('f <- f * i', DiagramShape.process).width,
    );
  });
}

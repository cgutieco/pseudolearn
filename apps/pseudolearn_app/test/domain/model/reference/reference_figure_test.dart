import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_figure.dart';
import 'package:pseudolearn_app/domain/model/reference/reference_run.dart';

const _figure = ReferenceFigure(
  id: 'caja',
  number: '6.1-1',
  alt: 'Caja',
  description: 'Una caja',
  caption: [ReferenceTextRun('Pie')],
  svg: '<svg><rect/></svg>',
  layers: [
    ReferenceFigureLayer(fromStep: 1, untilStep: 1, svg: '<g id="uno"/>'),
    ReferenceFigureLayer(fromStep: 2, svg: '<g id="dos"/>'),
  ],
  steps: [
    [ReferenceTextRun('Primero')],
    [ReferenceTextRun('Segundo')],
    [ReferenceTextRun('Tercero')],
  ],
  panels: [
    ReferenceFigurePanel(zone: 'Memoria', fromStep: 1, runs: []),
    ReferenceFigurePanel(zone: 'Salida', fromStep: 3, runs: []),
    ReferenceFigurePanel(zone: 'Memoria', fromStep: 2, runs: []),
  ],
);

void main() {
  group('ReferenceFigure', () {
    test('inserts the layers of a step before the closing tag', () {
      expect(_figure.svgAt(1), '<svg><rect/><g id="uno"/></svg>');
      expect(_figure.svgAt(2), '<svg><rect/><g id="dos"/></svg>');
      expect(_figure.svgAt(3), '<svg><rect/><g id="dos"/></svg>');
    });

    test('keeps the base when no layer is visible or the svg is malformed', () {
      expect(_figure.svgAt(0), '<svg><rect/></svg>');
      const broken = ReferenceFigure(
        id: 'x',
        number: '1',
        alt: '',
        description: '',
        caption: [],
        svg: 'nada',
        layers: [ReferenceFigureLayer(fromStep: 1, svg: '<g/>')],
      );
      expect(broken.svgAt(1), 'nada');
    });

    test('accumulates panels and zones in first-appearance order', () {
      expect(_figure.panelsAt(1).length, 1);
      expect(_figure.panelsAt(3).length, 3);
      expect(_figure.zonesAt(3), ['Memoria', 'Salida']);
      expect(_figure.zonesAt(0), isEmpty);
      expect(_figure.stepCount, 3);
    });
  });

  test('reads the aspect ratio from the viewBox', () {
    expect(svgAspectRatio('<svg viewBox="0 0 340 170">'), 2);
    expect(svgAspectRatio('<svg>'), 1);
    expect(svgAspectRatio('<svg viewBox="0 0 340">'), 1);
    expect(svgAspectRatio('<svg viewBox="0 0 340 0">'), 1);
    expect(svgAspectRatio('<svg viewBox="0 0 340'), 1);
  });
}

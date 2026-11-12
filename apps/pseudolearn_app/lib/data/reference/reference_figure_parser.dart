import '../../domain/model/reference/reference_figure.dart';
import 'reference_json.dart';
import 'reference_run_parser.dart';

ReferenceFigure parseFigure(Map<String, Object?> source) {
  return ReferenceFigure(
    id: textOf(source, 'id'),
    number: textOf(source, 'number'),
    alt: optionalTextOf(source, 'alt'),
    description: optionalTextOf(source, 'description'),
    caption: parseRuns(source['caption']),
    svg: textOf(source, 'svg'),
    layers: mappedList(source['layers'], _layer),
    steps: mappedList(
      source['steps'],
      (step) => parseRuns(objectOf(step)['runs']),
    ),
    panels: mappedList(source['panels'], _panel),
  );
}

ReferenceFigureLayer _layer(Object? value) {
  final source = objectOf(value);
  final until = source['until_step'];
  return ReferenceFigureLayer(
    fromStep: numberOf(source, 'from_step'),
    untilStep: until is int ? until : null,
    svg: textOf(source, 'svg'),
  );
}

ReferenceFigurePanel _panel(Object? value) {
  final source = objectOf(value);
  return ReferenceFigurePanel(
    zone: textOf(source, 'zone'),
    fromStep: numberOf(source, 'from_step'),
    runs: parseRuns(source['runs']),
  );
}

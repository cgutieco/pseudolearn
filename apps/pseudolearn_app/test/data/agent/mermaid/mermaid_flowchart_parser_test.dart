import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/data/agent/mermaid/mermaid_flowchart_parser.dart';
import 'package:pseudolearn_app/domain/model/agent/flowchart.dart';

FlowchartNode _node(Flowchart chart, String id) => chart.nodes.firstWhere((node) => node.id == id);

void main() {
  test('the engine overview diagram is read with labels, shapes and edge labels', () {
    final chart = parseMermaidFlowchart('''
flowchart TD
    A[Programa en pseudocódigo] --> B[Análisis y validación]
    B -->|Errores| C[Diagnósticos]
    B -->|Programa válido| D[Compilación]
    D --> E[Representación intermedia]
    E --> F[Máquina virtual]
    G[Entradas y argumentos] --> F
    F --> H[Salida del programa]
    F --> I[Efectos autorizados<br/>archivos, red u otras capacidades]
    F -->|Fallo o límite excedido| J[Resultado de ejecución]
''')!;
    expect(chart.direction, FlowchartDirection.down);
    expect(chart.nodes, hasLength(10));
    expect(chart.edges, hasLength(9));
    expect(_node(chart, 'I').label, 'Efectos autorizados\narchivos, red u otras capacidades');
    expect(chart.edges[1].label, 'Errores');
    expect(chart.edges.last.label, 'Fallo o límite excedido');
  });

  test('every shape syntax is recognised', () {
    final chart = parseMermaidFlowchart(
      'graph LR\na[r]\nb(r)\nc([s])\nd((c))\ne{d}\nf{{h}}\ng[/p/]\nh[/t\\]\ni[[s]]\nj[(c)]\nk>f]\nl(((c)))',
    )!;
    expect(chart.nodes.map((node) => node.shape), [
      FlowchartShape.rectangle,
      FlowchartShape.rounded,
      FlowchartShape.stadium,
      FlowchartShape.circle,
      FlowchartShape.diamond,
      FlowchartShape.hexagon,
      FlowchartShape.parallelogram,
      FlowchartShape.trapezoid,
      FlowchartShape.subroutine,
      FlowchartShape.cylinder,
      FlowchartShape.flag,
      FlowchartShape.circle,
    ]);
  });

  test('link styles, inline labels, chains and groups produce edges', () {
    final chart = parseMermaidFlowchart(
      'flowchart TB\nA -- sí --> B -.-> C ==> D\nA & B --- E\nC <--> D\nD ~~~ A\nE --o A',
    )!;
    final edges = chart.edges;
    expect(edges.first.label, 'sí');
    expect(edges.map((edge) => edge.stroke).take(3), [FlowchartStroke.solid, FlowchartStroke.dotted, FlowchartStroke.thick]);
    expect(edges.where((edge) => edge.to == 'E').map((edge) => edge.from), ['A', 'B']);
    expect(edges.firstWhere((edge) => edge.to == 'E').arrowAtEnd, isFalse);
    final both = edges.firstWhere((edge) => edge.from == 'C' && edge.to == 'D' && edge.arrowAtStart);
    expect(both.arrowAtEnd, isTrue);
    expect(edges.firstWhere((edge) => edge.from == 'D').stroke, FlowchartStroke.invisible);
    expect(edges.last.arrowAtEnd, isTrue);
  });

  test('quoted labels, entities, comments, semicolons and styling are handled', () {
    final chart = parseMermaidFlowchart(
      '%% comentario\ngraph RL;\nA["Hola (mundo) #quot;x#quot;"]:::nota --> B;B --> C\n'
      'classDef nota fill:#f9f\nstyle A fill:#fff\nsubgraph S [Grupo]\nC --> D\nend\nclick A callback',
    )!;
    expect(chart.direction, FlowchartDirection.left);
    expect(_node(chart, 'A').label, 'Hola (mundo) "x"');
    expect(chart.nodes.map((node) => node.id), ['A', 'B', 'C', 'D']);
  });

  test('a node declared later with a label keeps that label', () {
    final chart = parseMermaidFlowchart('graph BT\nA --> B\nB{¿Seguir?}')!;
    expect(chart.direction, FlowchartDirection.up);
    expect(_node(chart, 'B').label, '¿Seguir?');
    expect(_node(chart, 'B').shape, FlowchartShape.diamond);
    expect(_node(chart, 'A').label, 'A');
  });

  test('other diagram kinds and empty sources are not flowcharts', () {
    expect(parseMermaidFlowchart(''), isNull);
    expect(parseMermaidFlowchart('sequenceDiagram\nA->>B: x'), isNull);
    expect(parseMermaidFlowchart('classDiagram\nA <|-- B'), isNull);
    expect(parseMermaidFlowchart('flowchart TD'), isNull);
    expect(parseMermaidFlowchart('flowchart XY\nA-->B'), isNull);
  });

  test('a malformed statement is skipped without losing the rest', () {
    final chart = parseMermaidFlowchart('flowchart TD\nA --> \n--> B\nC[sin cerrar\nD --> E')!;
    expect(chart.nodes.map((node) => node.id), containsAll(['A', 'D', 'E']));
    expect(chart.edges.single.from, 'D');
  });

  test('single character identifiers and a lone node are accepted', () {
    final chart = parseMermaidFlowchart('graph TD\nx')!;
    expect(chart.nodes.single.id, 'x');
    expect(chart.edges, isEmpty);
  });
}

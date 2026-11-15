import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/diagram/class_model.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/classdiagram/class_diagram_layout.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';
import 'package:pseudolearn_app/presentation/diagram/class_box_painter.dart';
import 'package:pseudolearn_app/presentation/theme/tokens/color_semantic.dart';

import '../../fakes/recording_rust_transport.dart';

void main() {
  final outputPath = Platform.environment['STATIC_VIEW_OUTPUT'];
  if (outputPath == null) {
    test(
      'measurement is disabled without an output path',
      () {},
      skip: 'Set STATIC_VIEW_OUTPUT to a JSONL output file.',
    );
    return;
  }

  test('records reproducible static view measurements', () async {
    final output = File(outputPath);
    await output.parent.create(recursive: true);
    final sink = output.openWrite();
    final nativeTransport = openNativeTransport();
    addTearDown(nativeTransport.close);
    final transport = RecordingRustTransport(nativeTransport);
    final profile = SyntaxProfileId.english;
    final viewSource = RustProgramViewSource(transport);
    final diagramBuilder = RustClassDiagramBuilder(transport);
    const layout = ClassDiagramLayout();
    const painterColors = AppSemanticColors.light();
    final ticksPerSecond = _ticksPerSecond();
    final clockResolutionTicks = _clockResolutionTicks();

    for (var iteration = 0; iteration < 30; iteration++) {
      for (final typeCount in [1, 10, 100]) {
        final source = _programOf(typeCount);
        final viewOperationStart = transport.operations.length;
        final viewClock = Stopwatch()..start();
        final view = viewSource.loadStructure(
          sourceCode: source,
          profileId: profile,
        );
        viewClock.stop();
        expect(view, isNotNull);
        expect(view!.staticData.realizations, hasLength(typeCount));
        final viewOperations = transport.operations.length - viewOperationStart;
        expect(viewOperations, 4);

        final sceneOperationStart = transport.operations.length;
        final sceneClock = Stopwatch()..start();
        final scene = diagramBuilder.buildDiagram(
          sourceCode: source,
          profileId: profile,
        );
        sceneClock.stop();
        _expectScene(scene, typeCount);
        final sceneOperations =
            transport.operations.length - sceneOperationStart;
        expect(sceneOperations, 4);

        final layoutClock = Stopwatch()..start();
        final layoutScene = layout.of(_modelOf(typeCount));
        layoutClock.stop();
        _expectScene(layoutScene, typeCount);

        final recorder = ui.PictureRecorder();
        final paintClock = Stopwatch()..start();
        ClassBoxPainter(
          scene: scene,
          colors: painterColors,
        ).paint(ui.Canvas(recorder), ui.Size(scene.width, scene.height));
        paintClock.stop();
        recorder.endRecording().dispose();

        sink.writeln(
          jsonEncode({
            'process_id': pid,
            'iteration': iteration,
            'type_count': typeCount,
            'source_bytes': utf8.encode(source).length,
            'clock_ticks_per_second': ticksPerSecond,
            'clock_resolution_ticks': clockResolutionTicks,
            'view_load_ns': _nanosecondsOf(viewClock, ticksPerSecond),
            'view_operations': viewOperations,
            'scene_build_ns': _nanosecondsOf(sceneClock, ticksPerSecond),
            'scene_operations': sceneOperations,
            'layout_ns': _nanosecondsOf(layoutClock, ticksPerSecond),
            'paint_record_ns': _nanosecondsOf(paintClock, ticksPerSecond),
            'scene_frames': scene.nodes
                .where((node) => node.shape == DiagramShape.classFrame)
                .length,
            'scene_edges': scene.edges.length,
            'rss_bytes': ProcessInfo.currentRss,
          }),
        );
      }
    }

    await sink.flush();
    await sink.close();
    nativeTransport.close();
  });
}

double _ticksPerSecond() {
  final clock = Stopwatch()..start();
  while (clock.elapsedMicroseconds < 100000) {}
  clock.stop();
  return clock.elapsedTicks * 1000000 / clock.elapsedMicroseconds;
}

int _clockResolutionTicks() {
  final clock = Stopwatch()..start();
  var previous = clock.elapsedTicks;
  var minimum = 0;
  for (var attempt = 0; attempt < 10000; attempt++) {
    final current = clock.elapsedTicks;
    final delta = current - previous;
    if (delta > 0 && (minimum == 0 || delta < minimum)) minimum = delta;
    previous = current;
  }
  clock.stop();
  return minimum;
}

int _nanosecondsOf(Stopwatch clock, double ticksPerSecond) =>
    (clock.elapsedTicks * 1000000000 / ticksPerSecond).round();

String _programOf(int typeCount) {
  final declarations = [
    'interface Contract\nmethod getValue() as integer;\nendInterface',
    for (var index = 0; index < typeCount; index++)
      'class Type$index implements Contract\n'
          'public method getValue() as integer\n'
          'return $index;\n'
          'endMethod\n'
          'endClass',
    'algorithm Main\nendAlgorithm',
  ];
  return '${declarations.join('\n')}\n';
}

ClassModel _modelOf(int typeCount) {
  const contractId = ProgramNodeId(1);
  final boxes = [
    const ClassBox(
      name: 'Contract',
      attributes: [],
      methods: [],
      nodeId: contractId,
      sourceLine: 1,
      kind: ClassBoxKind.interfaceContract,
    ),
    for (var index = 0; index < typeCount; index++)
      ClassBox(
        name: 'Type$index',
        attributes: const [],
        methods: const [],
        nodeId: ProgramNodeId(index + 2),
        sourceLine: index + 2,
        contractNames: const ['Contract'],
      ),
  ];
  final relations = [
    for (var index = 0; index < typeCount; index++)
      ClassRelation(
        fromClassName: 'Type$index',
        toClassName: 'Contract',
        kind: ClassRelationKind.realization,
        fromNodeId: ProgramNodeId(index + 2),
        toNodeId: contractId,
        originNodeId: ProgramNodeId(index + 2),
      ),
  ];
  return ClassModel(classes: boxes, relations: relations);
}

void _expectScene(DiagramScene scene, int typeCount) {
  expect(
    scene.nodes.where((node) => node.shape == DiagramShape.classFrame).length,
    typeCount + 1,
  );
  expect(
    scene.edges
        .where((edge) => edge.kind == DiagramEdgeKind.realization)
        .length,
    typeCount,
  );
}

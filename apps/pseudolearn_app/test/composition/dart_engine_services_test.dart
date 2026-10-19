import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/dart_engine_services.dart';
import 'package:pseudolearn_app/engine/analysis/core_program_analyzer.dart';
import 'package:pseudolearn_app/engine/classdiagram/core_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/execution/core_program_execution.dart';
import 'package:pseudolearn_app/engine/export/core_program_exporter.dart';

void main() {
  test('builds the Dart engine set from shared analysis state', () {
    final services = buildDartEngineServices();
    final firstExecution = services.createProgramExecution();
    final secondExecution = services.createProgramExecution();

    expect(services.analyzer, isA<CoreProgramAnalyzer>());
    expect(firstExecution, isA<CoreProgramExecution>());
    expect(secondExecution, isA<CoreProgramExecution>());
    expect(identical(firstExecution, secondExecution), isFalse);
    expect(services.classDiagramBuilder, isA<CoreClassDiagramBuilder>());
    expect(services.programExporter, isA<CoreProgramExporter>());
  });
}

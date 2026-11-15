import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/export/rust_program_exporter.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_analyzer.dart';
import '../fakes/native_test_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'builds independent executions through the Rust service composition',
    () {
      final services = nativeTestEngine;
      final firstExecution = services.createProgramExecution();
      final secondExecution = services.createProgramExecution();

      expect(services.analyzer, isA<RustProgramAnalyzer>());
      expect(firstExecution, isA<RustProgramExecution>());
      expect(secondExecution, isA<RustProgramExecution>());
      expect(identical(firstExecution, secondExecution), isFalse);
      expect(services.classDiagramBuilder, isA<RustClassDiagramBuilder>());
      expect(services.programExporter, isA<RustProgramExporter>());
    },
  );
}

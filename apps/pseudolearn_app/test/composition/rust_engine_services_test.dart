import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_analyzer.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_flowchart_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_structogram_builder.dart';

import '../fakes/fake_rust_transport.dart';

void main() {
  test('builds Rust adapters without any Dart core fallback', () {
    final services = buildRustEngineServices(FakeRustTransport({}));
    expect(services.analyzer, isA<RustProgramAnalyzer>());
    final first = services.createProgramExecution();
    final second = services.createProgramExecution();
    expect(first, isA<RustProgramExecution>());
    expect(identical(first, second), isFalse);
    expect(services.flowchartBuilder, isA<RustFlowchartBuilder>());
    expect(services.structogramBuilder, isA<RustStructogramBuilder>());
    expect(services.classDiagramBuilder, isA<RustClassDiagramBuilder>());
  });
}

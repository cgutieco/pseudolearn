import 'package:pseudolearn_app/engine/rust/export/rust_program_exporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_completion_source.dart';
import 'package:pseudolearn_app/engine/rust/rust_flowchart_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_analyzer.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_execution.dart';
import 'package:pseudolearn_app/engine/rust/rust_structogram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_syntax_reference_source.dart';

import '../fakes/fake_rust_transport.dart';
import '../fakes/test_dependencies.dart';

void main() {
  test('builds Rust adapters for every engine port', () {
    final services = buildRustEngineServices(FakeRustTransport({}));
    expect(services.analyzer, isA<RustProgramAnalyzer>());
    final first = services.createProgramExecution();
    final second = services.createProgramExecution();
    expect(first, isA<RustProgramExecution>());
    expect(second, isA<RustProgramExecution>());
    expect(identical(first, second), isFalse);
    expect(services.flowchartBuilder, isA<RustFlowchartBuilder>());
    expect(services.structogramBuilder, isA<RustStructogramBuilder>());
    expect(services.classDiagramBuilder, isA<RustClassDiagramBuilder>());
    expect(services.contextualCompletionSource, isA<RustCompletionSource>());
    expect(services.syntaxReferenceSource, isA<RustSyntaxReferenceSource>());
    expect(services.programExporter, isA<RustProgramExporter>());
  });

  test(
    'application dependencies accept the Rust set without Dart adapters',
    () {
      final services = buildRustEngineServices(FakeRustTransport({}));

      final dependencies = buildTestDependencies(engine: services);

      expect(dependencies.programAnalyzer, same(services.analyzer));
      expect(dependencies.programExporter, same(services.programExporter));
      expect(
        dependencies.syntaxReferenceSource,
        same(services.syntaxReferenceSource),
      );
      expect(dependencies.exerciseChecker, same(services.exerciseChecker));
      expect(
        dependencies.contextualCompletionSource,
        same(services.contextualCompletionSource),
      );
      expect(
        dependencies.createProgramExecution(),
        isA<RustProgramExecution>(),
      );
    },
  );
}

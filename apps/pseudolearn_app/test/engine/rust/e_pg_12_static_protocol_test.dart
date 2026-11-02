import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_view_static_data.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_scene.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_class_diagram_builder.dart';
import 'package:pseudolearn_app/engine/rust/rust_program_view_source.dart';

import '../../fakes/recording_rust_transport.dart';

void main() {
  for (final fixture in [
    (
      path: 'test/fixtures/e_pg_12_static/static_es.pseudo',
      profile: SyntaxProfileId.classicSpanish,
    ),
    (
      path: 'test/fixtures/e_pg_12_static/static_en.pseudo',
      profile: SyntaxProfileId.english,
    ),
  ]) {
    test('keeps static identities and links for ${fixture.profile.name}', () {
      final source = File(fixture.path).readAsStringSync();
      final nativeTransport = openNativeTransport();
      addTearDown(nativeTransport.close);
      final transport = RecordingRustTransport(nativeTransport);
      final view = RustProgramViewSource(
        transport,
      ).loadStructure(sourceCode: source, profileId: fixture.profile);

      expect(view, isNotNull);
      expect(view!.staticData.realizations, hasLength(2));
      expect(
        view.staticData.realizations.map((item) => item.status),
        everyElement(ProgramViewLinkStatus.valid),
      );
      expect(
        view.staticData.variants.map((item) => item.discriminant).toSet(),
        containsAll(['success', 'error']),
      );
      expect(view.staticData.captures, hasLength(1));
      expect(
        view.staticData.captures.single.mode,
        ProgramViewCaptureMode.value,
      );
      expect(view.staticData.iterations, hasLength(1));
      expect(view.staticData.scopes, hasLength(1));

      final scene = RustClassDiagramBuilder(
        transport,
      ).buildDiagram(sourceCode: source, profileId: fixture.profile);
      expect(
        scene.nodes.where((node) => node.shape == DiagramShape.classFrame),
        hasLength(3),
      );
      expect(
        scene.edges.where((edge) => edge.kind == DiagramEdgeKind.realization),
        hasLength(2),
      );
      expect(scene.sourceRanges, isNotEmpty);
      expect(
        transport.operations.where((item) => item == 'release'),
        hasLength(2),
      );

      final invalidSource = _invalidWriterSignature(source, fixture.profile);
      expect(invalidSource, isNot(source));
      final invalidView = RustProgramViewSource(
        transport,
      ).loadStructure(sourceCode: invalidSource, profileId: fixture.profile);
      expect(invalidView, isNotNull);
      final invalidRealization = invalidView!.staticData.realizations
          .singleWhere((item) => item.status == ProgramViewLinkStatus.invalid);
      expect(
        invalidRealization.diagnostics,
        contains('interfaceMethodSignatureMismatch'),
      );
      final invalidScene = RustClassDiagramBuilder(
        transport,
      ).buildDiagram(sourceCode: invalidSource, profileId: fixture.profile);
      expect(
        invalidScene.edges.where(
          (edge) => edge.kind == DiagramEdgeKind.realization,
        ),
        hasLength(2),
      );
      expect(
        invalidScene.edges.where(
          (edge) => edge.kind == DiagramEdgeKind.realization && !edge.isValid,
        ),
        hasLength(1),
      );
      expect(
        invalidScene.edges.where(
          (edge) => edge.kind == DiagramEdgeKind.realization && edge.isValid,
        ),
        hasLength(1),
      );
    });
  }
}

String _invalidWriterSignature(String source, SyntaxProfileId profile) {
  final validHeader = profile == SyntaxProfileId.english
      ? 'class Writer implements Readable\n'
            '    public method getValue(value as integer) as result<integer, string>'
      : 'Clase Escritor Realiza Legible\n'
            '    Publico Metodo Obtener(valor Como Entero) Como Resultado<Entero, Cadena>';
  final invalidHeader = profile == SyntaxProfileId.english
      ? 'class Writer implements Readable\n'
            '    public method getValue(value as integer) as integer'
      : 'Clase Escritor Realiza Legible\n'
            '    Publico Metodo Obtener(valor Como Entero) Como Entero';
  final validReturn = profile == SyntaxProfileId.english
      ? 'return failure("blocked");'
      : 'Retornar Error("bloqueado");';
  final invalidReturn = profile == SyntaxProfileId.english
      ? 'return 0;'
      : 'Retornar 0;';
  return source
      .replaceFirst(validHeader, invalidHeader)
      .replaceFirst(validReturn, invalidReturn);
}

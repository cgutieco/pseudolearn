import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/composition/dart_engine_services.dart';
import 'package:pseudolearn_app/composition/rust_engine_services.dart';
import 'package:pseudolearn_app/data/knowledge/exercise_document_parser.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/ports/program_construct_reader.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_load_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_marker_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';
import 'package:pseudolearn_app/engine/bridge/frb_generated.dart';
import 'package:pseudolearn_app/engine/rust/native_rust_transport.dart';
import 'package:pseudolearn_app/engine/rust/rust_transport.dart';

import 'equivalence_corpus.dart';
import 'equivalence_normalisers.dart';

typedef DiagramSource =
    DiagramProgram Function({
      required String sourceCode,
      required SyntaxProfileId profileId,
      required UiLanguageId languageId,
    });

const Set<String> _rustOnlyWarnings = {'unusedParameter'};

void main() {
  RustTransport? transport;
  late RustEngineServices rust;
  final dart = buildDartEngineServices();
  final programs = [...exampleCorpus(), ...exerciseSolutionCorpus()];

  setUpAll(() async {
    await initializeNativeBridge();
    transport = openNativeTransport();
    rust = buildRustEngineServices(transport!);
  });

  tearDownAll(() {
    transport?.close();
    RustLib.dispose();
  });

  group('analysis', () {
    test('error diagnostics are identical and warnings differ only where the corpus requires', () {
      for (final program in programs) {
        final expected = dart.analyzer.analyze(
          sourceCode: program.source,
          profileId: program.profile,
          languageId: program.language,
        );
        final actual = rust.analyzer.analyze(
          sourceCode: program.source,
          profileId: program.profile,
          languageId: program.language,
        );
        expect(actual.isExecutable, expected.isExecutable, reason: program.name);
        final dartKeys = diagnosticKeys(expected);
        final rustKeys = diagnosticKeys(actual);
        expect(dartKeys.difference(rustKeys), isEmpty, reason: program.name);
        for (final extra in rustKeys.difference(dartKeys)) {
          expect(
            _rustOnlyWarnings.contains(extra.split('/').first),
            isTrue,
            reason: '${program.name}: $extra',
          );
        }
      }
    });

    test('defective programs are rejected by both compositions', () {
      for (final (name, source) in defectivePrograms) {
        final expected = dart.analyzer.analyze(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
        final actual = rust.analyzer.analyze(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
        expect(actual.isExecutable, expected.isExecutable, reason: name);
        expect(actual.hasErrors, expected.hasErrors, reason: name);
      }
    });
  });

  group('constructs', () {
    test('both compositions read the same language constructs', () {
      for (final program in programs) {
        Set<String> read(ProgramConstructReader reader) => {
          for (final construct in reader.constructsOf(
            sourceCode: program.source,
            profileId: program.profile,
          ))
            construct.name,
        };
        expect(
          read(rust.programConstructReader),
          read(dart.programConstructReader),
          reason: program.name,
        );
      }
    });
  });

  group('export', () {
    test('Python and Rust output is identical with the same line attribution shape', () {
      var compared = 0;
      for (final program in programs) {
        for (final target in TargetLanguageId.values) {
          final expected = dart.programExporter.export(
            sourceCode: program.source,
            targetLanguage: target,
            profileId: program.profile,
          );
          final actual = rust.programExporter.export(
            sourceCode: program.source,
            targetLanguage: target,
            profileId: program.profile,
          );
          expect(expected, isA<ExportSuccess>(), reason: program.name);
          expect(actual, isA<ExportSuccess>(), reason: program.name);
          final dartProgram = (expected as ExportSuccess).program;
          final rustProgram = (actual as ExportSuccess).program;
          expect(rustProgram.sourceCode, dartProgram.sourceCode, reason: '${program.name} ${target.name}');
          expect(
            rustProgram.lineOrigins.map((origin) => origin == null).toList(),
            dartProgram.lineOrigins.map((origin) => origin == null).toList(),
            reason: '${program.name} ${target.name}',
          );
          compared++;
        }
      }
      expect(compared, programs.length * TargetLanguageId.values.length);
    });

    test('defective programs are not exported by either composition', () {
      for (final (name, source) in defectivePrograms) {
        final analysis = dart.analyzer.analyze(
          sourceCode: source,
          profileId: SyntaxProfileId.classicSpanish,
          languageId: UiLanguageId.spanish,
        );
        if (analysis.isExecutable) continue;
        for (final target in TargetLanguageId.values) {
          for (final services in [dart.programExporter, rust.programExporter]) {
            expect(
              services.export(
                sourceCode: source,
                targetLanguage: target,
                profileId: SyntaxProfileId.classicSpanish,
              ),
              isA<ExportAnalysisError>(),
              reason: name,
            );
          }
        }
      }
    });
  });

  group('diagrams', () {
    test('flowcharts and structograms share units and node shapes', () {
      for (final program in programs) {
        final pairs = <(DiagramSource, DiagramSource)>[
          (dart.flowchartBuilder.buildDiagram, rust.flowchartBuilder.buildDiagram),
          (dart.structogramBuilder.buildDiagram, rust.structogramBuilder.buildDiagram),
        ];
        for (final builders in pairs) {
          final expected = builders.$1(
            sourceCode: program.source,
            profileId: program.profile,
            languageId: program.language,
          );
          final actual = builders.$2(
            sourceCode: program.source,
            profileId: program.profile,
            languageId: program.language,
          );
          expect(diagramShapes(actual), diagramShapes(expected), reason: program.name);
        }
      }
    });

    test('class diagrams share nodes and edges', () {
      for (final program in programs) {
        final expected = dart.classDiagramBuilder.buildDiagram(
          sourceCode: program.source,
          profileId: program.profile,
        );
        final actual = rust.classDiagramBuilder.buildDiagram(
          sourceCode: program.source,
          profileId: program.profile,
        );
        expect(actual.nodes.length, expected.nodes.length, reason: program.name);
        expect(actual.edges.length, expected.edges.length, reason: program.name);
      }
    });
  });

  group('exercises', () {
    test('every exercise yields the same verdict through both compositions', () {
      final files = Directory('assets/knowledge/exercises')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList();
      expect(files, hasLength(190));
      for (final file in files) {
        final document = file.readAsStringSync();
        final parsed = const ExerciseDocumentParser().parse(document);
        expect(parsed, isA<ContentLoaded<Exercise>>(), reason: file.path);
        final exercise = (parsed as ContentLoaded<Exercise>).value;
        final isEnglish = file.path.endsWith('_en.json');
        final source = (jsonDecode(document) as Map<String, Object?>)['referenceSolution'] as String;
        final arguments = (
          isEnglish ? SyntaxProfileId.english : SyntaxProfileId.classicSpanish,
          isEnglish ? UiLanguageId.english : UiLanguageId.spanish,
        );
        final expected = dart.exerciseChecker.check(
          sourceCode: source,
          profileId: arguments.$1,
          languageId: arguments.$2,
          visibleCases: exercise.visibleCases,
          hiddenCases: exercise.hiddenCases,
          assertions: exercise.assertions,
        );
        final actual = rust.exerciseChecker.check(
          sourceCode: source,
          profileId: arguments.$1,
          languageId: arguments.$2,
          visibleCases: exercise.visibleCases,
          hiddenCases: exercise.hiddenCases,
          assertions: exercise.assertions,
        );
        expect(actual.outcome, expected.outcome, reason: file.path);
        expect(actual.passedCases, expected.passedCases, reason: file.path);
        expect(actual.unmetAssertions, expected.unmetAssertions, reason: file.path);
      }
    });
  });

  group('knowledge markers', () {
    test('every marker used by the content resolves alike in both compositions', () {
      final pattern = RegExp(r'\{\{([a-z]+):([A-Za-z]+)\}\}');
      final markers = <String>{};
      for (final file in Directory('assets/knowledge').listSync(recursive: true).whereType<File>()) {
        for (final match in pattern.allMatches(file.readAsStringSync())) {
          markers.add('${match.group(1)}:${match.group(2)}');
        }
      }
      expect(markers, isNotEmpty);
      for (final identifier in markers) {
        final kind = ContentMarkerKind.fromSlug(identifier.split(':').first);
        if (kind == null || kind == ContentMarkerKind.example || kind == ContentMarkerKind.figure || kind == ContentMarkerKind.diagram) {
          continue;
        }
        final marker = ContentMarker(kind: kind, argument: identifier.split(':').last);
        for (final profile in SyntaxProfileId.values) {
          for (final language in [UiLanguageId.spanish, UiLanguageId.english]) {
            final expected = dart.syntaxReferenceSource.resolveMarker(marker: marker, profileId: profile, languageId: language);
            final actual = rust.syntaxReferenceSource.resolveMarker(marker: marker, profileId: profile, languageId: language);
            expect(
              markerFingerprint(actual),
              markerFingerprint(expected),
              reason: '$identifier ${profile.name} ${language.name}',
            );
          }
        }
      }
    });
  });

  group('editor', () {
    test('both compositions offer the same keys', () {
      for (final profile in SyntaxProfileId.values) {
        expect(
          rust.editorKeySource.keysFor(profile).map((key) => '${key.label}|${key.insertion}').toList(),
          dart.editorKeySource.keysFor(profile).map((key) => '${key.label}|${key.insertion}').toList(),
        );
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/export/export_state.dart';
import 'package:pseudolearn_app/domain/model/export/export_result.dart';
import 'package:pseudolearn_app/domain/model/export/target_language_id.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import '../../fakes/fake_program_exporter.dart';

void main() {
  late FakeProgramExporter fakeExporter;
  late ExportCubit cubit;

  setUp(() {
    fakeExporter = FakeProgramExporter();
    cubit = ExportCubit(executionStates: const Stream<ExecutionState>.empty(), exporter: fakeExporter);
  });

  tearDown(() {
    cubit.close();
  });

  group('ExportCubit Application Tests', () {
    test('initial state has default python language and initial status', () {
      expect(cubit.state.selectedLanguage, equals(TargetLanguageId.python));
      expect(cubit.state.status, equals(ExportStatus.initial));
      expect(cubit.state.exportedCode, isEmpty);
    });

    test('updateSource with empty source emits ready status with empty code', () {
      cubit.updateSource(sourceCode: '   ', profileId: SyntaxProfileId.classicSpanish);

      expect(cubit.state.status, equals(ExportStatus.ready));
      expect(cubit.state.exportedCode, isEmpty);
    });

    test('updateSource with valid code emits ready status with generated code', () {
      cubit.updateSource(
        sourceCode: 'x <- 10',
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.status, equals(ExportStatus.ready));
      expect(cubit.state.exportedCode, contains('Generated Python code'));
      expect(fakeExporter.lastTargetLanguage, equals(TargetLanguageId.python));
    });

    test('selectLanguage changes language and re-exports code', () {
      cubit.selectLanguage(
        TargetLanguageId.rust,
        sourceCode: 'x <- 10',
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.selectedLanguage, equals(TargetLanguageId.rust));
      expect(cubit.state.status, equals(ExportStatus.ready));
      expect(cubit.state.exportedCode, contains('Generated Rust code'));
      expect(fakeExporter.lastTargetLanguage, equals(TargetLanguageId.rust));
    });

    test('updateSource with syntax/semantic error emits analysisError status', () {
      cubit.updateSource(
        sourceCode: 'ERROR in code',
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.status, equals(ExportStatus.analysisError));
      expect(cubit.state.exportedCode, isEmpty);
    });

    test('updateSource when exporter returns unavailable emits unavailable status', () {
      fakeExporter.nextResult = const ExportUnavailable('Export engine not ready');

      cubit.updateSource(
        sourceCode: 'x <- 10',
        profileId: SyntaxProfileId.classicSpanish,
      );

      expect(cubit.state.status, equals(ExportStatus.unavailable));
      expect(cubit.state.unavailableReason, equals('Export engine not ready'));
    });

    test('reset restores initial state', () {
      cubit.updateSource(
        sourceCode: 'x <- 10',
        profileId: SyntaxProfileId.classicSpanish,
      );
      cubit.reset();

      expect(cubit.state.status, equals(ExportStatus.initial));
      expect(cubit.state.exportedCode, isEmpty);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/companion/companion_cubit.dart';
import 'package:pseudolearn_app/application/companion/companion_source.dart';
import 'package:pseudolearn_app/application/companion/companion_view.dart';
import 'package:pseudolearn_app/application/diagram/diagram_cubit.dart';
import 'package:pseudolearn_app/application/execution/execution_state.dart';
import 'package:pseudolearn_app/application/export/export_cubit.dart';
import 'package:pseudolearn_app/application/export/export_state.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../fakes/fake_diagram_builders.dart';
import '../../fakes/fake_program_exporter.dart';

CompanionSource _source(String code) => CompanionSource(
  sourceCode: code,
  profileId: SyntaxProfileId.classicSpanish,
  languageId: UiLanguageId.spanish,
);

void main() {
  late FakeFlowchartBuilder flowchart;
  late FakeStructogramBuilder structogram;
  late FakeClassDiagramBuilder classDiagram;
  late FakeProgramExporter exporter;
  late DiagramCubit diagram;
  late ExportCubit export;
  late CompanionCubit companions;

  setUp(() {
    flowchart = FakeFlowchartBuilder();
    structogram = FakeStructogramBuilder();
    classDiagram = FakeClassDiagramBuilder();
    exporter = FakeProgramExporter();
    diagram = DiagramCubit(
      flowchartBuilder: flowchart,
      structogramBuilder: structogram,
      classDiagramBuilder: classDiagram,
    );
    export = ExportCubit(
      exporter: exporter,
      executionStates: const Stream<ExecutionState>.empty(),
    );
    companions = CompanionCubit(diagram: diagram, export: export);
  });

  tearDown(() async {
    await companions.close();
    await export.close();
    await diagram.close();
  });

  test('starts with no companion shown', () {
    expect(companions.state, CompanionView.none);
  });

  test('a source change with no companion shown builds nothing', () {
    companions.sourceChanged(_source('x <- 1'));

    expect(flowchart.buildCount, 0);
    expect(structogram.buildCount, 0);
    expect(classDiagram.buildCount, 0);
    expect(exporter.lastExportedSource, isNull);
  });

  test('showing the diagram builds it once from the latest source', () {
    for (var revision = 0; revision < 5; revision++) {
      companions.sourceChanged(_source('x <- $revision'));
    }

    companions.show(CompanionView.diagram);

    expect(companions.state, CompanionView.diagram);
    expect(flowchart.buildCount, 1);
    expect(structogram.buildCount, 1);
    expect(classDiagram.buildCount, 1);
    expect(diagram.state.units, isNotEmpty);
    expect(exporter.lastExportedSource, isNull);
  });

  test('showing the diagram again without edits does not rebuild it', () {
    companions.sourceChanged(_source('x <- 1'));
    companions.show(CompanionView.diagram);
    companions.show(CompanionView.none);
    companions.show(CompanionView.diagram);

    expect(flowchart.buildCount, 1);
  });

  test('each edit rebuilds the shown diagram and defers the export', () {
    companions.show(CompanionView.diagram);
    companions.sourceChanged(_source('x <- 1'));
    companions.sourceChanged(_source('x <- 2'));

    expect(flowchart.buildCount, 2);
    expect(exporter.lastExportedSource, isNull);
  });

  test('showing the equivalent code exports the latest source only', () {
    companions.show(CompanionView.diagram);
    companions.sourceChanged(_source('x <- 1'));
    companions.sourceChanged(_source('x <- 2'));

    companions.show(CompanionView.equivalentCode);

    expect(exporter.lastExportedSource, 'x <- 2');
    expect(export.state.status, ExportStatus.ready);
    expect(flowchart.buildCount, 2);
  });

  test('showing a companion before any source builds nothing', () {
    companions.show(CompanionView.diagram);
    companions.show(CompanionView.equivalentCode);

    expect(flowchart.buildCount, 0);
    expect(exporter.lastExportedSource, isNull);
    expect(export.state.status, ExportStatus.initial);
  });

  test('an empty program reaches the shown equivalent code as ready', () {
    companions.show(CompanionView.equivalentCode);
    companions.sourceChanged(_source(''));

    expect(export.state.status, ExportStatus.ready);
    expect(export.state.exportedCode, isEmpty);
    expect(exporter.lastExportedSource, isNull);
  });
}

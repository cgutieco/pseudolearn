import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/application/diagram/diagram_projection.dart';
import 'package:pseudolearn_app/application/diagram/diagram_state.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/source_range.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_program.dart';
import 'package:pseudolearn_app/domain/model/execution/execution_focus.dart';
import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import '../../fakes/fake_diagram_builders.dart';

DiagramProjection _projectionWith({
  List<String> unitIds = const ['alg_A', 'sub_B'],
  List<String> classNames = const [],
}) {
  return DiagramProjection(
    flowchartBuilder: FakeFlowchartBuilder(unitIds: unitIds),
    structogramBuilder: FakeStructogramBuilder(unitIds: unitIds),
    classDiagramBuilder: FakeClassDiagramBuilder(classNames: classNames),
  );
}

DiagramState _project(
  DiagramProjection projection, {
  DiagramState previous = const DiagramState.initial(),
}) {
  return projection.project(
    previous: previous,
    sourceCode: 'Proceso A FinProceso',
    profileId: SyntaxProfileId.classicSpanish,
    languageId: UiLanguageId.spanish,
  );
}

ExecutionFocus _focusOn(String unitId) {
  return ExecutionFocus(
    nodeId: const ProgramNodeId(1),
    range: const SourceRange(
      startOffset: 0,
      endOffset: 1,
      startLine: 1,
      startColumn: 1,
      endLine: 1,
      endColumn: 2,
    ),
    kind: ExecutionFocusKind.statement,
    unitId: unitId,
  );
}

void main() {
  group('DiagramProjection.project', () {
    test('fills the three notations and selects the default unit', () {
      final state = _project(_projectionWith(classNames: const ['Persona']));

      expect(state.hasValidAst, isTrue);
      expect(state.flowchart.units.length, 2);
      expect(state.structogram.units.length, 2);
      expect(state.classDiagram.isNotEmpty, isTrue);
      expect(state.selectedUnitId, 'alg_A');
    });

    test('reports an invalid ast when nothing can be built', () {
      final state = _project(
        _projectionWith(unitIds: const [], classNames: const []),
      );

      expect(state.hasValidAst, isFalse);
      expect(state.selectedUnitId, isNull);
      expect(state.flowchart.isEmpty, isTrue);
    });

    test('keeps a valid ast when only classes survive', () {
      final state = _project(
        _projectionWith(unitIds: const [], classNames: const ['Persona']),
      );

      expect(state.hasValidAst, isTrue);
      expect(state.classDiagram.isNotEmpty, isTrue);
    });

    test('preserves a selected unit that still exists', () {
      final projection = _projectionWith();
      final first = _project(projection);
      final second = _project(
        projection,
        previous: first.copyWith(selectedUnitId: 'sub_B'),
      );

      expect(second.selectedUnitId, 'sub_B');
    });

    test('falls back to the default unit when the selection disappeared', () {
      final previous = const DiagramState.initial().copyWith(
        selectedUnitId: 'gone',
      );
      final state = _project(_projectionWith(), previous: previous);

      expect(state.selectedUnitId, 'alg_A');
    });
  });

  group('DiagramProjection.followingFocus', () {
    test('moves the selection to the focused unit', () {
      final state = _project(_projectionWith());

      final followed = DiagramProjection.followingFocus(
        state,
        _focusOn('sub_B'),
      );

      expect(followed.selectedUnitId, 'sub_B');
    });

    test('keeps the selection when the focus names an unknown unit', () {
      final state = _project(_projectionWith());

      final followed = DiagramProjection.followingFocus(
        state,
        _focusOn('unknown'),
      );

      expect(followed.selectedUnitId, 'alg_A');
    });

    test('returns the very same state when nothing changed', () {
      final state = _project(_projectionWith());

      final followed = DiagramProjection.followingFocus(state, null);

      expect(identical(followed, state), isTrue);
    });
  });

  group('DiagramProjection.selectedUnitIdFor', () {
    test('returns null for an empty program', () {
      expect(
        DiagramProjection.selectedUnitIdFor(
          const DiagramProgram.empty(),
          'alg_A',
        ),
        isNull,
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/diagram/diagram_notation.dart';
import 'package:pseudolearn_app/domain/model/knowledge/ast_construct.dart';
import 'package:pseudolearn_app/domain/model/knowledge/content_block.dart';
import 'package:pseudolearn_app/domain/model/knowledge/document_heading.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_case_failure.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_outcome.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_check_result.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/exercise_level.dart';
import 'package:pseudolearn_app/domain/model/knowledge/expected_value_kind.dart';
import 'package:pseudolearn_app/domain/model/knowledge/illustration_reference.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_detail_content.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry.dart';
import 'package:pseudolearn_app/domain/model/knowledge/knowledge_entry_type.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_module.dart';
import 'package:pseudolearn_app/domain/model/knowledge/learning_track.dart';
import 'package:pseudolearn_app/domain/model/knowledge/member_visibility.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_part.dart';
import 'package:pseudolearn_app/domain/model/knowledge/module_section.dart';
import 'package:pseudolearn_app/domain/model/knowledge/prediction_activity.dart';
import 'package:pseudolearn_app/domain/model/knowledge/specification_document.dart';
import 'package:pseudolearn_app/domain/model/knowledge/specification_section.dart';
import 'package:pseudolearn_app/domain/model/knowledge/structural_assertion.dart';

const _case = ExerciseCase(
  inputs: ['4'],
  expectedOutputs: ['16'],
  expectedValueKind: ExpectedValueKind.numeric,
);

Exercise _exercise({ExerciseLevel level = ExerciseLevel.reproduce}) => Exercise(
      id: 'CON-B1-E1',
      title: 'Cuadrado',
      statement: 'Escribe el cuadrado.',
      level: level,
      kind: ExerciseKind.create,
      visibleCases: const [_case],
      hiddenCases: const [_case],
    );

LearningModule _module({String title = 'Datos'}) => LearningModule(
      id: 'CON-B1',
      track: LearningTrack.imperative,
      order: 1,
      title: title,
      sections: const [
        ModuleSection(
          part: ModulePart.question,
          blocks: [ParagraphBlock(text: 'Por que existen los datos.')],
        ),
      ],
    );

void main() {
  group('structural equality of the knowledge model', () {
    test('exercise cases compare by inputs, outputs and expected value kind', () {
      const same = ExerciseCase(
        inputs: ['4'],
        expectedOutputs: ['16'],
        expectedValueKind: ExpectedValueKind.numeric,
      );
      const asText = ExerciseCase(
        inputs: ['4'],
        expectedOutputs: ['16'],
        expectedValueKind: ExpectedValueKind.text,
      );

      expect(_case, same);
      expect(_case.hashCode, same.hashCode);
      expect(_case, isNot(asText));
    });

    test('an exercise differing only in level is another exercise', () {
      expect(_exercise(), _exercise());
      expect(_exercise(), isNot(_exercise(level: ExerciseLevel.design)));
    });

    test('exercise cases are listed visible first, then hidden', () {
      expect(_exercise().allCases.length, 2);
    });

    test('a module differing only in title is another module', () {
      expect(_module(), _module());
      expect(_module(), isNot(_module(title: 'Datos y expresiones')));
    });

    test('a module differing only in predictionActivity is another module', () {
      const activity = PredictionActivity(
        id: 'CON-B1-P1',
        exampleId: 'swap',
        prompt: 'Prompt',
        stepNumber: 5,
      );
      final moduleWithActivity = LearningModule(
        id: _module().id,
        track: _module().track,
        order: _module().order,
        title: _module().title,
        sections: _module().sections,
        predictionActivity: activity,
      );
      expect(_module(), isNot(moduleWithActivity));
    });

    test('a module finds the section of a part it declares, and none of one it does not', () {
      expect(_module().sectionOf(ModulePart.question), isNotNull);
      expect(_module().sectionOf(ModulePart.exercises), isNull);
    });

    test('specification sections compare by document, anchor and blocks', () {
      const one = SpecificationSection(
        id: 'esp-i-datos',
        document: SpecificationDocument.imperative,
        anchor: 'datos',
        order: 1,
        title: 'Datos',
        blocks: [ParagraphBlock(text: 'Cinco tipos.')],
      );
      const inTheOtherDocument = SpecificationSection(
        id: 'esp-i-datos',
        document: SpecificationDocument.objectOriented,
        anchor: 'datos',
        order: 1,
        title: 'Datos',
        blocks: [ParagraphBlock(text: 'Cinco tipos.')],
      );

      expect(one, isNot(inTheOtherDocument));
    });

    test('structural assertions of different kinds are never equal', () {
      const contains = ContainsConstructAssertion(
        requirement: 'Resuelvelo con un bucle contado.',
        construct: AstConstruct.countedLoop,
      );
      const omits = OmitsConstructAssertion(
        requirement: 'Resuelvelo con un bucle contado.',
        construct: AstConstruct.countedLoop,
      );

      expect(contains, isNot(omits));
      expect(contains, const ContainsConstructAssertion(
        requirement: 'Resuelvelo con un bucle contado.',
        construct: AstConstruct.countedLoop,
      ));
    });

    test('a class member assertion compares by visibility', () {
      const private = DeclaresClassMemberAssertion(
        requirement: 'El saldo es privado.',
        className: 'Cuenta',
        memberName: 'saldo',
        visibility: MemberVisibility.privateMember,
      );
      const madePublic = DeclaresClassMemberAssertion(
        requirement: 'El saldo es privado.',
        className: 'Cuenta',
        memberName: 'saldo',
        visibility: MemberVisibility.publicMember,
      );

      expect(private, isNot(madePublic));
    });

    test('a subprogram assertion compares by name and arity', () {
      const one = DeclaresSubprogramAssertion(
        requirement: 'Define EsPrimo(n).',
        name: 'EsPrimo',
        arity: 1,
      );
      const withAnotherArity = DeclaresSubprogramAssertion(
        requirement: 'Define EsPrimo(n).',
        name: 'EsPrimo',
        arity: 2,
      );

      expect(one, isNot(withAnotherArity));
    });

    test('a repetition assertion compares by limit', () {
      const twice = RepeatsAtMostAssertion(
        requirement: 'Extrae el calculo.',
        construct: AstConstruct.conditional,
        maxOccurrences: 2,
      );

      expect(twice, isNot(const RepeatsAtMostAssertion(
        requirement: 'Extrae el calculo.',
        construct: AstConstruct.conditional,
        maxOccurrences: 3,
      )));
    });

    test('check results compare by outcome, counts and first failure', () {
      const failure = ExerciseCaseFailure(
        caseIndex: 2,
        isHidden: true,
        inputs: ['7'],
        expectedOutputs: ['49'],
        actualOutputs: ['16'],
      );
      const failed = ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.caseFailed,
        passedCases: 2,
        totalCases: 3,
        firstFailure: failure,
      );

      expect(failed, const ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.caseFailed,
        passedCases: 2,
        totalCases: 3,
        firstFailure: failure,
      ));
      expect(failed.isSolved, isFalse);
    });

    test('a passed result with an unmet assertion is not solved', () {
      const withUnmet = ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.allCasesPassed,
        passedCases: 3,
        totalCases: 3,
        unmetAssertions: [
          ContainsConstructAssertion(
            requirement: 'Resuelvelo con un bucle contado.',
            construct: AstConstruct.countedLoop,
          ),
        ],
      );

      expect(withUnmet.isSolved, isFalse);
      expect(const ExerciseCheckResult(
        outcome: ExerciseCheckOutcome.allCasesPassed,
        passedCases: 3,
        totalCases: 3,
      ).isSolved, isTrue);
    });

    test('prediction activities and illustration references compare by value', () {
      const activity = PredictionActivity(
        id: 'CON-B1-P1',
        exampleId: 'swap',
        prompt: 'Que valor tiene a en el paso 5.',
        stepNumber: 5,
        variableName: 'a',
      );

      expect(activity, const PredictionActivity(
        id: 'CON-B1-P1',
        exampleId: 'swap',
        prompt: 'Que valor tiene a en el paso 5.',
        stepNumber: 5,
        variableName: 'a',
      ));
      expect(activity, isNot(const PredictionActivity(
        id: 'CON-B1-P1',
        exampleId: 'swap',
        prompt: 'Que valor tiene a en el paso 5.',
        stepNumber: 6,
        variableName: 'a',
      )));
      expect(
        const IllustrationReference(id: 'memory-boxes', caption: 'Cajas'),
        const IllustrationReference(id: 'memory-boxes', caption: 'Cajas'),
      );
    });

    test('knowledge detail contents compare by structural equality', () {
      final moduleContent = ModuleDetailContent(
        module: _module(),
        headings: const <DocumentHeading>[],
      );
      const specContent = SpecificationDetailContent(
        entry: KnowledgeEntry(
          id: 'esp-i-datos',
          type: KnowledgeEntryType.specificationSection,
          title: 'Datos',
          summary: 'Tipos',
        ),
        blocks: <ContentBlock>[],
        headings: <DocumentHeading>[],
      );

      expect(
        moduleContent,
        ModuleDetailContent(module: _module(), headings: const <DocumentHeading>[]),
      );
      expect(
        moduleContent,
        isNot(ModuleDetailContent(module: _module(title: 'Otro'), headings: const <DocumentHeading>[])),
      );
      expect(
        specContent,
        const SpecificationDetailContent(
          entry: KnowledgeEntry(
            id: 'esp-i-datos',
            type: KnowledgeEntryType.specificationSection,
            title: 'Datos',
            summary: 'Tipos',
          ),
          blocks: <ContentBlock>[],
          headings: <DocumentHeading>[],
        ),
      );
      expect(
        const CodeBlock(code: 'a <- 1'),
        const CodeBlock(code: 'a <- 1'),
      );
      expect(
        const CodeBlock(code: 'a <- 1', title: 'Ejemplo 1'),
        const CodeBlock(code: 'a <- 1', title: 'Ejemplo 1'),
      );
      expect(
        const CodeBlock(code: 'a <- 1', title: 'Ejemplo 1'),
        isNot(const CodeBlock(code: 'a <- 1', title: 'Ejemplo 2')),
      );
      expect(
        const DiagramBlock(code: 'a <- 1', notation: DiagramNotation.flowchart, title: 'D1'),
        const DiagramBlock(code: 'a <- 1', notation: DiagramNotation.flowchart, title: 'D1'),
      );
      expect(
        const DiagramBlock(code: 'a <- 1', notation: DiagramNotation.flowchart, title: 'D1'),
        isNot(const DiagramBlock(code: 'a <- 1', notation: DiagramNotation.flowchart, title: 'D2')),
      );
    });
  });
}

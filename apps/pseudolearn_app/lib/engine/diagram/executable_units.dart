import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/analysis/program_node_id.dart';
import '../../domain/model/diagram/diagram_unit.dart';
import 'diagram_vocabulary.dart';

final class ExecutableUnitEntry {
  final DiagramUnit unit;
  final List<StatementNode> body;
  final Span span;

  const ExecutableUnitEntry({
    required this.unit,
    required this.body,
    required this.span,
  });
}

final class ExecutableUnits {
  const ExecutableUnits._();

  static List<ExecutableUnitEntry> fromAst(
    SourceUnitNode? unit, {
    required DiagramVocabulary vocabulary,
  }) {
    if (unit == null) return const [];
    final entries = <ExecutableUnitEntry>[];

    if (unit.algorithm != null) {
      entries.add(_fromAlgorithm(unit.algorithm!, vocabulary));
    }

    for (final sub in unit.subroutines) {
      entries.add(_fromSubroutine(sub, vocabulary));
    }

    for (final cls in unit.classes) {
      _extractClassUnits(cls, vocabulary, entries);
    }

    return List.unmodifiable(entries);
  }

  static ExecutableUnitEntry _fromAlgorithm(
    AlgorithmNode algo,
    DiagramVocabulary vocabulary,
  ) {
    final name = algo.name.isEmpty ? 'Algoritmo' : algo.name;
    return ExecutableUnitEntry(
      unit: DiagramUnit(
        id: 'alg_${algo.name}',
        displayName: vocabulary.formatUnitTitle(
          kind: DiagramUnitKind.algorithm,
          name: algo.name,
        ),
        kind: DiagramUnitKind.algorithm,
        name: name,
        sourceLine: algo.span.start.line,
        nodeId: ProgramNodeId(algo.id.value),
      ),
      body: algo.body,
      span: algo.span,
    );
  }

  static ExecutableUnitEntry _fromSubroutine(
    SubroutineDeclarationNode sub,
    DiagramVocabulary vocabulary,
  ) {
    final isFunc = sub.returnType != null || sub.customReturnType != null;
    return ExecutableUnitEntry(
      unit: DiagramUnit(
        id: 'sub_${sub.name}',
        displayName: vocabulary.formatUnitTitle(
          kind: DiagramUnitKind.subroutine,
          name: sub.name,
          isFunction: isFunc,
        ),
        kind: DiagramUnitKind.subroutine,
        name: sub.name,
        sourceLine: sub.span.start.line,
        nodeId: ProgramNodeId(sub.id.value),
      ),
      body: sub.body,
      span: sub.span,
    );
  }

  static void _extractClassUnits(
    ClassNode cls,
    DiagramVocabulary vocabulary,
    List<ExecutableUnitEntry> entries,
  ) {
    for (final member in cls.members) {
      if (member is ConstructorDeclarationNode) {
        entries.add(_fromConstructor(cls, member, vocabulary));
      } else if (member is MethodDeclarationNode) {
        entries.add(_fromMethod(cls, member, vocabulary));
      }
    }
  }

  static ExecutableUnitEntry _fromConstructor(
    ClassNode cls,
    ConstructorDeclarationNode ctor,
    DiagramVocabulary vocabulary,
  ) {
    return ExecutableUnitEntry(
      unit: DiagramUnit(
        id: 'ctor_${cls.name}',
        displayName: vocabulary.formatUnitTitle(
          kind: DiagramUnitKind.constructor,
          name: 'Constructor',
          className: cls.name,
        ),
        kind: DiagramUnitKind.constructor,
        className: cls.name,
        name: 'Constructor',
        sourceLine: ctor.span.start.line,
        nodeId: ProgramNodeId(ctor.id.value),
      ),
      body: ctor.body,
      span: ctor.span,
    );
  }

  static ExecutableUnitEntry _fromMethod(
    ClassNode cls,
    MethodDeclarationNode method,
    DiagramVocabulary vocabulary,
  ) {
    return ExecutableUnitEntry(
      unit: DiagramUnit(
        id: 'method_${cls.name}_${method.name}',
        displayName: vocabulary.formatUnitTitle(
          kind: DiagramUnitKind.method,
          name: method.name,
          className: cls.name,
        ),
        kind: DiagramUnitKind.method,
        className: cls.name,
        name: method.name,
        sourceLine: method.span.start.line,
        nodeId: ProgramNodeId(method.id.value),
      ),
      body: method.body,
      span: method.span,
    );
  }
}

import '../../domain/model/diagram/diagram_unit.dart';
import '../diagram/diagram_vocabulary.dart';
import 'rust_diagram_unit_identifier.dart';
import 'rust_program_view.dart';

final class RustExecutableUnit {
  final DiagramUnit unit;
  final RustViewNode body;
  final RustViewNode node;

  const RustExecutableUnit({
    required this.unit,
    required this.body,
    required this.node,
  });
}

final class RustExecutableUnitReader {
  const RustExecutableUnitReader();

  List<RustExecutableUnit> read(
    RustProgramView view, {
    required DiagramVocabulary vocabulary,
  }) {
    final entries = <RustExecutableUnit>[];
    final classMethods = <RustExecutableUnit>[];
    for (final unit in view.units) {
      final node = view.nodeById(unit.nodeId);
      if (node == null) continue;
      if (unit.kind == 'class') {
        _appendClassMethods(
          view: view,
          className: unit.name,
          vocabulary: vocabulary,
          entries: classMethods,
        );
        continue;
      }
      final body = view.childForRole(node, 'body');
      if (body == null) continue;
      entries.add(
        _topLevelEntry(
          view: view,
          sourceUnit: unit,
          node: node,
          body: body,
          vocabulary: vocabulary,
        ),
      );
    }
    final algorithms = entries.where(
      (entry) => entry.unit.kind == DiagramUnitKind.algorithm,
    );
    final subroutines = entries.where(
      (entry) => entry.unit.kind == DiagramUnitKind.subroutine,
    );
    return List.unmodifiable([...algorithms, ...subroutines, ...classMethods]);
  }

  RustExecutableUnit _topLevelEntry({
    required RustProgramView view,
    required RustViewUnit sourceUnit,
    required RustViewNode node,
    required RustViewNode body,
    required DiagramVocabulary vocabulary,
  }) {
    final isAlgorithm = sourceUnit.kind == 'algorithm';
    final kind = isAlgorithm
        ? DiagramUnitKind.algorithm
        : DiagramUnitKind.subroutine;
    return RustExecutableUnit(
      unit: DiagramUnit(
        id: RustDiagramUnitIdentifier.fromUnit(sourceUnit),
        displayName: vocabulary.formatUnitTitle(
          kind: kind,
          name: sourceUnit.name,
          isFunction: _returnsValue(view, node),
        ),
        kind: kind,
        name: sourceUnit.name,
        sourceLine: node.range.startLine,
        nodeId: node.id,
      ),
      body: body,
      node: node,
    );
  }

  void _appendClassMethods({
    required RustProgramView view,
    required String className,
    required DiagramVocabulary vocabulary,
    required List<RustExecutableUnit> entries,
  }) {
    for (final member in view.members) {
      if (member.className != className || member.nodeId == null) continue;
      final node = view.nodeById(member.nodeId!);
      if (node == null) continue;
      final body = view.childForRole(node, 'body');
      if (body == null) continue;
      final isConstructor = member.kind == 'constructor';
      final kind = isConstructor
          ? DiagramUnitKind.constructor
          : DiagramUnitKind.method;
      final name = isConstructor ? 'Constructor' : member.name;
      entries.add(
        RustExecutableUnit(
          unit: DiagramUnit(
            id: RustDiagramUnitIdentifier.fromMember(member),
            displayName: vocabulary.formatUnitTitle(
              kind: kind,
              name: name,
              className: className,
              isFunction: _returnsValue(view, node),
            ),
            kind: kind,
            className: className,
            name: name,
            sourceLine: node.range.startLine,
            nodeId: node.id,
          ),
          body: body,
          node: node,
        ),
      );
    }
  }

  bool _returnsValue(RustProgramView view, RustViewNode node) =>
      rustChildrenForRole(
        view,
        node,
        'signature',
      ).any((child) => child.syntaxKind == 'type');
}

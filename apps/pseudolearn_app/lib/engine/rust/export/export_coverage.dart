import '../../../domain/model/export/export_blocker.dart';
import '../rust_program_view.dart';
import 'export_support.dart';
import 'expression_types.dart';
import 'read_target_types.dart';

const Set<String> _unitKinds = {'algorithm_unit', 'class_unit', 'subroutine'};

const Set<String> _booleanKinds = {
  'conjunction',
  'disjunction',
  'equality',
  'ordering',
};

final class ExportCoverage {
  final RustProgramView _view;
  final ExportSupport _support;
  final ExpressionTypes _types;
  final ReadTargetTypes _reads;

  factory ExportCoverage(RustProgramView view, ExportSupport support) {
    final types = ExpressionTypes.of(view);
    return ExportCoverage._(
      view,
      support,
      types,
      ReadTargetTypes.of(view, types),
    );
  }

  ExportCoverage._(this._view, this._support, this._types, this._reads);

  List<ExportBlocker> blockers() {
    final blockers = <ExportBlocker>[];
    final hasBoolean = _view.nodes.any(_isBooleanTyped);
    for (final node in _view.nodes) {
      for (final construct in _constructsOf(node, hasBoolean)) {
        blockers.add(
          ExportBlocker(
            construct: construct,
            origin: node.id,
            range: node.range,
          ),
        );
      }
    }
    return [...blockers, ..._droppedUnits()];
  }

  Iterable<String> _constructsOf(RustViewNode node, bool hasBoolean) sync* {
    if (!_support.syntaxKinds.contains(node.syntaxKind)) {
      yield node.syntaxKind;
      return;
    }
    yield* _semanticConstructs(node);
    if (node.syntaxKind == 'output' && _outputsBoolean(node, hasBoolean)) {
      yield 'boolean_output';
    }
    if (node.syntaxKind == 'input') yield* _unreadableTargets(node);
    if (_support.requiresNumericTypes && _isUntypedOperation(node)) {
      yield 'untyped_operation';
    }
    if (_returnsValue(node)) yield 'value_return';
    if (_concatenatesText(node)) yield 'text_concatenation';
  }

  Iterable<String> _semanticConstructs(RustViewNode node) sync* {
    final semantics = node.semantics;
    if (semantics.collectionOperation case final String operation) {
      yield 'collection:$operation';
    }
    final builtin = semantics.builtin;
    if (builtin != null && !_support.builtins.contains(builtin)) {
      yield 'builtin:$builtin';
    }
    for (final operator in semantics.operators) {
      if (_support.blockedOperators.contains(operator)) {
        yield 'operator:$operator';
      }
    }
    final literal = semantics.literal;
    if (literal != null &&
        _support.blockedLiteralTypes.contains(literal.type)) {
      yield 'literal:${literal.type}';
    }
    if (_support.blockedPrimitives.contains(semantics.primitive)) {
      yield 'type:${semantics.primitive}';
    }
    if (semantics.suspendable) yield 'suspendable';
    if (semantics.capabilityType != null || semantics.effectOperation != null) {
      yield 'capability';
    }
  }

  Iterable<String> _unreadableTargets(RustViewNode input) sync* {
    for (final target in rustChildrenOf(_view, input)) {
      final primitive = _reads.of(target);
      if (primitive == null) {
        yield 'input:designator';
      } else if (!_support.readablePrimitives.contains(primitive)) {
        yield 'input:$primitive';
      }
    }
  }

  /// Arithmetic and comparisons whose operand types are unknown cannot be
  /// given the explicit conversions a typed target needs.
  bool _isUntypedOperation(RustViewNode node) {
    final kind = node.syntaxKind;
    if (kind == 'addition' || kind == 'multiplication') {
      return _types.of(node) == null;
    }
    if (kind == 'ordering' || kind == 'equality') {
      return rustChildrenOf(
        _view,
        node,
      ).any((child) => _types.of(child) == null);
    }
    return false;
  }

  bool _isBooleanTyped(RustViewNode node) =>
      node.semantics.primitive == 'boolean';

  bool _outputsBoolean(RustViewNode output, bool hasBoolean) {
    for (final node in _subtree(output)) {
      if (node.semantics.literal?.type == 'boolean') return true;
      if (_booleanKinds.contains(node.syntaxKind)) return true;
      if (node.semantics.operator == 'not') return true;
      if (hasBoolean && node.syntaxKind == 'identifier') return true;
    }
    return false;
  }

  bool _returnsValue(RustViewNode node) =>
      !_support.allowsValueReturn &&
      node.syntaxKind == 'return_statement' &&
      node.children.isNotEmpty;

  bool _concatenatesText(RustViewNode node) {
    if (_support.allowsTextConcatenation || node.syntaxKind != 'addition') {
      return false;
    }
    return rustChildrenOf(_view, node).any(
      (child) =>
          const {'string', 'character'}.contains(child.semantics.literal?.type),
    );
  }

  Iterable<RustViewNode> _subtree(RustViewNode node) sync* {
    yield node;
    for (final child in rustChildrenOf(_view, node)) {
      yield* _subtree(child);
    }
  }

  List<ExportBlocker> _droppedUnits() => [
    for (final unit in _view.units)
      if (!_unitKinds.contains(_view.nodeById(unit.nodeId)?.syntaxKind))
        ExportBlocker(
          construct: unit.kind,
          origin: unit.nodeId,
          range: unit.range,
        ),
  ];
}

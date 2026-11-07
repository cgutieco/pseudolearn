const Set<String> _commonKinds = {
  'algorithm_unit',
  'subroutine',
  'parameters',
  'parameter',
  'type',
  'body',
  'statement',
  'identifier',
  'literal',
  'arguments',
  'primary',
  'unary',
  'postfix',
  'addition',
  'multiplication',
  'power_expression',
  'conjunction',
  'disjunction',
  'equality',
  'ordering',
  'assignment_statement',
  'declaration',
  'output',
  'conditional',
  'while_loop',
  'repeat_loop',
  'for_loop',
  'return_statement',
  'call_statement',
  'input',
};

const Set<String> _selectionKinds = {'switch', 'default_case', 'labels'};

const Set<String> _classKinds = {
  'class_unit',
  'field_declaration',
  'constructor_member',
  'method_member',
  'instantiation',
  'this_object',
};

final class ExportSupport {
  final Set<String> syntaxKinds;
  final Set<String> builtins;
  final Set<String> blockedOperators;
  final Set<String> blockedLiteralTypes;
  final Set<String> blockedPrimitives;

  /// Types a `Leer` target may have: each one has a reading that re-asks on
  /// invalid input, like the engine does.
  final Set<String> readablePrimitives;
  final bool allowsValueReturn;

  /// The target has no implicit numeric conversions, so every arithmetic and
  /// comparison operand needs a known type.
  final bool requiresNumericTypes;
  final bool allowsTextConcatenation;

  const ExportSupport({
    required this.syntaxKinds,
    required this.builtins,
    this.blockedOperators = const {},
    this.blockedLiteralTypes = const {},
    this.blockedPrimitives = const {},
    this.readablePrimitives = const {},
    this.allowsValueReturn = true,
    this.requiresNumericTypes = false,
    this.allowsTextConcatenation = true,
  });
}

const ExportSupport pythonExportSupport = ExportSupport(
  syntaxKinds: {..._commonKinds, ..._classKinds},
  builtins: {'squareRoot', 'length', 'toText', 'truncate'},
  blockedOperators: {'integer_divide'},
  readablePrimitives: {'integer', 'real', 'string'},
);

const ExportSupport rustExportSupport = ExportSupport(
  syntaxKinds: {..._commonKinds, ..._selectionKinds},
  builtins: {'length', 'toText', 'truncate'},
  blockedOperators: {'integer_divide', 'power'},
  readablePrimitives: {'integer', 'real'},
  allowsTextConcatenation: false,
  requiresNumericTypes: true,
);

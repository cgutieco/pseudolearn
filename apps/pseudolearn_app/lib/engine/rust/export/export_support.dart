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
  final bool allowsValueReturn;
  final bool allowsTextConcatenation;

  const ExportSupport({
    required this.syntaxKinds,
    required this.builtins,
    this.blockedOperators = const {},
    this.blockedLiteralTypes = const {},
    this.blockedPrimitives = const {},
    this.allowsValueReturn = true,
    this.allowsTextConcatenation = true,
  });
}

const ExportSupport pythonExportSupport = ExportSupport(
  syntaxKinds: {..._commonKinds, ..._classKinds},
  builtins: {'squareRoot', 'length', 'toText', 'truncate'},
  blockedOperators: {'integer_divide'},
);

const ExportSupport rustExportSupport = ExportSupport(
  syntaxKinds: {..._commonKinds, ..._selectionKinds},
  builtins: {'length', 'toText', 'truncate'},
  blockedOperators: {'divide', 'integer_divide', 'power'},
  blockedLiteralTypes: {'real'},
  blockedPrimitives: {'real'},
  allowsValueReturn: false,
  allowsTextConcatenation: false,
);

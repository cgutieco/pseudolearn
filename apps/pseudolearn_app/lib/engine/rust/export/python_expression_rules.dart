import '../rust_view_semantics.dart';
import 'view_expression_rules.dart';

const Map<String, String> _operators = {
  'add': '+',
  'subtract': '-',
  'multiply': '*',
  'divide': '/',
  'integer_divide': '//',
  'modulo': '%',
  'power': '**',
  'equal': '==',
  'not_equal': '!=',
  'less_than': '<',
  'less_than_or_equal': '<=',
  'greater_than': '>',
  'greater_than_or_equal': '>=',
  'and': 'and',
  'or': 'or',
};

const Set<String> mathBuiltins = {
  'squareRoot',
  'naturalLogarithm',
  'exponential',
  'sine',
  'cosine',
  'arcTangent',
  'truncate',
};

final class PythonExpressionRules implements ViewExpressionRules {
  const PythonExpressionRules();

  @override
  Map<String, String> get binaryOperators => _operators;

  @override
  String get thisText => 'self';

  @override
  String get superText => 'super()';

  @override
  String literal(RustViewLiteral literal) => switch (literal.type) {
    'boolean' => literal.value == 'true' ? 'True' : 'False',
    'string' || 'character' => '"${literal.value}"',
    _ => literal.value,
  };

  @override
  String unary(String operatorIdentity, String operand) =>
      switch (operatorIdentity) {
        'not' => 'not $operand',
        'negate' => '-$operand',
        _ => '+$operand',
      };

  @override
  String instantiation(String className, List<String> arguments) =>
      '$className(${arguments.join(', ')})';

  @override
  String index(String position) => '[$position]';

  @override
  String builtin(String identity, List<String> arguments) {
    final joined = arguments.join(', ');
    return switch (identity) {
      'squareRoot' => 'math.sqrt($joined)',
      'absoluteValue' => 'abs($joined)',
      'naturalLogarithm' => 'math.log($joined)',
      'exponential' => 'math.exp($joined)',
      'sine' => 'math.sin($joined)',
      'cosine' => 'math.cos($joined)',
      'arcTangent' => 'math.atan($joined)',
      'truncate' => 'math.trunc($joined)',
      'round' => 'round($joined)',
      'random' =>
        arguments.isEmpty
            ? 'random.random()'
            : 'random.randint(0, ${arguments.first} - 1)',
      'toText' => 'str($joined)',
      'textToInteger' => 'int($joined)',
      'textToReal' => 'float($joined)',
      'length' => 'len($joined)',
      'characterAt' => '${arguments.first}[${arguments[1]}]',
      'characterCode' => 'ord($joined)',
      'characterFromCode' => 'chr($joined)',
      'shallowCopy' => 'list($joined)',
      _ => '$identity($joined)',
    };
  }
}

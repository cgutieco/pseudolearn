import '../rust_view_semantics.dart';
import 'view_expression_rules.dart';

const Map<String, String> _operators = {
  'add': '+',
  'subtract': '-',
  'multiply': '*',
  'divide': '/',
  'integer_divide': '/',
  'modulo': '%',
  'power': '.pow()',
  'equal': '==',
  'not_equal': '!=',
  'less_than': '<',
  'less_than_or_equal': '<=',
  'greater_than': '>',
  'greater_than_or_equal': '>=',
  'and': '&&',
  'or': '||',
};

final class RustExpressionRules implements ViewExpressionRules {
  const RustExpressionRules();

  @override
  Map<String, String> get binaryOperators => _operators;

  @override
  String get thisText => 'self';

  @override
  String get superText => 'self.base';

  @override
  String literal(RustViewLiteral literal) => switch (literal.type) {
    'boolean' => literal.value,
    'character' => "'${literal.value}'",
    'string' => '"${literal.value}".to_string()',
    _ => literal.value,
  };

  @override
  String unary(String operatorIdentity, String operand) =>
      switch (operatorIdentity) {
        'not' => '!$operand',
        'negate' => '-$operand',
        _ => '+$operand',
      };

  @override
  String instantiation(String className, List<String> arguments) =>
      '$className::new(${arguments.join(', ')})';

  @override
  String index(String position) => '[($position) as usize]';

  @override
  String builtin(String identity, List<String> arguments) {
    final first = arguments.isEmpty ? '' : arguments.first;
    return switch (identity) {
      'squareRoot' => '($first as f64).sqrt()',
      'absoluteValue' => '($first).abs()',
      'naturalLogarithm' => '($first as f64).ln()',
      'exponential' => '($first as f64).exp()',
      'sine' => '($first as f64).sin()',
      'cosine' => '($first as f64).cos()',
      'arcTangent' => '($first as f64).atan()',
      'truncate' => '($first as f64).trunc()',
      'round' => '($first as f64).round()',
      'random' => '0.0 /* rand */',
      'toText' => 'format!("{}", ${arguments.join(', ')})',
      'textToInteger' => '$first.parse::<i64>().unwrap_or(0)',
      'textToReal' => '$first.parse::<f64>().unwrap_or(0.0)',
      'length' => '($first).len() as i64',
      'characterAt' =>
        "($first).chars().nth((${arguments[1]}) as usize).unwrap_or(' ').to_string()",
      'characterCode' =>
        '($first).chars().next().map(|c| c as i64).unwrap_or(0)',
      'characterFromCode' =>
        'char::from_u32(($first) as u32).map(|c| c.to_string()).unwrap_or_default()',
      'shallowCopy' => '$first.clone()',
      _ => '$identity(${arguments.join(', ')})',
    };
  }
}

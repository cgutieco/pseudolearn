import 'package:pseudolearn_core/pseudolearn_core.dart';

final class RustExpressionEmitter {
  final ResolutionResult? _resolution;

  const RustExpressionEmitter([this._resolution]);

  String emit(ExpressionNode expr) {
    return switch (expr) {
      final LiteralExpressionNode e => _emitLiteral(e),
      final VariableExpressionNode e => e.name,
      final ParenthesizedExpressionNode e => '(${emit(e.expression)})',
      final UnaryExpressionNode e => _emitUnary(e),
      final BinaryExpressionNode e =>
        '${emit(e.left)} ${_binaryOp(e.operator)} ${emit(e.right)}',
      final FunctionCallExpressionNode e => _emitFunctionCall(e),
      final ArrayAccessExpressionNode e =>
        '${emit(e.target)}${e.indices.map((i) => '[(${emit(i)}) as usize]').join()}',
      final MemberAccessExpressionNode e => '${emit(e.target)}.${e.memberName}',
      final MethodCallExpressionNode e =>
        '${emit(e.target)}.${e.methodName}(${e.arguments.map(emit).join(', ')})',
      final InstantiationExpressionNode e =>
        '${e.className}::new(${e.arguments.map(emit).join(', ')})',
      final ThisExpressionNode _ => 'self',
      final SuperExpressionNode _ => 'self.base',
    };
  }

  String _emitFunctionCall(FunctionCallExpressionNode e) {
    final symbol = _resolution?.symbolFor(e.id);
    if (symbol is BuiltinFunctionSymbol) {
      final args = e.arguments.map(emit).toList();
      return _emitBuiltin(symbol.function, args);
    }
    return '${e.name}(${e.arguments.map(emit).join(', ')})';
  }

  String _emitBuiltin(BuiltinFunction function, List<String> args) {
    return switch (function) {
      BuiltinFunction.squareRoot => '(${args.first} as f64).sqrt()',
      BuiltinFunction.absoluteValue => '(${args.first}).abs()',
      BuiltinFunction.naturalLogarithm => '(${args.first} as f64).ln()',
      BuiltinFunction.exponential => '(${args.first} as f64).exp()',
      BuiltinFunction.sine => '(${args.first} as f64).sin()',
      BuiltinFunction.cosine => '(${args.first} as f64).cos()',
      BuiltinFunction.arcTangent => '(${args.first} as f64).atan()',
      BuiltinFunction.truncate => '(${args.first} as f64).trunc()',
      BuiltinFunction.round => '(${args.first} as f64).round()',
      BuiltinFunction.random => '0.0 /* rand */',
      BuiltinFunction.toText => 'format!("{}", ${args.join(', ')})',
      BuiltinFunction.textToInteger =>
        '${args.first}.parse::<i64>().unwrap_or(0)',
      BuiltinFunction.textToReal =>
        '${args.first}.parse::<f64>().unwrap_or(0.0)',
      BuiltinFunction.length => '(${args.first}).len() as i64',
      BuiltinFunction.characterAt =>
        '(${args.first}).chars().nth((${args[1]}) as usize).unwrap_or(\' \').to_string()',
      BuiltinFunction.characterCode =>
        '(${args.first}).chars().next().map(|c| c as i64).unwrap_or(0)',
      BuiltinFunction.characterFromCode =>
        'char::from_u32((${args.first}) as u32).map(|c| c.to_string()).unwrap_or_default()',
      BuiltinFunction.shallowCopy => '${args.first}.clone()',
    };
  }

  String _emitLiteral(LiteralExpressionNode e) {
    if (e.type == PrimitiveType.boolean) {
      return e.value == true ? 'true' : 'false';
    }
    if (e.type == PrimitiveType.character) {
      return "'${e.value}'";
    }
    if (e.type == PrimitiveType.string) {
      return '"${e.value}".to_string()';
    }
    return '${e.value}';
  }

  String _emitUnary(UnaryExpressionNode e) {
    return switch (e.operator) {
      UnaryOperator.not => '!${emit(e.operand)}',
      UnaryOperator.negate => '-${emit(e.operand)}',
      UnaryOperator.positive => '+${emit(e.operand)}',
    };
  }

  String _binaryOp(BinaryOperator op) {
    return switch (op) {
      BinaryOperator.add => '+',
      BinaryOperator.subtract => '-',
      BinaryOperator.multiply => '*',
      BinaryOperator.divide => '/',
      BinaryOperator.integerDivide => '/',
      BinaryOperator.modulo => '%',
      BinaryOperator.power => '.pow()',
      BinaryOperator.equal => '==',
      BinaryOperator.notEqual => '!=',
      BinaryOperator.lessThan => '<',
      BinaryOperator.lessThanOrEqual => '<=',
      BinaryOperator.greaterThan => '>',
      BinaryOperator.greaterThanOrEqual => '>=',
      BinaryOperator.and => '&&',
      BinaryOperator.or => '||',
    };
  }
}

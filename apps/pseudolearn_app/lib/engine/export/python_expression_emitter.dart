import 'package:pseudolearn_core/pseudolearn_core.dart';

final class PythonExpressionEmitter {
  final ResolutionResult? _resolution;

  const PythonExpressionEmitter([this._resolution]);

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
        '${emit(e.target)}${e.indices.map((i) => '[${emit(i)}]').join()}',
      final MemberAccessExpressionNode e => '${emit(e.target)}.${e.memberName}',
      final MethodCallExpressionNode e =>
        '${emit(e.target)}.${e.methodName}(${e.arguments.map(emit).join(', ')})',
      final InstantiationExpressionNode e =>
        '${e.className}(${e.arguments.map(emit).join(', ')})',
      final ThisExpressionNode _ => 'self',
      final SuperExpressionNode _ => 'super()',
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
      BuiltinFunction.squareRoot => 'math.sqrt(${args.join(', ')})',
      BuiltinFunction.absoluteValue => 'abs(${args.join(', ')})',
      BuiltinFunction.naturalLogarithm => 'math.log(${args.join(', ')})',
      BuiltinFunction.exponential => 'math.exp(${args.join(', ')})',
      BuiltinFunction.sine => 'math.sin(${args.join(', ')})',
      BuiltinFunction.cosine => 'math.cos(${args.join(', ')})',
      BuiltinFunction.arcTangent => 'math.atan(${args.join(', ')})',
      BuiltinFunction.truncate => 'math.trunc(${args.join(', ')})',
      BuiltinFunction.round => 'round(${args.join(', ')})',
      BuiltinFunction.random =>
        args.isEmpty ? 'random.random()' : 'random.randint(0, ${args.first} - 1)',
      BuiltinFunction.toText => 'str(${args.join(', ')})',
      BuiltinFunction.textToInteger => 'int(${args.join(', ')})',
      BuiltinFunction.textToReal => 'float(${args.join(', ')})',
      BuiltinFunction.length => 'len(${args.join(', ')})',
      BuiltinFunction.characterAt => '${args.first}[${args[1]}]',
      BuiltinFunction.characterCode => 'ord(${args.join(', ')})',
      BuiltinFunction.characterFromCode => 'chr(${args.join(', ')})',
      BuiltinFunction.shallowCopy => 'list(${args.join(', ')})',
    };
  }

  String _emitLiteral(LiteralExpressionNode e) {
    if (e.type == PrimitiveType.boolean) {
      return e.value == true ? 'True' : 'False';
    }
    if (e.type == PrimitiveType.string || e.type == PrimitiveType.character) {
      return '"${e.value}"';
    }
    return '${e.value}';
  }

  String _emitUnary(UnaryExpressionNode e) {
    return switch (e.operator) {
      UnaryOperator.not => 'not ${emit(e.operand)}',
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
      BinaryOperator.integerDivide => '//',
      BinaryOperator.modulo => '%',
      BinaryOperator.power => '**',
      BinaryOperator.equal => '==',
      BinaryOperator.notEqual => '!=',
      BinaryOperator.lessThan => '<',
      BinaryOperator.lessThanOrEqual => '<=',
      BinaryOperator.greaterThan => '>',
      BinaryOperator.greaterThanOrEqual => '>=',
      BinaryOperator.and => 'and',
      BinaryOperator.or => 'or',
    };
  }
}

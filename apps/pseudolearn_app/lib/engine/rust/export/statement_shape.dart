import '../../../domain/model/analysis/program_node_id.dart';
import '../rust_program_view.dart';

sealed class StatementShape {
  final ProgramNodeId origin;

  const StatementShape(this.origin);
}

final class AssignmentShape extends StatementShape {
  final RustViewNode target;
  final RustViewNode value;

  const AssignmentShape(super.origin, this.target, this.value);
}

final class DeclarationShape extends StatementShape {
  final List<String> names;
  final RustViewNode? initializer;

  const DeclarationShape(super.origin, this.names, [this.initializer]);
}

final class ArrayShape {
  final String name;
  final List<RustViewNode> dimensions;

  const ArrayShape(this.name, this.dimensions);
}

final class DimensionShape extends StatementShape {
  final List<ArrayShape> arrays;

  const DimensionShape(super.origin, this.arrays);
}

final class WriteShape extends StatementShape {
  final List<RustViewNode> expressions;
  final bool withoutNewline;

  const WriteShape(super.origin, this.expressions, this.withoutNewline);
}

final class ReadShape extends StatementShape {
  final List<RustViewNode> targets;

  const ReadShape(super.origin, this.targets);
}

final class IfShape extends StatementShape {
  final RustViewNode condition;
  final List<StatementShape> thenBody;
  final List<StatementShape> elseBody;

  const IfShape(
    super.origin, {
    required this.condition,
    required this.thenBody,
    required this.elseBody,
  });
}

final class WhileShape extends StatementShape {
  final RustViewNode condition;
  final List<StatementShape> body;

  const WhileShape(super.origin, this.condition, this.body);
}

final class RepeatShape extends StatementShape {
  final RustViewNode condition;
  final List<StatementShape> body;

  const RepeatShape(super.origin, this.condition, this.body);
}

final class ForShape extends StatementShape {
  final String variable;
  final RustViewNode from;
  final RustViewNode to;
  final RustViewNode? step;
  final List<StatementShape> body;

  const ForShape(
    super.origin, {
    required this.variable,
    required this.from,
    required this.to,
    required this.step,
    required this.body,
  });
}

final class CaseShape {
  final List<RustViewNode> labels;
  final List<StatementShape> body;

  const CaseShape(this.labels, this.body);
}

final class SwitchShape extends StatementShape {
  final RustViewNode selector;
  final List<CaseShape> cases;
  final List<StatementShape>? defaultBody;

  const SwitchShape(
    super.origin, {
    required this.selector,
    required this.cases,
    required this.defaultBody,
  });
}

final class ReturnShape extends StatementShape {
  final RustViewNode? value;

  const ReturnShape(super.origin, this.value);
}

final class CallShape extends StatementShape {
  final String name;
  final List<RustViewNode> arguments;

  const CallShape(super.origin, this.name, this.arguments);
}

final class MethodCallShape extends StatementShape {
  final RustViewNode call;
  final List<RustViewNode> target;
  final String methodName;
  final List<RustViewNode> arguments;

  const MethodCallShape(
    super.origin, {
    required this.call,
    required this.target,
    required this.methodName,
    required this.arguments,
  });

  bool get isSuperConstructor => call.semantics.superConstructor;
}

final class UnsupportedShape extends StatementShape {
  const UnsupportedShape(super.origin);
}

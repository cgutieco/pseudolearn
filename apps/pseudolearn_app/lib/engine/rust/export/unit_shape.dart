import 'statement_shape.dart';

final class TypeShape {
  final String? primitive;
  final String text;

  const TypeShape({required this.primitive, required this.text});
}

final class ParameterShape {
  final String name;
  final TypeShape type;

  const ParameterShape(this.name, this.type);
}

final class FieldShape {
  final TypeShape type;
  final List<String> names;

  const FieldShape(this.type, this.names);
}

sealed class MemberShape {
  final List<ParameterShape> parameters;
  final List<StatementShape> body;

  const MemberShape(this.parameters, this.body);
}

final class ConstructorShape extends MemberShape {
  const ConstructorShape(super.parameters, super.body);
}

final class MethodShape extends MemberShape {
  final String name;
  final TypeShape? returnType;

  const MethodShape(
    this.name,
    super.parameters,
    super.body, {
    required this.returnType,
  });
}

final class ClassShape {
  final String name;
  final String? superclass;
  final List<FieldShape> fields;
  final List<MemberShape> members;

  const ClassShape({
    required this.name,
    required this.superclass,
    required this.fields,
    required this.members,
  });
}

final class SubroutineShape {
  final String name;
  final List<ParameterShape> parameters;
  final List<StatementShape> body;

  const SubroutineShape(this.name, this.parameters, this.body);
}

final class ProgramShape {
  final List<ClassShape> classes;
  final List<SubroutineShape> subroutines;
  final List<StatementShape>? algorithm;
  final Set<String> builtins;

  const ProgramShape({
    required this.classes,
    required this.subroutines,
    required this.algorithm,
    required this.builtins,
  });
}

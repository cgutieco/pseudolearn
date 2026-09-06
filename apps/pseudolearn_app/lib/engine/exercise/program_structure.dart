import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/knowledge/ast_construct.dart';
import '../../domain/model/knowledge/member_visibility.dart';
import 'class_member_signature.dart';
import 'subprogram_signature.dart';

final class ProgramStructure {
  final Map<AstConstruct, int> _occurrences;
  final Set<SubprogramSignature> _subprograms;
  final Set<ClassMemberSignature> _classMembers;

  const ProgramStructure._({
    required Map<AstConstruct, int> occurrences,
    required Set<SubprogramSignature> subprograms,
    required Set<ClassMemberSignature> classMembers,
  })  : _occurrences = occurrences,
        _subprograms = subprograms,
        _classMembers = classMembers;

  factory ProgramStructure.of(SourceUnitNode unit) {
    final builder = _StructureBuilder();
    builder.visit(unit);
    return ProgramStructure._(
      occurrences: builder.occurrences,
      subprograms: builder.subprograms,
      classMembers: builder.classMembers,
    );
  }

  int occurrencesOf(AstConstruct construct) => _occurrences[construct] ?? 0;

  Set<AstConstruct> get usedConstructs => _occurrences.keys.toSet();

  bool declaresSubprogram(String name, int arity) =>
      _subprograms.contains(SubprogramSignature(name: name, arity: arity));

  bool declaresClassMember({
    required String className,
    required String memberName,
    required MemberVisibility visibility,
  }) {
    return _classMembers.contains(ClassMemberSignature(
      className: className,
      memberName: memberName,
      visibility: visibility,
    ));
  }
}

final class _StructureBuilder {
  final Map<AstConstruct, int> occurrences = {};
  final Set<SubprogramSignature> subprograms = {};
  final Set<ClassMemberSignature> classMembers = {};

  void visit(AstNode node) {
    _count(node);
    if (node is ClassNode) _collectClassMembers(node);
    if (node is SubroutineDeclarationNode) {
      subprograms.add(SubprogramSignature(
        name: node.name,
        arity: node.parameters.length,
      ));
    }
    for (final child in getChildNodes(node)) {
      visit(child);
    }
  }

  void _count(AstNode node) {
    final construct = _constructOf(node);
    if (construct == null) return;
    occurrences[construct] = (occurrences[construct] ?? 0) + 1;
  }

  AstConstruct? _constructOf(AstNode node) => switch (node) {
        IfStatementNode() => AstConstruct.conditional,
        SwitchStatementNode() => AstConstruct.multipleSelection,
        WhileStatementNode() => AstConstruct.conditionalLoop,
        RepeatUntilStatementNode() => AstConstruct.postConditionalLoop,
        ForStatementNode() => AstConstruct.countedLoop,
        DimensionStatementNode() => AstConstruct.arrayDeclaration,
        SubroutineDeclarationNode() => AstConstruct.subprogram,
        ClassNode() => AstConstruct.classDeclaration,
        _ => null,
      };

  void _collectClassMembers(ClassNode node) {
    for (final member in node.members) {
      classMembers.addAll(_signaturesOf(node.name, member));
    }
  }

  List<ClassMemberSignature> _signaturesOf(
    String className,
    ClassMemberNode member,
  ) {
    return switch (member) {
      ClassFieldNode(:final visibility, :final declaration) =>
        _fieldSignatures(className, visibility, declaration),
      MethodDeclarationNode(:final visibility, :final name) => [
          ClassMemberSignature(
            className: className,
            memberName: name,
            visibility: _toMemberVisibility(visibility),
          ),
        ],
      ConstructorDeclarationNode() => const [],
    };
  }

  List<ClassMemberSignature> _fieldSignatures(
    String className,
    Visibility visibility,
    StatementNode declaration,
  ) {
    if (declaration is! VariableDeclarationNode) return const [];
    return [
      for (final variable in declaration.variables)
        ClassMemberSignature(
          className: className,
          memberName: variable.name,
          visibility: _toMemberVisibility(visibility),
        ),
    ];
  }

  MemberVisibility _toMemberVisibility(Visibility visibility) =>
      switch (visibility) {
        Visibility.public => MemberVisibility.publicMember,
        Visibility.private => MemberVisibility.privateMember,
      };
}

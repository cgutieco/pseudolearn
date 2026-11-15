import '../../domain/model/knowledge/member_visibility.dart';

final class ClassMemberSignature {
  final String className;
  final String memberName;
  final MemberVisibility visibility;

  const ClassMemberSignature({
    required this.className,
    required this.memberName,
    required this.visibility,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassMemberSignature &&
          runtimeType == other.runtimeType &&
          className == other.className &&
          memberName == other.memberName &&
          visibility == other.visibility;

  @override
  int get hashCode => Object.hash(className, memberName, visibility);
}

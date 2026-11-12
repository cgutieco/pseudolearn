import 'rust_program_view.dart';

final class RustDiagramUnitIdentifier {
  const RustDiagramUnitIdentifier._();

  static String fromUnit(RustViewUnit unit) =>
      '${unit.kind == 'algorithm' ? 'alg' : 'sub'}_${unit.name}';

  static String fromMember(RustViewMember member) => switch (member.kind) {
    'constructor' => 'ctor_${member.className}',
    _ => 'method_${member.className}_${member.name}',
  };
}

import 'rust_program_view.dart';

final class RustDiagramUnitIdentifier {
  const RustDiagramUnitIdentifier._();

  static String fromUnit(RustViewUnit unit) =>
      '${unit.kind == 'algorithm' ? 'alg' : 'sub'}_${unit.name}';

  static String fromMember(RustViewMember member) =>
      '${member.kind == 'constructor' ? 'ctor' : 'method'}'
      '_${member.className}_${member.name}';
}

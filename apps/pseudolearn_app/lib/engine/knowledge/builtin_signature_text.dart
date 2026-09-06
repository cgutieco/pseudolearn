import 'package:pseudolearn_core/pseudolearn_core.dart';

String builtinSignatureText(LanguageProfile profile, BuiltinFunction function) {
  final entry = profile.builtinFunctions[function];
  final signature = builtinSignatures[function];
  final name = entry?.canonicalName ?? function.name;
  if (signature == null) return name;
  final parameters = signature.parameters
      .map((parameter) => builtinParameterText(profile, parameter))
      .join(', ');
  return '$name($parameters)';
}

String builtinParameterText(
  LanguageProfile profile,
  BuiltinParameterKind kind,
) {
  return switch (kind) {
    BuiltinParameterKind.integer => profile.formatPrimitiveType(PrimitiveType.integer),
    BuiltinParameterKind.real => profile.formatPrimitiveType(PrimitiveType.real),
    BuiltinParameterKind.numeric =>
      '${profile.formatPrimitiveType(PrimitiveType.integer)} | ${profile.formatPrimitiveType(PrimitiveType.real)}',
    BuiltinParameterKind.string => profile.formatPrimitiveType(PrimitiveType.string),
    BuiltinParameterKind.character => profile.formatPrimitiveType(PrimitiveType.character),
    BuiltinParameterKind.anyPrimitive => PrimitiveType.values
        .map(profile.formatPrimitiveType)
        .join(' | '),
    BuiltinParameterKind.anyClass => profile.formatTokenType(TokenType.identifier),
  };
}

String builtinReturnText(LanguageProfile profile, BuiltinReturnKind kind, String sameAsArgument) {
  return switch (kind) {
    BuiltinReturnKind.integer => profile.formatPrimitiveType(PrimitiveType.integer),
    BuiltinReturnKind.real => profile.formatPrimitiveType(PrimitiveType.real),
    BuiltinReturnKind.string => profile.formatPrimitiveType(PrimitiveType.string),
    BuiltinReturnKind.character => profile.formatPrimitiveType(PrimitiveType.character),
    BuiltinReturnKind.sameAsFirstArgument => sameAsArgument,
  };
}

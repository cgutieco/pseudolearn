import 'builtin_function.dart';
import 'builtin_parameter_kind.dart';

final class BuiltinSignature {
  final List<BuiltinParameterKind> parameters;
  final BuiltinReturnKind returnKind;

  const BuiltinSignature({
    required this.parameters,
    required this.returnKind,
  });
}

const Map<BuiltinFunction, BuiltinSignature> builtinSignatures = {
  BuiltinFunction.squareRoot: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.absoluteValue: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.naturalLogarithm: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.exponential: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.sine: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.cosine: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.arcTangent: BuiltinSignature(
    parameters: [BuiltinParameterKind.numeric],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.truncate: BuiltinSignature(
    parameters: [BuiltinParameterKind.real],
    returnKind: BuiltinReturnKind.integer,
  ),
  BuiltinFunction.round: BuiltinSignature(
    parameters: [BuiltinParameterKind.real],
    returnKind: BuiltinReturnKind.integer,
  ),
  BuiltinFunction.random: BuiltinSignature(
    parameters: [],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.toText: BuiltinSignature(
    parameters: [BuiltinParameterKind.anyPrimitive],
    returnKind: BuiltinReturnKind.string,
  ),
  BuiltinFunction.textToInteger: BuiltinSignature(
    parameters: [BuiltinParameterKind.string],
    returnKind: BuiltinReturnKind.integer,
  ),
  BuiltinFunction.textToReal: BuiltinSignature(
    parameters: [BuiltinParameterKind.string],
    returnKind: BuiltinReturnKind.real,
  ),
  BuiltinFunction.length: BuiltinSignature(
    parameters: [BuiltinParameterKind.string],
    returnKind: BuiltinReturnKind.integer,
  ),
  BuiltinFunction.characterAt: BuiltinSignature(
    parameters: [BuiltinParameterKind.string, BuiltinParameterKind.integer],
    returnKind: BuiltinReturnKind.character,
  ),
  BuiltinFunction.characterCode: BuiltinSignature(
    parameters: [BuiltinParameterKind.character],
    returnKind: BuiltinReturnKind.integer,
  ),
  BuiltinFunction.characterFromCode: BuiltinSignature(
    parameters: [BuiltinParameterKind.integer],
    returnKind: BuiltinReturnKind.character,
  ),
  BuiltinFunction.shallowCopy: BuiltinSignature(
    parameters: [BuiltinParameterKind.anyClass],
    returnKind: BuiltinReturnKind.sameAsFirstArgument,
  ),
};

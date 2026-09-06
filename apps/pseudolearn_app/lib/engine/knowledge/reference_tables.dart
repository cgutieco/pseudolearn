import 'package:pseudolearn_core/pseudolearn_core.dart';
import '../../domain/model/knowledge/marker_resolution.dart';
import 'builtin_signature_text.dart';
import 'marker_vocabulary.dart';

const String primitiveTypesTable = 'primitiveTypes';
const String precedenceTable = 'precedence';
const String builtinFunctionsTable = 'builtinFunctions';

const List<List<TokenType>> _precedenceLevels = [
  [TokenType.plus, TokenType.minus, TokenType.not],
  [TokenType.power],
  [TokenType.multiply, TokenType.divide, TokenType.integerDivide, TokenType.modulo],
  [TokenType.plus, TokenType.minus],
  [TokenType.lessThan, TokenType.lessThanOrEqual, TokenType.greaterThan, TokenType.greaterThanOrEqual],
  [TokenType.equal, TokenType.notEqual],
  [TokenType.and],
  [TokenType.or],
];

const List<bool> _levelIsRightAssociative = [
  true,
  true,
  false,
  false,
  false,
  false,
  false,
  false,
];

MarkerResolution? referenceTable({
  required String identifier,
  required LanguageProfile profile,
  required MarkerVocabulary vocabulary,
}) {
  return switch (identifier) {
    primitiveTypesTable => _primitiveTypes(profile, vocabulary),
    precedenceTable => _precedence(profile, vocabulary),
    builtinFunctionsTable => _builtinFunctions(profile, vocabulary),
    _ => null,
  };
}

MarkerResolution _primitiveTypes(
  LanguageProfile profile,
  MarkerVocabulary vocabulary,
) {
  return ResolvedMarkerTable(
    headers: [vocabulary.type],
    rows: [
      for (final type in PrimitiveType.values) [profile.formatPrimitiveType(type)],
    ],
  );
}

MarkerResolution _precedence(
  LanguageProfile profile,
  MarkerVocabulary vocabulary,
) {
  final rows = <List<String>>[];
  for (var index = 0; index < _precedenceLevels.length; index++) {
    rows.add([
      '${index + 1}',
      _precedenceLevels[index].map(profile.formatTokenType).join(' '),
      _levelIsRightAssociative[index] ? vocabulary.toTheRight : vocabulary.toTheLeft,
    ]);
  }
  return ResolvedMarkerTable(
    headers: [vocabulary.level, vocabulary.operators, vocabulary.associativity],
    rows: rows,
  );
}

MarkerResolution _builtinFunctions(
  LanguageProfile profile,
  MarkerVocabulary vocabulary,
) {
  final rows = <List<String>>[];
  for (final function in BuiltinFunction.values) {
    final signature = builtinSignatures[function];
    if (signature == null) continue;
    rows.add([
      builtinSignatureText(profile, function),
      builtinReturnText(
        profile,
        signature.returnKind,
        profile.formatTokenType(TokenType.identifier),
      ),
    ]);
  }
  return ResolvedMarkerTable(
    headers: [vocabulary.function, vocabulary.returns],
    rows: rows,
  );
}

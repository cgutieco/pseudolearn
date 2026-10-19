import '../knowledge/marker_vocabulary.dart';
import 'rust_reference_vocabulary.dart';

List<String> primitiveTypeLexemes(RustReferenceData data) => [
  for (final identity in const [
    'integerType',
    'realType',
    'booleanType',
    'characterType',
    'stringType',
  ])
    data.lexeme(identity),
];

String signatureText(RustReferenceData data, RustBuiltinEntry entry) {
  final parameters = entry.parameters
      .map((kind) => _parameterText(data, kind))
      .join(', ');
  return '${entry.lexeme}($parameters)';
}

String returnText(RustReferenceData data, String kind) => switch (kind) {
  'integer' => data.lexeme('integerType'),
  'real' => data.lexeme('realType'),
  'string' => data.lexeme('stringType'),
  'character' => data.lexeme('characterType'),
  _ => data.identifierLabel,
};

List<List<String>> precedenceRows(
  RustReferenceData data,
  MarkerVocabulary vocabulary,
) => [
  for (final level in data.precedence)
    [
      '${level.level}',
      level.operators.map(data.lexeme).join(' '),
      level.rightAssociative ? vocabulary.toTheRight : vocabulary.toTheLeft,
    ],
];

String _parameterText(RustReferenceData data, String kind) => switch (kind) {
  'integer' => data.lexeme('integerType'),
  'real' => data.lexeme('realType'),
  'numeric' => '${data.lexeme('integerType')} | ${data.lexeme('realType')}',
  'string' => data.lexeme('stringType'),
  'character' => data.lexeme('characterType'),
  'anyPrimitive' => primitiveTypeLexemes(data).join(' | '),
  _ => data.identifierLabel,
};

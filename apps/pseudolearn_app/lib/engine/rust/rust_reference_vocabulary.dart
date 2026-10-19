import '../../domain/model/profiles/syntax_profile_id.dart';
import 'rust_profile_name.dart';
import 'rust_transport.dart';

final class RustBuiltinEntry {
  final String identity;
  final String lexeme;
  final List<String> parameters;
  final String returns;

  const RustBuiltinEntry({
    required this.identity,
    required this.lexeme,
    required this.parameters,
    required this.returns,
  });
}

final class RustPrecedenceLevel {
  final int level;
  final List<String> operators;
  final bool rightAssociative;

  const RustPrecedenceLevel({
    required this.level,
    required this.operators,
    required this.rightAssociative,
  });
}

final class RustReferenceData {
  final Map<String, String> keywords;
  final List<RustBuiltinEntry> builtins;
  final List<RustPrecedenceLevel> precedence;
  final String identifierLabel;

  const RustReferenceData({
    required this.keywords,
    required this.builtins,
    required this.precedence,
    required this.identifierLabel,
  });

  String lexeme(String identity) => keywords[identity] ?? identity;
}

final class RustReferenceVocabulary {
  final RustTransport _transport;

  const RustReferenceVocabulary(this._transport);

  RustReferenceData forProfile(SyntaxProfileId profileId) {
    final arguments = {'profile': rustProfileName(profileId)};
    final words =
        _transport.call('editor_vocabulary', arguments) as Map<String, Object?>;
    final reference =
        _transport.call('reference_vocabulary', arguments)
            as Map<String, Object?>;
    return RustReferenceData(
      keywords: {
        for (final pair in words['keywords'] as List<Object?>)
          (pair as List<Object?>)[0] as String: pair[1] as String,
      },
      builtins: [
        for (final row in _rows(reference['builtins'])) _builtinOf(row),
      ],
      precedence: [
        for (final row in _rows(reference['precedence'])) _levelOf(row),
      ],
      identifierLabel: reference['identifier_label'] as String,
    );
  }

  Iterable<Map<String, Object?>> _rows(Object? value) =>
      (value as List<Object?>).cast<Map<String, Object?>>();

  RustBuiltinEntry _builtinOf(Map<String, Object?> row) => RustBuiltinEntry(
    identity: row['identity'] as String,
    lexeme: row['lexeme'] as String,
    parameters: (row['parameters'] as List<Object?>).cast<String>(),
    returns: row['returns'] as String,
  );

  RustPrecedenceLevel _levelOf(Map<String, Object?> row) =>
      RustPrecedenceLevel(
        level: row['level'] as int,
        operators: (row['operators'] as List<Object?>).cast<String>(),
        rightAssociative: row['right_associative'] as bool,
      );
}

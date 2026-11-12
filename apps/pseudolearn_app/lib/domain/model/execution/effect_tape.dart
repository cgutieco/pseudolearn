import 'dart:convert';

final class EffectTape {
  final String canonicalJson;

  const EffectTape._(this.canonicalJson);

  factory EffectTape.fromDocument(Map<String, Object?> document) =>
      EffectTape._(jsonEncode(document));

  Map<String, Object?> toDocument() =>
      jsonDecode(canonicalJson) as Map<String, Object?>;

  @override
  bool operator ==(Object other) =>
      other is EffectTape && other.canonicalJson == canonicalJson;

  @override
  int get hashCode => canonicalJson.hashCode;
}

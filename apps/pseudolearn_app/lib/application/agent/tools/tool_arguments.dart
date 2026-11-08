import 'dart:convert';
import '../../../domain/model/profiles/syntax_profile_id.dart';

ToolArguments? decodeToolArguments(String json) {
  try {
    final decoded = jsonDecode(json.trim().isEmpty ? '{}' : json);
    return decoded is Map<String, Object?> ? ToolArguments(decoded) : null;
  } on FormatException {
    return null;
  }
}

final class ToolArguments {
  final Map<String, Object?> values;

  const ToolArguments(this.values);

  String? text(String name) {
    final value = values[name];
    return value is String ? value : null;
  }

  int? integer(String name) {
    final value = values[name];
    return value is int ? value : (value is double ? value.toInt() : null);
  }

  bool? flag(String name) {
    final value = values[name];
    return value is bool ? value : null;
  }

  List<String>? texts(String name) {
    final value = values[name];
    if (value is! List<Object?>) return null;
    final strings = <String>[];
    for (final entry in value) {
      if (entry is! String) return null;
      strings.add(entry);
    }
    return strings;
  }

  SyntaxProfileId? profile(String name) {
    final value = text(name);
    for (final profile in SyntaxProfileId.values) {
      if (profile.name == value) return profile;
    }
    return null;
  }
}

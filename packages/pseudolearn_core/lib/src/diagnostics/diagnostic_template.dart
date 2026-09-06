final class DiagnosticTemplate {
  final String pattern;
  final Set<String> requiredArguments;

  const DiagnosticTemplate(
    this.pattern, {
    this.requiredArguments = const <String>{},
  });

  String render(Map<String, String> values) {
    var result = pattern;
    for (final entry in values.entries) {
      result = result.replaceAll('{${entry.key}}', entry.value);
    }
    return result;
  }
}

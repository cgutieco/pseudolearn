final class ExecutionConfiguration {
  final String documentId;
  final List<String> arguments;
  final String strictness;

  const ExecutionConfiguration({
    this.documentId = 'untitled',
    this.arguments = const [],
    this.strictness = 'flexible',
  });
}

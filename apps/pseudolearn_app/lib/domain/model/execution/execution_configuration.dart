final class ExecutionConfiguration {
  final String documentId;
  final List<String> arguments;

  const ExecutionConfiguration({
    this.documentId = 'untitled',
    this.arguments = const [],
  });
}

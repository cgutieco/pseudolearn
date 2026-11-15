final class Workload {
  final String name;
  final String family;
  final String source;
  final String expectedOutput;
  final int operations;

  const Workload({
    required this.name,
    required this.family,
    required this.source,
    required this.expectedOutput,
    required this.operations,
  });
}

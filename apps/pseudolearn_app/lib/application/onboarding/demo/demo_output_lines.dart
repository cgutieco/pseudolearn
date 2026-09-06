import '../../../domain/model/execution/output_line.dart';

final class DemoOutputLines {
  const DemoOutputLines();

  List<String> of(List<OutputLine> fragments) {
    final buffer = StringBuffer();
    for (final fragment in fragments) {
      buffer.write(fragment.text);
    }
    final joined = buffer.toString();
    if (joined.isEmpty) return const [];
    final lines = joined.split('\n');
    while (lines.isNotEmpty && lines.last.isEmpty) {
      lines.removeLast();
    }
    return lines;
  }
}

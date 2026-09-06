import 'package:pseudolearn_app/domain/model/progress/progress_entry.dart';
import 'package:pseudolearn_app/domain/ports/progress_history.dart';

final class InMemoryProgressHistory implements ProgressHistory {
  List<ProgressEntry> entries;
  bool shouldThrow;

  InMemoryProgressHistory({this.entries = const [], this.shouldThrow = false});

  @override
  Future<List<ProgressEntry>> readEntries() async {
    if (shouldThrow) throw Exception('Progress history unavailable');
    return entries;
  }
}

import '../model/progress/progress_entry.dart';

abstract interface class ProgressHistory {
  Future<List<ProgressEntry>> readEntries();
}

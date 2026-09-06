import '../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';

enum KnowledgeDetailStatus {
  initial,
  loading,
  success,
  notFound,
  error,
}

final class EntryDetailState {
  final KnowledgeDetailStatus status;
  final KnowledgeEntry? entry;
  final KnowledgeDetailContent? content;
  final String? errorMessage;

  const EntryDetailState({
    this.status = KnowledgeDetailStatus.initial,
    this.entry,
    this.content,
    this.errorMessage,
  });

  EntryDetailState copyWith({
    KnowledgeDetailStatus? status,
    KnowledgeEntry? Function()? entry,
    KnowledgeDetailContent? Function()? content,
    String? Function()? errorMessage,
  }) {
    return EntryDetailState(
      status: status ?? this.status,
      entry: entry != null ? entry() : this.entry,
      content: content != null ? content() : this.content,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EntryDetailState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          entry == other.entry &&
          content == other.content &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(status, entry, content, errorMessage);
}

final class KnowledgeDetailState {
  final Map<String, EntryDetailState> entries;

  const KnowledgeDetailState({
    this.entries = const {},
  });

  EntryDetailState forEntry(String entryId) =>
      entries[entryId] ?? const EntryDetailState();

  KnowledgeDetailState copyWithEntry(
    String entryId,
    EntryDetailState Function(EntryDetailState current) updater,
  ) {
    final current = forEntry(entryId);
    return KnowledgeDetailState(
      entries: {
        ...entries,
        entryId: updater(current),
      },
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KnowledgeDetailState &&
          runtimeType == other.runtimeType &&
          _mapsEqual(entries, other.entries);

  @override
  int get hashCode => Object.hashAll(entries.entries);

  static bool _mapsEqual(
    Map<String, EntryDetailState> a,
    Map<String, EntryDetailState> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) return false;
    }
    return true;
  }
}

import 'package:equatable/equatable.dart';
import '../../domain/model/knowledge/knowledge_entry.dart';

enum KnowledgeStatus {
  initial,
  loading,
  success,
  error,
}

final class KnowledgeState extends Equatable {
  final KnowledgeStatus status;
  final List<KnowledgeEntry> specificationEntries;
  final List<KnowledgeEntry> filteredSpecificationEntries;
  final List<KnowledgeEntry> exerciseEntries;
  final List<KnowledgeEntry> filteredExerciseEntries;
  final String searchQuery;
  final String? errorMessage;

  const KnowledgeState({
    this.status = KnowledgeStatus.initial,
    this.specificationEntries = const [],
    this.filteredSpecificationEntries = const [],
    this.exerciseEntries = const [],
    this.filteredExerciseEntries = const [],
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get isSearching => searchQuery.trim().isNotEmpty;

  bool get isSpecificationEmpty =>
      status == KnowledgeStatus.success && specificationEntries.isEmpty;

  bool get isSpecificationSearchEmpty =>
      status == KnowledgeStatus.success &&
      specificationEntries.isNotEmpty &&
      filteredSpecificationEntries.isEmpty;

  bool get isExerciseEmpty =>
      status == KnowledgeStatus.success && exerciseEntries.isEmpty;

  bool get isExerciseSearchEmpty =>
      status == KnowledgeStatus.success &&
      exerciseEntries.isNotEmpty &&
      filteredExerciseEntries.isEmpty;

  KnowledgeState copyWith({
    KnowledgeStatus? status,
    List<KnowledgeEntry>? specificationEntries,
    List<KnowledgeEntry>? filteredSpecificationEntries,
    List<KnowledgeEntry>? exerciseEntries,
    List<KnowledgeEntry>? filteredExerciseEntries,
    String? searchQuery,
    String? Function()? errorMessage,
  }) {
    return KnowledgeState(
      status: status ?? this.status,
      specificationEntries: specificationEntries ?? this.specificationEntries,
      filteredSpecificationEntries:
          filteredSpecificationEntries ?? this.filteredSpecificationEntries,
      exerciseEntries: exerciseEntries ?? this.exerciseEntries,
      filteredExerciseEntries: filteredExerciseEntries ?? this.filteredExerciseEntries,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        specificationEntries,
        filteredSpecificationEntries,
        exerciseEntries,
        filteredExerciseEntries,
        searchQuery,
        errorMessage,
      ];
}

import '../../../domain/model/knowledge/ast_construct.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/knowledge/exercise_level.dart';
import '../../../domain/model/knowledge/list_equality.dart';

enum ExerciseBankStatus {
  initial,
  loading,
  success,
  error,
}

final class ExerciseBankState {
  final ExerciseBankStatus status;
  final List<Exercise> allExercises;
  final List<Exercise> filteredExercises;
  final Set<String> completedExerciseIds;
  final List<String> availableModuleIds;
  final List<AstConstruct> availableConstructs;
  final ExerciseLevel? selectedLevel;
  final String? selectedModuleId;
  final AstConstruct? selectedConstruct;
  final String searchQuery;
  final String? errorMessage;

  const ExerciseBankState({
    this.status = ExerciseBankStatus.initial,
    this.allExercises = const [],
    this.filteredExercises = const [],
    this.completedExerciseIds = const {},
    this.availableModuleIds = const [],
    this.availableConstructs = const [],
    this.selectedLevel,
    this.selectedModuleId,
    this.selectedConstruct,
    this.searchQuery = '',
    this.errorMessage,
  });

  bool get isEmptyBank => allExercises.isEmpty && status == ExerciseBankStatus.success;

  bool get isEmptyFilterResult =>
      allExercises.isNotEmpty && filteredExercises.isEmpty && status == ExerciseBankStatus.success;

  bool get isAnyFilterActive =>
      selectedLevel != null ||
      selectedModuleId != null ||
      selectedConstruct != null ||
      searchQuery.trim().isNotEmpty;

  bool isExerciseCompleted(String id) => completedExerciseIds.contains(id);

  Exercise? findExercise(String id) {
    for (final exercise in allExercises) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  ExerciseBankState copyWith({
    ExerciseBankStatus? status,
    List<Exercise>? allExercises,
    List<Exercise>? filteredExercises,
    Set<String>? completedExerciseIds,
    List<String>? availableModuleIds,
    List<AstConstruct>? availableConstructs,
    ExerciseLevel? Function()? selectedLevel,
    String? Function()? selectedModuleId,
    AstConstruct? Function()? selectedConstruct,
    String? searchQuery,
    String? Function()? errorMessage,
  }) {
    return ExerciseBankState(
      status: status ?? this.status,
      allExercises: allExercises ?? this.allExercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      availableModuleIds: availableModuleIds ?? this.availableModuleIds,
      availableConstructs: availableConstructs ?? this.availableConstructs,
      selectedLevel: selectedLevel != null ? selectedLevel() : this.selectedLevel,
      selectedModuleId: selectedModuleId != null ? selectedModuleId() : this.selectedModuleId,
      selectedConstruct: selectedConstruct != null ? selectedConstruct() : this.selectedConstruct,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseBankState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          listEquals(allExercises, other.allExercises) &&
          listEquals(filteredExercises, other.filteredExercises) &&
          setEquals(completedExerciseIds, other.completedExerciseIds) &&
          listEquals(availableModuleIds, other.availableModuleIds) &&
          listEquals(availableConstructs, other.availableConstructs) &&
          selectedLevel == other.selectedLevel &&
          selectedModuleId == other.selectedModuleId &&
          selectedConstruct == other.selectedConstruct &&
          searchQuery == other.searchQuery &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => Object.hash(
        status,
        Object.hashAll(allExercises),
        Object.hashAll(filteredExercises),
        Object.hashAll(completedExerciseIds),
        Object.hashAll(availableModuleIds),
        Object.hashAll(availableConstructs),
        selectedLevel,
        selectedModuleId,
        selectedConstruct,
        searchQuery,
        errorMessage,
      );
}

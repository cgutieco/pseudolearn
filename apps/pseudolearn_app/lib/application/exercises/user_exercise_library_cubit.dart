import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/documents/document_command_result.dart';
import '../../domain/model/exercises/exercise_reference.dart';
import '../../domain/model/exercises/user_exercise.dart';
import '../../domain/model/exercises/user_exercise_change.dart';
import '../../domain/ports/user_exercise_repository.dart';
import '../library/use_cases/create_document.dart';
import '../library/use_cases/list_documents.dart';
import 'use_cases/delete_user_exercise.dart';
import 'user_exercise_library_state.dart';

final class UserExerciseLibraryCubit extends Cubit<UserExerciseLibraryState> {
  final UserExerciseRepository _repository;
  final DeleteUserExercise _delete;
  final ListDocuments _listDocuments;
  final CreateDocument _createDocument;
  StreamSubscription<UserExerciseChange>? _changes;

  UserExerciseLibraryCubit({
    required UserExerciseRepository repository,
    required this._listDocuments,
    required this._createDocument,
  }) : _repository = repository,
       _delete = DeleteUserExercise(repository: repository),
       super(const UserExerciseLibraryState()) {
    _changes = repository.changes.listen((_) {
      if (!isClosed && state.status == UserExerciseLibraryStatus.ready) load();
    });
  }

  Future<void> load() async {
    if (state.status != UserExerciseLibraryStatus.ready) {
      emit(const UserExerciseLibraryState(status: UserExerciseLibraryStatus.loading));
    }
    try {
      final exercises = await _repository.listExercises();
      if (!isClosed) {
        emit(UserExerciseLibraryState(
          status: UserExerciseLibraryStatus.ready,
          exercises: exercises,
        ));
      }
    } catch (_) {
      if (!isClosed) {
        emit(const UserExerciseLibraryState(status: UserExerciseLibraryStatus.failure));
      }
    }
  }

  Future<bool> delete(String exerciseId) => _delete(exerciseId);

  Future<String?> openAttempt(UserExercise exercise) async {
    final reference = exercise.reference;
    final documents = await _listDocuments() ?? const <DocumentSummary>[];
    for (final document in documents) {
      final linked = document.exerciseId;
      if (linked != null && ExerciseReference.parse(linked) == reference) {
        return document.id;
      }
    }
    final result = await _createDocument(CreateDocumentCommand(
      title: _attemptTitle(exercise.title, documents),
      profileId: exercise.draft.profileId,
      content: exercise.draft.starterCode,
      exerciseId: reference.encoded,
    ));
    return result is DocumentCommandSucceeded ? result.document.id : null;
  }

  @override
  Future<void> close() async {
    await _changes?.cancel();
    return super.close();
  }

  String _attemptTitle(String title, List<DocumentSummary> documents) {
    final taken = {for (final document in documents) document.title.toLowerCase()};
    var candidate = title.trim();
    var suffix = 2;
    while (taken.contains(candidate.toLowerCase())) {
      candidate = '${title.trim()} ($suffix)';
      suffix += 1;
    }
    return candidate;
  }
}

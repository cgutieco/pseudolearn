import '../../domain/model/exercises/exercise_publication.dart';
import '../../domain/model/exercises/user_exercise_draft.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';

enum UserExerciseEditorStatus { editing, loading, saving, saved, missing, formatError, storageError }

enum UserExerciseFormField { visibleCases, hiddenCases, assertions }

final class UserExerciseEditorState {
  final String? exerciseId;
  final UserExerciseDraft draft;
  final UserExerciseEditorStatus status;
  final ExercisePublication? publication;
  final UserExerciseFormField? malformedField;

  const UserExerciseEditorState({
    required this.draft,
    this.exerciseId,
    this.status = UserExerciseEditorStatus.editing,
    this.publication,
    this.malformedField,
  });

  UserExerciseEditorState.blank(SyntaxProfileId profileId)
    : this(
        draft: UserExerciseDraft(
          title: '',
          statement: '',
          referenceSolution: '',
          profileId: profileId,
        ),
      );

  bool get isNew => exerciseId == null;
}

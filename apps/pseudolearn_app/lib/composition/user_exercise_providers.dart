import 'package:flutter_bloc/flutter_bloc.dart';
import '../application/exercises/use_cases/create_user_exercise.dart';
import '../application/exercises/use_cases/update_user_exercise.dart';
import '../application/exercises/use_cases/validate_user_exercise.dart';
import '../application/exercises/user_exercise_editor_cubit.dart';
import '../application/exercises/user_exercise_library_cubit.dart';
import '../application/library/use_cases/create_document.dart';
import '../application/library/use_cases/list_documents.dart';
import 'app_dependencies.dart';

ValidateUserExercise buildUserExerciseValidation(AppDependencies dependencies) =>
    ValidateUserExercise(
      analyzer: dependencies.programAnalyzer,
      checker: dependencies.exerciseChecker,
    );

List<BlocProvider> createUserExerciseProviders(AppDependencies dependencies) {
  final validate = buildUserExerciseValidation(dependencies);
  return [
    BlocProvider<UserExerciseLibraryCubit>(
      create: (_) => UserExerciseLibraryCubit(
        repository: dependencies.userExerciseRepository,
        listDocuments: ListDocuments(repository: dependencies.documentRepository),
        createDocument: CreateDocument(
          repository: dependencies.documentRepository,
          identifiers: dependencies.identifiers,
          clock: dependencies.clock,
        ),
      ),
    ),
    BlocProvider<UserExerciseEditorCubit>(
      create: (_) => UserExerciseEditorCubit(
        repository: dependencies.userExerciseRepository,
        create: CreateUserExercise(
          repository: dependencies.userExerciseRepository,
          validate: validate,
          identifiers: dependencies.identifiers,
          clock: dependencies.clock,
        ),
        update: UpdateUserExercise(
          repository: dependencies.userExerciseRepository,
          validate: validate,
          clock: dependencies.clock,
        ),
      ),
    ),
  ];
}

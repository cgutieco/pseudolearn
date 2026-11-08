import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pseudolearn_app/application/route/session/exercise_session_cubit.dart';
import 'package:pseudolearn_app/application/settings/settings_cubit.dart';
import 'package:pseudolearn_app/composition/agent_providers.dart';
import 'package:pseudolearn_app/composition/app_dependencies.dart';
import 'package:pseudolearn_app/composition/app_scope.dart';

List<BlocProvider> buildTestAgentProviders(AppDependencies dependencies) => buildAgentProviders(
  dependencies: dependencies,
  scope: AppScope.detached(),
  settings: SettingsCubit(preferences: dependencies.preferences),
  exerciseSession: ExerciseSessionCubit(
    repository: dependencies.routeRepository,
    checker: dependencies.exerciseChecker,
    progressStore: dependencies.localProgressStore,
    userExercises: dependencies.userExerciseRepository,
  ),
);

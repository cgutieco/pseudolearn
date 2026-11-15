import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/route/route_toc.dart';
import '../../domain/ports/local_progress_store.dart';
import '../../domain/ports/route_repository.dart';
import 'route_bank_state.dart';
import 'route_progress.dart';

final class RouteBankCubit extends Cubit<RouteBankState> {
  final RouteRepository _repository;
  final LocalProgressStore _progressStore;
  RouteToc _toc = const RouteToc.empty();
  ReferenceEdition? _edition;
  late final StreamSubscription<void> _progressChanges;

  RouteBankCubit({
    required this._repository,
    required this._progressStore,
    Stream<void> progressChanges = const Stream.empty(),
  }) : super(const RouteBankState()) {
    _progressChanges = progressChanges.listen((_) => refresh());
  }

  Future<void> load(ReferenceEdition edition) async {
    emit(const RouteBankState(status: RouteBankStatus.loading));
    await _project(edition);
  }

  Future<void> refresh() async {
    final edition = _edition;
    if (edition != null) await _project(edition);
  }

  Future<void> _project(ReferenceEdition edition) async {
    _edition = edition;
    final toc = await _repository.loadToc(edition);
    final progress = RouteProgress(await _progressStore.readProgress());
    if (isClosed) return;
    if (toc is! ContentLoaded<RouteToc>) {
      emit(const RouteBankState(status: RouteBankStatus.error));
      return;
    }
    _toc = toc.value;
    _emitFiltered(
      state.filter,
      completed: {
        for (final exercise in _toc.exercises)
          if (progress.isExerciseDone(exercise.id)) exercise.id,
      },
    );
  }

  void filter(RouteBankFilter filter) =>
      _emitFiltered(filter, completed: state.completedIds);

  void _emitFiltered(RouteBankFilter filter, {required Set<String> completed}) {
    final visible = [
      for (final exercise in _toc.exercises)
        if (_matches(exercise, filter)) exercise,
    ];
    emit(
      RouteBankState(
        status: RouteBankStatus.success,
        parts: _toc.parts,
        visible: visible,
        completedIds: completed,
        filter: filter,
      ),
    );
  }

  bool _matches(RouteExerciseEntry exercise, RouteBankFilter filter) {
    final partId = _toc.partOf(exercise.lessonId)?.id;
    return (filter.partId == null || filter.partId == partId) &&
        (filter.kind == null || exercise.kind == filter.kind) &&
        (filter.level == null || exercise.level == filter.level);
  }

  @override
  Future<void> close() async {
    await _progressChanges.cancel();
    return super.close();
  }
}

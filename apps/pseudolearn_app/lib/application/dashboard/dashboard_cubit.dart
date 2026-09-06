import 'package:bloc/bloc.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/settings/ui_language_id.dart';
import 'dashboard_inputs.dart';
import 'dashboard_loader.dart';
import 'dashboard_projection.dart';
import 'dashboard_state.dart';

final class DashboardCubit extends Cubit<DashboardState> {
  final DashboardLoader _loader;
  final DashboardProjection _projection;

  DashboardCubit({
    required DashboardLoader loader,
    DashboardProjection projection = const DashboardProjection(),
  })  : _loader = loader,
        _projection = projection,
        super(const DashboardState());

  Future<void> load(UiLanguageId language) async {
    emit(const DashboardState(status: DashboardStatus.loading));
    try {
      final result = await _loader.load(language);
      switch (result) {
        case ContentLoadFailed<DashboardInputs>(:final detail):
          emit(DashboardState(
            status: DashboardStatus.error,
            errorMessage: detail,
          ));
        case ContentLoaded<DashboardInputs>(:final value):
          emit(_projection.project(value));
      }
    } catch (error) {
      emit(DashboardState(
        status: DashboardStatus.error,
        errorMessage: error.toString(),
      ));
    }
  }
}

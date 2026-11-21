import 'package:bloc/bloc.dart';
import '../diagram/diagram_cubit.dart';
import '../export/export_cubit.dart';
import 'companion_source.dart';
import 'companion_view.dart';

final class CompanionCubit extends Cubit<CompanionView> {
  final DiagramCubit _diagram;
  final ExportCubit _export;
  CompanionSource? _pendingDiagram;
  CompanionSource? _pendingExport;

  CompanionCubit({required this._diagram, required this._export})
    : super(CompanionView.none);

  void sourceChanged(CompanionSource source) {
    _pendingDiagram = source;
    _pendingExport = source;
    _refreshShown();
  }

  void show(CompanionView view) {
    if (view != state) emit(view);
    _refreshShown();
  }

  void _refreshShown() {
    switch (state) {
      case CompanionView.diagram:
        _refreshDiagram();
      case CompanionView.equivalentCode:
        _refreshExport();
      case CompanionView.none:
        return;
    }
  }

  void _refreshDiagram() {
    final source = _pendingDiagram;
    if (source == null) return;
    _pendingDiagram = null;
    _diagram.updateDiagram(
      sourceCode: source.sourceCode,
      profileId: source.profileId,
      languageId: source.languageId,
    );
  }

  void _refreshExport() {
    final source = _pendingExport;
    if (source == null) return;
    _pendingExport = null;
    _export.updateSource(
      sourceCode: source.sourceCode,
      profileId: source.profileId,
    );
  }
}

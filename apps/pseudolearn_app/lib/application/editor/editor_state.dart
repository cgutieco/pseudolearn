import 'package:equatable/equatable.dart';
import '../../domain/model/analysis/analysis_report.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../../domain/model/completion/completion_item.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/editor/editor_key.dart';
import '../../domain/model/editor/source_edit.dart';

final class EditorState extends Equatable {
  final Document? document;
  final String sourceCode;
  final AnalysisReport report;
  final AppDiagnostic? selectedDiagnostic;
  final bool isSaving;
  final bool isDirty;
  final List<CompletionItem> completions;
  final List<EditorKey> keys;
  final SourceEdit? pendingEdit;
  final bool showsKeyBar;
  final String? errorMessage;

  const EditorState({
    required this.document,
    required this.sourceCode,
    required this.report,
    this.selectedDiagnostic,
    this.isSaving = false,
    this.isDirty = false,
    this.completions = const [],
    this.keys = const [],
    this.pendingEdit,
    this.showsKeyBar = false,
    this.errorMessage,
  });

  const EditorState.initial({this.showsKeyBar = false})
      : document = null,
        sourceCode = '',
        report = const AnalysisReport.empty(),
        selectedDiagnostic = null,
        isSaving = false,
        isDirty = false,
        completions = const [],
        keys = const [],
        pendingEdit = null,
        errorMessage = null;

  EditorState copyWith({
    Document? document,
    String? sourceCode,
    AnalysisReport? report,
    AppDiagnostic? selectedDiagnostic,
    bool? isSaving,
    bool? isDirty,
    List<CompletionItem>? completions,
    List<EditorKey>? keys,
    SourceEdit? pendingEdit,
    String? errorMessage,
  }) {
    return EditorState(
      document: document ?? this.document,
      sourceCode: sourceCode ?? this.sourceCode,
      report: report ?? this.report,
      selectedDiagnostic: selectedDiagnostic,
      isSaving: isSaving ?? this.isSaving,
      isDirty: isDirty ?? this.isDirty,
      completions: completions ?? this.completions,
      keys: keys ?? this.keys,
      pendingEdit: pendingEdit ?? this.pendingEdit,
      showsKeyBar: showsKeyBar,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        document,
        sourceCode,
        report,
        selectedDiagnostic,
        isSaving,
        isDirty,
        completions,
        keys,
        pendingEdit,
        showsKeyBar,
        errorMessage,
      ];
}

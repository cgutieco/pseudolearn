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
  final List<CompletionItem> contextualCompletions;
  final int completionRevision;
  final List<EditorKey> keys;
  final SourceEdit? pendingEdit;
  final bool showsKeyBar;
  final bool templateActive;
  final String? errorMessage;

  const EditorState({
    required this.document,
    required this.sourceCode,
    required this.report,
    this.selectedDiagnostic,
    this.isSaving = false,
    this.isDirty = false,
    this.completions = const [],
    this.contextualCompletions = const [],
    this.completionRevision = 0,
    this.keys = const [],
    this.pendingEdit,
    this.showsKeyBar = false,
    this.templateActive = false,
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
      contextualCompletions = const [],
      completionRevision = 0,
      keys = const [],
      pendingEdit = null,
      templateActive = false,
      errorMessage = null;

  EditorState copyWith({
    Document? document,
    String? sourceCode,
    AnalysisReport? report,
    AppDiagnostic? selectedDiagnostic,
    bool? isSaving,
    bool? isDirty,
    List<CompletionItem>? completions,
    List<CompletionItem>? contextualCompletions,
    int? completionRevision,
    List<EditorKey>? keys,
    SourceEdit? pendingEdit,
    bool? templateActive,
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
      contextualCompletions:
          contextualCompletions ?? this.contextualCompletions,
      completionRevision: completionRevision ?? this.completionRevision,
      keys: keys ?? this.keys,
      pendingEdit: pendingEdit ?? this.pendingEdit,
      showsKeyBar: showsKeyBar,
      templateActive: templateActive ?? this.templateActive,
      errorMessage: errorMessage,
    );
  }

  List<CompletionItem> get popupCandidates =>
      contextualCompletions.take(8).toList();

  int get completionPrefixLength {
    final range = contextualCompletions.firstOrNull?.replacementRange;
    return range == null ? 0 : range.upper - range.lower;
  }

  CompletionItem? get inlineCandidate {
    for (final candidate in contextualCompletions) {
      if (candidate.isInline) return candidate;
    }
    return null;
  }

  String? get ghostText {
    final candidate = inlineCandidate;
    final range = candidate?.replacementRange;
    if (candidate == null || range == null) return null;
    if (range.upper > sourceCode.length) return null;
    final typed = sourceCode.substring(range.lower, range.upper);
    final line = candidate.template.split('\n').first;
    final matches = line.toLowerCase().startsWith(typed.toLowerCase());
    if (!matches || line.length == typed.length) return null;
    return line.substring(typed.length);
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
    contextualCompletions,
    completionRevision,
    keys,
    pendingEdit,
    showsKeyBar,
    templateActive,
    errorMessage,
  ];
}

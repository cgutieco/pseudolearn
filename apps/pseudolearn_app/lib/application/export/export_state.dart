import 'package:equatable/equatable.dart';
import '../../domain/model/export/target_language_id.dart';

enum ExportStatus { initial, ready, analysisError, unavailable }

final class ExportState extends Equatable {
  final TargetLanguageId selectedLanguage;
  final ExportStatus status;
  final String exportedCode;
  final List<String> notes;
  final String unavailableReason;
  final Set<int> focusedLines;

  const ExportState({
    this.selectedLanguage = TargetLanguageId.python,
    this.status = ExportStatus.initial,
    this.exportedCode = '',
    this.notes = const [],
    this.unavailableReason = '',
    this.focusedLines = const {},
  });

  ExportState copyWith({
    TargetLanguageId? selectedLanguage,
    ExportStatus? status,
    String? exportedCode,
    List<String>? notes,
    String? unavailableReason,
    Set<int>? focusedLines,
  }) {
    return ExportState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      status: status ?? this.status,
      exportedCode: exportedCode ?? this.exportedCode,
      notes: notes ?? this.notes,
      unavailableReason: unavailableReason ?? this.unavailableReason,
      focusedLines: focusedLines ?? this.focusedLines,
    );
  }

  @override
  List<Object?> get props => [
        selectedLanguage,
        status,
        exportedCode,
        notes,
        unavailableReason,
        focusedLines,
      ];
}

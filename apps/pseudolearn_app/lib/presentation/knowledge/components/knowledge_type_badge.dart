import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/knowledge_entry_type.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';

(String, Color) knowledgeTypeBadge({
  required KnowledgeEntryType type,
  required AppLocalizations l10n,
  required AppThemeExtension theme,
}) {
  return switch (type) {
    KnowledgeEntryType.module => (l10n.knowledgeTypeModule, theme.syntax.keywordStructured),
    KnowledgeEntryType.specificationSection => (l10n.knowledgeTypeSpecification, theme.syntax.keywordProcedural),
    KnowledgeEntryType.exercise => (l10n.knowledgeTypeExercise, theme.syntax.keywordOop),
    KnowledgeEntryType.predictionActivity => (l10n.knowledgeTypePrediction, theme.syntax.literalNumber),
    KnowledgeEntryType.illustration => (l10n.knowledgeTypeIllustration, theme.syntax.comment),
    KnowledgeEntryType.reference => (l10n.knowledgeTypeReference, theme.syntax.literalText),
    KnowledgeEntryType.example => (l10n.knowledgeTypeExample, theme.syntax.keywordProcedural),
    KnowledgeEntryType.contact => (l10n.settingsContactTitle, theme.colors.text.secondary),
  };
}

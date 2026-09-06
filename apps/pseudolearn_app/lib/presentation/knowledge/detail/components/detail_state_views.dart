import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/exercise.dart';
import '../../../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../../components/empty/app_empty_state.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'document_detail_view.dart';
import 'exercise_detail_view.dart';
import 'module_detail_view.dart';
import 'specification_detail_view.dart';

final class NotFoundBody extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onBack;

  const NotFoundBody({
    super.key,
    required this.l10n,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: l10n.knowledgeDetailNotFoundTitle,
      description: l10n.knowledgeDetailNotFoundDescription,
      actionLabel: l10n.knowledgeDetailBack,
      onAction: onBack,
    );
  }
}

final class ErrorBody extends StatelessWidget {
  final AppLocalizations l10n;
  final String? message;
  final VoidCallback onRetry;

  const ErrorBody({
    super.key,
    required this.l10n,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.error_outline_rounded,
      title: l10n.knowledgeErrorTitle,
      description: message ?? l10n.knowledgeErrorDescription,
      actionLabel: l10n.knowledgeActionRetry,
      onAction: onRetry,
    );
  }
}

final class SuccessContent extends StatelessWidget {
  final KnowledgeDetailContent? content;
  final void Function(String entryId, {String? anchor}) onOpenSpecification;
  final ValueChanged<String>? onOpenExercise;
  final ValueChanged<String>? onReturnToModule;
  final ValueChanged<double> onScrollChanged;
  final ValueChanged<Exercise>? onOpenExerciseInNewDocument;

  const SuccessContent({
    super.key,
    required this.content,
    required this.onOpenSpecification,
    this.onOpenExercise,
    this.onReturnToModule,
    required this.onScrollChanged,
    this.onOpenExerciseInNewDocument,
  });

  @override
  Widget build(BuildContext context) {
    return switch (content) {
      final ModuleDetailContent c => ModuleDetailView(
          content: c,
          onOpenSpecification: onOpenSpecification,
          onOpenExercise: onOpenExercise,
          onScrollChanged: onScrollChanged,
        ),
      final SpecificationDetailContent c => SpecificationDetailView(
          content: c,
          onReturnToModule: onReturnToModule,
          onScrollChanged: onScrollChanged,
        ),
      final DocumentDetailContent c => DocumentDetailView(
          content: c,
          onScrollChanged: onScrollChanged,
        ),
      final ExerciseDetailContent c => ExerciseDetailView(
          content: c,
          onOpenInNewDocument: onOpenExerciseInNewDocument ?? (_) {},
        ),
      null => const SizedBox.shrink(),
    };
  }
}

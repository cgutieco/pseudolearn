import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/library/library_cubit.dart';
import '../../application/settings/settings_cubit.dart';
import '../../domain/model/documents/document.dart';
import '../../domain/model/documents/document_title_policy.dart';
import '../../domain/model/knowledge/exercise.dart';
import '../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../domain/model/settings/effective_ui_language.dart';
import '../library/dialogs/new_document_dialog.dart';

DocumentSummary? _findExistingDocument(List<DocumentSummary> docs, String exerciseId) {
  for (final doc in docs) {
    if (doc.exerciseId == exerciseId) return doc;
  }
  return null;
}

void _navigateToDocument(BuildContext context, String documentId, VoidCallback? onClosed) {
  context.push('/biblioteca/documento/$documentId').then((_) {
    if (context.mounted && onClosed != null) {
      onClosed();
    }
  });
}

void _showCreateDialog({
  required BuildContext context,
  required Exercise exercise,
  required LibraryCubit libraryCubit,
  VoidCallback? onClosed,
}) {
  final settingsCubit = context.read<SettingsCubit>();
  final existingTitles = libraryCubit.state.allDocuments.map((d) => d.title);
  final suggestedTitle = suggestNextDocumentTitle(exercise.title, existingTitles);
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  final effectiveLanguage = resolveEffectiveLanguage(
    setting: settingsCubit.state.language,
    systemLanguageCode: systemLocale,
  );
  final defaultProfile = syntaxProfileForLanguage(effectiveLanguage);

  showNewDocumentDialog(
    context: context,
    existingTitles: existingTitles,
    initialTitle: suggestedTitle,
    initialProfile: defaultProfile,
    onConfirm: (title, profileId) {
      libraryCubit
          .createDocument(
            title: title,
            profileId: profileId,
            content: exercise.starterCode ?? '',
            exerciseId: exercise.id,
          )
          .then((doc) {
        if (doc != null && context.mounted) {
          _navigateToDocument(context, doc.id, onClosed);
        }
      });
    },
  );
}

void launchExerciseCreationDialog({
  required BuildContext context,
  required Exercise exercise,
  VoidCallback? onClosed,
}) {
  final libraryCubit = context.read<LibraryCubit>();
  final existingDoc = _findExistingDocument(libraryCubit.state.allDocuments, exercise.id);
  if (existingDoc != null) {
    _navigateToDocument(context, existingDoc.id, onClosed);
    return;
  }

  _showCreateDialog(
    context: context,
    exercise: exercise,
    libraryCubit: libraryCubit,
    onClosed: onClosed,
  );
}

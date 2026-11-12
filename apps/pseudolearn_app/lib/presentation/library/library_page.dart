import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/library/library_cubit.dart';
import '../../application/library/library_state.dart';
import '../../application/exercises/user_exercise_library_cubit.dart';
import '../../application/exercises/user_exercise_library_state.dart';
import '../../domain/model/documents/document.dart';
import '../exercises/user_exercise_editor_page.dart';
import '../exercises/user_exercises_section.dart';
import 'components/library_section_selector.dart';
import 'dialogs/delete_rename_document_dialog.dart';
import 'dialogs/new_document_dialog.dart';
import 'library_view.dart';

final class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

final class _LibraryPageState extends State<LibraryPage> {
  late final TextEditingController _searchController;
  LibrarySection _section = LibrarySection.algorithms;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<LibraryCubit>().loadDocuments();
    context.read<UserExerciseLibraryCubit>().load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNewDoc() {
    final cubit = context.read<LibraryCubit>();
    showNewDocumentDialog(
      context: context,
      existingTitles: cubit.state.allDocuments.map((d) => d.title),
      onConfirm: (title, profileId) {
        cubit.createDocument(title: title, profileId: profileId).then((doc) {
          if (doc != null && mounted) {
            context.push('/biblioteca/documento/${doc.id}').then((_) {
              if (mounted) cubit.loadDocuments();
            });
          }
        });
      },
    );
  }

  void _onNewExercise() => context.push('/biblioteca/ejercicio/$newUserExerciseSegment');

  void _onOpenDoc(DocumentSummary doc) {
    final cubit = context.read<LibraryCubit>();
    context.push('/biblioteca/documento/${doc.id}').then((_) {
      if (mounted) cubit.loadDocuments();
    });
  }

  void _onRenameDoc(DocumentSummary doc) {
    final cubit = context.read<LibraryCubit>();
    showRenameDocumentDialog(
      context: context,
      currentTitle: doc.title,
      existingTitles: cubit.state.allDocuments.map((d) => d.title),
      onConfirm: (newTitle) => cubit.renameDocument(doc.id, newTitle),
    );
  }

  void _onDeleteDoc(DocumentSummary doc) {
    showDeleteDocumentDialog(
      context: context,
      documentTitle: doc.title,
      onConfirm: () => context.read<LibraryCubit>().deleteDocument(doc.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LibraryCubit>();
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) => BlocBuilder<UserExerciseLibraryCubit, UserExerciseLibraryState>(
        builder: (context, exerciseState) => LibraryView(
          state: state,
          searchController: _searchController,
          onSearchChanged: cubit.searchDocuments,
          onNewDocument: _onNewDoc,
          onOpenDocument: _onOpenDoc,
          onRenameDocument: _onRenameDoc,
          onDeleteDocument: _onDeleteDoc,
          section: _section,
          onSectionSelected: (section) => setState(() => _section = section),
          exercises: LibraryExercisesSlot(
            content: UserExercisesSection(onCreate: _onNewExercise),
            count: exerciseState.exercises.length,
            onCreate: _onNewExercise,
          ),
        ),
      ),
    );
  }
}

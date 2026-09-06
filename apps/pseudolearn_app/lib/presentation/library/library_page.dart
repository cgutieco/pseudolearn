import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/library/library_cubit.dart';
import '../../application/library/library_state.dart';
import '../../domain/model/documents/document.dart';
import '../components/button/app_button.dart';
import '../components/button/app_icon_button.dart';
import '../components/field/app_search_field.dart';
import '../components/layout/app_page.dart';
import '../components/sync_banner.dart';
import '../l10n/generated/app_localizations.dart';
import '../shell/design_canvas.dart';
import '../shell/device_class.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/spacing.dart';
import 'components/library_body.dart';
import 'dialogs/delete_rename_document_dialog.dart';
import 'dialogs/new_document_dialog.dart';

final class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

final class _LibraryPageState extends State<LibraryPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<LibraryCubit>().loadDocuments();
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
      builder: (context, state) => LibraryView(
        state: state,
        searchController: _searchController,
        onSearchChanged: cubit.searchDocuments,
        onNewDocument: _onNewDoc,
        onOpenDocument: _onOpenDoc,
        onRenameDocument: _onRenameDoc,
        onDeleteDocument: _onDeleteDoc,
      ),
    );
  }
}

final class LibraryView extends StatelessWidget {
  final LibraryState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onNewDocument;
  final ValueChanged<DocumentSummary> onOpenDocument;
  final ValueChanged<DocumentSummary> onRenameDocument;
  final ValueChanged<DocumentSummary> onDeleteDocument;

  const LibraryView({
    super.key,
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onNewDocument,
    required this.onOpenDocument,
    required this.onRenameDocument,
    required this.onDeleteDocument,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.libraryTitle,
        measure: ContentMeasure.wide,
        action: _NewDocumentAction(onNewDocument: onNewDocument),
        filter: AppSearchField(
          controller: searchController,
          hintText: l10n.librarySearchPlaceholder,
          onChanged: onSearchChanged,
        ),
        body: _LibraryPageBody(
          state: state,
          onNewDocument: onNewDocument,
          onOpenDocument: onOpenDocument,
          onRenameDocument: onRenameDocument,
          onDeleteDocument: onDeleteDocument,
        ),
      ),
    );
  }
}

final class _LibraryPageBody extends StatelessWidget {
  final LibraryState state;
  final VoidCallback onNewDocument;
  final ValueChanged<DocumentSummary> onOpenDocument;
  final ValueChanged<DocumentSummary> onRenameDocument;
  final ValueChanged<DocumentSummary> onDeleteDocument;

  const _LibraryPageBody({
    required this.state,
    required this.onNewDocument,
    required this.onOpenDocument,
    required this.onRenameDocument,
    required this.onDeleteDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SyncBanner(),
        Expanded(
          child: LibraryBody(
            state: state,
            onNewDocument: onNewDocument,
            onOpenDocument: onOpenDocument,
            onRenameDocument: onRenameDocument,
            onDeleteDocument: onDeleteDocument,
          ),
        ),
      ],
    );
  }
}

final class _NewDocumentAction extends StatelessWidget {
  final VoidCallback onNewDocument;

  const _NewDocumentAction({required this.onNewDocument});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    return switch (canvas.deviceClass) {
      DeviceClass.compact => AppIconButton(
          icon: Icons.add,
          semanticLabel: l10n.libraryNewDocument,
          variant: AppButtonVariant.primary,
          onPressed: onNewDocument,
        ),
      DeviceClass.medium || DeviceClass.expanded => AppButton(
          label: l10n.libraryNewDocument,
          icon: Icons.add,
          variant: AppButtonVariant.primary,
          onPressed: onNewDocument,
        ),
    };
  }
}

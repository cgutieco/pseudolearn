import 'package:flutter/material.dart';
import '../../../application/library/library_state.dart';
import '../../../domain/model/documents/document.dart';
import '../../components/empty/app_empty_state.dart';
import '../../components/layout/app_card_grid.dart';
import '../../components/progress/app_skeleton_list.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/grid_metrics.dart';
import 'document_card.dart';
import 'document_context_menu.dart';

final class LibraryBody extends StatelessWidget {
  final LibraryState state;
  final VoidCallback onNewDocument;
  final ValueChanged<DocumentSummary> onOpenDocument;
  final ValueChanged<DocumentSummary> onRenameDocument;
  final ValueChanged<DocumentSummary> onDeleteDocument;

  const LibraryBody({
    super.key,
    required this.state,
    required this.onNewDocument,
    required this.onOpenDocument,
    required this.onRenameDocument,
    required this.onDeleteDocument,
  });

  @override
  Widget build(BuildContext context) {
    if (state.status == LibraryStatus.loading && state.allDocuments.isEmpty) {
      return const AppSkeletonList(itemExtent: GridMetricsTokens.cardExtentDocument);
    }
    if (state.isEmptyLibrary || state.isEmptySearchResults) {
      return _EmptyView(state: state, onNewDocument: onNewDocument);
    }
    return _DocumentListView(
      documents: state.filteredDocuments,
      onOpenDocument: onOpenDocument,
      onRenameDocument: onRenameDocument,
      onDeleteDocument: onDeleteDocument,
    );
  }
}

final class _EmptyView extends StatelessWidget {
  final LibraryState state;
  final VoidCallback onNewDocument;

  const _EmptyView({required this.state, required this.onNewDocument});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (state.isEmptyLibrary) {
      return AppEmptyState(
        icon: Icons.code_rounded,
        title: l10n.libraryEmptyTitle,
        description: l10n.libraryEmptyDescription,
        actionLabel: l10n.libraryNewDocument,
        onAction: onNewDocument,
      );
    }
    return AppEmptyState(
      icon: Icons.search_off_rounded,
      title: l10n.libraryEmptySearchTitle,
      description: l10n.libraryEmptySearchDescription(state.searchQuery),
    );
  }
}

final class _DocumentListView extends StatelessWidget {
  final List<DocumentSummary> documents;
  final ValueChanged<DocumentSummary> onOpenDocument;
  final ValueChanged<DocumentSummary> onRenameDocument;
  final ValueChanged<DocumentSummary> onDeleteDocument;

  const _DocumentListView({
    required this.documents,
    required this.onOpenDocument,
    required this.onRenameDocument,
    required this.onDeleteDocument,
  });

  @override
  Widget build(BuildContext context) {
    return AppCardGrid(
      itemCount: documents.length,
      cardExtent: GridMetricsTokens.cardExtentDocument,
      itemBuilder: (itemContext, index) {
        final doc = documents[index];
        return DocumentCard(
          document: doc,
          onTap: () => onOpenDocument(doc),
          onMenuTap: () => showDocumentContextMenu(
            context: itemContext,
            onRename: () => onRenameDocument(doc),
            onDelete: () => onDeleteDocument(doc),
          ),
        );
      },
    );
  }
}

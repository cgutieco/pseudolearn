import 'package:equatable/equatable.dart';
import '../../domain/model/documents/document.dart';

enum LibraryStatus {
  initial,
  loading,
  success,
  error,
}

final class LibraryState extends Equatable {
  final LibraryStatus status;
  final List<DocumentSummary> allDocuments;
  final List<DocumentSummary> filteredDocuments;
  final String searchQuery;
  final String? errorMessage;

  const LibraryState({
    required this.status,
    required this.allDocuments,
    required this.filteredDocuments,
    required this.searchQuery,
    this.errorMessage,
  });

  const LibraryState.initial()
      : status = LibraryStatus.initial,
        allDocuments = const [],
        filteredDocuments = const [],
        searchQuery = '',
        errorMessage = null;

  bool get isEmptyLibrary => status == LibraryStatus.success && allDocuments.isEmpty;
  bool get isEmptySearchResults =>
      status == LibraryStatus.success && allDocuments.isNotEmpty && filteredDocuments.isEmpty;

  LibraryState copyWith({
    LibraryStatus? status,
    List<DocumentSummary>? allDocuments,
    List<DocumentSummary>? filteredDocuments,
    String? searchQuery,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      allDocuments: allDocuments ?? this.allDocuments,
      filteredDocuments: filteredDocuments ?? this.filteredDocuments,
      searchQuery: searchQuery ?? this.searchQuery,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allDocuments,
        filteredDocuments,
        searchQuery,
        errorMessage,
      ];
}

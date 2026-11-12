import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../domain/model/documents/document_change.dart';

mixin DocumentChangeFollower<S> on Cubit<S> {
  StreamSubscription<DocumentChange>? _documentChanges;

  void followDocumentChanges(
    Stream<DocumentChange> changes,
    void Function(DocumentChange change) onChange,
  ) {
    _documentChanges?.cancel();
    _documentChanges = changes.listen((change) {
      if (!isClosed) onChange(change);
    });
  }

  @override
  Future<void> close() async {
    await _documentChanges?.cancel();
    return super.close();
  }
}

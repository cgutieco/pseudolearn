import 'rust_transport.dart';

final class RustAnalysisHandle {
  final int document;
  final int analysis;

  const RustAnalysisHandle({required this.document, required this.analysis});
}

final class RustAnalysisApi {
  final RustTransport _transport;

  const RustAnalysisApi(this._transport);

  RustAnalysisHandle open({required String source, required String profile}) {
    final created =
        _transport.call('create_analysis', {
              'program': source,
              'profile': profile,
              'strictness': 'strict',
            })
            as Map<String, Object?>;
    return RustAnalysisHandle(
      document: created['document'] as int,
      analysis: created['resource'] as int,
    );
  }

  Map<String, Object?> report(RustAnalysisHandle handle) =>
      _transport.call('analysis', {'resource': handle.analysis})
          as Map<String, Object?>;

  Map<String, Object?> programView(RustAnalysisHandle handle) =>
      _transport.call('program_view', {'resource': handle.document})
          as Map<String, Object?>;

  void release(RustAnalysisHandle handle) {
    _transport.call('release', {'resource': handle.document});
  }
}

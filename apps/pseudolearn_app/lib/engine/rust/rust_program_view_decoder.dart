part of 'rust_program_view.dart';

final class _RustProgramViewDecoder {
  final Map<String, Object?> _json;
  final SourceOffsetIndex _offsets;

  const _RustProgramViewDecoder(this._json, this._offsets);

  RustProgramViewReadResult decode() {
    final failure = _RustProgramViewWireValidator(_json, _offsets).validate();
    if (failure case final RustProgramViewReadFailure value) return value;
    final revision = _json['revision_id'] as String;
    final rawNodes = (_json['nodes'] as List<Object?>)
        .cast<Map<String, Object?>>();
    final ordinals = _ordinalsFor(rawNodes);
    final viewNodes = _RustViewNodeBuilder(ordinals, _offsets).build(rawNodes);
    final staticData = _RustProgramViewStaticBuilder(
      _json,
      rawNodes,
      ordinals,
    ).build();
    return RustProgramViewReadSuccess(
      RustProgramView._(
        revision: revision,
        byIdentifier: viewNodes.byIdentifier,
        identifiers: viewNodes.identifiers,
        units: _unitsFor(_json, ordinals, _offsets),
        members: _membersFor(_json, ordinals),
        superclasses: _superclassesFor(_json),
        staticData: staticData,
      ),
    );
  }
}

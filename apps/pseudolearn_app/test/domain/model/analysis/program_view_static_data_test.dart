import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_node_id.dart';
import 'package:pseudolearn_app/domain/model/analysis/program_view_static_data.dart';

void main() {
  test('keeps static links immutable and source-local', () {
    final realization = ProgramViewRealization(
      classNodeId: const ProgramNodeId(0),
      interfaceNodeId: const ProgramNodeId(1),
      originNodeId: const ProgramNodeId(0),
      targetNodeId: const ProgramNodeId(1),
      origin: ProgramViewRealizationOrigin.explicit,
      status: ProgramViewLinkStatus.valid,
      diagnostics: const [],
    );
    final data = ProgramViewStaticData(
      realizations: [realization],
      constraints: const [],
      variants: const [],
      captures: const [],
      iterations: const [],
      scopes: const [],
    );

    expect(data.realizations.single.classNodeId, const ProgramNodeId(0));
    expect(() => data.realizations.add(realization), throwsUnsupportedError);
  });
}

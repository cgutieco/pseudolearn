import 'program_node_id.dart';
import 'program_view_control_exit.dart';

enum ProgramViewLinkStatus { valid, invalid }

enum ProgramViewRealizationOrigin { explicit, inherited }

enum ProgramViewCaptureMode { value }

final class ProgramViewRealization {
  final ProgramNodeId classNodeId;
  final ProgramNodeId? interfaceNodeId;
  final ProgramNodeId originNodeId;
  final ProgramNodeId? targetNodeId;
  final ProgramViewRealizationOrigin origin;
  final ProgramViewLinkStatus status;
  final List<String> diagnostics;

  ProgramViewRealization({
    required this.classNodeId,
    required this.interfaceNodeId,
    required this.originNodeId,
    required this.targetNodeId,
    required this.origin,
    required this.status,
    required List<String> diagnostics,
  }) : diagnostics = List.unmodifiable(diagnostics);
}

final class ProgramViewConstraint {
  final ProgramNodeId parameterNodeId;
  final ProgramNodeId? interfaceNodeId;
  final ProgramNodeId? targetNodeId;
  final ProgramViewLinkStatus status;
  final List<String> diagnostics;

  ProgramViewConstraint({
    required this.parameterNodeId,
    required this.interfaceNodeId,
    required this.targetNodeId,
    required this.status,
    required List<String> diagnostics,
  }) : diagnostics = List.unmodifiable(diagnostics);
}

final class ProgramViewVariant {
  final ProgramNodeId nodeId;
  final String discriminant;
  final List<ProgramNodeId> payloadNodeIds;
  final List<ProgramNodeId> bindingNodeIds;

  ProgramViewVariant({
    required this.nodeId,
    required this.discriminant,
    required List<ProgramNodeId> payloadNodeIds,
    required List<ProgramNodeId> bindingNodeIds,
  }) : payloadNodeIds = List.unmodifiable(payloadNodeIds),
       bindingNodeIds = List.unmodifiable(bindingNodeIds);
}

final class ProgramViewCapture {
  final ProgramNodeId closureNodeId;
  final ProgramNodeId originNodeId;
  final ProgramNodeId bindingNodeId;
  final ProgramViewCaptureMode mode;

  const ProgramViewCapture({
    required this.closureNodeId,
    required this.originNodeId,
    required this.bindingNodeId,
    required this.mode,
  });
}

final class ProgramViewIteration {
  final ProgramNodeId loopNodeId;
  final ProgramNodeId collectionNodeId;
  final ProgramNodeId bindingsNodeId;
  final ProgramNodeId bodyNodeId;
  final ProgramNodeId scopeOwnerNodeId;

  const ProgramViewIteration({
    required this.loopNodeId,
    required this.collectionNodeId,
    required this.bindingsNodeId,
    required this.bodyNodeId,
    required this.scopeOwnerNodeId,
  });
}

final class ProgramViewScope {
  final ProgramNodeId ownerNodeId;
  final ProgramNodeId bindingsNodeId;
  final ProgramNodeId bodyNodeId;
  final List<ProgramNodeId> bindingNodeIds;

  ProgramViewScope({
    required this.ownerNodeId,
    required this.bindingsNodeId,
    required this.bodyNodeId,
    required List<ProgramNodeId> bindingNodeIds,
  }) : bindingNodeIds = List.unmodifiable(bindingNodeIds);
}

final class ProgramViewStaticData {
  final List<ProgramViewRealization> realizations;
  final List<ProgramViewConstraint> constraints;
  final List<ProgramViewVariant> variants;
  final List<ProgramViewCapture> captures;
  final List<ProgramViewIteration> iterations;
  final List<ProgramViewScope> scopes;
  final List<ProgramViewControlExit> exits;
  final List<ProgramViewCleanupScope> cleanupScopes;

  ProgramViewStaticData({
    required List<ProgramViewRealization> realizations,
    required List<ProgramViewConstraint> constraints,
    required List<ProgramViewVariant> variants,
    required List<ProgramViewCapture> captures,
    required List<ProgramViewIteration> iterations,
    required List<ProgramViewScope> scopes,
    List<ProgramViewControlExit> exits = const [],
    List<ProgramViewCleanupScope> cleanupScopes = const [],
  }) : realizations = List.unmodifiable(realizations),
       constraints = List.unmodifiable(constraints),
       variants = List.unmodifiable(variants),
       captures = List.unmodifiable(captures),
       iterations = List.unmodifiable(iterations),
       scopes = List.unmodifiable(scopes),
       exits = List.unmodifiable(exits),
       cleanupScopes = List.unmodifiable(cleanupScopes);

  static final empty = ProgramViewStaticData(
    realizations: const [],
    constraints: const [],
    variants: const [],
    captures: const [],
    iterations: const [],
    scopes: const [],
  );
}

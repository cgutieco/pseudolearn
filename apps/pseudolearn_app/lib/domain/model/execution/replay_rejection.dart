enum ReplayRejection {
  missingTape('missing_tape'),
  unsupportedSchema('unsupported_schema'),
  identityMismatch('replay_identity_mismatch'),
  divergence('replay_divergence'),
  truncatedTape('replay_truncated_tape'),
  corruptedTape('replay_corrupted_tape'),
  nonReproducible('replay_non_reproducible'),
  engineRefused('engine_refused');

  final String code;

  const ReplayRejection(this.code);
}

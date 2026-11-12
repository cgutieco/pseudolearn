part of 'rust_program_execution.dart';

extension _RustExecutionStart on RustProgramExecution {
  ExecutionStep _startConfigured({
    required String sourceCode,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required ExecutionConfiguration configuration,
    EffectTape? replayTape,
  }) {
    stop();
    _reproduction.begin(replaying: replayTape != null);
    _gate.reset(configuration, replaying: replayTape != null);
    _events.configure(profileId);
    final opened = RustExecutionOpening(_analysis).open(
      sourceCode: sourceCode,
      profileId: profileId,
      languageId: languageId,
    );
    if (opened == null) {
      _rejectUnopened(replayTape);
      return const ExecutionStep.unstarted();
    }
    _opened = opened;
    _tracker = RustFocusTracker(opened.view);
    try {
      _executionId = _execution.start(
        opened.handle,
        replayTape == null ? _gate.hostDocument : null,
        opened.view.revision,
        replay: replayTape,
      );
    } on RustBridgeFailure catch (failure) {
      if (replayTape == null) rethrow;
      _reproduction.reject(failure);
      stop();
      return const ExecutionStep.unstarted();
    }
    return _snapshot();
  }

  void _rejectUnopened(EffectTape? replayTape) {
    if (replayTape == null) return;
    _reproduction.reject(
      const RustBridgeFailure(
        family: 'usage',
        detail: 'Invalid protocol: analysis has errors',
      ),
    );
  }
}

import '../../../domain/model/execution/replay_rejection.dart';
import '../../l10n/generated/app_localizations.dart';

String replayRejectionText(ReplayRejection rejection, AppLocalizations l10n) =>
    switch (rejection) {
      ReplayRejection.identityMismatch => l10n.executionReplayRejectedChanged,
      ReplayRejection.nonReproducible ||
      ReplayRejection.missingTape => l10n.executionReplayRejectedUnfinished,
      ReplayRejection.unsupportedSchema ||
      ReplayRejection.divergence ||
      ReplayRejection.truncatedTape ||
      ReplayRejection.corruptedTape ||
      ReplayRejection.engineRefused => l10n.executionReplayRejectedInvalid,
    };

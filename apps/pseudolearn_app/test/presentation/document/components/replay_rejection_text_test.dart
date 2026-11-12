import 'package:flutter_test/flutter_test.dart';
import 'package:pseudolearn_app/domain/model/execution/replay_rejection.dart';
import 'package:pseudolearn_app/presentation/document/components/replay_rejection_text.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_en.dart';
import 'package:pseudolearn_app/presentation/l10n/generated/app_localizations_es.dart';

final _es = AppLocalizationsEs();
final _en = AppLocalizationsEn();

void main() {
  group('replayRejectionText', () {
    test('a changed program points at the edit', () {
      expect(
        replayRejectionText(ReplayRejection.identityMismatch, _es),
        _es.executionReplayRejectedChanged,
      );
    });

    test('a run that cannot be reproduced says it did not finish cleanly', () {
      for (final rejection in [
        ReplayRejection.nonReproducible,
        ReplayRejection.missingTape,
      ]) {
        expect(
          replayRejectionText(rejection, _es),
          _es.executionReplayRejectedUnfinished,
          reason: '$rejection',
        );
      }
    });

    test('a damaged or incompatible recording is reported as invalid', () {
      for (final rejection in [
        ReplayRejection.unsupportedSchema,
        ReplayRejection.divergence,
        ReplayRejection.truncatedTape,
        ReplayRejection.corruptedTape,
        ReplayRejection.engineRefused,
      ]) {
        expect(
          replayRejectionText(rejection, _es),
          _es.executionReplayRejectedInvalid,
          reason: '$rejection',
        );
      }
    });

    test('every rejection has a non-empty reason in both languages', () {
      for (final rejection in ReplayRejection.values) {
        expect(replayRejectionText(rejection, _es), isNotEmpty);
        expect(replayRejectionText(rejection, _en), isNotEmpty);
        expect(
          replayRejectionText(rejection, _en),
          isNot(replayRejectionText(rejection, _es)),
        );
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';

import 'plate_stage.dart';
import 'trailer_scene.dart';

void main() {
  test('records the trailer run in a theme the stage knows', () {
    expect(plateThemes.keys, contains(trailerTheme));
    expect(trailerPlate, startsWith('trailer-'));
  });

  test('steps long enough to fill the five-second interface tail', () {
    const seconds = 1 + 0.8 + trailerSteps * trailerStepSeconds + 1;
    expect(seconds, greaterThanOrEqualTo(2.5 + 5));
  });

  test('sets up the guided demo on the flowchart before recording', () {
    expect(trailerSetup, hasLength(2));
    expect(trailerFocus().keys, <String>['diagram', 'output']);
  });
}

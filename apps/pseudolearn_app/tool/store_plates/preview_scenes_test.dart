import 'package:flutter_test/flutter_test.dart';

import 'plate_stage.dart';
import 'preview_scenes.dart';

void main() {
  test('names every animated plate once with the preview prefix', () {
    final plates = previewScenes.map((scene) => scene.plate).toList();
    expect(plates.toSet(), hasLength(plates.length));
    expect(plates, everyElement(startsWith('preview-')));
  });

  test('records every scene in a theme the stage knows', () {
    expect(
      previewScenes.map((scene) => scene.theme),
      everyElement(isIn(plateThemes.keys)),
    );
  });

  test('selects scenes by name and keeps all of them without a filter', () {
    String name(PreviewScene scene) => scene.plate;
    expect(selectedByName(previewScenes, '', name), previewScenes);
    expect(
      selectedByName(previewScenes, 'preview-nodo,missing', name)
          .map(name),
      <String>['preview-nodo'],
    );
    expect(selectedByName(previewScenes, 'missing', name), isEmpty);
  });
}

import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'plate_timeline.dart';

const String _contractPath =
    '../../packages/pseudolearn_store_media/tests/contracts/plate-timeline.json';

PlateTimeline _contractTimeline() => const PlateTimeline(
      scene: 'contract',
      language: 'es',
      fps: 30,
      pixelSize: Size(886, 1920),
      frames: <PlateFrame>[
        PlateFrame(
          index: 0,
          file: 'frame_000001.png',
          focus: <PlateFocus>[
            PlateFocus(key: 'tabs', pixelRect: Rect.fromLTWH(0, 96, 886, 88)),
          ],
        ),
        PlateFrame(index: 1, file: 'frame_000001.png', focus: <PlateFocus>[]),
      ],
      events: <PlateEvent>[
        PlateEvent(frame: 0, kind: PlateEventKind.statement),
        PlateEvent(
          frame: 1,
          kind: PlateEventKind.tap,
          point: Offset(443, 1700),
        ),
        PlateEvent(frame: 1, kind: PlateEventKind.completion),
      ],
    );

void main() {
  test('encodes exactly the contract the store media engine parses', () {
    expect(
      _contractTimeline().encode(),
      File(_contractPath).readAsStringSync(),
    );
  });

  test('uses the wire names the store media engine accepts', () {
    expect(
      PlateEventKind.values.map((kind) => kind.wireName),
      <String>['statement', 'diagram-node', 'agent-message', 'completion', 'tap'],
    );
  });

  test('writes a point only for the events that carry one', () {
    const plain = PlateEvent(frame: 3, kind: PlateEventKind.statement);
    const touch = PlateEvent(
      frame: 4,
      kind: PlateEventKind.tap,
      point: Offset(1.5, 2),
    );
    expect(plain.toJson().keys, <String>['frame', 'kind']);
    expect(touch.toJson(), <String, Object>{
      'frame': 4,
      'kind': 'tap',
      'x': 1.5,
      'y': 2.0,
    });
  });

  test('encodes an empty recording as empty lists', () {
    const empty = PlateTimeline(
      scene: 'empty',
      language: 'en',
      fps: 30,
      pixelSize: Size(1, 1),
      frames: <PlateFrame>[],
      events: <PlateEvent>[],
    );
    expect(empty.encode(), contains('"frames": []'));
    expect(empty.encode(), endsWith('}\n'));
  });
}

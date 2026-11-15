import 'dart:convert';
import 'dart:ui';

enum PlateEventKind {
  statement('statement'),
  diagramNode('diagram-node'),
  agentMessage('agent-message'),
  completion('completion'),
  tap('tap');

  final String wireName;

  const PlateEventKind(this.wireName);
}

final class PlateFocus {
  final String key;
  final Rect pixelRect;

  const PlateFocus({required this.key, required this.pixelRect});

  Map<String, Object> toJson() => <String, Object>{
        'key': key,
        'x': pixelRect.left,
        'y': pixelRect.top,
        'width': pixelRect.width,
        'height': pixelRect.height,
      };
}

final class PlateFrame {
  final int index;
  final String file;
  final List<PlateFocus> focus;

  const PlateFrame({
    required this.index,
    required this.file,
    required this.focus,
  });

  Map<String, Object> toJson() => <String, Object>{
        'index': index,
        'file': file,
        'focus': focus.map((entry) => entry.toJson()).toList(),
      };
}

final class PlateEvent {
  final int frame;
  final PlateEventKind kind;
  final Offset? point;

  const PlateEvent({required this.frame, required this.kind, this.point});

  Map<String, Object> toJson() => <String, Object>{
        'frame': frame,
        'kind': kind.wireName,
        if (point case final Offset touch) 'x': touch.dx,
        if (point case final Offset touch) 'y': touch.dy,
      };
}

final class PlateTimeline {
  final String scene;
  final String language;
  final int fps;
  final Size pixelSize;
  final List<PlateFrame> frames;
  final List<PlateEvent> events;

  const PlateTimeline({
    required this.scene,
    required this.language,
    required this.fps,
    required this.pixelSize,
    required this.frames,
    required this.events,
  });

  String encode() {
    const encoder = JsonEncoder.withIndent('  ');
    return '${encoder.convert(<String, Object>{
          'scene': scene,
          'language': language,
          'fps': fps,
          'pixelWidth': pixelSize.width.round(),
          'pixelHeight': pixelSize.height.round(),
          'frames': frames.map((frame) => frame.toJson()).toList(),
          'events': events.map((event) => event.toJson()).toList(),
        })}\n';
  }
}

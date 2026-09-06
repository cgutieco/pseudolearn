import '../analysis/app_diagnostic.dart';
import '../analysis/highlight_span.dart';
import '../diagram/diagram_notation.dart';
import '../diagram/diagram_scene.dart';
import 'content_marker.dart';
import 'list_equality.dart';

sealed class ContentBlock {
  const ContentBlock();
}

final class HeadingBlock extends ContentBlock {
  final int level;
  final String text;

  const HeadingBlock({
    required this.level,
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HeadingBlock &&
          runtimeType == other.runtimeType &&
          level == other.level &&
          text == other.text;

  @override
  int get hashCode => Object.hash(level, text);
}

final class ParagraphBlock extends ContentBlock {
  final String text;

  const ParagraphBlock({required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParagraphBlock &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

final class ListBlock extends ContentBlock {
  final List<String> items;
  final bool isOrdered;

  const ListBlock({
    required this.items,
    this.isOrdered = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListBlock &&
          runtimeType == other.runtimeType &&
          isOrdered == other.isOrdered &&
          listEquals(items, other.items);

  @override
  int get hashCode => Object.hash(isOrdered, Object.hashAll(items));
}

final class CodeBlock extends ContentBlock {
  final String code;
  final String language;
  final List<HighlightSpan> highlightSpans;
  final String? title;

  const CodeBlock({
    required this.code,
    this.language = 'pseudo',
    this.highlightSpans = const [],
    this.title,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CodeBlock &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          language == other.language &&
          title == other.title;

  @override
  int get hashCode => Object.hash(code, language, title);
}

final class QuoteBlock extends ContentBlock {
  final String text;

  const QuoteBlock({required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuoteBlock &&
          runtimeType == other.runtimeType &&
          text == other.text;

  @override
  int get hashCode => text.hashCode;
}

final class DiagramBlock extends ContentBlock {
  final String code;
  final DiagramNotation notation;
  final DiagramScene scene;
  final String? title;

  const DiagramBlock({
    required this.code,
    required this.notation,
    this.scene = const DiagramScene.empty(),
    this.title,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagramBlock &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          notation == other.notation &&
          title == other.title;

  @override
  int get hashCode => Object.hash(code, notation, title);
}

final class FigureBlock extends ContentBlock {
  final String illustrationId;
  final String caption;

  const FigureBlock({
    required this.illustrationId,
    required this.caption,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FigureBlock &&
          runtimeType == other.runtimeType &&
          illustrationId == other.illustrationId &&
          caption == other.caption;

  @override
  int get hashCode => Object.hash(illustrationId, caption);
}

final class MarkerBlock extends ContentBlock {
  final ContentMarker marker;
  final String resolvedText;

  const MarkerBlock({
    required this.marker,
    required this.resolvedText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarkerBlock &&
          runtimeType == other.runtimeType &&
          marker == other.marker &&
          resolvedText == other.resolvedText;

  @override
  int get hashCode => Object.hash(marker, resolvedText);
}

final class TableBlock extends ContentBlock {
  final List<String> headers;
  final List<List<String>> rows;

  const TableBlock({
    required this.headers,
    required this.rows,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TableBlock &&
          runtimeType == other.runtimeType &&
          listEquals(headers, other.headers) &&
          _rowsEqual(rows, other.rows);

  @override
  int get hashCode => Object.hash(
        Object.hashAll(headers),
        Object.hashAll(rows.map(Object.hashAll)),
      );

  static bool _rowsEqual(List<List<String>> a, List<List<String>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!listEquals(a[i], b[i])) return false;
    }
    return true;
  }
}

final class DiagnosticBlock extends ContentBlock {
  final String code;
  final String message;
  final AppSeverity severity;

  const DiagnosticBlock({
    required this.code,
    required this.message,
    required this.severity,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiagnosticBlock &&
          runtimeType == other.runtimeType &&
          code == other.code &&
          message == other.message &&
          severity == other.severity;

  @override
  int get hashCode => Object.hash(code, message, severity);
}


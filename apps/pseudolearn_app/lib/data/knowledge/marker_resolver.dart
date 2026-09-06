import '../../domain/model/knowledge/content_block.dart';
import '../../domain/model/knowledge/content_load_failure.dart';
import '../../domain/model/knowledge/content_load_result.dart';
import '../../domain/model/knowledge/content_marker.dart';
import '../../domain/model/knowledge/content_marker_kind.dart';
import '../../domain/model/knowledge/marker_resolution.dart';
import '../../domain/model/profiles/syntax_profile_id.dart';
import '../../domain/model/settings/ui_language_id.dart';
import '../../domain/ports/syntax_reference_source.dart';
import 'content_assets.dart';
import 'content_marker_blocks.dart';
import 'content_marker_scanner.dart';
import 'marker_occurrence.dart';

final class MarkerResolver {
  final SyntaxReferenceSource _reference;
  final ContentMarkerScanner _scanner;

  const MarkerResolver({
    required SyntaxReferenceSource reference,
    ContentMarkerScanner scanner = const ContentMarkerScanner(),
  })  : _reference = reference,
        _scanner = scanner;

  List<ContentMarker> markersIn(List<ContentBlock> blocks) {
    final markers = <ContentMarker>[];
    for (final block in blocks) {
      for (final occurrence in _scanner.scan(_textOf(block))) {
        final marker = occurrence.marker;
        if (marker != null) markers.add(marker);
      }
    }
    return markers;
  }

  String _textOf(ContentBlock block) => switch (block) {
        HeadingBlock(:final text) => text,
        ParagraphBlock(:final text) => text,
        QuoteBlock(:final text) => text,
        ListBlock(:final items) => items.join('\n'),
        _ => '',
      };

  ContentLoadResult<List<ContentBlock>> resolveAll({
    required List<ContentBlock> blocks,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required ContentAssets assets,
  }) {
    final resolved = <ContentBlock>[];
    for (final block in blocks) {
      final outcome = _resolveBlock(
        block: block,
        profileId: profileId,
        languageId: languageId,
        assets: assets,
      );
      if (outcome is ContentLoadFailed<ContentBlock>) {
        return ContentLoadFailed(
          failure: outcome.failure,
          detail: outcome.detail,
        );
      }
      resolved.add((outcome as ContentLoaded<ContentBlock>).value);
    }
    return ContentLoaded(resolved);
  }

  ContentLoadResult<ContentBlock> _resolveBlock({
    required ContentBlock block,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required ContentAssets assets,
  }) {
    final standalone = _standaloneMarkerOf(block);
    if (standalone != null) {
      return _blockForMarker(
        marker: standalone,
        profileId: profileId,
        languageId: languageId,
        assets: assets,
      );
    }
    return _substituteInline(
      block: block,
      profileId: profileId,
      languageId: languageId,
    );
  }

  ContentMarker? _standaloneMarkerOf(ContentBlock block) {
    if (block is! ParagraphBlock) return null;
    final occurrences = _scanner.scan(block.text);
    if (occurrences.length != 1) return null;
    if (occurrences.first.raw != block.text.trim()) return null;
    return occurrences.first.marker;
  }

  ContentLoadResult<ContentBlock> _blockForMarker({
    required ContentMarker marker,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required ContentAssets assets,
  }) {
    final fromContent = contentMarkerBlock(marker, assets);
    if (fromContent != null) return fromContent;
    if (_isContentMarker(marker.kind)) return _unresolved(marker.text);
    final resolution = _reference.resolveMarker(
      marker: marker,
      profileId: profileId,
      languageId: languageId,
    );
    return switch (resolution) {
      ResolvedMarkerText(:final text) =>
        ContentLoaded(MarkerBlock(marker: marker, resolvedText: text)),
      ResolvedMarkerTable(:final headers, :final rows) =>
        ContentLoaded(TableBlock(headers: headers, rows: rows)),
      ResolvedMarkerDiagnostic(:final code, :final message, :final severity) =>
        ContentLoaded(
          DiagnosticBlock(
            code: code,
            message: message,
            severity: severity,
          ),
        ),
      null => _unresolved(marker.text),
    };
  }

  bool _isContentMarker(ContentMarkerKind kind) {
    return kind == ContentMarkerKind.example ||
        kind == ContentMarkerKind.figure ||
        kind == ContentMarkerKind.diagram;
  }

  ContentLoadResult<ContentBlock> _substituteInline({
    required ContentBlock block,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
  }) {
    return switch (block) {
      HeadingBlock(:final level, :final text) => _rebuildText(
          text: text,
          profileId: profileId,
          languageId: languageId,
          rebuild: (replaced) => HeadingBlock(level: level, text: replaced),
        ),
      ParagraphBlock(:final text) => _rebuildText(
          text: text,
          profileId: profileId,
          languageId: languageId,
          rebuild: (replaced) => ParagraphBlock(text: replaced),
        ),
      QuoteBlock(:final text) => _rebuildText(
          text: text,
          profileId: profileId,
          languageId: languageId,
          rebuild: (replaced) => QuoteBlock(text: replaced),
        ),
      ListBlock() => _rebuildList(block, profileId, languageId),
      _ => ContentLoaded(block),
    };
  }

  ContentLoadResult<ContentBlock> _rebuildText({
    required String text,
    required SyntaxProfileId profileId,
    required UiLanguageId languageId,
    required ContentBlock Function(String) rebuild,
  }) {
    final replacement = _replace(text, profileId, languageId);
    final replaced = replacement.text;
    if (replaced == null) return _unresolved(replacement.unresolvedRaw);
    return ContentLoaded(rebuild(replaced));
  }

  ContentLoadResult<ContentBlock> _rebuildList(
    ListBlock block,
    SyntaxProfileId profileId,
    UiLanguageId languageId,
  ) {
    final items = <String>[];
    for (final item in block.items) {
      final replacement = _replace(item, profileId, languageId);
      final replaced = replacement.text;
      if (replaced == null) return _unresolved(replacement.unresolvedRaw);
      items.add(replaced);
    }
    return ContentLoaded(ListBlock(items: items, isOrdered: block.isOrdered));
  }

  _TextReplacement _replace(
    String text,
    SyntaxProfileId profileId,
    UiLanguageId languageId,
  ) {
    final occurrences = _scanner.scan(text);
    if (occurrences.isEmpty) return _TextReplacement.done(text);
    final buffer = StringBuffer();
    var cursor = 0;
    for (final occurrence in occurrences) {
      final inline = _inlineTextOf(occurrence, profileId, languageId);
      if (inline == null) return _TextReplacement.stuckOn(occurrence.raw);
      buffer.write(text.substring(cursor, occurrence.start));
      buffer.write(inline);
      cursor = occurrence.end;
    }
    buffer.write(text.substring(cursor));
    return _TextReplacement.done(buffer.toString());
  }

  String? _inlineTextOf(
    MarkerOccurrence occurrence,
    SyntaxProfileId profileId,
    UiLanguageId languageId,
  ) {
    final marker = occurrence.marker;
    if (marker == null) return null;
    final resolution = _reference.resolveMarker(
      marker: marker,
      profileId: profileId,
      languageId: languageId,
    );
    if (resolution is ResolvedMarkerText) return resolution.text;
    return null;
  }

  ContentLoadResult<ContentBlock> _unresolved(String? detail) {
    return ContentLoadFailed(
      failure: ContentLoadFailure.unresolvedMarker,
      detail: detail ?? '',
    );
  }
}

final class _TextReplacement {
  final String? text;
  final String? unresolvedRaw;

  const _TextReplacement.done(this.text) : unresolvedRaw = null;

  const _TextReplacement.stuckOn(this.unresolvedRaw) : text = null;
}

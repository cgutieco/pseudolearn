import 'package:markdown/markdown.dart' as md;
import '../../../domain/model/agent/reply_block.dart';
import '../../../domain/model/agent/reply_run.dart';
import 'markdown_inline_converter.dart';

const Map<String, ReplyCellAlignment> _alignments = {
  'left': ReplyCellAlignment.start,
  'center': ReplyCellAlignment.center,
  'right': ReplyCellAlignment.end,
};

ReplyTable tableOf(md.Element table) {
  final rows = _rowsOf(table);
  final header = rows.isEmpty ? const <md.Element>[] : _cellsOf(rows.first);
  return ReplyTable(
    alignments: [for (final cell in header) _alignments[cell.attributes['align']] ?? ReplyCellAlignment.start],
    header: [for (final cell in header) _runsOf(cell)],
    rows: [
      for (final row in rows.skip(1)) [for (final cell in _cellsOf(row)) _runsOf(cell)],
    ],
  );
}

List<md.Element> _rowsOf(md.Element table) => [
  for (final section in _elements(table))
    ...(section.tag == 'tr' ? [section] : _elements(section).where((row) => row.tag == 'tr')),
];

List<md.Element> _cellsOf(md.Element row) =>
    _elements(row).where((cell) => cell.tag == 'th' || cell.tag == 'td').toList();

List<md.Element> _elements(md.Element parent) =>
    (parent.children ?? const <md.Node>[]).whereType<md.Element>().toList();

List<ReplyRun> _runsOf(md.Element cell) => inlineRuns(cell.children ?? const []);

import 'package:flutter/material.dart';
import '../../domain/model/reference/reference_block.dart';
import '../../domain/model/reference/reference_edition.dart';
import '../../domain/model/reference/reference_section.dart';
import '../theme/tokens/spacing.dart';
import 'blocks/reference_block_view.dart';
import 'reference_contents.dart';
import 'reference_section_header.dart';

const double referenceWideLayout = 1080;
const double referenceReadingWidth = 720;
const double referenceContentsWidth = 280;

final class ReferenceReader extends StatefulWidget {
  final ReferenceSection section;
  final ReferenceEdition edition;
  final String? anchor;
  final ValueChanged<String> onOpenSection;
  final Widget? footer;

  const ReferenceReader({
    super.key,
    required this.section,
    required this.edition,
    required this.anchor,
    required this.onOpenSection,
    this.footer,
  });

  @override
  State<ReferenceReader> createState() => _ReferenceReaderState();
}

final class _ReferenceReaderState extends State<ReferenceReader> {
  final Map<String, GlobalKey> _headingKeys = {};

  @override
  void initState() {
    super.initState();
    final anchor = widget.anchor;
    if (anchor != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _jumpTo(anchor));
    }
  }

  GlobalKey _keyFor(String id) => _headingKeys.putIfAbsent(id, GlobalKey.new);

  void _jumpTo(String headingId) {
    final target = _headingKeys[headingId]?.currentContext;
    if (target != null) Scrollable.ensureVisible(target, alignment: 0.05);
  }

  @override
  Widget build(BuildContext context) {
    final contents = ReferenceContents(
      headings: widget.section.headings,
      onSelect: _jumpTo,
    );
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth >= referenceWideLayout
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: referenceContentsWidth,
                  child: SingleChildScrollView(child: contents),
                ),
                Expanded(child: _ReaderScroll(state: this)),
              ],
            )
          : Stack(
              children: [
                _ReaderScroll(state: this),
                ReferenceContentsButton(contents: contents),
              ],
            ),
    );
  }
}

final class _ReaderScroll extends StatelessWidget {
  final _ReferenceReaderState state;

  const _ReaderScroll({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SpacingTokens.space4,
        SpacingTokens.space2,
        SpacingTokens.space4,
        SpacingTokens.space16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: referenceReadingWidth),
          child: _ReaderColumn(state: state),
        ),
      ),
    );
  }
}

final class _ReaderColumn extends StatelessWidget {
  final _ReferenceReaderState state;

  const _ReaderColumn({required this.state});

  @override
  Widget build(BuildContext context) {
    final widget = state.widget;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ReferenceSectionHeader(
          section: widget.section,
          onOpenSection: widget.onOpenSection,
        ),
        for (final block in widget.section.blocks)
          Padding(
            key: block is ReferenceHeading ? state._keyFor(block.id) : null,
            padding: const EdgeInsets.only(bottom: referenceBlockGap),
            child: ReferenceBlockView(
              block: block,
              edition: widget.edition,
              onOpenSection: widget.onOpenSection,
            ),
          ),
        ?widget.footer,
      ],
    );
  }
}

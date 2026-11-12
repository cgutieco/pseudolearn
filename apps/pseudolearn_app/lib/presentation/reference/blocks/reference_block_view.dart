import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../../domain/model/reference/reference_edition.dart';
import '../reference_runs_text.dart';
import 'reference_anatomy_view.dart';
import 'reference_callout_view.dart';
import 'reference_figure_view.dart';
import 'reference_form_view.dart';
import 'reference_heading_view.dart';
import 'reference_list_view.dart';
import 'reference_listing_view.dart';
import 'reference_program_view.dart';
import 'reference_summary_view.dart';
import 'reference_table_view.dart';

const double referenceBlockGap = 14;

final class ReferenceBlockView extends StatelessWidget {
  final ReferenceBlock block;
  final ReferenceEdition edition;
  final ValueChanged<String> onOpenSection;

  const ReferenceBlockView({
    super.key,
    required this.block,
    required this.edition,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final block = this.block;
    final open = onOpenSection;
    return switch (block) {
      ReferenceHeading() => ReferenceHeadingView(
        heading: block,
        onOpenSection: open,
      ),
      ReferenceParagraph(:final runs) => ReferenceRunsText(
        runs: runs,
        onOpenSection: open,
      ),
      ReferenceList() => ReferenceListView(list: block, onOpenSection: open),
      ReferenceTable() => ReferenceTableView(table: block, onOpenSection: open),
      ReferenceFormBlock(:final lines) => ReferenceFormView(lines: lines),
      ReferenceAnatomy(:final parts) => ReferenceAnatomyView(
        parts: parts,
        onOpenSection: open,
      ),
      _ => ReferenceRichBlockView(
        block: block,
        edition: edition,
        onOpenSection: open,
      ),
    };
  }
}

final class ReferenceRichBlockView extends StatelessWidget {
  final ReferenceBlock block;
  final ReferenceEdition edition;
  final ValueChanged<String> onOpenSection;

  const ReferenceRichBlockView({
    super.key,
    required this.block,
    required this.edition,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final block = this.block;
    final open = onOpenSection;
    return switch (block) {
      ReferenceProgramBlock(:final program) => ReferenceProgramView(
        program: program,
        edition: edition,
      ),
      ReferenceFigureBlock(:final figure) => ReferenceFigureView(
        figure: figure,
        onOpenSection: open,
      ),
      ReferenceCallout() => ReferenceCalloutView(
        callout: block,
        edition: edition,
        onOpenSection: open,
      ),
      ReferenceSummary(:final points) => ReferenceSummaryView(
        points: points,
        onOpenSection: open,
      ),
      ReferenceSeeAlso(:final links) => ReferenceSeeAlsoView(
        links: links,
        onOpenSection: open,
      ),
      ReferenceListing() => ReferenceListingView(listing: block),
      _ => const SizedBox.shrink(),
    };
  }
}

final class ReferenceBlockColumn extends StatelessWidget {
  final List<ReferenceBlock> blocks;
  final ReferenceEdition edition;
  final ValueChanged<String> onOpenSection;

  const ReferenceBlockColumn({
    super.key,
    required this.blocks,
    required this.edition,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final block in blocks)
          Padding(
            padding: const EdgeInsets.only(bottom: referenceBlockGap),
            child: ReferenceBlockView(
              block: block,
              edition: edition,
              onOpenSection: onOpenSection,
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../application/reference/reference_section_cubit.dart';
import '../../application/reference/reference_section_state.dart';
import '../components/empty/app_empty_state.dart';
import '../components/progress/app_skeleton_list.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_theme.dart';
import 'reference_edition_resolver.dart';
import 'reference_reader.dart';

final class ReferenceSectionPage extends StatefulWidget {
  final String sectionId;
  final String? anchor;

  const ReferenceSectionPage({super.key, required this.sectionId, this.anchor});

  @override
  State<ReferenceSectionPage> createState() => _ReferenceSectionPageState();
}

final class _ReferenceSectionPageState extends State<ReferenceSectionPage> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ReferenceSectionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sectionId != widget.sectionId) _load();
  }

  void _load() => context.read<ReferenceSectionCubit>().load(
    currentReferenceEdition(context),
    widget.sectionId,
  );

  void _openSection(String sectionId) =>
      context.push('/conocimiento/especificacion/$sectionId');

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      appBar: AppBar(backgroundColor: theme.colors.surfaces.canvas),
      body: BlocBuilder<ReferenceSectionCubit, ReferenceSectionState>(
        builder: (context, state) => ReferenceSectionBody(
          state: state,
          sectionId: widget.sectionId,
          anchor: widget.anchor,
          onOpenSection: _openSection,
        ),
      ),
    );
  }
}

final class ReferenceSectionBody extends StatelessWidget {
  final ReferenceSectionState state;
  final String sectionId;
  final String? anchor;
  final ValueChanged<String> onOpenSection;

  const ReferenceSectionBody({
    super.key,
    required this.state,
    required this.sectionId,
    required this.anchor,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final section = state.sectionOf(sectionId);
    final edition = state.edition;
    if (section != null && edition != null) {
      return ReferenceReader(
        section: section,
        edition: edition,
        anchor: anchor,
        onOpenSection: onOpenSection,
      );
    }
    if (state.statusOf(sectionId) == ReferenceSectionStatus.notFound) {
      final l10n = AppLocalizations.of(context)!;
      return AppEmptyState(
        icon: Icons.menu_book_outlined,
        title: l10n.referenceNotFoundTitle,
        description: l10n.referenceNotFoundDescription,
      );
    }
    return const AppSkeletonList(itemExtent: 96);
  }
}

import 'package:flutter/material.dart';
import '../../../../domain/model/knowledge/content_block.dart';
import '../../../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../../../domain/model/knowledge/knowledge_entry.dart';
import '../../../../domain/model/knowledge/module_part.dart';
import '../../../../domain/model/knowledge/module_section.dart';
import '../../../../domain/model/knowledge/prediction_activity.dart';
import '../../../components/typography/app_text.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/app_theme.dart';
import '../../../theme/tokens/motion.dart';
import '../../../theme/tokens/radii.dart';
import '../../../theme/tokens/spacing.dart';
import 'content_block_view.dart';
import 'document_headings_nav.dart';
import 'module_section_cards.dart';
import 'prediction_activity_view.dart';

final class ModuleDetailView extends StatefulWidget {
  final ModuleDetailContent content;
  final void Function(String entryId, {String? anchor}) onOpenSpecification;
  final ValueChanged<String>? onOpenExercise;
  final ValueChanged<double>? onScrollChanged;

  const ModuleDetailView({
    super.key,
    required this.content,
    required this.onOpenSpecification,
    this.onOpenExercise,
    this.onScrollChanged,
  });

  @override
  State<ModuleDetailView> createState() => _ModuleDetailViewState();
}

final class _ModuleDetailViewState extends State<ModuleDetailView> {
  late final ScrollController _scrollController;
  final Map<int, GlobalKey> _sectionKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset: widget.content.scrollOffset,
    );
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (widget.onScrollChanged != null && _scrollController.hasClients) {
      widget.onScrollChanged!(_scrollController.offset);
    }
  }

  void _scrollToSection(int index) {
    final key = _sectionKeys[index];
    final context = key?.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: MotionTokens.motionScreen,
        curve: MotionTokens.easeStandard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sections = widget.content.module.sections;

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DocumentHeadingsNav(
            headings: widget.content.headings,
            onSelectHeading: _scrollToSection,
          ),
          for (var i = 0; i < sections.length; i++)
            _ModuleSectionItem(
              key: _sectionKeys.putIfAbsent(i, () => GlobalKey()),
              section: sections[i],
              index: i + 1,
              l10n: l10n,
              specEntries: widget.content.specificationEntries,
              exerciseEntries: widget.content.exerciseEntries,
              predictionActivity: widget.content.module.predictionActivity,
              onOpenSpecification: widget.onOpenSpecification,
              onOpenExercise: widget.onOpenExercise,
            ),
        ],
      ),
    );
  }
}

final class _ModuleSectionItem extends StatelessWidget {
  final ModuleSection section;
  final int index;
  final AppLocalizations l10n;
  final List<KnowledgeEntry> specEntries;
  final List<KnowledgeEntry> exerciseEntries;
  final PredictionActivity? predictionActivity;
  final void Function(String entryId, {String? anchor}) onOpenSpecification;
  final ValueChanged<String>? onOpenExercise;

  const _ModuleSectionItem({
    super.key,
    required this.section,
    required this.index,
    required this.l10n,
    required this.specEntries,
    required this.exerciseEntries,
    this.predictionActivity,
    required this.onOpenSpecification,
    this.onOpenExercise,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final title = _partTitle(section.part, l10n);

    return Padding(
      padding: const EdgeInsets.only(bottom: SpacingTokens.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PartHeader(index: index, title: title, theme: theme),
          const SizedBox(height: SpacingTokens.space3),
          for (final block in section.blocks)
            if (_shouldRenderBlock(block, section.part))
              ContentBlockView(block: block),
          if (section.part == ModulePart.prediction && predictionActivity != null)
            PredictionActivityView(activity: predictionActivity!),
          if (section.part == ModulePart.specificationAnchors && specEntries.isNotEmpty)
            SpecAnchorList(entries: specEntries, onOpen: onOpenSpecification),
          if (section.part == ModulePart.exercises && exerciseEntries.isNotEmpty)
            ExerciseList(entries: exerciseEntries, onOpen: onOpenExercise),
        ],
      ),
    );
  }

  bool _shouldRenderBlock(ContentBlock block, ModulePart part) {
    if (block is! ListBlock) return true;
    return switch (part) {
      ModulePart.specificationAnchors ||
      ModulePart.exercises ||
      ModulePart.prediction =>
        false,
      _ => true,
    };
  }
}

final class _PartHeader extends StatelessWidget {
  final int index;
  final String title;
  final AppThemeExtension theme;

  const _PartHeader({
    required this.index,
    required this.title,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.space2,
            vertical: SpacingTokens.space1,
          ),
          decoration: BoxDecoration(
            color: theme.colors.surfaces.brandSubtle,
            borderRadius: BorderRadius.circular(RadiusTokens.radiusSm),
          ),
          child: AppText(
            '$index',
            variant: AppTextVariant.caption,
            color: theme.colors.actions.primary.bgDefault,
          ),
        ),
        const SizedBox(width: SpacingTokens.space2),
        Expanded(
          child: AppText(
            title,
            variant: AppTextVariant.heading2,
            color: theme.colors.text.primary,
          ),
        ),
      ],
    );
  }
}

String _partTitle(ModulePart part, AppLocalizations l10n) => switch (part) {
      ModulePart.question => l10n.knowledgeModulePartQuestion,
      ModulePart.machineModel => l10n.knowledgeModulePartMachineModel,
      ModulePart.development => l10n.knowledgeModulePartDevelopment,
      ModulePart.prediction => l10n.knowledgeModulePartPrediction,
      ModulePart.commonErrors => l10n.knowledgeModulePartCommonErrors,
      ModulePart.specificationAnchors => l10n.knowledgeModulePartSpecification,
      ModulePart.exercises => l10n.knowledgeModulePartExercises,
    };

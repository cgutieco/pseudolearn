import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/route/route_bank_cubit.dart';
import '../../../application/route/route_bank_state.dart';
import '../../../application/route/route_index_cubit.dart';
import '../../../application/route/route_index_state.dart';
import '../../../domain/model/route/route_toc.dart';
import '../../reference/reference_index_section.dart';
import '../../route/route_bank_view.dart';
import '../../route/route_index_view.dart';
import '../../theme/tokens/spacing.dart';
import 'knowledge_section_selector.dart';

final class KnowledgeBody extends StatelessWidget {
  final KnowledgeSectionKind activeSection;
  final ValueChanged<KnowledgeSectionKind> onSectionSelected;
  final ValueChanged<String> onOpenLesson;
  final ValueChanged<RouteExerciseEntry> onOpenExercise;
  final VoidCallback onRetry;

  const KnowledgeBody({
    super.key,
    required this.activeSection,
    required this.onSectionSelected,
    required this.onOpenLesson,
    required this.onOpenExercise,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KnowledgeSectionSelector(
          activeSection: activeSection,
          onSectionSelected: onSectionSelected,
        ),
        const SizedBox(height: SpacingTokens.space4),
        Expanded(
          child: KnowledgeSectionContent(
            activeSection: activeSection,
            onOpenLesson: onOpenLesson,
            onOpenExercise: onOpenExercise,
            onRetry: onRetry,
          ),
        ),
      ],
    );
  }
}

final class KnowledgeSectionContent extends StatelessWidget {
  final KnowledgeSectionKind activeSection;
  final ValueChanged<String> onOpenLesson;
  final ValueChanged<RouteExerciseEntry> onOpenExercise;
  final VoidCallback onRetry;

  const KnowledgeSectionContent({
    super.key,
    required this.activeSection,
    required this.onOpenLesson,
    required this.onOpenExercise,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (activeSection) {
      KnowledgeSectionKind.route => BlocBuilder<RouteIndexCubit, RouteIndexState>(
        builder: (context, state) =>
            RouteIndexView(state: state, onOpenLesson: onOpenLesson, onRetry: onRetry),
      ),
      KnowledgeSectionKind.specification => const ReferenceIndexSection(),
      KnowledgeSectionKind.exercises => BlocBuilder<RouteBankCubit, RouteBankState>(
        builder: (context, state) => RouteBankView(
          state: state,
          onFilter: context.read<RouteBankCubit>().filter,
          onOpenExercise: onOpenExercise,
        ),
      ),
    };
  }
}

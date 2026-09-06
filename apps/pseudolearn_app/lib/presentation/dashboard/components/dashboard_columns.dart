import 'package:flutter/widgets.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/grid_metrics.dart';
import 'activity_card.dart';
import 'concepts_card.dart';
import 'creations_card.dart';
import 'exercises_card.dart';
import 'learning_route_card.dart';
import 'library_card.dart';
import 'next_step_card.dart';
import 'specification_card.dart';
import 'sync_card.dart';

final class DashboardPrimaryColumn extends StatelessWidget {
  final DashboardState state;
  final ValueChanged<String> onOpenModule;

  const DashboardPrimaryColumn({
    super.key,
    required this.state,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final gap = DesignCanvasScope.of(context).scaled(GridMetricsTokens.cardGap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LibraryCard(metrics: state.library),
        SizedBox(height: gap),
        LearningRouteCard(tracks: state.route),
        SizedBox(height: gap),
        NextStepCard(nextModule: state.nextModule, onOpenModule: onOpenModule),
        SizedBox(height: gap),
        ExercisesCard(coverage: state.exercises),
      ],
    );
  }
}

final class DashboardSecondaryColumn extends StatelessWidget {
  final DashboardState state;
  final DateTime? lastSyncAt;

  const DashboardSecondaryColumn({
    super.key,
    required this.state,
    required this.lastSyncAt,
  });

  @override
  Widget build(BuildContext context) {
    final gap = DesignCanvasScope.of(context).scaled(GridMetricsTokens.cardGap);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ConceptsCard(coverage: state.concepts),
        SizedBox(height: gap),
        SpecificationCard(coverage: state.specification),
        SizedBox(height: gap),
        ActivityCard(timeline: state.activity),
        SizedBox(height: gap),
        CreationsCard(timeline: state.activity),
        SizedBox(height: gap),
        SyncCard(health: state.sync, lastSyncAt: lastSyncAt),
      ],
    );
  }
}

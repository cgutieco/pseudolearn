import 'package:flutter/widgets.dart';
import '../../../application/dashboard/dashboard_state.dart';
import '../../shell/design_canvas.dart';
import '../../theme/tokens/grid_metrics.dart';
import 'activity_card.dart';
import 'concepts_card.dart';
import 'exercises_card.dart';
import 'library_card.dart';
import 'next_step_card.dart';
import 'overview_card.dart';
import 'route_map_card.dart';
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
        OverviewCard(state: state),
        SizedBox(height: gap),
        NextStepCard(nextLesson: state.nextLesson, onOpenModule: onOpenModule),
        SizedBox(height: gap),
        RouteMapCard(parts: state.route, onOpenModule: onOpenModule),
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
        ActivityCard(timeline: state.activity),
        SizedBox(height: gap),
        LibraryCard(metrics: state.library),
        SizedBox(height: gap),
        ConceptsCard(coverage: state.concepts),
        SizedBox(height: gap),
        SpecificationCard(coverage: state.specification),
        SizedBox(height: gap),
        SyncCard(health: state.sync, lastSyncAt: lastSyncAt),
      ],
    );
  }
}

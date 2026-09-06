import 'package:flutter/material.dart';
import '../../application/dashboard/dashboard_state.dart';
import '../components/empty/app_empty_state.dart';
import '../components/layout/app_page.dart';
import '../components/progress/app_skeleton_list.dart';
import '../l10n/generated/app_localizations.dart';
import '../shell/design_canvas.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/component_metrics.dart';
import '../theme/tokens/spacing.dart';
import 'components/dashboard_columns.dart';
import 'components/dashboard_sections_layout.dart';

final class DashboardView extends StatelessWidget {
  final DashboardState state;
  final DateTime? lastSyncAt;
  final ValueChanged<String> onOpenModule;

  const DashboardView({
    super.key,
    required this.state,
    required this.lastSyncAt,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.dashboardTitle,
        measure: ContentMeasure.wide,
        body: _DashboardBody(view: this),
      ),
    );
  }
}

final class _DashboardBody extends StatelessWidget {
  final DashboardView view;

  const _DashboardBody({required this.view});

  @override
  Widget build(BuildContext context) {
    final state = view.state;

    return switch (state.status) {
      DashboardStatus.initial || DashboardStatus.loading => const AppSkeletonList(
          itemExtent: ComponentMetricsTokens.dashboardCardExtent,
        ),
      DashboardStatus.error => _DashboardError(message: state.errorMessage),
      DashboardStatus.success when state.hasNothingRecorded =>
        const _DashboardEmpty(),
      DashboardStatus.success => _DashboardGrid(view: view),
    };
  }
}

final class _DashboardError extends StatelessWidget {
  final String? message;

  const _DashboardError({required this.message});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppEmptyState(
      icon: Icons.error_outline,
      title: l10n.dashboardErrorTitle,
      description: message ?? '',
    );
  }
}

final class _DashboardEmpty extends StatelessWidget {
  const _DashboardEmpty();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AppEmptyState(
      icon: Icons.insights_outlined,
      title: l10n.dashboardEmptyTitle,
      description: l10n.dashboardEmptyMessage,
    );
  }
}

final class _DashboardGrid extends StatelessWidget {
  final DashboardView view;

  const _DashboardGrid({required this.view});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardSectionsLayout(
            primary: DashboardPrimaryColumn(
              state: view.state,
              onOpenModule: view.onOpenModule,
            ),
            secondary: DashboardSecondaryColumn(
              state: view.state,
              lastSyncAt: view.lastSyncAt,
            ),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}

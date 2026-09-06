import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/sync/sync_cubit.dart';
import '../../application/sync/sync_state.dart';
import '../../domain/model/analysis/app_diagnostic.dart';
import '../l10n/generated/app_localizations.dart';
import 'button/app_button.dart';
import 'status_banner.dart';

final class SyncBanner extends StatelessWidget {
  const SyncBanner({super.key});

  @override
  Widget build(BuildContext context) {
    SyncCubit? cubit;
    try {
      cubit = BlocProvider.of<SyncCubit>(context);
    } catch (_) {
      return const SizedBox.shrink();
    }
    return BlocBuilder<SyncCubit, SyncState>(
      bloc: cubit,
      builder: (context, state) => switch (state) {
        SyncIdle(:final conflictCount) when conflictCount > 0 =>
          _ConflictSyncBanner(count: conflictCount),
        SyncConflictDetected(:final conflictCount) =>
          _ConflictSyncBanner(count: conflictCount),
        SyncInProgress() => const _InProgressSyncBanner(),
        SyncError() => const _ErrorSyncBanner(),
        SyncIdle() => const SizedBox.shrink(),
      },
    );
  }
}

final class _ConflictSyncBanner extends StatelessWidget {
  final int count;

  const _ConflictSyncBanner({required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusBanner(
      severity: AppSeverity.warning,
      title: l10n.syncBannerConflictTitle,
      message: l10n.syncBannerConflictMessage(count),
    );
  }
}

final class _InProgressSyncBanner extends StatelessWidget {
  const _InProgressSyncBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusBanner(
      severity: AppSeverity.info,
      title: l10n.syncBannerInProgress,
    );
  }
}

final class _ErrorSyncBanner extends StatelessWidget {
  const _ErrorSyncBanner();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return StatusBanner(
      severity: AppSeverity.error,
      title: l10n.syncBannerErrorTitle,
      message: l10n.syncBannerErrorMessage,
      action: _SyncRetryButton(
        label: l10n.syncRetryButton,
        onPressed: () => context.read<SyncCubit>().syncNow(),
      ),
    );
  }
}

final class _SyncRetryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SyncRetryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: label,
      variant: AppButtonVariant.secondary,
      onPressed: onPressed,
    );
  }
}

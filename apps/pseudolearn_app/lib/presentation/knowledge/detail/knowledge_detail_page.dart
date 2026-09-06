import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/knowledge/knowledge_detail_cubit.dart';
import '../../../application/knowledge/knowledge_detail_state.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../domain/model/knowledge/exercise.dart';
import '../../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../../domain/model/settings/effective_ui_language.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../exercise_creation_launcher.dart';
import 'components/detail_header.dart';
import 'components/detail_state_views.dart';

final class KnowledgeDetailPage extends StatefulWidget {
  final String entryId;
  final String? anchor;
  final String? fromModuleId;

  const KnowledgeDetailPage({
    super.key,
    required this.entryId,
    this.anchor,
    this.fromModuleId,
  });

  @override
  State<KnowledgeDetailPage> createState() => _KnowledgeDetailPageState();
}

final class _KnowledgeDetailPageState extends State<KnowledgeDetailPage> {
  @override
  void initState() {
    super.initState();
    _loadEntry();
  }

  @override
  void didUpdateWidget(KnowledgeDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entryId != widget.entryId ||
        oldWidget.anchor != widget.anchor ||
        oldWidget.fromModuleId != widget.fromModuleId) {
      _loadEntry();
    }
  }

  void _loadEntry() {
    final settings = context.read<SettingsCubit>().state;
    final systemLocale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final effectiveLanguage = resolveEffectiveLanguage(
      setting: settings.language,
      systemLanguageCode: systemLocale,
    );
    final profile = syntaxProfileForLanguage(effectiveLanguage);
    context.read<KnowledgeDetailCubit>().loadEntry(
          widget.entryId,
          effectiveLanguage,
          profileId: profile,
          anchor: widget.anchor,
          fromModuleId: widget.fromModuleId,
        );
  }

  void _onOpenSpec(String specId, {String? anchor}) {
    final suffix = anchor != null ? '&anchor=$anchor' : '';
    context.push('/conocimiento/$specId?fromModule=${widget.entryId}$suffix');
  }

  void _onReturnToModule(String moduleId) {
    if (widget.fromModuleId == moduleId && context.canPop()) {
      context.pop();
    } else {
      context.push('/conocimiento/$moduleId');
    }
  }

  void _onOpenExercise(String exerciseId) {
    context.push('/conocimiento/$exerciseId').then((_) {
      if (mounted) _loadEntry();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<KnowledgeDetailCubit>();
    return BlocBuilder<KnowledgeDetailCubit, KnowledgeDetailState>(
      buildWhen: (previous, current) =>
          previous.forEntry(widget.entryId) != current.forEntry(widget.entryId),
      builder: (context, state) => KnowledgeDetailView(
        state: state.forEntry(widget.entryId),
        onBack: () => context.pop(),
        onRetry: _loadEntry,
        onScrollChanged: (offset) => cubit.saveScrollOffset(widget.entryId, offset),
        onOpenSpecification: _onOpenSpec,
        onReturnToModule: _onReturnToModule,
        onOpenExercise: _onOpenExercise,
        onOpenExerciseInNewDocument: (ex) => launchExerciseCreationDialog(
          context: context,
          exercise: ex,
          onClosed: _loadEntry,
        ),
      ),
    );
  }
}

final class KnowledgeDetailView extends StatelessWidget {
  final EntryDetailState state;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final ValueChanged<double> onScrollChanged;
  final void Function(String entryId, {String? anchor}) onOpenSpecification;
  final ValueChanged<String>? onReturnToModule;
  final ValueChanged<String>? onOpenExercise;
  final ValueChanged<Exercise>? onOpenExerciseInNewDocument;

  const KnowledgeDetailView({
    super.key,
    required this.state,
    required this.onBack,
    required this.onRetry,
    required this.onScrollChanged,
    required this.onOpenSpecification,
    this.onReturnToModule,
    this.onOpenExercise,
    this.onOpenExerciseInNewDocument,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.space4,
            vertical: SpacingTokens.space3,
          ),
          child: _DetailLayout(
            state: state,
            onBack: onBack,
            onRetry: onRetry,
            onScrollChanged: onScrollChanged,
            onOpenSpecification: onOpenSpecification,
            onReturnToModule: onReturnToModule,
            onOpenExercise: onOpenExercise,
            onOpenExerciseInNewDocument: onOpenExerciseInNewDocument,
          ),
        ),
      ),
    );
  }
}

final class _DetailLayout extends StatelessWidget {
  final EntryDetailState state;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final ValueChanged<double> onScrollChanged;
  final void Function(String entryId, {String? anchor}) onOpenSpecification;
  final ValueChanged<String>? onReturnToModule;
  final ValueChanged<String>? onOpenExercise;
  final ValueChanged<Exercise>? onOpenExerciseInNewDocument;

  const _DetailLayout({
    required this.state,
    required this.onBack,
    required this.onRetry,
    required this.onScrollChanged,
    required this.onOpenSpecification,
    this.onReturnToModule,
    this.onOpenExercise,
    this.onOpenExerciseInNewDocument,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailHeader(entry: state.entry, onBack: onBack),
        const SizedBox(height: SpacingTokens.space4),
        Expanded(
          child: _DetailBody(
            state: state,
            onBack: onBack,
            onRetry: onRetry,
            onScrollChanged: onScrollChanged,
            onOpenSpecification: onOpenSpecification,
            onReturnToModule: onReturnToModule,
            onOpenExercise: onOpenExercise,
            onOpenExerciseInNewDocument: onOpenExerciseInNewDocument,
          ),
        ),
      ],
    );
  }
}

final class _DetailBody extends StatelessWidget {
  final EntryDetailState state;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final ValueChanged<double> onScrollChanged;
  final void Function(String entryId, {String? anchor}) onOpenSpecification;
  final ValueChanged<String>? onReturnToModule;
  final ValueChanged<String>? onOpenExercise;
  final ValueChanged<Exercise>? onOpenExerciseInNewDocument;

  const _DetailBody({
    required this.state,
    required this.onBack,
    required this.onRetry,
    required this.onScrollChanged,
    required this.onOpenSpecification,
    this.onReturnToModule,
    this.onOpenExercise,
    this.onOpenExerciseInNewDocument,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (state.status) {
      KnowledgeDetailStatus.initial || KnowledgeDetailStatus.loading => const Center(
          child: CircularProgressIndicator(),
        ),
      KnowledgeDetailStatus.notFound => NotFoundBody(l10n: l10n, onBack: onBack),
      KnowledgeDetailStatus.error => ErrorBody(
          l10n: l10n,
          message: state.errorMessage,
          onRetry: onRetry,
        ),
      KnowledgeDetailStatus.success => SuccessContent(
          content: state.content,
          onOpenSpecification: onOpenSpecification,
          onOpenExercise: onOpenExercise,
          onReturnToModule: onReturnToModule,
          onScrollChanged: onScrollChanged,
          onOpenExerciseInNewDocument: onOpenExerciseInNewDocument,
        ),
    };
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../application/knowledge/knowledge_detail_cubit.dart';
import '../../../application/knowledge/knowledge_detail_state.dart';
import '../../../application/settings/settings_cubit.dart';
import '../../../domain/model/knowledge/content_block.dart';
import '../../../domain/model/knowledge/knowledge_detail_content.dart';
import '../../../domain/model/profiles/syntax_profile_for_language.dart';
import '../../../domain/model/settings/effective_ui_language.dart';
import 'contact_support_view.dart';

final class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

final class _ContactSupportPageState extends State<ContactSupportPage> {
  @override
  void initState() {
    super.initState();
    _loadEntry();
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
      'contact-support',
      effectiveLanguage,
      profileId: profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KnowledgeDetailCubit, KnowledgeDetailState>(
      buildWhen: (previous, current) =>
          previous.forEntry('contact-support') != current.forEntry('contact-support'),
      builder: (context, state) {
        final entryState = state.forEntry('contact-support');
        final List<ContentBlock> blocks = switch (entryState.content) {
          final DocumentDetailContent document => document.blocks,
          _ => const [],
        };

        return ContactSupportView(
          blocks: blocks,
          isLoading: entryState.status == KnowledgeDetailStatus.loading,
          errorMessage: entryState.errorMessage,
          onRetry: _loadEntry,
          onBack: () => context.pop(),
        );
      },
    );
  }
}

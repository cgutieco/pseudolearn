import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import '../../application/agent/reply_citations.dart';
import '../../domain/model/agent/agent_message.dart';
import '../components/typography/app_text.dart';
import '../theme/app_theme.dart';
import '../theme/tokens/radii.dart';
import '../theme/tokens/spacing.dart';
import 'agent_step_list.dart';
import 'reply/reply_blocks_view.dart';

final class AgentMessageBubble extends StatelessWidget {
  final AgentMessage message;

  const AgentMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final mine = message.role == AgentRole.user;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: SpacingTokens.space1),
        padding: const EdgeInsets.all(SpacingTokens.space3),
        decoration: BoxDecoration(
          color: mine ? theme.colors.surfaces.brandSubtle : theme.colors.surfaces.subtle,
          borderRadius: const BorderRadius.all(Radius.circular(RadiusTokens.radiusLg)),
        ),
        child: mine ? SelectableText(message.text) : _AssistantContent(message: message),
      ),
    );
  }
}

final class _AssistantContent extends StatelessWidget {
  final AgentMessage message;

  const _AssistantContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (message.steps.isNotEmpty) AgentStepList(steps: message.steps),
        SelectionArea(child: ReplyBlocksView(blocks: message.blocks, codeBlocks: message.codeBlocks)),
        _SpecificationLinks(sections: citedSpecificationSections(message.text)),
      ],
    );
  }
}

final class _SpecificationLinks extends StatelessWidget {
  final List<String> sections;

  const _SpecificationLinks({required this.sections});

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: SpacingTokens.space2,
      children: [
        for (final section in sections)
          ActionChip(
            label: AppText(section, variant: AppTextVariant.caption),
            onPressed: () => context.go('/conocimiento/especificacion/$section'),
          ),
      ],
    );
  }
}

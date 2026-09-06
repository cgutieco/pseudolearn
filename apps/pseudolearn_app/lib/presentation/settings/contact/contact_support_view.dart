import 'package:flutter/material.dart';
import '../../../domain/model/knowledge/content_block.dart';
import '../../components/card/app_card_surface.dart';
import '../../components/layout/app_page.dart';
import '../../components/typography/app_text.dart';
import '../../knowledge/detail/components/content_block_view.dart';
import '../../knowledge/detail/components/detail_state_views.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../shell/design_canvas.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import '../widgets/settings_sections_layout.dart';
import 'contact_cards.dart';
import 'contact_channel_tile.dart';

final class ContactSupportView extends StatelessWidget {
  final List<ContentBlock> blocks;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  const ContactSupportView({
    super.key,
    required this.blocks,
    required this.onRetry,
    required this.onBack,
    this.isLoading = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colors.surfaces.canvas,
      body: AppPage(
        title: l10n.settingsContactTitle,
        onBack: onBack,
        backSemanticLabel: l10n.settingsBack,
        body: _ContactBody(view: this),
      ),
    );
  }
}

final class _ContactBody extends StatelessWidget {
  final ContactSupportView view;

  const _ContactBody({required this.view});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (view.isLoading) return const Center(child: CircularProgressIndicator());
    if (view.errorMessage != null) {
      return ErrorBody(l10n: l10n, message: view.errorMessage, onRetry: view.onRetry);
    }
    if (view.blocks.isEmpty) {
      return Center(
        child: AppText(
          l10n.settingsContactEmpty,
          variant: AppTextVariant.bodyDefault,
          color: theme.colors.text.secondary,
        ),
      );
    }
    return _ContactSheet(blocks: view.blocks);
  }
}

final class _ContactSheet extends StatelessWidget {
  final List<ContentBlock> blocks;

  const _ContactSheet({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final primaryBlocks = <ContentBlock>[];
    final secondaryBlocks = <ContentBlock>[];
    var headingCount = 0;

    for (final block in blocks) {
      if (block is HeadingBlock) headingCount++;
      if (headingCount >= 2) {
        secondaryBlocks.add(block);
      } else {
        primaryBlocks.add(block);
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SettingsSectionsLayout(
            primary: _PrimarySection(blocks: primaryBlocks),
            secondary: _SecondarySection(blocks: secondaryBlocks),
          ),
          SizedBox(height: canvas.scaled(SpacingTokens.space6)),
        ],
      ),
    );
  }
}

final class _PrimarySection extends StatelessWidget {
  final List<ContentBlock> blocks;

  const _PrimarySection({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);
    final hasIntro = blocks.isNotEmpty && blocks.first is ParagraphBlock;
    final introText = hasIntro ? (blocks.first as ParagraphBlock).text : null;
    final channelBlocks = hasIntro ? blocks.sublist(1) : blocks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContactHeroCard(introText: introText),
        if (channelBlocks.isNotEmpty) ...[
          SizedBox(height: canvas.scaled(SpacingTokens.space4)),
          _ChannelsCard(blocks: channelBlocks),
        ],
      ],
    );
  }
}

final class _ChannelsCard extends StatelessWidget {
  final List<ContentBlock> blocks;

  const _ChannelsCard({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return AppCardSurface(
      padding: EdgeInsets.all(canvas.scaled(SpacingTokens.space5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final block in blocks) _BlockView(block: block),
        ],
      ),
    );
  }
}

final class _BlockView extends StatelessWidget {
  final ContentBlock block;

  const _BlockView({required this.block});

  @override
  Widget build(BuildContext context) {
    if (block is ListBlock) {
      final listBlock = block as ListBlock;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in listBlock.items) ContactChannelTile(item: item),
        ],
      );
    }
    return ContentBlockView(block: block);
  }
}

final class _SecondarySection extends StatelessWidget {
  final List<ContentBlock> blocks;

  const _SecondarySection({required this.blocks});

  @override
  Widget build(BuildContext context) {
    final canvas = DesignCanvasScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (blocks.isNotEmpty) ...[
          ContactPedagogicalCard(blocks: blocks),
          SizedBox(height: canvas.scaled(SpacingTokens.space4)),
        ],
        const ContactTipsCard(),
      ],
    );
  }
}

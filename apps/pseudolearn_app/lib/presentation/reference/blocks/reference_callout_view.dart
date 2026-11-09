import 'package:flutter/material.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../../domain/model/reference/reference_callout_kind.dart';
import '../../../domain/model/reference/reference_edition.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';
import 'reference_block_view.dart';

final class ReferenceCalloutView extends StatelessWidget {
  final ReferenceCallout callout;
  final ReferenceEdition edition;
  final ValueChanged<String> onOpenSection;

  const ReferenceCalloutView({
    super.key,
    required this.callout,
    required this.edition,
    required this.onOpenSection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    final accent = calloutAccent(callout.kind, theme);
    final title = calloutTitle(callout.kind, AppLocalizations.of(context)!);
    final body = ReferenceBlockColumn(
      blocks: callout.blocks,
      edition: edition,
      onOpenSection: onOpenSection,
    );
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.surfaces.subtle,
        borderRadius: BorderRadius.circular(RadiusTokens.radiusMd),
        border: Border(
          left: BorderSide(color: accent, width: SpacingTokens.space1),
        ),
      ),
      padding: const EdgeInsets.only(
        left: SpacingTokens.space4,
        top: SpacingTokens.space2,
        right: SpacingTokens.space3,
      ),
      child: callout.collapsible
          ? ReferenceCollapsible(title: title, color: accent, child: body)
          : ReferenceCalloutBody(title: title, color: accent, child: body),
    );
  }
}

final class ReferenceCalloutBody extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const ReferenceCalloutBody({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(title, variant: AppTextVariant.overline, color: color),
        const SizedBox(height: SpacingTokens.space2),
        child,
      ],
    );
  }
}

final class ReferenceCollapsible extends StatelessWidget {
  final String title;
  final Color color;
  final Widget child;

  const ReferenceCollapsible({
    super.key,
    required this.title,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const Border(),
      collapsedShape: const Border(),
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: AppText(title, variant: AppTextVariant.label, color: color),
      children: [child],
    );
  }
}

Color calloutAccent(ReferenceCalloutKind kind, AppThemeExtension theme) =>
    switch (kind) {
      ReferenceCalloutKind.phrase => theme.syntax.keywordStructured,
      ReferenceCalloutKind.limit => theme.syntax.literalNumber,
      ReferenceCalloutKind.errors => theme.colors.severities.error.fg,
      ReferenceCalloutKind.inside => theme.syntax.keywordOop,
      ReferenceCalloutKind.analogy => theme.colors.severities.success.fg,
      ReferenceCalloutKind.parts ||
      ReferenceCalloutKind.note => theme.colors.text.tertiary,
    };

String calloutTitle(ReferenceCalloutKind kind, AppLocalizations l10n) =>
    switch (kind) {
      ReferenceCalloutKind.phrase => l10n.referenceCalloutPhrase,
      ReferenceCalloutKind.limit => l10n.referenceCalloutLimit,
      ReferenceCalloutKind.inside => l10n.referenceCalloutInside,
      ReferenceCalloutKind.analogy => l10n.referenceCalloutAnalogy,
      ReferenceCalloutKind.note => l10n.referenceCalloutNote,
      ReferenceCalloutKind.parts => l10n.referenceCalloutParts,
      ReferenceCalloutKind.errors => l10n.referenceCalloutErrors,
    };

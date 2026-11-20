import 'package:material_ui/material_ui.dart';

import '../../components/typography/app_text.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/radii.dart';
import '../../theme/tokens/spacing.dart';

final class ReadLineTarget extends StatelessWidget {
  final String designator;

  const ReadLineTarget({super.key, required this.designator});

  @override
  Widget build(BuildContext context) {
    final theme = AppThemeExtension.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: SpacingTokens.space20 + SpacingTokens.space10,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.surfaces.raised,
          borderRadius: BorderRadius.circular(RadiusTokens.radiusFull),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.space2,
            vertical: SpacingTokens.spaceHalf,
          ),
          child: AppText(
            designator,
            variant: AppTextVariant.codeEditor,
            color: theme.colors.text.link,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

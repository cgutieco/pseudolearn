import 'package:material_ui/material_ui.dart';
import '../../../domain/model/reference/reference_block.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import 'reference_code_frame.dart';

final class ReferenceListingView extends StatelessWidget {
  final ReferenceListing listing;

  const ReferenceListingView({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    return ReferenceCodeFrame(
      label: listing.kind == ReferenceListingKind.intermediate
          ? l10n.referenceIntermediate
          : l10n.referenceTrace,
      child: AppText(
        listing.lines.join('\n'),
        variant: AppTextVariant.codeCaption,
        color: theme.colors.text.secondary,
      ),
    );
  }
}

import 'package:material_ui/material_ui.dart';

import '../../components/button/app_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';

final class ReadLineChoices extends StatelessWidget {
  final ValueChanged<String> onChoose;

  const ReadLineChoices({super.key, required this.onChoose});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space2),
      child: Wrap(
        spacing: SpacingTokens.space2,
        runSpacing: SpacingTokens.space2,
        children: [
          AppButton(
            label: l10n.readValueTrue,
            variant: AppButtonVariant.secondary,
            onPressed: () => onChoose(l10n.readValueTrue),
          ),
          AppButton(
            label: l10n.readValueFalse,
            variant: AppButtonVariant.secondary,
            onPressed: () => onChoose(l10n.readValueFalse),
          ),
        ],
      ),
    );
  }
}

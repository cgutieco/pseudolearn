import 'package:flutter/widgets.dart';
import '../../components/button/app_button.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/tokens/spacing.dart';

final class OnboardingNavigationActions extends StatelessWidget {
  final bool canGoBack;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const OnboardingNavigationActions({
    super.key,
    required this.canGoBack,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: SpacingTokens.space3,
      runSpacing: SpacingTokens.space2,
      children: [
        AppButton(
          label: l10n.onboardingActionBack,
          variant: AppButtonVariant.secondary,
          onPressed: canGoBack ? onBack : null,
        ),
        AppButton(
          label: l10n.onboardingActionNext,
          variant: AppButtonVariant.primary,
          onPressed: onNext,
        ),
      ],
    );
  }
}

import 'package:material_ui/material_ui.dart';
import '../../components/button/app_button.dart';
import '../../l10n/generated/app_localizations.dart';

final class DataInputSubmitAction extends StatelessWidget {
  final VoidCallback onSubmit;

  const DataInputSubmitAction({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AppButton(
          label: l10n.inputDialogSubmit,
          variant: AppButtonVariant.primary,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

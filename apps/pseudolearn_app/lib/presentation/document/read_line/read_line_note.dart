import 'package:material_ui/material_ui.dart';

import '../../../domain/model/execution/read_request.dart';
import '../../components/typography/app_text.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens/spacing.dart';
import 'read_value_type_label.dart';

final class ReadLineNote extends StatelessWidget {
  final ReadRequest request;

  const ReadLineNote({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = AppThemeExtension.of(context);
    final isRejected = request.rejection != null;
    return Padding(
      padding: const EdgeInsets.only(top: SpacingTokens.space2),
      child: Semantics(
        liveRegion: isRejected,
        child: AppText(
          isRejected ? _rejectionText(l10n) : _hintText(l10n),
          variant: AppTextVariant.caption,
          color: isRejected
              ? theme.colors.severities.error.fg
              : theme.colors.text.secondary,
        ),
      ),
    );
  }

  String _hintText(AppLocalizations l10n) {
    final type = request.valueType;
    if (type == null) return l10n.readLineHintUntyped(request.designator);
    return l10n.readLineHint(
      readValueTypeLabel(l10n, type),
      request.designator,
    );
  }

  String _rejectionText(AppLocalizations l10n) {
    final message = request.rejection?.message;
    if (message != null && message.isNotEmpty) return message;
    final type = request.valueType;
    if (type == null) return l10n.readLineRejectedUntyped(request.designator);
    return l10n.readLineRejected(
      request.designator,
      readValueTypeLabel(l10n, type),
    );
  }
}

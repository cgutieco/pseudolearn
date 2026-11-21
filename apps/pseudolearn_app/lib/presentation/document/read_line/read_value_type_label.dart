import '../../../domain/model/execution/read_value_type.dart';
import '../../l10n/generated/app_localizations.dart';

String readValueTypeLabel(AppLocalizations l10n, ReadValueType type) =>
    switch (type) {
      ReadValueType.integer => l10n.readTypeInteger,
      ReadValueType.real => l10n.readTypeReal,
      ReadValueType.boolean => l10n.readTypeBoolean,
      ReadValueType.character => l10n.readTypeCharacter,
      ReadValueType.text => l10n.readTypeText,
    };

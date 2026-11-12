import '../../../domain/model/completion/completion_item.dart';
import '../../l10n/generated/app_localizations.dart';

String? localizedCompletionDetail(AppLocalizations l10n, CompletionItem item) {
  final argument = item.detailArguments.firstOrNull;
  return switch (item.detailKey) {
    'close_block' => l10n.editorDetailCloseBlock,
    'structure' => l10n.editorDetailStructure,
    'bilingual_equivalent' => l10n.editorDetailBilingualEquivalent(
      argument ?? '',
    ),
    'primitive_type' => l10n.editorDetailPrimitiveType,
    'class' => l10n.editorDetailClass,
    'standard_function' => l10n.editorDetailStandardFunction,
    'type_name' || 'signature' => argument,
    _ => item.detail,
  };
}

import 'dart:convert';
import 'dart:io';

const String _catalogPath =
    '../../packages/pseudolearn_spec/specifications/cases/catalogs.json';

Set<String> readHelpCardIds({String path = _catalogPath}) {
  final catalogs =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  final help = catalogs['helpCatalog'] as Map<String, Object?>;
  return {
    for (final card in help['cards'] as List<Object?>)
      (card as Map<String, Object?>)['id'] as String,
  };
}

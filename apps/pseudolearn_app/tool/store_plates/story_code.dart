import 'dart:convert';
import 'dart:io';

import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

const String storeStoryPath =
    '../../packages/pseudolearn_store_media/stories/app-store-screenshots.json';

const Map<UiLanguageId, String> _storyLanguages = <UiLanguageId, String>{
  UiLanguageId.spanish: 'es',
  UiLanguageId.english: 'en',
};

List<String> storyPrograms(UiLanguageId language, [String path = storeStoryPath]) {
  final story =
      jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;
  final chapters = (story['chapters']! as List<Object?>).cast<Map<String, Object?>>();
  return <String>[
    for (final chapter in chapters)
      if (chapter['code'] case final Map<String, Object?> code)
        (code[_storyLanguages[language]]! as List<Object?>).cast<String>().join('\n'),
  ];
}

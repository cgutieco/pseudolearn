import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

import 'store_scene.dart';

const Map<UiLanguageId, Map<StoreScene, String>> storeHeadlines =
    <UiLanguageId, Map<StoreScene, String>>{
  UiLanguageId.spanish: <StoreScene, String>{
    StoreScene.syncedViews: 'Tu algoritmo, en código y en diagrama',
    StoreScene.stepByStep: 'Avanza instrucción por instrucción',
    StoreScene.traceTable: 'Mira cada variable cambiar en la tabla',
    StoreScene.equivalentCode: 'El mismo algoritmo en Python y Rust',
    StoreScene.knowledgeBase: 'Módulos y ejercicios para practicar',
  },
  UiLanguageId.english: <StoreScene, String>{
    StoreScene.syncedViews: 'Your algorithm as code and as diagram',
    StoreScene.stepByStep: 'Move one statement at a time',
    StoreScene.traceTable: 'Watch every variable change in the table',
    StoreScene.equivalentCode: 'The same algorithm in Python and Rust',
    StoreScene.knowledgeBase: 'Modules and exercises to practice with',
  },
};

const Map<UiLanguageId, String> featureGraphicTagline = <UiLanguageId, String>{
  UiLanguageId.spanish: 'Pseudocódigo que se ve ejecutar',
  UiLanguageId.english: 'Pseudocode you can watch run',
};

const Map<UiLanguageId, String> localeTags = <UiLanguageId, String>{
  UiLanguageId.spanish: 'es',
  UiLanguageId.english: 'en',
};

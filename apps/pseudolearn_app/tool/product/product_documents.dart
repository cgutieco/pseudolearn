import 'package:pseudolearn_app/domain/model/profiles/syntax_profile_id.dart';
import 'package:pseudolearn_app/domain/model/settings/ui_language_id.dart';

const String guidedDemoId = 'guided-demo';
const String aliasDemoId = 'alias-demo';
const String functionDemoId = 'function-demo';
const String tasksDemoId = 'tasks-demo';

final class ProductDocumentSpec {
  final String id;
  final String title;
  final String sourcePath;

  const ProductDocumentSpec({
    required this.id,
    required this.title,
    required this.sourcePath,
  });
}

const Map<UiLanguageId, SyntaxProfileId> productProfiles =
    <UiLanguageId, SyntaxProfileId>{
  UiLanguageId.spanish: SyntaxProfileId.classicSpanish,
  UiLanguageId.english: SyntaxProfileId.english,
};

const Map<UiLanguageId, List<ProductDocumentSpec>> productDocuments =
    <UiLanguageId, List<ProductDocumentSpec>>{
  UiLanguageId.spanish: <ProductDocumentSpec>[
    ProductDocumentSpec(
      id: guidedDemoId,
      title: 'Control de temperatura',
      sourcePath: 'assets/demo/guided_demo_es.pseudo',
    ),
    ProductDocumentSpec(
      id: aliasDemoId,
      title: 'Alias entre objetos',
      sourcePath: 'assets/demo/c3_alias_es.pseudo',
    ),
    ProductDocumentSpec(
      id: functionDemoId,
      title: 'Máximo de dos números',
      sourcePath: 'assets/demo/b6_funcion_es.pseudo',
    ),
    ProductDocumentSpec(
      id: tasksDemoId,
      title: 'Mostrador del kiosco',
      sourcePath: 'tool/product/tasks_demo_es.pseudo',
    ),
  ],
  UiLanguageId.english: <ProductDocumentSpec>[
    ProductDocumentSpec(
      id: guidedDemoId,
      title: 'Temperature control',
      sourcePath: 'assets/demo/guided_demo_en.pseudo',
    ),
    ProductDocumentSpec(
      id: aliasDemoId,
      title: 'Aliasing between objects',
      sourcePath: 'assets/demo/c3_alias_en.pseudo',
    ),
    ProductDocumentSpec(
      id: functionDemoId,
      title: 'Maximum of two numbers',
      sourcePath: 'assets/demo/b6_funcion_en.pseudo',
    ),
    ProductDocumentSpec(
      id: tasksDemoId,
      title: 'Kiosk counter',
      sourcePath: 'tool/product/tasks_demo_en.pseudo',
    ),
  ],
};

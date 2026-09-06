import 'ast_construct.dart';

const Map<AstConstruct, String> constructSpecificationSections =
    <AstConstruct, String>{
  AstConstruct.conditional: 'esp-i-control',
  AstConstruct.multipleSelection: 'esp-i-control',
  AstConstruct.conditionalLoop: 'esp-i-control',
  AstConstruct.postConditionalLoop: 'esp-i-control',
  AstConstruct.countedLoop: 'esp-i-control',
  AstConstruct.arrayDeclaration: 'esp-i-arreglos',
  AstConstruct.subprogram: 'esp-i-subprogramas',
  AstConstruct.classDeclaration: 'esp-o-clases',
};

Set<String> measurableSpecificationSectionIds() =>
    constructSpecificationSections.values.toSet();

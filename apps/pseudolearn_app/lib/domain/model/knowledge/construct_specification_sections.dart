import 'ast_construct.dart';

const Map<AstConstruct, String> constructSpecificationSections =
    <AstConstruct, String>{
      AstConstruct.conditional: 'control.si',
      AstConstruct.multipleSelection: 'control.segun',
      AstConstruct.conditionalLoop: 'control.mientras',
      AstConstruct.postConditionalLoop: 'control.repetir',
      AstConstruct.countedLoop: 'control.para',
      AstConstruct.arrayDeclaration: 'tipos.arreglos',
      AstConstruct.subprogram: 'subprogramas.declaracion',
      AstConstruct.classDeclaration: 'objetos.clase',
      AstConstruct.interfaceDeclaration: 'objetos.interfaces',
    };

Set<String> measurableSpecificationSectionIds() =>
    constructSpecificationSections.values.toSet();

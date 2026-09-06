part of 'diagnostic_catalog.dart';

const Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _semanticTemplates = {
  DiagnosticCode.undeclaredVariable: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Variable no declarada: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Undeclared variable: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.variableUsedBeforeDeclaration: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La variable {lexeme} se usa antes de su declaración',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Variable {lexeme} is used before its declaration',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.duplicateVariableDeclaration: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Declaración duplicada de la variable {lexeme} en el mismo ámbito',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Duplicate declaration of variable {lexeme} in the same scope',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.duplicateParameterName: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Parámetro duplicado: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Duplicate parameter name: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.duplicateSubroutine: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Declaración duplicada del subprograma {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Duplicate declaration of subroutine {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.duplicateClass: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Declaración duplicada de la clase {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Duplicate declaration of class {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.classAndSubroutineSameName: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Conflicto de nombres: la clase y el subprograma no pueden llamarse {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Name conflict: class and subroutine cannot both be named {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.subroutineAndVariableSameName: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La variable {lexeme} no puede llamarse igual que un subprograma en el mismo ámbito',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Variable {lexeme} cannot have the same name as a subroutine in the same scope',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.undeclaredSubroutine: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Subprograma no declarado: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Undeclared subroutine: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.undeclaredClass: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Clase no declarada: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Undeclared class: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.undeclaredSuperclass: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La superclase {lexeme} no está declarada',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Superclass {lexeme} is not declared',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.circularInheritance: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Herencia circular detectada en la clase {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Circular inheritance detected in class {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.duplicateMember: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Miembro duplicado {lexeme} en la clase',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Duplicate member {lexeme} in class',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.inheritedAttributeShadowed: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El atributo {lexeme} ya está declarado en una superclase',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Attribute {lexeme} is already declared in a superclass',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.incompatibleMethodOverride: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La firma del método sobrescrito {lexeme} no coincide con la de la superclase',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Overridden method {lexeme} signature does not match superclass method',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.missingSuperConstructorCall: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Falta la invocación obligatoria al constructor de la superclase',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Missing required call to superclass constructor',
    ),
  },
  DiagnosticCode.invalidSuperConstructorCallPosition: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La invocación al constructor de la superclase debe ser la primera sentencia',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Call to superclass constructor must be the first statement',
    ),
  },
  DiagnosticCode.returnWithValueInConstructor: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Un constructor no puede retornar un valor',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'A constructor cannot return a value',
    ),
  },
  DiagnosticCode.identifierMatchesFieldWithoutThis: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Acceso a atributo no calificado; use Este.{lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Unqualified field access; use this.{lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.undefinedMember: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Miembro no definido: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Undefined member: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.variableDeclaredNeverUsed: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Variable declarada y nunca usada: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Variable declared but never used: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.variableAssignedNeverRead: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Variable asignada pero nunca leída: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Variable assigned but never read: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.unusedParameter: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Parámetro nunca usado: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Parameter never used: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.unusedSubroutine: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Subprograma declarado pero nunca llamado: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Subroutine declared but never called: {lexeme}',
      requiredArguments: {'lexeme'},
    ),
  },
};

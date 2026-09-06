part of 'diagnostic_catalog.dart';

final Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _classTemplates = {
  DiagnosticCode.expectedClassName: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el nombre de la clase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected class name',
    ),
  },
  DiagnosticCode.unclosedClass: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Clase sin cerrar al final del archivo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed class at end of file',
    ),
  },
  DiagnosticCode.classInsideAlgorithm: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite declarar una clase dentro del cuerpo del algoritmo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Declaring a class inside the algorithm body is not allowed',
    ),
  },
  DiagnosticCode.classInsideSubroutine: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite declarar una clase dentro de un subprograma',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Declaring a class inside a subroutine is not allowed',
    ),
  },
  DiagnosticCode.nestedClassNotSupported: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite declarar una clase dentro de otra clase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Declaring a class inside another class is not allowed',
    ),
  },
  DiagnosticCode.subroutineInsideClass: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite declarar un subprograma dentro de una clase; use la declaración de método',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Declaring a subroutine inside a class is not allowed; use a method declaration',
    ),
  },
  DiagnosticCode.multipleInheritanceNotSupported: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La herencia múltiple no está permitida; solo se admite herencia simple',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Multiple inheritance is not allowed; only single inheritance is supported',
    ),
  },
  DiagnosticCode.duplicateVisibilityModifier: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se puede especificar más de un modificador de visibilidad en el mismo miembro',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Cannot specify more than one visibility modifier for the same member',
    ),
  },
  DiagnosticCode.constructorVisibilityNotAllowed: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El constructor no admite modificador de visibilidad; es siempre público',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Constructor does not allow a visibility modifier; it is always public',
    ),
  },
  DiagnosticCode.constructorReturnTypeNotAllowed: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El constructor no admite tipo de retorno',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Constructor does not allow a return type',
    ),
  },
  DiagnosticCode.duplicateConstructor: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se permite más de un constructor en la misma clase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Multiple constructors in the same class are not allowed',
    ),
  },
  DiagnosticCode.methodNamedAsClass: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Para declarar el constructor use la palabra reservada Constructor en lugar del nombre de la clase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'To declare a constructor use the keyword Constructor instead of the class name',
    ),
  },
  DiagnosticCode.methodOutsideClass: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La declaración de método solo es válida dentro de una clase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Method declaration is only valid inside a class',
    ),
  },
  DiagnosticCode.constructorOutsideClass: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El constructor solo es válido dentro de una clase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Constructor is only valid inside a class',
    ),
  },
  DiagnosticCode.unclosedMethod: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Método sin cerrar al final del archivo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Unclosed method at end of file',
    ),
  },
};

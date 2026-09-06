part of 'diagnostic_catalog.dart';

final Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _oopExpressionTemplates = {
  DiagnosticCode.expectedClassNameInInstantiation: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba el nombre de la clase tras la palabra reservada Nuevo',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected class name after keyword new',
    ),
  },
  DiagnosticCode.missingInstantiationParentheses: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La instanciación requiere paréntesis con o sin argumentos',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Instantiation requires parentheses with or without arguments',
    ),
  },
  DiagnosticCode.expectedMemberNameAfterDot: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Se esperaba un nombre de miembro tras el operador de acceso punto',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Expected member name after dot access operator',
    ),
  },
  DiagnosticCode.thisOutsideMethod: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La palabra reservada Este solo es válida dentro de un método o constructor',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Keyword this is only valid inside a method or constructor',
    ),
  },
  DiagnosticCode.expectedMemberNameAfterThis: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La palabra reservada Este debe ir seguida de un acceso a miembro (.nombre)',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Keyword this must be followed by a member access (.name)',
    ),
  },
  DiagnosticCode.superOutsideMethod: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La palabra reservada Super solo es válida dentro de un método o constructor',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Keyword super is only valid inside a method or constructor',
    ),
  },
  DiagnosticCode.superInClassWithoutSuperclass: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'No se puede usar Super en una clase que no hereda de ninguna superclase',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Cannot use super in a class that does not inherit from any superclass',
    ),
  },
  DiagnosticCode.superNotFollowedByCall: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La palabra reservada Super solo puede usarse como destino de llamada a método o constructor',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Keyword super can only be used as target of a method or constructor call',
    ),
  },
  DiagnosticCode.unsupportedInterfaceConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Las interfaces no forman parte de PseudoLearn',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Interfaces are not supported in PseudoLearn',
    ),
  },
  DiagnosticCode.unsupportedAbstractConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Las clases y métodos abstractos no forman parte de PseudoLearn',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Abstract classes and methods are not supported in PseudoLearn',
    ),
  },
  DiagnosticCode.unsupportedStaticConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Los miembros estáticos no forman parte de PseudoLearn',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Static members are not supported in PseudoLearn',
    ),
  },
  DiagnosticCode.unsupportedProtectedConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'La visibilidad protegida no forma parte de PseudoLearn; use Publico o Privado',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Protected visibility is not supported in PseudoLearn; use public or private',
    ),
  },
  DiagnosticCode.unsupportedGenericsConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'Los tipos genéricos no forman parte de PseudoLearn',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Generic types are not supported in PseudoLearn',
    ),
  },
  DiagnosticCode.unsupportedExceptionConstruct: {
    DiagnosticLocale.es: const DiagnosticTemplate(
      'El manejo de excepciones estructurado no forma parte de PseudoLearn',
    ),
    DiagnosticLocale.en: const DiagnosticTemplate(
      'Structured exception handling is not supported in PseudoLearn',
    ),
  },
};

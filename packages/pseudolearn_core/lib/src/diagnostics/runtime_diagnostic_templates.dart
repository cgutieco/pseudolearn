part of 'diagnostic_catalog.dart';

const Map<DiagnosticCode, Map<DiagnosticLocale, DiagnosticTemplate>>
    _runtimeTemplates = {
  DiagnosticCode.integerLiteralOutOfRange: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El literal entero {lexeme} está fuera del rango de 64 bits con signo',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Integer literal {lexeme} is out of the signed 64-bit range',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.divisionByZero: {
    DiagnosticLocale.es: DiagnosticTemplate('División por cero'),
    DiagnosticLocale.en: DiagnosticTemplate('Division by zero'),
  },
  DiagnosticCode.integerOverflow: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La operación produce un entero fuera del rango de 64 bits con signo',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'The operation produces an integer outside the signed 64-bit range',
    ),
  },
  DiagnosticCode.nonFiniteRealResult: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La operación produce un valor real no finito',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'The operation produces a non-finite real value',
    ),
  },
  DiagnosticCode.negativeIntegerExponent: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La potencia entera no admite un exponente negativo: {exponent}',
      requiredArguments: {'exponent'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Integer power does not allow a negative exponent: {exponent}',
      requiredArguments: {'exponent'},
    ),
  },
  DiagnosticCode.arrayIndexOutOfRange: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Índice {index} fuera de rango para un arreglo de tamaño {size}',
      requiredArguments: {'index', 'size'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Index {index} is out of range for an array of size {size}',
      requiredArguments: {'index', 'size'},
    ),
  },
  DiagnosticCode.negativeArraySize: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El tamaño de un arreglo no puede ser negativo: {size}',
      requiredArguments: {'size'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'An array size cannot be negative: {size}',
      requiredArguments: {'size'},
    ),
  },
  DiagnosticCode.zeroStepInCountedLoop: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El paso de un bucle contado no puede ser cero',
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'The step of a counted loop cannot be zero',
    ),
  },
  DiagnosticCode.recursionDepthExceeded: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Se alcanzó el límite de profundidad de recursión: {limit}',
      requiredArguments: {'limit'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Recursion depth limit reached: {limit}',
      requiredArguments: {'limit'},
    ),
  },
  DiagnosticCode.uninitializedVariableRead: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'La variable {lexeme} se lee sin haber sido inicializada',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Variable {lexeme} is read without being initialized',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.stringToNumberConversionFailed: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El texto {lexeme} no representa un número',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Text {lexeme} does not represent a number',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.stringPositionOutOfRange: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Posición {position} fuera de rango para una cadena de longitud {length}',
      requiredArguments: {'position', 'length'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Position {position} is out of range for a string of length {length}',
      requiredArguments: {'position', 'length'},
    ),
  },
  DiagnosticCode.invalidCharacterCode: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'El código {code} no designa ningún punto de código Unicode válido',
      requiredArguments: {'code'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Code {code} does not designate a valid Unicode code point',
      requiredArguments: {'code'},
    ),
  },
  DiagnosticCode.subroutineEndedWithoutReturn: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Un camino de ejecución de {lexeme} llega al cierre sin retornar',
      requiredArguments: {'lexeme'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'An execution path of {lexeme} reaches the end without returning',
      requiredArguments: {'lexeme'},
    ),
  },
  DiagnosticCode.readValueTypeMismatch: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'Se esperaba un valor de tipo {expected}, y se recibió {found}',
      requiredArguments: {'expected', 'found'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Expected a value of type {expected}, and received {found}',
      requiredArguments: {'expected', 'found'},
    ),
  },
  DiagnosticCode.privateMemberAccess: {
    DiagnosticLocale.es: DiagnosticTemplate(
      'No se puede acceder al miembro privado {lexeme} de la clase {className}',
      requiredArguments: {'lexeme', 'className'},
    ),
    DiagnosticLocale.en: DiagnosticTemplate(
      'Cannot access private member {lexeme} of class {className}',
      requiredArguments: {'lexeme', 'className'},
    ),
  },
};

---
{
  "formato": "see/1",
  "id": "DIAG.CATALOG",
  "titulo": "Catálogo bilingüe de diagnósticos",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Catálogo bilingüe de diagnósticos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "DIAG.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "DIAG.SEVERITY.POLICY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Catálogo bilingüe de diagnósticos

```definicion
{
  "id": "D1",
  "termino": "diagnostics",
  "texto": "Fichas de diagnóstico y plantillas de presentación de la edición vigente.",
  "valor": {
    "expectedSubroutineName": {
      "mensajes": {
        "es": "Se esperaba el nombre del subprograma",
        "en": "Expected subroutine name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedSubroutineLeftParenthesis": {
      "mensajes": {
        "es": "Se esperaba el paréntesis de apertura en la cabecera del subprograma",
        "en": "Expected opening parenthesis in subroutine header"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedSubroutine": {
      "mensajes": {
        "es": "Subprograma sin cerrar al final del archivo",
        "en": "Unclosed subroutine at end of file"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "subroutineInsideAlgorithm": {
      "mensajes": {
        "es": "No se permite declarar un subprograma dentro del cuerpo del algoritmo",
        "en": "Declaring a subroutine inside the algorithm body is not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "subroutineInsideSubroutine": {
      "mensajes": {
        "es": "No se permite declarar un subprograma dentro de otro subprograma",
        "en": "Declaring a subroutine inside another subroutine is not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "returnOutsideSubroutine": {
      "mensajes": {
        "es": "La instrucción de retorno solo es válida dentro de un subprograma",
        "en": "Return statement is only valid inside a subroutine"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedParameterName": {
      "mensajes": {
        "es": "Se esperaba el nombre del parámetro",
        "en": "Expected parameter name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "duplicatePassingModifier": {
      "mensajes": {
        "es": "No se puede especificar Por Valor y Por Referencia en el mismo parámetro",
        "en": "Cannot specify both By Value and By Reference for the same parameter"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "passingModifierBeforeParameterName": {
      "mensajes": {
        "es": "El modificador de paso debe colocarse después del tipo del parámetro",
        "en": "Passing modifier must be placed after parameter type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "invalidArrayReturnType": {
      "mensajes": {
        "es": "El tipo de retorno no puede ser un arreglo",
        "en": "Return type cannot be an array"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "multipleAlgorithms": {
      "mensajes": {
        "es": "No se permite más de un algoritmo por archivo fuente",
        "en": "Multiple algorithms in a single source file are not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unexpectedTokenOutsideProgramUnit": {
      "mensajes": {
        "es": "Elemento inesperado fuera del algoritmo y de los subprogramas: {lexeme}",
        "en": "Unexpected token outside algorithm and subroutines: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "expectedThenKeyword": {
      "mensajes": {
        "es": "Se esperaba la palabra condicional intermedia",
        "en": "Expected then keyword"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedIfStatement": {
      "mensajes": {
        "es": "Estructura condicional sin cerrar",
        "en": "Unclosed if statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "duplicateElseClause": {
      "mensajes": {
        "es": "La estructura condicional no puede tener más de una rama alternativa",
        "en": "If statement cannot have more than one else branch"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedDoKeyword": {
      "mensajes": {
        "es": "Se esperaba la palabra intermedia de acción",
        "en": "Expected do keyword"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedBranchSeparator": {
      "mensajes": {
        "es": "Se esperaba el separador de rama",
        "en": "Expected branch separator"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "nonLiteralSwitchCaseLabel": {
      "mensajes": {
        "es": "Las etiquetas del selector múltiple deben ser valores literales",
        "en": "Switch case labels must be literal values"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "duplicateSwitchCaseLabel": {
      "mensajes": {
        "es": "Etiqueta duplicada en el selector múltiple: {lexeme}",
        "en": "Duplicate label in switch statement: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "duplicateDefaultCase": {
      "mensajes": {
        "es": "No puede haber más de una rama por defecto",
        "en": "Cannot have more than one default branch"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "invalidDefaultCasePosition": {
      "mensajes": {
        "es": "La rama por defecto debe ser la última del selector múltiple",
        "en": "Default branch must be the last branch in switch statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedSwitchStatement": {
      "mensajes": {
        "es": "Selector múltiple sin cerrar",
        "en": "Unclosed switch statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedWhileStatement": {
      "mensajes": {
        "es": "Bucle condicional sin cerrar",
        "en": "Unclosed while loop"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedTaskScope": {
      "mensajes": {
        "es": "Ámbito de tareas sin cerrar",
        "en": "Unclosed task scope"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedRepeatStatement": {
      "mensajes": {
        "es": "Bucle de repetición sin cerrar",
        "en": "Unclosed repeat loop"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedForLoopVariable": {
      "mensajes": {
        "es": "Se esperaba la variable de control del bucle contado",
        "en": "Expected control variable for counted loop"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedToKeyword": {
      "mensajes": {
        "es": "Se esperaba el límite final del bucle contado",
        "en": "Expected to keyword for counted loop limit"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "missingStepClause": {
      "mensajes": {
        "es": "Se requiere especificar el paso del bucle contado",
        "en": "Step clause is required in counted loop"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedForStatement": {
      "mensajes": {
        "es": "Bucle contado sin cerrar",
        "en": "Unclosed for loop"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "mismatchedBlockEnd": {
      "mensajes": {
        "es": "El cierre no corresponde a la estructura abierta: {lexeme}",
        "en": "Closing token does not match open block: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unexpectedBlockEnd": {
      "mensajes": {
        "es": "Cierre de estructura sin bloque abierto correspondiente: {lexeme}",
        "en": "Unexpected block closing without matching open block: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unexpectedStatement": {
      "mensajes": {
        "es": "Instrucción o elemento no reconocido: {lexeme}",
        "en": "Unrecognized statement or token: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unsupportedStructuredConstruct": {
      "mensajes": {
        "es": "Instrucción fuera del alcance estructurado: {lexeme}",
        "en": "Construct not supported in structured programming: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "maxDiagnosticsExceeded": {
      "mensajes": {
        "es": "Se ha alcanzado el límite máximo de diagnósticos sintácticos",
        "en": "Maximum limit of syntactic diagnostics exceeded"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedClassName": {
      "mensajes": {
        "es": "Se esperaba el nombre de la clase",
        "en": "Expected class name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedClass": {
      "mensajes": {
        "es": "Clase sin cerrar al final del archivo",
        "en": "Unclosed class at end of file"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "classInsideAlgorithm": {
      "mensajes": {
        "es": "No se permite declarar una clase dentro del cuerpo del algoritmo",
        "en": "Declaring a class inside the algorithm body is not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "classInsideSubroutine": {
      "mensajes": {
        "es": "No se permite declarar una clase dentro de un subprograma",
        "en": "Declaring a class inside a subroutine is not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "nestedClassNotSupported": {
      "mensajes": {
        "es": "No se permite declarar una clase dentro de otra clase",
        "en": "Declaring a class inside another class is not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "subroutineInsideClass": {
      "mensajes": {
        "es": "No se permite declarar un subprograma dentro de una clase; use la declaración de método",
        "en": "Declaring a subroutine inside a class is not allowed; use a method declaration"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "multipleInheritanceNotSupported": {
      "mensajes": {
        "es": "La herencia múltiple no está permitida; solo se admite herencia simple",
        "en": "Multiple inheritance is not allowed; only single inheritance is supported"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "duplicateVisibilityModifier": {
      "mensajes": {
        "es": "No se puede especificar más de un modificador de visibilidad en el mismo miembro",
        "en": "Cannot specify more than one visibility modifier for the same member"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "constructorVisibilityNotAllowed": {
      "mensajes": {
        "es": "El constructor no admite modificador de visibilidad; es siempre público",
        "en": "Constructor does not allow a visibility modifier; it is always public"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "constructorReturnTypeNotAllowed": {
      "mensajes": {
        "es": "El constructor no admite tipo de retorno",
        "en": "Constructor does not allow a return type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "duplicateConstructor": {
      "mensajes": {
        "es": "No se permite más de un constructor en la misma clase",
        "en": "Multiple constructors in the same class are not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "methodNamedAsClass": {
      "mensajes": {
        "es": "Para declarar el constructor use la palabra reservada Constructor en lugar del nombre de la clase",
        "en": "To declare a constructor use the keyword Constructor instead of the class name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "methodOutsideClass": {
      "mensajes": {
        "es": "La declaración de método solo es válida dentro de una clase",
        "en": "Method declaration is only valid inside a class"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "constructorOutsideClass": {
      "mensajes": {
        "es": "El constructor solo es válido dentro de una clase",
        "en": "Constructor is only valid inside a class"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedMethod": {
      "mensajes": {
        "es": "Método sin cerrar al final del archivo",
        "en": "Unclosed method at end of file"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "integerLiteralOutOfRange": {
      "mensajes": {
        "es": "El literal entero {lexeme} está fuera del rango de 64 bits con signo",
        "en": "Integer literal {lexeme} is out of the signed 64-bit range"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "divisionByZero": {
      "mensajes": {
        "es": "División por cero",
        "en": "Division by zero"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "integerOverflow": {
      "mensajes": {
        "es": "La operación produce un entero fuera del rango de 64 bits con signo",
        "en": "The operation produces an integer outside the signed 64-bit range"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "nonFiniteRealResult": {
      "mensajes": {
        "es": "La operación produce un valor real no finito",
        "en": "The operation produces a non-finite real value"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "negativeIntegerExponent": {
      "mensajes": {
        "es": "La potencia entera no admite un exponente negativo: {exponent}",
        "en": "Integer power does not allow a negative exponent: {exponent}"
      },
      "argumentos": [
        "exponent"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "exponent": "entero"
      }
    },
    "arrayIndexOutOfRange": {
      "mensajes": {
        "es": "Índice {index} fuera de rango para un arreglo de tamaño {size}",
        "en": "Index {index} is out of range for an array of size {size}"
      },
      "argumentos": [
        "index",
        "size"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "index": "numero",
        "size": "numero"
      }
    },
    "negativeArraySize": {
      "mensajes": {
        "es": "El tamaño de un arreglo no puede ser negativo: {size}",
        "en": "An array size cannot be negative: {size}"
      },
      "argumentos": [
        "size"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "size": "numero"
      }
    },
    "zeroStepInCountedLoop": {
      "mensajes": {
        "es": "El paso de un bucle contado no puede ser cero",
        "en": "The step of a counted loop cannot be zero"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "recursionDepthExceeded": {
      "mensajes": {
        "es": "Se alcanzó el límite de profundidad de recursión: {limit}",
        "en": "Recursion depth limit reached: {limit}"
      },
      "argumentos": [
        "limit"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "limit": "numero"
      }
    },
    "uninitializedVariableRead": {
      "mensajes": {
        "es": "La variable {lexeme} se lee sin haber sido inicializada",
        "en": "Variable {lexeme} is read without being initialized"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "stringToNumberConversionFailed": {
      "mensajes": {
        "es": "El texto {lexeme} no representa un número",
        "en": "Text {lexeme} does not represent a number"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "stringPositionOutOfRange": {
      "mensajes": {
        "es": "Posición {position} fuera de rango para una cadena de longitud {length}",
        "en": "Position {position} is out of range for a string of length {length}"
      },
      "argumentos": [
        "length",
        "position"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "length": "numero",
        "position": "numero"
      }
    },
    "invalidCharacterCode": {
      "mensajes": {
        "es": "El código {code} no designa ningún punto de código Unicode válido",
        "en": "Code {code} does not designate a valid Unicode code point"
      },
      "argumentos": [
        "code"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "code": "numero"
      }
    },
    "subroutineEndedWithoutReturn": {
      "mensajes": {
        "es": "Un camino de ejecución de {lexeme} llega al cierre sin retornar",
        "en": "An execution path of {lexeme} reaches the end without returning"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "readValueTypeMismatch": {
      "mensajes": {
        "es": "Se esperaba un valor de tipo {expected}, y se recibió {found}",
        "en": "Expected a value of type {expected}, and received {found}"
      },
      "argumentos": [
        "expected",
        "found"
      ],
      "politica": "E",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "expected": "tipo",
        "found": "lexema"
      }
    },
    "privateMemberAccess": {
      "mensajes": {
        "es": "No se puede acceder al miembro privado {lexeme} de la clase {className}",
        "en": "Cannot access private member {lexeme} of class {className}"
      },
      "argumentos": [
        "className",
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "className": "lexema",
        "lexeme": "lexema"
      }
    },
    "expectedAlgorithmStart": {
      "mensajes": {
        "es": "Se esperaba el inicio del algoritmo",
        "en": "Expected algorithm start"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedAlgorithmName": {
      "mensajes": {
        "es": "Se esperaba el nombre del algoritmo",
        "en": "Expected algorithm name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedAlgorithm": {
      "mensajes": {
        "es": "Algoritmo sin cerrar al final del archivo",
        "en": "Unclosed algorithm at end of file"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unexpectedTokenOutsideAlgorithm": {
      "mensajes": {
        "es": "Elemento inesperado fuera del algoritmo: {lexeme}",
        "en": "Unexpected token outside algorithm: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "missingStatementTerminator": {
      "mensajes": {
        "es": "Se esperaba un punto y coma al final de la sentencia",
        "en": "Expected a semicolon at the end of the statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedIdentifierInDeclaration": {
      "mensajes": {
        "es": "Se esperaba al menos una variable para declarar",
        "en": "Expected at least one variable to declare"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "reservedLexemeUsedAsName": {
      "mensajes": {
        "es": "«{lexeme}» es una palabra reservada de este perfil, equivalente a {token}. Elegí otro nombre.",
        "en": "\"{lexeme}\" is a reserved word in this profile, equivalent to {token}. Choose another name."
      },
      "argumentos": [
        "lexeme",
        "token"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema",
        "token": "token"
      }
    },
    "expectedTypeConnector": {
      "mensajes": {
        "es": "Se esperaba la palabra de tipo",
        "en": "Expected type connector"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedType": {
      "mensajes": {
        "es": "Se esperaba un tipo de dato primitivo",
        "en": "Expected a primitive data type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "initializationInDeclarationNotAllowed": {
      "mensajes": {
        "es": "La declaración de variables no admite asignación de valor inicial",
        "en": "Variable declaration does not support initial value assignment"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedIdentifierInDimension": {
      "mensajes": {
        "es": "Se esperaba el nombre del arreglo a dimensionar",
        "en": "Expected array name to dimension"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "emptyDimensionList": {
      "mensajes": {
        "es": "El dimensionamiento requiere al menos una dimensión",
        "en": "Dimension declaration requires at least one dimension"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "invalidAssignmentTarget": {
      "mensajes": {
        "es": "El destino de la asignación no es una variable o elemento válido",
        "en": "Assignment target is not a valid variable or array element"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedAssignmentOperator": {
      "mensajes": {
        "es": "Se esperaba el operador de asignación",
        "en": "Expected assignment operator"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedReadTarget": {
      "mensajes": {
        "es": "La sentencia de lectura requiere al menos una variable",
        "en": "Read statement requires at least one variable"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "invalidReadTarget": {
      "mensajes": {
        "es": "El elemento a leer no es una variable o elemento válido",
        "en": "Read target is not a valid variable or array element"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unexpectedModifierPosition": {
      "mensajes": {
        "es": "El modificador sin salto debe colocarse al final de la sentencia",
        "en": "Without newline modifier must be placed at the end of the statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "duplicateModifier": {
      "mensajes": {
        "es": "Modificador duplicado",
        "en": "Duplicate modifier"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedClassNameInInstantiation": {
      "mensajes": {
        "es": "Se esperaba el nombre de la clase tras la palabra reservada Nuevo",
        "en": "Expected class name after keyword new"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "missingInstantiationParentheses": {
      "mensajes": {
        "es": "La instanciación requiere paréntesis con o sin argumentos",
        "en": "Instantiation requires parentheses with or without arguments"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedMemberNameAfterDot": {
      "mensajes": {
        "es": "Se esperaba un nombre de miembro tras el operador de acceso punto",
        "en": "Expected member name after dot access operator"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "thisOutsideMethod": {
      "mensajes": {
        "es": "La palabra reservada Este solo es válida dentro de un método o constructor",
        "en": "Keyword this is only valid inside a method or constructor"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedMemberNameAfterThis": {
      "mensajes": {
        "es": "La palabra reservada Este debe ir seguida de un acceso a miembro (.nombre)",
        "en": "Keyword this must be followed by a member access (.name)"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "superOutsideMethod": {
      "mensajes": {
        "es": "La palabra reservada Super solo es válida dentro de un método o constructor",
        "en": "Keyword super is only valid inside a method or constructor"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "superInClassWithoutSuperclass": {
      "mensajes": {
        "es": "No se puede usar Super en una clase que no hereda de ninguna superclase",
        "en": "Cannot use super in a class that does not inherit from any superclass"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "superNotFollowedByCall": {
      "mensajes": {
        "es": "La palabra reservada Super solo puede usarse como destino de llamada a método o constructor",
        "en": "Keyword super can only be used as target of a method or constructor call"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unsupportedInterfaceConstruct": {
      "mensajes": {
        "es": "Las interfaces no forman parte de PseudoLearn",
        "en": "Interfaces are not supported in PseudoLearn"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unsupportedAbstractConstruct": {
      "mensajes": {
        "es": "Las clases y métodos abstractos no forman parte de PseudoLearn",
        "en": "Abstract classes and methods are not supported in PseudoLearn"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unsupportedStaticConstruct": {
      "mensajes": {
        "es": "Los miembros estáticos no forman parte de PseudoLearn",
        "en": "Static members are not supported in PseudoLearn"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unsupportedProtectedConstruct": {
      "mensajes": {
        "es": "La visibilidad protegida no forma parte de PseudoLearn; use Publico o Privado",
        "en": "Protected visibility is not supported in PseudoLearn; use public or private"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unsupportedGenericsConstruct": {
      "mensajes": {
        "es": "Los tipos genéricos no forman parte de PseudoLearn",
        "en": "Generic types are not supported in PseudoLearn"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unsupportedExceptionConstruct": {
      "mensajes": {
        "es": "El manejo de excepciones estructurado no forma parte de PseudoLearn",
        "en": "Structured exception handling is not supported in PseudoLearn"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "undeclaredVariable": {
      "mensajes": {
        "es": "Variable no declarada: {lexeme}",
        "en": "Undeclared variable: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "variableUsedBeforeDeclaration": {
      "mensajes": {
        "es": "La variable {lexeme} se usa antes de su declaración",
        "en": "Variable {lexeme} is used before its declaration"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "pureFunctionSideEffect": {
      "mensajes": {
        "es": "Una función pura no puede realizar efectos de entrada/salida ni invocar capacidades",
        "en": "A pure function cannot perform I/O effects or invoke capabilities"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "pureFunctionTransitiveSideEffect": {
      "mensajes": {
        "es": "Una función pura no puede invocar subprogramas o clausuras con efectos secundarios",
        "en": "A pure function cannot invoke subroutines or closures with side effects"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "pureFunctionInterfaceImpurity": {
      "mensajes": {
        "es": "La realización de un método puro de interfaz no puede tener efectos secundarios",
        "en": "The implementation of a pure interface method cannot have side effects"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "duplicateVariableDeclaration": {
      "mensajes": {
        "es": "Declaración duplicada de la variable {lexeme} en el mismo ámbito",
        "en": "Duplicate declaration of variable {lexeme} in the same scope"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "duplicateParameterName": {
      "mensajes": {
        "es": "Parámetro duplicado: {lexeme}",
        "en": "Duplicate parameter name: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "duplicateSubroutine": {
      "mensajes": {
        "es": "Declaración duplicada del subprograma {lexeme}",
        "en": "Duplicate declaration of subroutine {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "moduleSyntaxOutsideProject": {
      "mensajes": {
        "es": "Importar, Exportar y la visibilidad de unidades solo se admiten dentro de un proyecto",
        "en": "Import, export and unit visibility are only allowed inside a project"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "expectedModuleName": {
      "mensajes": {
        "es": "Se esperaba un nombre de módulo",
        "en": "Expected a module name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unresolvedModule": {
      "mensajes": {
        "es": "No se encontró el módulo {lexeme}",
        "en": "Module {lexeme} was not found"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unresolvedImport": {
      "mensajes": {
        "es": "El módulo no exporta {lexeme}",
        "en": "The module does not export {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "privateImport": {
      "mensajes": {
        "es": "{lexeme} es privado en su módulo",
        "en": "{lexeme} is private in its module"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "privateReexport": {
      "mensajes": {
        "es": "No se puede reexportar {lexeme}: es privado",
        "en": "Cannot re-export {lexeme}: it is private"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "ambiguousReexport": {
      "mensajes": {
        "es": "El nombre exportado {lexeme} es ambiguo",
        "en": "The exported name {lexeme} is ambiguous"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "importCycle": {
      "mensajes": {
        "es": "Las importaciones forman un ciclo: {lexeme}",
        "en": "The imports form a cycle: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "profileMismatch": {
      "mensajes": {
        "es": "El perfil configurado no coincide con el que declara el archivo: {lexeme}",
        "en": "The configured profile does not match the one the file declares: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "reservedImportNeedsAlias": {
      "mensajes": {
        "es": "El nombre importado {lexeme} es una palabra reservada de este perfil y necesita un alias",
        "en": "The imported name {lexeme} is a reserved word of this profile and needs an alias"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "importNameCollision": {
      "mensajes": {
        "es": "El nombre {lexeme} ya está en uso en este módulo",
        "en": "The name {lexeme} is already in use in this module"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "entryMissingAlgorithm": {
      "mensajes": {
        "es": "El módulo de entrada no contiene un algoritmo",
        "en": "The entry module does not contain an algorithm"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "algorithmOutsideEntry": {
      "mensajes": {
        "es": "Solo el módulo de entrada puede contener un algoritmo",
        "en": "Only the entry module can contain an algorithm"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "duplicateClass": {
      "mensajes": {
        "es": "Declaración duplicada de la clase {lexeme}",
        "en": "Duplicate declaration of class {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "classAndSubroutineSameName": {
      "mensajes": {
        "es": "Conflicto de nombres: la clase y el subprograma no pueden llamarse {lexeme}",
        "en": "Name conflict: class and subroutine cannot both be named {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "subroutineAndVariableSameName": {
      "mensajes": {
        "es": "La variable {lexeme} no puede llamarse igual que un subprograma en el mismo ámbito",
        "en": "Variable {lexeme} cannot have the same name as a subroutine in the same scope"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "undeclaredSubroutine": {
      "mensajes": {
        "es": "Subprograma no declarado: {lexeme}",
        "en": "Undeclared subroutine: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "undeclaredClass": {
      "mensajes": {
        "es": "Clase no declarada: {lexeme}",
        "en": "Undeclared class: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "undeclaredSuperclass": {
      "mensajes": {
        "es": "La superclase {lexeme} no está declarada",
        "en": "Superclass {lexeme} is not declared"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "circularInheritance": {
      "mensajes": {
        "es": "Herencia circular detectada en la clase {lexeme}",
        "en": "Circular inheritance detected in class {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "duplicateMember": {
      "mensajes": {
        "es": "Miembro duplicado {lexeme} en la clase",
        "en": "Duplicate member {lexeme} in class"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "inheritedAttributeShadowed": {
      "mensajes": {
        "es": "El atributo {lexeme} ya está declarado en una superclase",
        "en": "Attribute {lexeme} is already declared in a superclass"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "incompatibleMethodOverride": {
      "mensajes": {
        "es": "La firma del método sobrescrito {lexeme} no coincide con la de la superclase",
        "en": "Overridden method {lexeme} signature does not match superclass method"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "missingSuperConstructorCall": {
      "mensajes": {
        "es": "Falta la invocación obligatoria al constructor de la superclase",
        "en": "Missing required call to superclass constructor"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "invalidSuperConstructorCallPosition": {
      "mensajes": {
        "es": "La invocación al constructor de la superclase debe ser la primera sentencia",
        "en": "Call to superclass constructor must be the first statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "returnWithValueInConstructor": {
      "mensajes": {
        "es": "Un constructor no puede retornar un valor",
        "en": "A constructor cannot return a value"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "identifierMatchesFieldWithoutThis": {
      "mensajes": {
        "es": "Acceso a atributo no calificado; use Este.{lexeme}",
        "en": "Unqualified field access; use this.{lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "undefinedMember": {
      "mensajes": {
        "es": "Miembro no definido: {lexeme}",
        "en": "Undefined member: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "variableDeclaredNeverUsed": {
      "mensajes": {
        "es": "Variable declarada y nunca usada: {lexeme}",
        "en": "Variable declared but never used: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "variableAssignedNeverRead": {
      "mensajes": {
        "es": "Variable asignada pero nunca leída: {lexeme}",
        "en": "Variable assigned but never read: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unusedParameter": {
      "mensajes": {
        "es": "Parámetro nunca usado: {lexeme}",
        "en": "Parameter never used: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unusedSubroutine": {
      "mensajes": {
        "es": "Subprograma declarado pero nunca llamado: {lexeme}",
        "en": "Subroutine declared but never called: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unrecognizedCharacter": {
      "mensajes": {
        "es": "Carácter no reconocido: {lexeme}",
        "en": "Unrecognized character: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "lexical",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unterminatedString": {
      "mensajes": {
        "es": "Cadena de texto sin cerrar",
        "en": "Unterminated string literal"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "lexical",
      "tipos_argumentos": {}
    },
    "invalidEscapeSequence": {
      "mensajes": {
        "es": "Secuencia de escape no válida: {lexeme}",
        "en": "Invalid escape sequence: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "lexical",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "expectedExpression": {
      "mensajes": {
        "es": "Se esperaba una expresión",
        "en": "Expected an expression"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unexpectedTokenInExpression": {
      "mensajes": {
        "es": "Elemento inesperado en la expresión: {lexeme}",
        "en": "Unexpected token in expression: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unclosedParenthesis": {
      "mensajes": {
        "es": "Paréntesis de apertura sin cerrar",
        "en": "Unclosed opening parenthesis"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unexpectedClosingParenthesis": {
      "mensajes": {
        "es": "Paréntesis de cierre inesperado",
        "en": "Unexpected closing parenthesis"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "emptyParentheses": {
      "mensajes": {
        "es": "Los paréntesis no pueden estar vacíos",
        "en": "Parentheses cannot be empty"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedBracket": {
      "mensajes": {
        "es": "Corchete de apertura sin cerrar",
        "en": "Unclosed opening bracket"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "emptyIndexList": {
      "mensajes": {
        "es": "El acceso a arreglo requiere al menos un índice",
        "en": "Array access requires at least one index"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "trailingComma": {
      "mensajes": {
        "es": "Coma sobrante",
        "en": "Trailing comma"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "chainedArrayAccess": {
      "mensajes": {
        "es": "El acceso multidimensional encadenado no está permitido; use corchetes con comas",
        "en": "Chained multidimensional array access is not allowed; use single brackets with commas"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "incompatibleTypesInAssignment": {
      "mensajes": {
        "es": "Tipo incompatible en la asignación: no se puede asignar {found} a {expected}",
        "en": "Incompatible types in assignment: cannot assign {found} to {expected}"
      },
      "argumentos": [
        "expected",
        "found"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "expected": "tipo|lexema",
        "found": "tipo|lexema"
      }
    },
    "incompatibleOperandTypes": {
      "mensajes": {
        "es": "Tipos incompatibles para el operador {lexeme}",
        "en": "Incompatible types for operator {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "cannotConcatenateNumberWithText": {
      "mensajes": {
        "es": "No se puede concatenar un número con texto; use la función de conversión o separe las expresiones con coma",
        "en": "Cannot concatenate number with text; use conversion function or separate expressions with comma"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "divOrModWithRealOperand": {
      "mensajes": {
        "es": "Los operadores div y mod solo admiten enteros; use truncamiento o redondeo para valores reales",
        "en": "The div and mod operators only accept integers; use trunc or round for real values"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "noOrderBetweenBooleans": {
      "mensajes": {
        "es": "Los operadores relacionales de orden no están permitidos entre valores lógicos",
        "en": "Relational order operators are not permitted between boolean values"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "realEqualityComparison": {
      "mensajes": {
        "es": "Comparación de igualdad entre valores reales; los errores de precisión pueden producir resultados inesperados",
        "en": "Equality comparison between real values; precision errors may yield unexpected results"
      },
      "argumentos": [],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "argumentCountMismatch": {
      "mensajes": {
        "es": "Número incorrecto de argumentos: se esperaban {expected} pero se encontraron {found}",
        "en": "Incorrect number of arguments: expected {expected} but found {found}"
      },
      "argumentos": [
        "expected",
        "found"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "expected": "numero",
        "found": "numero"
      }
    },
    "incompatibleArgumentType": {
      "mensajes": {
        "es": "Tipo de argumento incompatible para el parámetro {lexeme}",
        "en": "Incompatible argument type for parameter {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "byReferenceArgumentRequiresDesignator": {
      "mensajes": {
        "es": "Un argumento pasado por referencia debe ser una variable o elemento de arreglo",
        "en": "An argument passed by reference must be a variable or array element"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "byReferenceArgumentTypeMismatch": {
      "mensajes": {
        "es": "El tipo del argumento pasado por referencia a {lexeme} debe coincidir exactamente con el parámetro",
        "en": "The type of argument passed by reference to {lexeme} must match parameter type exactly"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "incompatibleReturnType": {
      "mensajes": {
        "es": "El tipo de la expresión retornada no coincide con el tipo de retorno declarado",
        "en": "The returned expression type does not match the declared return type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "returnExpressionInVoidSubroutine": {
      "mensajes": {
        "es": "Un subprograma o método sin tipo de retorno no puede retornar un valor",
        "en": "A subroutine or method with no return type cannot return a value"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "missingReturnExpression": {
      "mensajes": {
        "es": "Se esperaba una expresión en la sentencia de retorno",
        "en": "Expected an expression in the return statement"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "subroutineWithoutReturn": {
      "mensajes": {
        "es": "El subprograma {lexeme} declara tipo de retorno pero su cuerpo no contiene ninguna sentencia Retornar",
        "en": "Subroutine {lexeme} declares a return type but its body contains no return statement"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "callAsExpressionWithoutReturnType": {
      "mensajes": {
        "es": "El subprograma {lexeme} no devuelve ningún valor y no puede usarse dentro de una expresión",
        "en": "Subroutine {lexeme} does not return a value and cannot be used in an expression"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "discardedReturnValue": {
      "mensajes": {
        "es": "Se descarta el valor devuelto por el subprograma {lexeme}",
        "en": "Return value from subroutine {lexeme} is discarded"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "nonBooleanCondition": {
      "mensajes": {
        "es": "La condición debe ser una expresión de tipo Lógico",
        "en": "Condition must be a boolean expression"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "nonIntegerForBound": {
      "mensajes": {
        "es": "La variable de control y los límites del bucle Para deben ser de tipo Entero",
        "en": "For loop control variable and bounds must be of integer type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "nonIntegerArrayIndex": {
      "mensajes": {
        "es": "El índice del arreglo debe ser de tipo Entero",
        "en": "Array index must be of integer type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "arrayDimensionCountMismatch": {
      "mensajes": {
        "es": "Número de índices incorrecto para el arreglo {lexeme}",
        "en": "Incorrect number of indices for array {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "arrayCannotBeUsedAsValue": {
      "mensajes": {
        "es": "Un arreglo no puede usarse como valor escalar en una expresión o asignación",
        "en": "An array cannot be used as a scalar value in an expression or assignment"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "objectCannotBeWritten": {
      "mensajes": {
        "es": "No se puede escribir un objeto directamente en la salida; acceda a sus atributos",
        "en": "Cannot write an object directly to output; access its attributes"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "incompatibleSwitchCaseType": {
      "mensajes": {
        "es": "El tipo de la etiqueta del caso no es compatible con el selector",
        "en": "Case label type is not compatible with switch selector"
      },
      "argumentos": [],
      "politica": "B",
      "severidad": {
        "estricto": "error",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "inferredVariableType": {
      "mensajes": {
        "es": "Tipo inferido para {lexeme}: {type}",
        "en": "Inferred type for {lexeme}: {type}"
      },
      "argumentos": [
        "lexeme",
        "type"
      ],
      "politica": "D",
      "severidad": {
        "estricto": "info",
        "flexible": "info"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema",
        "type": "tipo"
      }
    },
    "widenedVariableType": {
      "mensajes": {
        "es": "Tipo de {lexeme} ampliado de Entero a Real",
        "en": "Type of {lexeme} widened from Integer to Real"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "D",
      "severidad": {
        "estricto": "info",
        "flexible": "info"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "typeConflictOnInferredVariable": {
      "mensajes": {
        "es": "Conflicto de tipos para la variable {lexeme}: no se puede reasignar a un tipo incompatible",
        "en": "Type conflict for variable {lexeme}: cannot reassign to incompatible type"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "variableUsedUninitialized": {
      "mensajes": {
        "es": "La variable {lexeme} se usa sin haber sido inicializada",
        "en": "Variable {lexeme} is used without being initialized"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "controlVariableModified": {
      "mensajes": {
        "es": "La variable de control {lexeme} se modifica dentro del bucle",
        "en": "Control variable {lexeme} is modified inside the loop"
      },
      "argumentos": [
        "lexeme"
      ],
      "tipos_argumentos": {
        "lexeme": "lexema"
      },
      "clase": "semantic",
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      }
    },
    "cellLimitExceeded": {
      "mensajes": {
        "es": "Se alcanzó el límite de memoria: {limit} celdas",
        "en": "Memory limit reached: {limit} cells"
      },
      "argumentos": [
        "limit"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "limit": "numero"
      }
    },
    "statementBudgetExhausted": {
      "mensajes": {
        "es": "Se agotó el presupuesto de sentencias: {limit}",
        "en": "Statement budget exhausted: {limit}"
      },
      "argumentos": [
        "limit"
      ],
      "politica": "D",
      "severidad": {
        "estricto": "info",
        "flexible": "info"
      },
      "clase": "runtime",
      "tipos_argumentos": {
        "limit": "numero"
      }
    },
    "analysisNestingLimitExceeded": {
      "mensajes": {
        "es": "Se superó el límite de anidación del análisis: {limit}",
        "en": "Analysis nesting limit exceeded: {limit}"
      },
      "argumentos": [
        "limit"
      ],
      "clase": "syntax",
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "tipos_argumentos": {
        "limit": "numero"
      }
    },
    "constantNotEvaluable": {
      "mensajes": {
        "es": "El valor de la constante {lexeme} no se puede calcular al analizar el programa",
        "en": "The value of constant {lexeme} cannot be computed when the program is analyzed"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "constantArithmeticOverflow": {
      "mensajes": {
        "es": "El cálculo de la constante {lexeme} desborda el rango permitido",
        "en": "Computing constant {lexeme} overflows the allowed range"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "constantDivisionByZero": {
      "mensajes": {
        "es": "El cálculo de la constante {lexeme} divide entre cero",
        "en": "Computing constant {lexeme} divides by zero"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "circularConstantDefinition": {
      "mensajes": {
        "es": "La constante {lexeme} depende de sí misma",
        "en": "Constant {lexeme} depends on itself"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "constantBudgetExceeded": {
      "mensajes": {
        "es": "El cálculo de la constante {lexeme} supera el presupuesto permitido",
        "en": "Computing constant {lexeme} exceeds the allowed budget"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "constantReassigned": {
      "mensajes": {
        "es": "La constante {lexeme} no admite asignación",
        "en": "Constant {lexeme} cannot be assigned"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "duplicateTypeDeclaration": {
      "mensajes": {
        "es": "El tipo {lexeme} ya está declarado",
        "en": "Type {lexeme} is already declared"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "duplicateEnumMember": {
      "mensajes": {
        "es": "El miembro {lexeme} está repetido en el enumerado",
        "en": "Member {lexeme} is repeated in the enumeration"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "undefinedEnumMember": {
      "mensajes": {
        "es": "El enumerado no tiene el miembro {lexeme}",
        "en": "The enumeration has no member {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "recursiveRecordContainment": {
      "mensajes": {
        "es": "El registro {lexeme} se contiene a sí mismo por valor",
        "en": "Record {lexeme} contains itself by value"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "recordCannotBeWritten": {
      "mensajes": {
        "es": "Un registro no se puede escribir directamente",
        "en": "A record cannot be written directly"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "recordPassedByReference": {
      "mensajes": {
        "es": "El registro {lexeme} no se puede pasar por referencia",
        "en": "Record {lexeme} cannot be passed by reference"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "recordArrayElementNotSupported": {
      "mensajes": {
        "es": "Un arreglo no puede tener registros como elementos",
        "en": "An array cannot have records as elements"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "recordClassFieldNotSupported": {
      "mensajes": {
        "es": "El campo {lexeme} de una clase no puede ser un registro",
        "en": "Field {lexeme} of a class cannot be a record"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "recordWithoutFields": {
      "mensajes": {
        "es": "El registro {lexeme} debe tener al menos un campo",
        "en": "Record {lexeme} must have at least one field"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "expectedConstantName": {
      "mensajes": {
        "es": "Se esperaba el nombre de la constante",
        "en": "Expected constant name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedConstantInitializer": {
      "mensajes": {
        "es": "La constante necesita un valor inicial",
        "en": "A constant needs an initial value"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedEnumName": {
      "mensajes": {
        "es": "Se esperaba el nombre del enumerado",
        "en": "Expected enumeration name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedEnumMember": {
      "mensajes": {
        "es": "Se esperaba un miembro del enumerado",
        "en": "Expected an enumeration member"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedEnum": {
      "mensajes": {
        "es": "Enumerado sin cerrar al final del archivo",
        "en": "Unclosed enumeration at end of file"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedRecordName": {
      "mensajes": {
        "es": "Se esperaba el nombre del registro",
        "en": "Expected record name"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedRecordField": {
      "mensajes": {
        "es": "Un registro solo contiene declaraciones de campo",
        "en": "A record only contains field declarations"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedRecord": {
      "mensajes": {
        "es": "Registro sin cerrar al final del archivo",
        "en": "Unclosed record at end of file"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "recordMemberSignatureNotSupported": {
      "mensajes": {
        "es": "Un método o constructor no puede recibir ni devolver registros",
        "en": "A method or constructor cannot receive or return records"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "recordNotInferable": {
      "mensajes": {
        "es": "La variable {lexeme} debe declararse con su tipo para guardar un registro",
        "en": "Variable {lexeme} must be declared with its type to hold a record"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "internalFault": {
      "mensajes": {
        "es": "Fallo interno del motor",
        "en": "Internal engine fault"
      },
      "argumentos": [],
      "clase": "internal",
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "tipos_argumentos": {}
    },
    "missingBindingInitializer": {
      "mensajes": {
        "es": "El vínculo necesita un inicializador; añadí <- expresión",
        "en": "Binding requires an initializer; add <- expression"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "immutableBindingAssignment": {
      "mensajes": {
        "es": "El vínculo es inmutable; usá Definir Mutable para reasignarlo",
        "en": "Binding is immutable; use define mutable to reassign it"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "mutableBindingNeverModified": {
      "mensajes": {
        "es": "El vínculo mutable nunca se modifica",
        "en": "Mutable binding is never modified"
      },
      "argumentos": [],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "bindingReadsOwnInitializer": {
      "mensajes": {
        "es": "El inicializador lee el vínculo que está declarando",
        "en": "Initializer reads its own binding"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "nonExhaustiveSwitch": {
      "mensajes": {
        "es": "Faltan ramas: {lexeme}",
        "en": "Missing branches: {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "unreachableSwitchPattern": {
      "mensajes": {
        "es": "El patrón es inalcanzable",
        "en": "Pattern is unreachable"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "ambiguousVariantType": {
      "mensajes": {
        "es": "La variante necesita un tipo Opcional o Resultado explícito en su contexto",
        "en": "Variant requires an explicit optional or result type in its context"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "incompatibleVariantConstructor": {
      "mensajes": {
        "es": "El constructor no pertenece al tipo de variante esperado",
        "en": "Constructor does not belong to the expected variant type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "incompatiblePropagationType": {
      "mensajes": {
        "es": "La propagación requiere un retorno compatible y el mismo tipo de error",
        "en": "Propagation requires a compatible return and the same error type"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "resultNotHandled": {
      "mensajes": {
        "es": "Resultado de tipo {type} sin tratar: manejalo con Segun, propagalo o descartalo explícitamente",
        "en": "Unhandled result of type {type}: handle it with switch, propagate it, or discard it explicitly"
      },
      "argumentos": [
        "type"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "type": "tipo"
      }
    },
    "discardRequiresResult": {
      "mensajes": {
        "es": "Descartar requiere un Resultado",
        "en": "Discard requires a result"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "variantRequiresPattern": {
      "mensajes": {
        "es": "La variante se consulta mediante patrones de Segun",
        "en": "Variant must be inspected through switch patterns"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "variantLayoutLimit": {
      "mensajes": {
        "es": "La disposición de la variante supera el límite de operandos",
        "en": "Variant layout exceeds the operand limit"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "bindingOutsideScope": {
      "mensajes": {
        "es": "La declaración de {lexeme} está fuera de ámbito",
        "en": "Declaration of {lexeme} is outside its scope"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "bindingShadowsOuter": {
      "mensajes": {
        "es": "La declaración de {lexeme} oculta un vínculo exterior",
        "en": "Declaration of {lexeme} shadows an outer binding"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "C",
      "severidad": {
        "estricto": "warning",
        "flexible": "warning"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "mutableClosureCapture": {
      "mensajes": {
        "es": "No se puede capturar el vínculo mutable o prestado {lexeme} de tipo {type}",
        "en": "Cannot capture mutable or borrowed binding {lexeme} of type {type}"
      },
      "argumentos": [
        "lexeme",
        "type"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema",
        "type": "tipo"
      }
    },
    "invalidFunctionReference": {
      "mensajes": {
        "es": "La referencia de función no corresponde a una firma válida",
        "en": "Function reference does not match a valid signature"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "closureEnvironmentTooLarge": {
      "mensajes": {
        "es": "El entorno de la clausura excede el límite de representación",
        "en": "Closure environment exceeds its representation limit"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "typeArgumentCountMismatch": {
      "mensajes": {
        "es": "El tipo {lexeme} espera {expected} argumentos de tipo pero recibió {found}",
        "en": "Type {lexeme} expects {expected} type arguments but received {found}"
      },
      "argumentos": [
        "lexeme",
        "expected",
        "found"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema",
        "expected": "numero",
        "found": "numero"
      }
    },
    "cannotInferTypeArgument": {
      "mensajes": {
        "es": "No se puede inferir de forma única el argumento de tipo {lexeme}",
        "en": "Cannot infer a unique type argument {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "genericInstanceLimitExceeded": {
      "mensajes": {
        "es": "El genérico {lexeme} excede el límite de {limit} instancias",
        "en": "Generic {lexeme} exceeds the limit of {limit} instances"
      },
      "argumentos": [
        "lexeme",
        "limit"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema",
        "limit": "numero"
      }
    },
    "interfaceInsideAlgorithm": {
      "mensajes": {
        "es": "No se permite declarar una interfaz dentro del cuerpo de una unidad",
        "en": "An interface cannot be declared inside a unit body"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "unclosedInterface": {
      "mensajes": {
        "es": "Interfaz sin cerrar",
        "en": "Unclosed interface"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "expectedInterfaceSignature": {
      "mensajes": {
        "es": "Se esperaba una firma de método sin cuerpo",
        "en": "Expected a method signature without a body"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "interfaceCannotBeValue": {
      "mensajes": {
        "es": "Una interfaz solo puede usarse como restricción de un parámetro de tipo",
        "en": "An interface can only constrain a type parameter"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "unknownInterface": {
      "mensajes": {
        "es": "La interfaz {lexeme} no está declarada",
        "en": "Interface {lexeme} is not declared"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "interfaceMethodMissing": {
      "mensajes": {
        "es": "Falta realizar el método {lexeme}",
        "en": "Missing implementation of method {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "interfaceMethodSignatureMismatch": {
      "mensajes": {
        "es": "La firma del método {lexeme} no satisface la interfaz",
        "en": "The signature of method {lexeme} does not satisfy the interface"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "interfaceMethodNotPublic": {
      "mensajes": {
        "es": "El método realizado {lexeme} debe ser público",
        "en": "Implemented method {lexeme} must be public"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "genericConstraintNotSatisfied": {
      "mensajes": {
        "es": "El argumento de tipo no realiza la interfaz {lexeme}",
        "en": "The type argument does not implement interface {lexeme}"
      },
      "argumentos": [
        "lexeme"
      ],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {
        "lexeme": "lexema"
      }
    },
    "invalidDictionaryKeyType": {
      "mensajes": {
        "es": "El tipo de clave del diccionario no está permitido",
        "en": "The dictionary key type is not allowed"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "missingDictionaryKey": {
      "mensajes": {
        "es": "La clave no existe en el diccionario",
        "en": "The key does not exist in the dictionary"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "collectionLimitExceeded": {
      "mensajes": {
        "es": "Se superó el límite de elementos o bytes de la colección",
        "en": "Collection element or byte limit exceeded"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "collectionVersionExhausted": {
      "mensajes": {
        "es": "Se agotó la versión estructural de la colección",
        "en": "Collection structural version exhausted"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "collectionModifiedDuringIteration": {
      "mensajes": {
        "es": "La colección cambió de estructura durante la iteración",
        "en": "The collection was structurally modified during iteration"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "runtime",
      "tipos_argumentos": {}
    },
    "collectionCannotBeWritten": {
      "mensajes": {
        "es": "Los elementos de la colección no tienen formato de salida",
        "en": "Collection elements have no output representation"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "invalidForEachCollection": {
      "mensajes": {
        "es": "Para Cada necesita Vector, Diccionario o arreglo unidimensional",
        "en": "For each requires a vector, dictionary, or one-dimensional array"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "invalidForEachBindings": {
      "mensajes": {
        "es": "La cantidad de vínculos no corresponde a la colección",
        "en": "The binding count does not match the collection"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "breakOutsideLoop": {
      "mensajes": {
        "es": "Salir solo es válido dentro de un bucle",
        "en": "Break is only valid inside a loop"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "controlTransferInsideCleanup": {
      "mensajes": {
        "es": "No se permite salir ni registrar otra limpieza dentro de una limpieza",
        "en": "A cleanup cannot transfer control or register another cleanup"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "unclosedDefer": {
      "mensajes": {
        "es": "Bloque Diferir sin cerrar",
        "en": "Unclosed defer block"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "syntax",
      "tipos_argumentos": {}
    },
    "suspendibleModifierNotAllowed": {
      "mensajes": {
        "es": "El modificador Suspendible no se admite en esta declaración",
        "en": "The suspendable modifier is not allowed on this declaration"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "suspendibleAsValue": {
      "mensajes": {
        "es": "Una unidad suspendible no se puede usar como valor",
        "en": "A suspendable subprogram cannot be used as a value"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "awaitOutsideSuspendible": {
      "mensajes": {
        "es": "Aguardar solo se permite en una unidad suspendible o raíz",
        "en": "Await is only allowed in a suspendable subprogram or root unit"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "awaitInsideDefer": {
      "mensajes": {
        "es": "Aguardar no se permite dentro de Diferir",
        "en": "Await is not allowed inside defer"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "awaitOperandInvalid": {
      "mensajes": {
        "es": "Aguardar requiere una operación suspendible o un asa de tarea",
        "en": "Await requires a suspendable operation or task handle"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "suspendibleCallWithoutAwait": {
      "mensajes": {
        "es": "La llamada a una unidad suspendible debe llevar Aguardar",
        "en": "A call to a suspendable subprogram must use await"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "spawnOutsideTaskScope": {
      "mensajes": {
        "es": "Lanzar solo se permite en el cuerpo léxico directo de Tareas",
        "en": "Spawn is only allowed in the direct lexical body of tasks"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "taskScopeInsideDefer": {
      "mensajes": {
        "es": "Tareas y Lanzar no se permiten dentro de Diferir",
        "en": "Tasks and spawn are not allowed inside defer"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "taskArgumentNotTransferable": {
      "mensajes": {
        "es": "El argumento de tarea no se puede transferir de forma aislada",
        "en": "The task argument cannot be transferred in isolation"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "taskByReferenceArgument": {
      "mensajes": {
        "es": "Un argumento de tarea no puede pasarse por referencia",
        "en": "A task argument cannot be passed by reference"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "taskHandleEscape": {
      "mensajes": {
        "es": "El asa de tarea solo se puede usar con Aguardar en su ámbito",
        "en": "A task handle can only be awaited within its scope"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    },
    "spawnTargetNotSuspendible": {
      "mensajes": {
        "es": "Lanzar requiere el nombre de una unidad suspendible",
        "en": "Spawn requires the name of a suspendable subprogram"
      },
      "argumentos": [],
      "politica": "A",
      "severidad": {
        "estricto": "error",
        "flexible": "error"
      },
      "clase": "semantic",
      "tipos_argumentos": {}
    }
  }
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "D1 declara códigos, clases, políticas, argumentos y plantillas bilingües. Cada código tiene ficha completa, iguales marcadores en español e inglés y severidad en ambos rigores. Identidades de código son independientes del idioma; la exportación es fuente del catálogo consumidor. Las situaciones adicionales normadas por reglas de lenguaje se registran con ficha propia, sin reutilizar códigos genéricos.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1 / 0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 / 0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

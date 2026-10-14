# Índice del lenguaje vigente

El comportamiento normativo vive en el corpus ejecutable de PseudoLearn. Este índice conserva la correspondencia de todas las secciones y la proyección educativa; no introduce reglas adicionales.

## Estado por sección

La columna **Proyectada en** declara en qué documento de la especificación publicada de la base de
conocimiento —ESP-I, ESP-O, o ninguno— se proyecta cada sección normativa —nombrando entre acentos
graves el identificador de esa sección publicada—. El cumplimiento se valida mediante el test de
cobertura uno a uno de invariantes de contenido. Una sección marcada «No se proyecta» es prosa
dirigida a quien implementa el motor, no material publicable.

| Sección                                    | Estado                                              | Proyectada en                                        |
|--------------------------------------------|-----------------------------------------------------|------------------------------------------------------|
| 1. Convenciones de la especificación       | Especificado                                        | No se proyecta — metanotación interna                |
| 2. Modelo de perfil                        | Especificado                                        | No se proyecta — dato de perfil, no de contenido     |
| 3. Estructura léxica                       | Especificado                                        | `esp-i-lexico` · publicada (CON-F18)                 |
| 4. Tipos primitivos                        | Especificado                                        | `esp-i-tipos-primitivos` · publicada (CON-F6)        |
| 5. Operadores, precedencia y asociatividad | Especificado                                        | `esp-i-operadores` · publicada (CON-F6)              |
| 6. Declaración y asignación                | Especificado                                        | `esp-i-declaracion` · publicada (CON-F6)             |
| 7. Entrada y salida                        | Especificado                                        | `esp-i-entrada-salida` · publicada (CON-F18)         |
| 8. Estructuras de control                  | Especificado                                        | `esp-i-control` · publicada (CON-F18)                |
| 9. Arreglos                                | Especificado                                        | `esp-i-arreglos` · publicada (CON-F18)               |
| 10. Subprocesos y funciones                | Especificado                                        | `esp-i-subprogramas` · publicada (CON-F18)           |
| 11. Orientación a objetos                  | Especificado                                        | `esp-o-clases` · publicada (CON-F19)                 |
| 12. Sistema de tipos y política de rigor   | Especificado                                        | `esp-i-sistema-de-tipos` · publicada (CON-F18)       |
| 13. Funciones incorporadas                 | Especificado                                             | `esp-i-funciones-incorporadas` · publicada (CON-F18) |
| 14. Gramática formal                       | Especificado | No se proyecta — gramática interna, no se publica    |


## Correspondencia del corpus

| Sección | Título | Contratos |
|---|---|---|
| 1 | Convenciones de la especificación | `LANG.PROFILE.MODEL`, `DIAG.CLASSES` |
| 1.1 | Metanotación de las formas | `LANG.SYNTAX.GRAMMAR` |
| 1.2 | Clases de error | `DIAG.CLASSES` |
| 1.3 | Estrategia de recuperación de errores de sintaxis | `LANG.SYNTAX.RECOVERY` |
| 2 | Modelo de perfil | `LANG.PROFILE.MODEL` |
| 2.1 | La prueba del eje | `LANG.PROFILE.MODEL` |
| 2.2 | Lo que nunca es configurable | `LANG.PROFILE.STRICTNESS` |
| 2.3 | Eje de vocabulario | `LANG.PROFILE.VOCABULARY`, `LIB.MODEL` |
| 2.4 | Inventario de tipos de token | `LANG.PROFILE.VOCABULARY` |
| 2.5 | Eje de rigor | `LANG.PROFILE.STRICTNESS` |
| 2.6 | Segregación por consumidor | `LANG.PROFILE.MODEL` |
| 2.7 | Independencia de ejes y traducción entre perfiles | `LANG.PROFILE.TRANSLATION` |
| 2.8 | Casos límite y errores | `LANG.PROFILE.VOCABULARY`, `LANG.LEXICAL.KEYWORD` |
| 3 | Estructura léxica | `LANG.SOURCE.ENCODING`, `LANG.SOURCE.POSITION`, `LANG.LEXICAL.WHITESPACE`, `LANG.LEXICAL.COMMENT`, `LANG.LEXICAL.IDENTIFIER`, `LANG.LEXICAL.KEYWORD`, `LANG.LEXICAL.NUMBER-LITERAL`, `LANG.LEXICAL.TEXT-LITERAL`, `LANG.LEXICAL.CHARACTER-LITERAL`, `LANG.LEXICAL.OPERATOR-TOKEN`, `LANG.LEXICAL.ERRORS` |
| 4 | Tipos primitivos | `LANG.TYPES.REAL`, `LANG.TYPES.BOOLEAN`, `LANG.TYPES.CHARACTER`, `LANG.TYPES.TEXT`, `LANG.TYPES.INTEGER` |
| 5 | Operadores, precedencia y asociatividad | `LANG.OPS.PRECEDENCE`, `LANG.OPS.ARITHMETIC`, `LANG.OPS.DIVISION`, `LANG.OPS.POWER`, `LANG.OPS.COMPARISON`, `LANG.OPS.LOGICAL`, `LANG.OPS.CONCATENATION` |
| 6 | Declaración y asignación | `LANG.DECL.VARIABLE`, `LANG.STMT.ASSIGNMENT` |
| 6.1 | Estructura del programa | `LANG.PROGRAM.STRUCTURE` |
| 6.2 | Sentencias y su terminación | `LANG.STMT.TERMINATION` |
| 6.3 | Declaración de variables | `LANG.DECL.VARIABLE` |
| 6.4 | Designadores | `LANG.DECL.DESIGNATOR` |
| 6.5 | Asignación | `LANG.STMT.ASSIGNMENT` |
| 7 | Entrada y salida | `LANG.IO.OUTPUT`, `LANG.IO.INPUT`, `LANG.IO.VALUE-FORMAT` |
| 7.1 | Salida | `LANG.IO.OUTPUT`, `LANG.IO.VALUE-FORMAT` |
| 7.2 | Entrada | `LANG.IO.INPUT` |
| 8 | Estructuras de control | `LANG.CONTROL.IF`, `LANG.CONTROL.SWITCH`, `LANG.CONTROL.WHILE`, `LANG.CONTROL.REPEAT`, `LANG.CONTROL.FOR` |
| 8.1 | Condicional | `LANG.CONTROL.IF` |
| 8.2 | Selección múltiple | `LANG.CONTROL.SWITCH` |
| 8.3 | Bucle condicional anterior | `LANG.CONTROL.WHILE` |
| 8.4 | Bucle condicional posterior | `LANG.CONTROL.REPEAT` |
| 8.5 | Bucle contado | `LANG.CONTROL.FOR` |
| 9 | Arreglos | `LANG.TYPES.ARRAY`, `LANG.ARRAY.DIMENSION`, `LANG.ARRAY.ACCESS` |
| 9.1 | Dimensionamiento | `LANG.ARRAY.DIMENSION` |
| 9.2 | Acceso a un elemento | `LANG.ARRAY.ACCESS` |
| 10 | Subprocesos y funciones | `LANG.SUBPROGRAM.DECLARATION`, `LANG.SUBPROGRAM.PARAMETERS`, `LANG.SUBPROGRAM.BY-REFERENCE`, `LANG.SUBPROGRAM.RETURN`, `LANG.SUBPROGRAM.CALL`, `LANG.SUBPROGRAM.SCOPE`, `LANG.SUBPROGRAM.RECURSION`, `LANG.SUBPROGRAM.INTERACTIONS` |
| 10.1 | Estructura del texto de origen | `LANG.PROGRAM.STRUCTURE` |
| 10.2 | Declaración | `LANG.SUBPROGRAM.DECLARATION` |
| 10.3 | Parámetros | `LANG.SUBPROGRAM.PARAMETERS` |
| 10.4 | Paso por referencia: qué es un argumento válido | `LANG.SUBPROGRAM.BY-REFERENCE` |
| 10.5 | Retorno | `LANG.SUBPROGRAM.RETURN` |
| 10.6 | Llamada | `LANG.SUBPROGRAM.CALL` |
| 10.7 | Ámbito y espacios de nombres | `LANG.SUBPROGRAM.SCOPE` |
| 10.8 | Recursión | `LANG.SUBPROGRAM.RECURSION` |
| 10.9 | Interacción con lo ya especificado | `LANG.SUBPROGRAM.INTERACTIONS` |
| 11 | Orientación a objetos | `LANG.CLASS.DECLARATION`, `LANG.CLASS.INHERITANCE`, `LANG.CLASS.FIELDS`, `LANG.CLASS.METHODS`, `LANG.CLASS.CONSTRUCTOR`, `LANG.CLASS.INSTANTIATION`, `LANG.CLASS.SELF-AND-SUPER`, `LANG.CLASS.MEMBER-ACCESS`, `LANG.CLASS.OVERRIDE`, `LANG.CLASS.COPY`, `LANG.CLASS.OUT-OF-SCOPE` |
| 11.1 | Declaración de clase | `LANG.CLASS.DECLARATION`, `LANG.CLASS.INHERITANCE` |
| 11.2 | Atributos y visibilidad | `LANG.CLASS.FIELDS` |
| 11.3 | Métodos | `LANG.CLASS.METHODS` |
| 11.4 | Constructor | `LANG.CLASS.CONSTRUCTOR` |
| 11.5 | Instanciación | `LANG.CLASS.INSTANTIATION` |
| 11.6 | Objeto actual y superclase | `LANG.CLASS.SELF-AND-SUPER` |
| 11.7 | Acceso a miembro, llamada a método y sobrescritura | `LANG.CLASS.MEMBER-ACCESS`, `LANG.CLASS.OVERRIDE` |
| 11.8 | Las clases como tipos | `LANG.TYPES.CLASS` |
| 11.9 | Copia | `LANG.CLASS.COPY` |
| 11.10 | Diagnósticos pedagógicos de construcciones fuera de alcance | `LANG.CLASS.OUT-OF-SCOPE` |
| 11.11 | Ejemplo | `LANG.CLASS.DECLARATION`, `LANG.CLASS.CONSTRUCTOR`, `LANG.CLASS.OVERRIDE` |
| 12 | Sistema de tipos y política de rigor | `LANG.TYPES.REAL`, `LANG.TYPES.BOOLEAN`, `LANG.TYPES.CHARACTER`, `LANG.TYPES.TEXT`, `LANG.TYPES.ARRAY`, `LANG.TYPES.CLASS`, `LANG.TYPES.RELATIONS`, `LANG.TYPES.INFERENCE`, `LANG.TYPES.CHECKING-LEVELS`, `DIAG.SEVERITY.POLICY`, `LANG.TYPES.INTEGER` |
| 12.1 | Las tres relaciones entre tipos | `LANG.TYPES.RELATIONS` |
| 12.2 | Rango de los tipos numéricos y desbordamiento | `LANG.TYPES.INTEGER`, `LANG.TYPES.REAL` |
| 12.3 | El tipo de cada operador | `LANG.OPS.PRECEDENCE`, `LANG.OPS.ARITHMETIC`, `LANG.OPS.DIVISION`, `LANG.OPS.POWER`, `LANG.OPS.COMPARISON`, `LANG.OPS.LOGICAL`, `LANG.OPS.CONCATENATION` |
| 12.4 | Quién comprueba qué: la regla de los dos niveles | `LANG.TYPES.CHECKING-LEVELS` |
| 12.5 | Inferencia de tipos en perfil flexible | `LANG.TYPES.INFERENCE` |
| 12.6 | Ampliación aceptable y conflicto real de tipos | `LANG.TYPES.RELATIONS` |
| 12.7 | Variable usada sin inicializar | `LANG.DECL.UNINITIALIZED` |
| 12.8 | Variable no usada | `LANG.DECL.UNUSED` |
| 12.9 | Tipado de arreglos y de objetos | `LANG.TYPES.ARRAY`, `LANG.TYPES.CLASS` |
| 12.10 | La política de severidad | `DIAG.SEVERITY.POLICY` |
| 12.11 | Funciones incorporadas que este sistema de tipos obliga a tener | `LIB.MODEL`, `LIB.CORE.MATH`, `LIB.CORE.ROUNDING`, `LIB.CORE.RANDOM`, `LIB.CORE.CONVERSION`, `LIB.CORE.TEXT`, `LIB.CORE.COPY` |
| 12.12 | Casos límite | `LANG.TYPES.INTEGER`, `LANG.TYPES.REAL`, `LANG.ARRAY.ACCESS`, `LANG.OPS.DIVISION`, `LANG.OPS.POWER` |
| 13 | Funciones incorporadas | `LIB.MODEL`, `LIB.CORE.MATH`, `LIB.CORE.ROUNDING`, `LIB.CORE.RANDOM`, `LIB.CORE.CONVERSION`, `LIB.CORE.TEXT`, `LIB.CORE.COPY` |
| 14 | Gramática formal | `LANG.SYNTAX.GRAMMAR` |

## Contratos publicados

- [DIAG.CATALOG · Catálogo bilingüe de diagnósticos](../../pseudolearn_spec/specifications/diag/diag.catalog.md)
- [DIAG.CLASSES · Clases de diagnóstico](../../pseudolearn_spec/specifications/diag/diag.classes.md)
- [DIAG.ENGINE.INTERNAL-FAULT · Fallo interno controlado](../../pseudolearn_spec/specifications/diag/diag.engine.internal-fault.md)
- [DIAG.MESSAGES · Presentación bilingüe de diagnósticos](../../pseudolearn_spec/specifications/diag/diag.messages.md)
- [DIAG.MODEL · Modelo de diagnóstico](../../pseudolearn_spec/specifications/diag/diag.model.md)
- [DIAG.ORDERING · Orden de diagnósticos](../../pseudolearn_spec/specifications/diag/diag.ordering.md)
- [DIAG.SEVERITY.POLICY · Política de severidad](../../pseudolearn_spec/specifications/diag/diag.severity.policy.md)
- [LANG.ARRAY.ACCESS · Acceso a arreglos](../../pseudolearn_spec/specifications/lang/lang.array.access.md)
- [LANG.ARRAY.DIMENSION · Dimensionamiento de arreglos](../../pseudolearn_spec/specifications/lang/lang.array.dimension.md)
- [LANG.CLASS.CONSTRUCTOR · Constructores](../../pseudolearn_spec/specifications/lang/lang.class.constructor.md)
- [LANG.CLASS.COPY · Copia superficial](../../pseudolearn_spec/specifications/lang/lang.class.copy.md)
- [LANG.CLASS.DECLARATION · Declaración de clases](../../pseudolearn_spec/specifications/lang/lang.class.declaration.md)
- [LANG.CLASS.FIELDS · Atributos y visibilidad](../../pseudolearn_spec/specifications/lang/lang.class.fields.md)
- [LANG.CLASS.INHERITANCE · Herencia simple](../../pseudolearn_spec/specifications/lang/lang.class.inheritance.md)
- [LANG.CLASS.INSTANTIATION · Instanciación explícita](../../pseudolearn_spec/specifications/lang/lang.class.instantiation.md)
- [LANG.CLASS.MEMBER-ACCESS · Acceso a miembros](../../pseudolearn_spec/specifications/lang/lang.class.member-access.md)
- [LANG.CLASS.METHODS · Métodos de instancia](../../pseudolearn_spec/specifications/lang/lang.class.methods.md)
- [LANG.CLASS.OUT-OF-SCOPE · Diagnósticos de construcciones ajenas a la edición](../../pseudolearn_spec/specifications/lang/lang.class.out-of-scope.md)
- [LANG.CLASS.OVERRIDE · Sobrescritura y despacho](../../pseudolearn_spec/specifications/lang/lang.class.override.md)
- [LANG.CLASS.SELF-AND-SUPER · Objeto actual y superclase](../../pseudolearn_spec/specifications/lang/lang.class.self-and-super.md)
- [LANG.CONTROL.FOR · Bucle contado](../../pseudolearn_spec/specifications/lang/lang.control.for.md)
- [LANG.CONTROL.IF · Condicional](../../pseudolearn_spec/specifications/lang/lang.control.if.md)
- [LANG.CONTROL.REPEAT · Bucle posterior](../../pseudolearn_spec/specifications/lang/lang.control.repeat.md)
- [LANG.CONTROL.SWITCH · Selección múltiple](../../pseudolearn_spec/specifications/lang/lang.control.switch.md)
- [LANG.CONTROL.WHILE · Bucle anterior](../../pseudolearn_spec/specifications/lang/lang.control.while.md)
- [LANG.DECL.DESIGNATOR · Designadores](../../pseudolearn_spec/specifications/lang/lang.decl.designator.md)
- [LANG.DECL.UNINITIALIZED · Lectura sin inicializar](../../pseudolearn_spec/specifications/lang/lang.decl.uninitialized.md)
- [LANG.DECL.UNUSED · Higiene de variables](../../pseudolearn_spec/specifications/lang/lang.decl.unused.md)
- [LANG.DECL.VARIABLE · Declaración de variables](../../pseudolearn_spec/specifications/lang/lang.decl.variable.md)
- [LANG.EDITION.MODEL · Edición del lenguaje](../../pseudolearn_spec/specifications/lang/lang.edition.model.md)
- [LANG.IO.INPUT · Entrada](../../pseudolearn_spec/specifications/lang/lang.io.input.md)
- [LANG.IO.OUTPUT · Salida](../../pseudolearn_spec/specifications/lang/lang.io.output.md)
- [LANG.IO.VALUE-FORMAT · Formato de valores](../../pseudolearn_spec/specifications/lang/lang.io.value-format.md)
- [LANG.LEXICAL.CHARACTER-LITERAL · Literales de carácter](../../pseudolearn_spec/specifications/lang/lang.lexical.character-literal.md)
- [LANG.LEXICAL.COMMENT · Comentarios y conservación](../../pseudolearn_spec/specifications/lang/lang.lexical.comment.md)
- [LANG.LEXICAL.ERRORS · Errores léxicos](../../pseudolearn_spec/specifications/lang/lang.lexical.errors.md)
- [LANG.LEXICAL.IDENTIFIER · Identificadores](../../pseudolearn_spec/specifications/lang/lang.lexical.identifier.md)
- [LANG.LEXICAL.KEYWORD · Palabras reservadas](../../pseudolearn_spec/specifications/lang/lang.lexical.keyword.md)
- [LANG.LEXICAL.NUMBER-LITERAL · Literales numéricos](../../pseudolearn_spec/specifications/lang/lang.lexical.number-literal.md)
- [LANG.LEXICAL.OPERATOR-TOKEN · Tokens de operadores](../../pseudolearn_spec/specifications/lang/lang.lexical.operator-token.md)
- [LANG.LEXICAL.TEXT-LITERAL · Literales de texto](../../pseudolearn_spec/specifications/lang/lang.lexical.text-literal.md)
- [LANG.LEXICAL.WHITESPACE · Separación léxica](../../pseudolearn_spec/specifications/lang/lang.lexical.whitespace.md)
- [LANG.OPS.ARITHMETIC · Aritmética básica](../../pseudolearn_spec/specifications/lang/lang.ops.arithmetic.md)
- [LANG.OPS.COMPARISON · Comparaciones](../../pseudolearn_spec/specifications/lang/lang.ops.comparison.md)
- [LANG.OPS.CONCATENATION · Concatenación](../../pseudolearn_spec/specifications/lang/lang.ops.concatenation.md)
- [LANG.OPS.DIVISION · División entera y real](../../pseudolearn_spec/specifications/lang/lang.ops.division.md)
- [LANG.OPS.LOGICAL · Operadores lógicos](../../pseudolearn_spec/specifications/lang/lang.ops.logical.md)
- [LANG.OPS.POWER · Potencia](../../pseudolearn_spec/specifications/lang/lang.ops.power.md)
- [LANG.OPS.PRECEDENCE · Precedencia y asociatividad](../../pseudolearn_spec/specifications/lang/lang.ops.precedence.md)
- [LANG.PROFILE.MODEL · Modelo de perfiles oficiales](../../pseudolearn_spec/specifications/lang/lang.profile.model.md)
- [LANG.PROFILE.STRICTNESS · Políticas de rigor](../../pseudolearn_spec/specifications/lang/lang.profile.strictness.md)
- [LANG.PROFILE.TRANSLATION · Traducción de vocabularios](../../pseudolearn_spec/specifications/lang/lang.profile.translation.md)
- [LANG.PROFILE.VOCABULARY · Vocabulario bilingüe](../../pseudolearn_spec/specifications/lang/lang.profile.vocabulary.md)
- [LANG.PROGRAM.STRUCTURE · Estructura del texto de programa](../../pseudolearn_spec/specifications/lang/lang.program.structure.md)
- [LANG.SOURCE.ENCODING · Codificación y normalización del texto fuente](../../pseudolearn_spec/specifications/lang/lang.source.encoding.md)
- [LANG.SOURCE.POSITION · Posiciones y tramos de fuente](../../pseudolearn_spec/specifications/lang/lang.source.position.md)
- [LANG.STMT.ASSIGNMENT · Asignación](../../pseudolearn_spec/specifications/lang/lang.stmt.assignment.md)
- [LANG.STMT.TERMINATION · Terminación de sentencias](../../pseudolearn_spec/specifications/lang/lang.stmt.termination.md)
- [LANG.SUBPROGRAM.BY-REFERENCE · Argumentos por referencia](../../pseudolearn_spec/specifications/lang/lang.subprogram.by-reference.md)
- [LANG.SUBPROGRAM.CALL · Llamadas](../../pseudolearn_spec/specifications/lang/lang.subprogram.call.md)
- [LANG.SUBPROGRAM.DECLARATION · Declaración de subprogramas](../../pseudolearn_spec/specifications/lang/lang.subprogram.declaration.md)
- [LANG.SUBPROGRAM.INTERACTIONS · Interacciones procedimentales](../../pseudolearn_spec/specifications/lang/lang.subprogram.interactions.md)
- [LANG.SUBPROGRAM.PARAMETERS · Parámetros](../../pseudolearn_spec/specifications/lang/lang.subprogram.parameters.md)
- [LANG.SUBPROGRAM.RECURSION · Recursión](../../pseudolearn_spec/specifications/lang/lang.subprogram.recursion.md)
- [LANG.SUBPROGRAM.RETURN · Retorno](../../pseudolearn_spec/specifications/lang/lang.subprogram.return.md)
- [LANG.SUBPROGRAM.SCOPE · Ámbitos y nombres](../../pseudolearn_spec/specifications/lang/lang.subprogram.scope.md)
- [LANG.SYNTAX.GRAMMAR · Gramática abstracta formal](../../pseudolearn_spec/specifications/lang/lang.syntax.grammar.md)
- [LANG.SYNTAX.RECOVERY · Recuperación sintáctica](../../pseudolearn_spec/specifications/lang/lang.syntax.recovery.md)
- [LANG.TYPES.ARRAY · Tipo arreglo](../../pseudolearn_spec/specifications/lang/lang.types.array.md)
- [LANG.TYPES.BOOLEAN · Tipo lógico](../../pseudolearn_spec/specifications/lang/lang.types.boolean.md)
- [LANG.TYPES.CHARACTER · Tipo carácter](../../pseudolearn_spec/specifications/lang/lang.types.character.md)
- [LANG.TYPES.CHECKING-LEVELS · Frontera entre análisis y ejecución](../../pseudolearn_spec/specifications/lang/lang.types.checking-levels.md)
- [LANG.TYPES.CLASS · Tipos de clase](../../pseudolearn_spec/specifications/lang/lang.types.class.md)
- [LANG.TYPES.INFERENCE · Inferencia flexible](../../pseudolearn_spec/specifications/lang/lang.types.inference.md)
- [LANG.TYPES.INTEGER · Tipo entero](../../pseudolearn_spec/specifications/lang/lang.types.integer.md)
- [LANG.TYPES.REAL · Tipo real](../../pseudolearn_spec/specifications/lang/lang.types.real.md)
- [LANG.TYPES.RELATIONS · Relaciones de tipos](../../pseudolearn_spec/specifications/lang/lang.types.relations.md)
- [LANG.TYPES.TEXT · Tipo cadena](../../pseudolearn_spec/specifications/lang/lang.types.text.md)
- [LIB.CORE.CONVERSION · Conversiones explícitas](../../pseudolearn_spec/specifications/lib/lib.core.conversion.md)
- [LIB.CORE.COPY · Función de copia superficial](../../pseudolearn_spec/specifications/lib/lib.core.copy.md)
- [LIB.CORE.MATH · Funciones matemáticas](../../pseudolearn_spec/specifications/lib/lib.core.math.md)
- [LIB.CORE.RANDOM · Fuente aleatoria explícita](../../pseudolearn_spec/specifications/lib/lib.core.random.md)
- [LIB.CORE.ROUNDING · Truncamiento y redondeo](../../pseudolearn_spec/specifications/lib/lib.core.rounding.md)
- [LIB.CORE.TEXT · Funciones de texto y carácter](../../pseudolearn_spec/specifications/lib/lib.core.text.md)
- [LIB.MODEL · Modelo de funciones incorporadas](../../pseudolearn_spec/specifications/lib/lib.model.md)

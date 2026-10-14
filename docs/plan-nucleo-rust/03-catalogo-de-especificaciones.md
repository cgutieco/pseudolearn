# 03 · Catálogo de especificaciones

> **Estado:** propuesta. Es el **inventario de trabajo** de la reescritura: cada fila es una
> especificación que hay que escribir antes de programar lo que exige. Los identificadores son
> provisionales hasta que la especificación nace en `borrador`; a partir de ahí no se reutilizan.

Columnas:

- **Origen**: de dónde sale el contenido.
  - `§n`: sección de `packages/pseudolearn_core/docs/language-spec.md`, que se migra.
  - `H-nn`: hallazgo del diagnóstico que la especificación debe resolver.
  - `docs/nn`: documento de investigación del que sale la propuesta.
  - `nueva`: no existe nada previo.
- **Sujetos**: quién debe cumplirla ([02](02-modelo-de-especificaciones.md) §4).
- **Esp.**: fase en la que la especificación llega a `experimental`.
- **Impl.**: fase en la que el núcleo Rust la cumple ([07](07-fases.md)).

---

## 1. Resumen por dominio

| Dominio | Qué cubre                                                       | Especificaciones | Esp.  | Impl.    |
|---------|-----------------------------------------------------------------|------------------|-------|----------|
| `SEE`   | El propio sistema de especificaciones                            | 15               | R1    | R1       |
| `LANG`  | El lenguaje vigente: texto, léxico, perfiles, tipos, construcciones | 72            | R2    | R4–R5    |
| `DIAG`  | Forma, clases, severidad, catálogo y mensajes de los diagnósticos | 7               | R2    | R4       |
| `LIB`   | Funciones incorporadas                                           | 7                | R2    | R5       |
| `ENG`   | Modelo de ejecución, eventos, estado observable, límites         | 8                | R3    | R5       |
| `MEM`   | Contrato de memoria                                              | 3                | R3    | R5       |
| `IR`    | Representación intermedia                                        | 7                | R3    | R5       |
| `API`   | Superficie pública del núcleo                                    | 7                | R3    | R4–R5    |
| `RT`    | Interfaz con el anfitrión, fallos en código compilado, ABI        | 5                | R3/R6 | R5–R6    |
| `TOOL`  | CLI, servicio de lenguaje, formateo, traducción, LSP             | 17               | R3/R7 | R4–R7    |
| `APP`   | Comportamientos de la app sobre el puente                        | 4                | R8    | R8       |
| `PERF`  | Protocolo, suites y umbrales                                     | 8                | R3/R6 | R5–R8    |
| **Total** |                                                                | **160**         |       |          |

La cifra es mayor que las 40–60 de [11](../11-especificaciones-ejecutables-diseno.md) §5.2, porque
aquella contaba solo la migración de `language-spec.md`. Las de `LANG` salen de ahí; el resto cubre
el motor, sus fronteras y sus herramientas.

---

## 2. Inventario

### 2.1 `SEE` · Sistema de especificaciones (Esp. R1, Impl. R1, sujeto `see`)

| ID                         | Título                                                           | Origen                    |
|----------------------------|------------------------------------------------------------------|---------------------------|
| `SEE.FORMAT`               | Formato `see/1`: Markdown, metadatos YAML, bloques tipados        | docs/11 §3–4              |
| `SEE.IDENTITY`             | Identificadores, elementos, lápidas, no reutilización             | docs/11 §5                |
| `SEE.LIFECYCLE`            | Estados y condiciones de paso                                    | docs/11 §2                |
| `SEE.VERSIONING`           | Clases de cambio, versión, edición                               | docs/11 §6.1              |
| `SEE.CHANGE.CLASSIFICATION`| Hash de contenido normativo y clasificación preliminar            | docs/11 §6.2–6.3          |
| `SEE.VALIDATION`           | Las cinco capas de validación                                    | docs/11 §4.2              |
| `SEE.GRAPH`                | Dependencias, tipos, aciclicidad, rangos                          | docs/11 §7                |
| `SEE.LOCK`                 | `specifications.lock`: versión exacta y hash por especificación   | docs/11 §7.2              |
| `SEE.IMPACT`               | Propagación e informe de impacto                                 | docs/11 §8                |
| `SEE.ADAPTER.PROTOCOL`     | Protocolo JSON por proceso entre `see` y un sujeto                 | nueva ([05](05-sistema-de-especificaciones.md) §3) |
| `SEE.CONFORMANCE.FILE`     | Archivo de conformidad por sujeto: vínculos, `pendiente`, `exento` | docs/11 §9.1              |
| `SEE.CONFORMANCE.MATRIX`   | Matriz regla × sujeto e informe                                  | docs/11 §9.2              |
| `SEE.ORACLE.POLICY`        | Origen de valores esperados, dos sujetos, mutación                | docs/11 §10               |
| `SEE.FEATURE-MANIFEST`     | Manifiestos de característica y estado agregado                   | nueva ([02](02-modelo-de-especificaciones.md) §5) |
| `SEE.GENERATION`           | Artefactos generados desde el corpus y su verificación            | docs/11 §9.3, `GEN-NO-HAND-COPY` |

### 2.2 `LANG` · Lenguaje (Esp. R2)

#### 2.2.1 Texto fuente y léxico (Impl. R4)

| ID                              | Título                                                     | Origen             | Sujetos                 |
|---------------------------------|------------------------------------------------------------|--------------------|-------------------------|
| `LANG.SOURCE.ENCODING`          | UTF-8, BOM, fines de línea, normalización NFC               | §3, H-23, D-14     | reference, engine       |
| `LANG.SOURCE.POSITION`          | Línea, columna y tramo: qué se cuenta (puntos de código)    | §3, nueva          | reference, engine       |
| `LANG.LEXICAL.WHITESPACE`       | Espacios, saltos de línea y su papel sintáctico             | §3                 | reference, engine       |
| `LANG.LEXICAL.COMMENT`          | Comentarios del lenguaje PseudoLearn y su conservación       | §3, H-19           | engine                  |
| `LANG.LEXICAL.IDENTIFIER`       | Forma de un identificador; Unicode; `ñ` y tildes por rigor  | §3, H-23, H-24, D-14 | reference, engine     |
| `LANG.LEXICAL.KEYWORD`          | Palabras reservadas y contextuales; presupuesto             | §2.4, H-22, D-13   | reference, engine       |
| `LANG.LEXICAL.NUMBER-LITERAL`   | Literales enteros y reales                                  | §3                 | reference, engine       |
| `LANG.LEXICAL.TEXT-LITERAL`     | Literales de cadena y escapes                               | §3                 | reference, engine       |
| `LANG.LEXICAL.CHARACTER-LITERAL`| Literales de carácter                                       | §3                 | reference, engine       |
| `LANG.LEXICAL.OPERATOR-TOKEN`   | Signos y operadores como tokens                             | §2.4, §3           | reference, engine       |
| `LANG.LEXICAL.ERRORS`           | Errores léxicos y su recuperación                           | §1.2, §3           | reference, engine       |

#### 2.2.2 Perfiles (Impl. R4)

| ID                              | Título                                                        | Origen         | Sujetos           |
|---------------------------------|---------------------------------------------------------------|----------------|-------------------|
| `LANG.PROFILE.MODEL`            | Ejes de perfil, prueba del eje, lo que nunca es configurable   | §2, §2.1, §2.2 | reference, engine |
| `LANG.PROFILE.VOCABULARY`       | Tabla bilingüe de lexemas (**fuente del léxico generado**)     | §2.3, §2.4     | reference, engine |
| `LANG.PROFILE.STRICTNESS`       | Eje de rigor: estricto y flexible; solo invalida, nunca cambia el significado | §2.5, docs/04 §1.3 | reference, engine |
| `LANG.PROFILE.TRANSLATION`      | Traducción entre perfiles por reimpresión de tokens; ida y vuelta | §2.7       | engine            |

#### 2.2.3 Estructura del programa y sintaxis (Impl. R4)

| ID                              | Título                                                     | Origen            | Sujetos           |
|---------------------------------|------------------------------------------------------------|-------------------|-------------------|
| `LANG.SYNTAX.GRAMMAR`           | Gramática formal (EBNF) por perfil abstracto: **fuente normativa de la sintaxis** | §14, H-32, docs/03 §5 | reference, engine |
| `LANG.SYNTAX.RECOVERY`          | Recuperación: sincronización, un diagnóstico por sentencia, tope, árbol siempre | §1.3, H-05, H-06 | reference, engine |
| `LANG.PROGRAM.STRUCTURE`        | Proceso principal, subprogramas y clases en el texto fuente | §6.1, §10.1       | reference, engine |
| `LANG.STMT.TERMINATION`         | Terminación de sentencias                                   | §6.2              | reference, engine |
| `LANG.EDITION.MODEL`            | Edición del lenguaje; la vigente es `2026`                  | D-11, docs/04 §5  | engine            |

#### 2.2.4 Tipos (Impl. R4 el chequeo, R5 la ejecución)

| ID                              | Título                                                  | Origen                 | Sujetos                |
|---------------------------------|---------------------------------------------------------|------------------------|------------------------|
| `LANG.TYPES.INTEGER`            | Entero de 64 bits con signo; desbordamiento como error   | §4, §12.2, H-16        | reference, engine, aot |
| `LANG.TYPES.REAL`               | Real IEEE 754 binario de 64 bits; no finitos como error  | §4, §12.2              | reference, engine, aot |
| `LANG.TYPES.BOOLEAN`            | Lógico                                                  | §4                     | reference, engine, aot |
| `LANG.TYPES.CHARACTER`          | Carácter como punto de código Unicode                    | §4                     | reference, engine, aot |
| `LANG.TYPES.TEXT`               | Cadena: secuencia de puntos de código, distinta de carácter | §4                  | reference, engine, aot |
| `LANG.TYPES.ARRAY`              | Tipo arreglo: elemento, dimensiones                      | §9, §12.9              | reference, engine, aot |
| `LANG.TYPES.CLASS`              | Las clases como tipos; subtipado nominal                 | §11.8, §12.9           | reference, engine, aot |
| `LANG.TYPES.RELATIONS`          | Igualdad, asignabilidad, ampliación entero→real; conversiones rechazadas | §12.1, §12.6 | reference, engine |
| `LANG.TYPES.INFERENCE`          | Inferencia en primera asignación (perfil flexible)       | §12.5                  | reference, engine      |
| `LANG.TYPES.CHECKING-LEVELS`    | Qué comprueba el análisis y qué la ejecución             | §12.4                  | reference, engine      |

#### 2.2.5 Operadores (Impl. R4 el tipo, R5 el valor)

| ID                              | Título                                                  | Origen          | Sujetos                |
|---------------------------------|---------------------------------------------------------|-----------------|------------------------|
| `LANG.OPS.PRECEDENCE`           | Precedencia y asociatividad                              | §5              | reference, engine      |
| `LANG.OPS.ARITHMETIC`           | `+ - *` unarios y binarios                               | §5, §12.3       | reference, engine, aot |
| `LANG.OPS.DIVISION`             | `/` siempre real; `div` y `mod` solo enteros; división por cero | §12.3, §12.12 | reference, engine, aot |
| `LANG.OPS.POWER`                | `^`; exponente negativo sobre base entera                 | §12.3, §12.12   | reference, engine, aot |
| `LANG.OPS.COMPARISON`           | Relacionales e igualdad; aviso al comparar reales         | §12.3, §12.12   | reference, engine, aot |
| `LANG.OPS.LOGICAL`              | `NO`, `Y`, `O`; orden de evaluación                       | §12.3           | reference, engine, aot |
| `LANG.OPS.CONCATENATION`        | `+` como concatenación                                   | §12.3           | reference, engine, aot |

#### 2.2.6 Declaración, asignación y entrada/salida (Impl. R4–R5)

| ID                              | Título                                                  | Origen     | Sujetos                |
|---------------------------------|---------------------------------------------------------|------------|------------------------|
| `LANG.DECL.VARIABLE`            | Declaración de variables                                 | §6.3       | reference, engine      |
| `LANG.DECL.DESIGNATOR`          | Designadores: variable, elemento, miembro               | §6.4       | reference, engine      |
| `LANG.DECL.UNINITIALIZED`       | Uso antes de asignar                                    | §12.7      | reference, engine      |
| `LANG.DECL.UNUSED`              | Variable no usada                                       | §12.8      | reference, engine      |
| `LANG.STMT.ASSIGNMENT`          | Asignación y su orden de evaluación                     | §6.5       | reference, engine, aot |
| `LANG.IO.OUTPUT`                | `Escribir`, `Sin Saltar`, lista de expresiones          | §7.1       | reference, engine, aot |
| `LANG.IO.INPUT`                 | `Leer`: conversión, entrada inválida                     | §7.2       | reference, engine, aot |
| `LANG.IO.VALUE-FORMAT`          | **Representación textual única** de cada tipo, por perfil | §7.1, H-25 | reference, engine, aot |

#### 2.2.7 Control (Impl. R4–R5)

| ID                              | Título                                                  | Origen       | Sujetos                |
|---------------------------------|---------------------------------------------------------|--------------|------------------------|
| `LANG.CONTROL.IF`               | Condicional                                             | §8.1         | reference, engine, aot |
| `LANG.CONTROL.SWITCH`           | Selección múltiple                                      | §8.2, H-18   | reference, engine, aot |
| `LANG.CONTROL.WHILE`            | Bucle condicional anterior                              | §8.3         | reference, engine, aot |
| `LANG.CONTROL.REPEAT`           | Bucle condicional posterior                             | §8.4         | reference, engine, aot |
| `LANG.CONTROL.FOR`              | Bucle contado (ejemplo completo en docs/12 §1)          | §8.5, H-37   | reference, engine, aot |

#### 2.2.8 Arreglos (Impl. R4–R5)

| ID                              | Título                                                  | Origen       | Sujetos                |
|---------------------------------|---------------------------------------------------------|--------------|------------------------|
| `LANG.ARRAY.DIMENSION`          | Dimensionamiento; tamaño cero; tamaño excesivo           | §9.1, H-09   | reference, engine, aot |
| `LANG.ARRAY.ACCESS`             | Acceso; índice fuera de rango                           | §9.2         | reference, engine, aot |

#### 2.2.9 Subprogramas (Impl. R4–R5)

| ID                              | Título                                                  | Origen       | Sujetos                |
|---------------------------------|---------------------------------------------------------|--------------|------------------------|
| `LANG.SUBPROGRAM.DECLARATION`   | Procedimientos y funciones                              | §10.2        | reference, engine      |
| `LANG.SUBPROGRAM.PARAMETERS`    | Parámetros por valor y por referencia                   | §10.3        | reference, engine, aot |
| `LANG.SUBPROGRAM.BY-REFERENCE`  | Qué es un argumento válido por referencia               | §10.4        | reference, engine, aot |
| `LANG.SUBPROGRAM.RETURN`        | Retorno y caminos sin retorno                           | §10.5        | reference, engine, aot |
| `LANG.SUBPROGRAM.CALL`          | Llamada y orden de evaluación de argumentos             | §10.6        | reference, engine, aot |
| `LANG.SUBPROGRAM.SCOPE`         | Ámbito y espacios de nombres                            | §10.7, H-36  | reference, engine      |
| `LANG.SUBPROGRAM.RECURSION`     | Recursión; la profundidad pasa a `ENG.LIMITS`           | §10.8, H-15, D-17 | reference, engine, aot |
| `LANG.SUBPROGRAM.INTERACTIONS`  | Interacción con construcciones ya especificadas          | §10.9        | reference, engine      |

#### 2.2.10 Orientación a objetos (Impl. R4–R5)

| ID                              | Título                                                  | Origen       | Sujetos                |
|---------------------------------|---------------------------------------------------------|--------------|------------------------|
| `LANG.CLASS.DECLARATION`        | Declaración de clase                                    | §11.1        | reference, engine      |
| `LANG.CLASS.INHERITANCE`        | Herencia simple; ciclos de herencia                      | §11.1, §11.7 | reference, engine      |
| `LANG.CLASS.FIELDS`             | Atributos y visibilidad                                 | §11.2        | reference, engine, aot |
| `LANG.CLASS.METHODS`            | Métodos                                                 | §11.3        | reference, engine, aot |
| `LANG.CLASS.CONSTRUCTOR`        | Constructor                                             | §11.4        | reference, engine, aot |
| `LANG.CLASS.INSTANTIATION`      | Instanciación                                           | §11.5        | reference, engine, aot |
| `LANG.CLASS.SELF-AND-SUPER`     | `Este` y `Super`                                        | §11.6        | reference, engine, aot |
| `LANG.CLASS.MEMBER-ACCESS`      | Acceso a miembro y llamada a método                     | §11.7        | reference, engine, aot |
| `LANG.CLASS.OVERRIDE`           | Sobrescritura y despacho dinámico                       | §11.7        | reference, engine, aot |
| `LANG.CLASS.COPY`               | Copia superficial                                       | §11.9        | reference, engine, aot |
| `LANG.CLASS.OUT-OF-SCOPE`       | Diagnósticos pedagógicos de construcciones fuera de alcance | §11.10   | reference, engine      |

### 2.3 `DIAG` · Diagnósticos (Esp. R2, Impl. R4)

| ID                             | Título                                                                  | Origen                  | Sujetos                 |
|--------------------------------|-------------------------------------------------------------------------|-------------------------|-------------------------|
| `DIAG.MODEL`                   | Forma: código, clase, severidad, tramo, tramos relacionados, argumentos tipados; sin idioma | README núcleo §1.2.8 | reference, engine |
| `DIAG.CLASSES`                 | Léxico, sintáctico, semántico, de ejecución; las fases semánticas no corren con errores sintácticos | §1.2 | reference, engine |
| `DIAG.SEVERITY.POLICY`         | Clases de severidad A–E por perfil de rigor                              | §12.10                  | reference, engine       |
| `DIAG.CATALOG`                 | Catálogo de códigos: cada código es una entidad con ficha bilingüe (**fuente del `enum` Rust generado**) | docs/11 §5.1 | reference, engine |
| `DIAG.MESSAGES`                | Reglas de redacción y renderizado bilingüe: términos, plurales, marcadores de lexema | núcleo `diagnostics/`, docs/03 §7.3 | engine |
| `DIAG.ORDERING`                | Orden determinista de los diagnósticos de un análisis                   | nueva                   | reference, engine       |
| `DIAG.ENGINE.INTERNAL-FAULT`   | Defecto interno del motor atrapado en la frontera                        | nueva, `QUALITY-NO-PANIC` | engine                |

### 2.4 `LIB` · Funciones incorporadas (Esp. R2, Impl. R5)

| ID                             | Título                                                      | Origen        | Sujetos                |
|--------------------------------|-------------------------------------------------------------|---------------|------------------------|
| `LIB.MODEL`                    | Funciones como dato del perfil: nombre bilingüe, no reservado, firma | §13    | reference, engine      |
| `LIB.CORE.MATH`                | Raíz cuadrada, valor absoluto, logaritmo, exponencial, seno, coseno, arcotangente | §13 | reference, engine, aot |
| `LIB.CORE.ROUNDING`            | Truncamiento y redondeo                                     | §12.11, §13   | reference, engine, aot |
| `LIB.CORE.RANDOM`              | Aleatorio con fuente inyectada y semilla explícita           | §13           | reference, engine, aot |
| `LIB.CORE.CONVERSION`          | A cadena, de cadena a entero y a real                        | §12.11        | reference, engine, aot |
| `LIB.CORE.TEXT`                | Longitud, carácter en posición, código de carácter, carácter desde código | §12.11 | reference, engine, aot |
| `LIB.CORE.COPY`                | Copia superficial como función                              | §12.11, §11.9 | reference, engine, aot |

### 2.5 `ENG` · Motor de ejecución (Esp. R3, Impl. R5)

| ID                             | Título                                                                   | Origen                | Sujetos            |
|--------------------------------|--------------------------------------------------------------------------|-----------------------|--------------------|
| `ENG.EXEC.MODEL`               | Ejecución determinista; estados de terminación: completada, fallida, esperando entrada, cancelada, límite alcanzado | docs/06 §1, H-08 | reference, engine |
| `ENG.EXEC.EFFECT-ORDER`        | Orden normativo de los efectos (lo que no tiene efectos no tiene orden observable) | docs/06 §1.2, §6.5, §10.6 | engine, aot |
| `ENG.TRACE.EVENTS`             | Alfabeto de eventos observables (ejemplo en docs/12 §6)                   | docs/06 §1.2, D-18    | reference, engine  |
| `ENG.TRACE.STEP`               | Definición de paso observable; lotes de eventos                          | docs/06 §1.2, H-14    | engine             |
| `ENG.STATE.SNAPSHOT`           | Máquina nocional: marcos, variables, arreglos, grafo de objetos; inmutable | docs/06 §2.1, H-10   | engine             |
| `ENG.STATE.INCREMENTAL`        | Cambios por evento y puntos de control; el estado reconstruido es igual al completo | docs/06 §2.2, H-12, E-06 | engine |
| `ENG.INPUT`                    | Suspensión por `Leer`, proveedor de entrada, entrada por lotes            | §7.2, README núcleo   | reference, engine  |
| `ENG.LIMITS`                   | Límites de recursos en unidades observables: profundidad (mínimo garantizado), sentencias, tiempo, memoria | D-17, H-09, H-14, H-15 | engine, aot |

### 2.6 `MEM` · Memoria (Esp. R3, Impl. R5)

| ID                             | Título                                                       | Origen                  | Sujetos           |
|--------------------------------|--------------------------------------------------------------|-------------------------|-------------------|
| `MEM.MANAGED.UNOBSERVABLE`     | Ningún programa observa la recuperación de memoria            | docs/09 §5, docs/12 §5  | engine, aot       |
| `MEM.IDENTITY`                 | Identidad de objetos, aliasing, ciclos válidos                | H-35, §11.5             | reference, engine, aot |
| `MEM.VALUE.COPY`               | Qué se copia al asignar y al pasar por valor (primitivos y arreglos según §9; objetos por referencia) | §6.5, §10.3, §11.9 | reference, engine, aot |

### 2.7 `IR` · Representación intermedia (Esp. R3, Impl. R5)

| ID                             | Título                                                       | Origen          | Sujetos        |
|--------------------------------|--------------------------------------------------------------|-----------------|----------------|
| `IR.MODEL`                     | Módulo, funciones, bloques, valores, tipos de la RI           | docs/13 §1      | engine, aot    |
| `IR.INSTRUCTIONS`              | Catálogo de instrucciones con su semántica; trampas           | nueva           | engine, aot    |
| `IR.WELL-FORMEDNESS`           | Reglas del verificador de la RI                              | nueva           | engine, aot    |
| `IR.TEXT-FORMAT`               | Formato textual con ida y vuelta exacta                      | nueva           | engine         |
| `IR.SOURCE-MAP`                | Correspondencia instrucción → nodo fuente, para eventos y fallos | docs/06 §1.3 | engine, aot    |
| `IR.LOWERING`                  | Preservación del significado: ejecutar la RI de `p` equivale a ejecutar `p` | docs/06 §4 | engine |
| `IR.OBSERVATION-POINTS`        | Qué instrucciones producen eventos; la regla «como si» en código optimizado | docs/06 §1.3 | engine, aot |

### 2.8 `RT` · Runtime (Esp. R3 lo común y R6 lo nativo)

| ID                             | Título                                                       | Origen        | Sujetos     | Esp. | Impl. |
|--------------------------------|--------------------------------------------------------------|---------------|-------------|------|-------|
| `RT.HOST.INTERFACE`            | Capacidades inyectadas: salida, entrada, semilla; sin reloj ni entorno implícitos | §13, nueva | engine, aot | R3 | R5 |
| `RT.FAULT.REPORTING`           | Un fallo en código compilado produce el mismo diagnóstico con el mismo tramo | nueva | aot | R6 | R6 |
| `RT.PROCESS`                   | Binario compilado: códigos de salida, vaciado de la salida, argumentos | nueva | aot  | R6 | R6 |
| `RT.ABI`                       | Contrato código generado ↔ runtime: valores, cabecera de objeto, asignación, raíces del recolector | nueva | aot | R6 | R6 |
| `RT.LINKING`                   | Enlazado del objeto con el runtime estático; enlazador requerido | nueva      | aot         | R6   | R6    |

### 2.9 `API` · Superficie pública del núcleo (Esp. R3)

| ID                             | Título                                                       | Origen       | Sujetos  | Impl. |
|--------------------------------|--------------------------------------------------------------|--------------|----------|-------|
| `API.MODEL`                    | Documentos, análisis y ejecuciones como recursos con identificador | H-07   | engine   | R4    |
| `API.ANALYZE`                  | Analizar: texto + perfil + rigor → diagnósticos y esquema     | nueva        | engine   | R4    |
| `API.EXECUTE`                  | Iniciar, avanzar por lotes de eventos o hasta una condición, dar entrada, cancelar | docs/06 §5 | engine | R5 |
| `API.STATE.QUERY`              | Consultar el estado por referencia: marcos, valores, objeto por identidad, arreglos paginados | E-06 | engine | R5 |
| `API.ERRORS`                   | Todo resultado es un valor; tipos de error; ningún pánico      | H-08, `QUALITY-NO-PANIC` | engine | R4 |
| `API.WIRE-FORMAT`              | Formato de intercambio para FFI, Wasm y protocolo de conformidad: versionado y determinista | nueva | engine | R4 |
| `API.VERSIONING`               | Versión de la API, ediciones soportadas, negociación          | docs/04 §5   | engine   | R4    |

### 2.10 `TOOL` · Herramientas

| ID                             | Título                                                       | Origen          | Sujetos  | Esp. | Impl. |
|--------------------------------|--------------------------------------------------------------|-----------------|----------|------|-------|
| `TOOL.CLI.CONVENTIONS`         | Idioma canónico de la CLI, alias, códigos de salida, salida para máquinas (`--json`) | D-21 | cli | R3 | R4 |
| `TOOL.CLI.MESSAGES` | Catálogo bilingüe de ayuda, errores y narración, independiente del vocabulario | D-R3-02 | cli | R3 | R4–R5 |
| `TOOL.CLI.CHECK`               | `pseudo comprobar` (`check`): diagnósticos de un archivo o directorio       | docs/07 §7      | cli      | R3   | R4    |
| `TOOL.CLI.RUN`                 | `pseudo ejecutar` (`run`): ejecuta en la VM                               | docs/07 §7      | cli      | R3   | R5    |
| `TOOL.CLI.BUILD`               | `pseudo compilar` (`build`): compila a binario nativo                     | docs/07 §7      | cli      | R6   | R6    |
| `TOOL.CLI.FORMAT`              | `pseudo formatear` (`format`)                                              | docs/07 §7      | cli      | R7   | R7    |
| `TOOL.CLI.TRANSLATE`           | `pseudo traducir --to en` (`translate`)                                   | docs/07 §7      | cli      | R7   | R7    |
| `TOOL.CLI.IR`                  | `pseudo ri` (`ir`): imprime la RI en formato textual (diagnóstico de herramientas) | nueva | cli   | R3   | R5    |
| `TOOL.SERVICE.LOSSLESS-TREE`   | Árbol sin pérdida: reimprimir da exactamente el texto        | docs/07 §3.1, H-19 | service | R3 | R4    |
| `TOOL.SERVICE.NODE-IDENTITY`   | Identidad estable de nodo entre ediciones                    | H-20            | service  | R7   | R7    |
| `TOOL.SERVICE.INCREMENTAL`     | Reanálisis incremental y latencias                           | H-21, E-08      | service  | R7   | R7    |
| `TOOL.SERVICE.COMPLETION`      | Autocompletado determinista y bilingüe (ejemplo en docs/12 §7.1) | docs/07 §4, H-17, H-18 | service | R7 | R7 |
| `TOOL.SERVICE.NAVIGATION`      | Ir a definición, referencias, resaltado de símbolo            | docs/07 §3.3    | service  | R7   | R7    |
| `TOOL.SERVICE.HOVER`           | Información al pasar: tipo, firma, documentación generada     | docs/07 §3.3    | service  | R7   | R7    |
| `TOOL.FORMAT.STYLE`            | Estilo canónico (EST-01 a EST-10) y formateo idempotente      | docs/03 §3      | service  | R7   | R7    |
| `TOOL.TRANSLATE.ROUND-TRIP`    | Traducción con comentarios; doble traducción idéntica         | docs/15 F3      | service  | R7   | R7    |
| `TOOL.LSP.CAPABILITIES`        | Capacidades LSP anunciadas y su correspondencia con el servicio | docs/07 §5    | service  | R7   | R7    |

### 2.11 `APP` · App sobre el puente (Esp. R8, Impl. R8, sujeto `app`)

| ID                             | Título                                                  | Origen            |
|--------------------------------|---------------------------------------------------------|-------------------|
| `APP.ENGINE.BOUNDARY`          | La app no contiene lógica de lenguaje: solo consume `API.*` | docs/11 §12   |
| `APP.EXEC.PACE`                | Ritmos sobre eventos (ejemplo en docs/12 §7.2)           | docs/06, H-14     |
| `APP.EXEC.SNAPSHOT-VIEW`       | Qué estado se visualiza: arreglos, grafo de objetos      | H-10, H-11        |
| `APP.EDITOR.COMPLETION`        | El editor usa `TOOL.SERVICE.COMPLETION`                  | docs/12 §7.1      |

### 2.12 `PERF` · Rendimiento

| ID                             | Título                                                  | Origen          | Esp. | Impl. |
|--------------------------------|---------------------------------------------------------|-----------------|------|-------|
| `PERF.PROTOCOL`                | Protocolo de medición, estadística y publicación        | docs/16 §2      | R3   | R5    |
| `PERF.BASELINE.REFERENCE`      | Línea base del núcleo Dart                              | E-01            | R3   | R3    |
| `PERF.SUITE.AWFY-CORE`         | Suite de programas comparables (ejemplo en docs/12 §8)  | docs/16, E-02   | R3   | R5    |
| `PERF.VM.STEP-LATENCY`         | Latencia por paso observado en el dispositivo más modesto | docs/15 F5    | R3   | R5    |
| `PERF.VM.THROUGHPUT`           | Rendimiento de la VM sin observar                       | H-13            | R3   | R5    |
| `PERF.AOT.LEVEL`               | Nivel alcanzado por familia y plataforma frente a C/Rust | D-07, docs/05 §2 | R6  | R6    |
| `PERF.FRONTEND.THROUGHPUT`     | Líneas por segundo y memoria del análisis               | E-08, E-20      | R3   | R4    |
| `PERF.ARTIFACT.SIZE`           | Presupuesto de tamaño de la biblioteca móvil y del Wasm  | docs/05 §1.2 (B) | R3  | R8    |

---

## 3. Grafo de dependencias entre áreas

Es el orden en que las especificaciones pueden escribirse y estabilizarse. Una flecha `A → B` significa
«A usa a B».

```
LANG.CONTROL.* ─┐
LANG.CLASS.*  ──┼──► LANG.SUBPROGRAM.* ──► LANG.DECL.* ──► LANG.OPS.* ──► LANG.TYPES.* ──► LANG.LEXICAL.* ──► LANG.SOURCE.*
LANG.ARRAY.*  ──┘                                 │                            │                │
                                                  ▼                            ▼                ▼
                                             LANG.IO.* ─────────────────► LANG.IO.VALUE-FORMAT   LANG.PROFILE.*
todos LANG.* ──► DIAG.MODEL, DIAG.CATALOG, DIAG.SEVERITY.POLICY
LIB.*  ──► LANG.TYPES.*, DIAG.*
ENG.*  ──► LANG.*, LIB.*, MEM.*
IR.*   ──► LANG.TYPES.*, ENG.TRACE.EVENTS (puntos de observación)
API.*  ──► DIAG.MODEL, ENG.*, LANG.PROFILE.*
RT.*   ──► IR.*, MEM.*, LIB.*
TOOL.* ──► API.*, LANG.SYNTAX.*, LANG.PROFILE.*
APP.*  ──► API.*, TOOL.SERVICE.*
PERF.* ──► (independiente; cita sujetos, no reglas)
```

Consecuencia práctica para R2: se escribe de derecha a izquierda.

1. `SOURCE` y `LEXICAL`.
2. `PROFILE`.
3. `TYPES`.
4. `OPS`.
5. `DECL` e `IO`.
6. `CONTROL` y `ARRAY`.
7. `SUBPROGRAM`.
8. `CLASS`.

En paralelo y desde el principio: `DIAG.MODEL` y `DIAG.CATALOG`, que se van llenando con cada
especificación.

---

## 4. Lo que no se porta

Todo lo que no tiene especificación queda fuera del núcleo Rust. La lista inicial, que R2 completa al
contrastar el corpus con el sujeto `reference`:

| Qué                                                    | Dónde está hoy                                   | Por qué no se porta                                     | Qué lo sustituye                    |
|--------------------------------------------------------|--------------------------------------------------|---------------------------------------------------------|-------------------------------------|
| Tope de 10 000 micro-pasos                             | `step_batch_runner.dart` (app)                   | Unidad sin significado (H-14)                            | `ENG.LIMITS`, `ENG.TRACE.STEP`      |
| `PseudoInteger` sobre `BigInt`                         | `domain/pseudo_integer.dart`                     | Detalle del anfitrión Dart (H-16)                        | `LANG.TYPES.INTEGER` + `i64` comprobado |
| `NotExecutableReason.containsClassDeclaration`         | `execution_result.dart`                          | Código muerto (H-02)                                     | Nada                                |
| Micro-paso de la máquina de tareas como unidad pública | `Interpreter.step()`                             | Detalle de implementación (docs/06 §1.1)                 | `ENG.TRACE.STEP`                    |
| Instantáneas con referencias vivas                     | `snapshot_builder.dart`                          | Incompletas y mutables (H-10)                            | `ENG.STATE.SNAPSHOT`                |
| Autocompletado de lista fija                           | `profile_completion_source.dart` (app)           | Sin contexto (H-17, H-18)                                | `TOOL.SERVICE.COMPLETION`           |
| Representación textual con `toString()` de Dart         | `watch_row_projection.dart` (app)                | Dos representaciones (H-25)                              | `LANG.IO.VALUE-FORMAT`              |
| Plantilla de selección múltiple inválida               | App                                              | Contradice la gramática (H-18)                           | Plantillas generadas de `LANG.SYNTAX.GRAMMAR` |

**Fuera del alcance de la reescritura, pero no podado:** los emisores de Python y Rust, el ordinograma, el
estructograma y el diagrama de clases viven en la app y consumen el AST del núcleo Dart. Siguen
funcionando con el núcleo Dart hasta R8. En R8 se decide si pasan a consumir `API.*`, lo que obligaría
a especificar una vista del árbol para consumidores, o si se retiran. Es la decisión D-P07 de
[08](08-decisiones-riesgos-y-cambios-de-reglas.md).

---

## 5. Lo que no entra en la reescritura

La reescritura alcanza **la paridad con el lenguaje vigente**, más los contratos del motor y las
herramientas. Las construcciones nuevas de la investigación entran **después** de R9, cada una como
especificación nueva sobre el núcleo Rust (`SCOPE-YAGNI`):

- edición A ([15](../15-evolucion-y-hoja-de-ruta.md) F4): módulos, constantes, enumerados, `Opcional`,
  registros, `Resultado`, interfaces;
- edición B (F7): ámbitos de bloque, closures, genéricos, `Para Cada`;
- paquetes, espacios de trabajo y eliminación de código (F8).

Las únicas excepciones son las que la reescritura necesita para no portar defectos:

- `LANG.SOURCE.ENCODING` con NFC (D-14), que es compatible;
- `ENG.LIMITS` (D-17). Es un cambio de significado, que exigiría una edición nueva; se resuelve como la
  primera decisión de R3.

Los códigos `cellLimitExceeded` y `statementBudgetExhausted` pertenecen a DIAG.CATALOG: profundidad y
celdas son fallos del programa; sentencias y tiempo agotan el presupuesto del anfitrión (ENG.LIMITS).

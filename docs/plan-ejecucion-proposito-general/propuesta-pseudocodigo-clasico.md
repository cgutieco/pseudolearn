# Propuesta · Pseudocódigo clásico ejecutable sin perder garantías

Documento transitorio de la carpeta documental de la raíz. Es una **propuesta para analizar y priorizar**, no un plan
autorizado: no inicia ninguna fase ni cambia el corpus. Fecha de análisis: 2026-11-05, sobre `052a4c1e` con el árbol de
trabajo de ese día.

## 0. Respuesta corta

Sí se puede, y la parte que más preocupa —seguridad y eficiencia— **casi no se toca**:

- La garantía de «nunca se lee una variable sin valor» se conserva entera: pasa del inicializador obligatorio (sintaxis)
  al **análisis de asignación definitiva** (semántica), que es lo que usan Rust, Java, C# y Swift.
- La palabra `Mutable` **no llega a la RI, al bytecode, a la VM, a Cranelift ni a la ABI**. Hoy solo la consultan tres
  verificaciones de `pseudolearn_semantic`. Quitarla no cambia ni el rendimiento ni la SSA (§3.2).
- Las clausuras y las tareas siguen sin estado mutable compartido: la regla «solo se captura lo inmutable» pasa a
  «solo se captura lo **efectivamente constante**», el mismo modelo de Java para lambdas.
- Lo único que **sí se pierde** es poder *declarar la intención* de que un valor de ejecución no cambie. Hoy, reasignar
  por accidente una variable pensada como fija es un error; con la propuesta pasa a ser legal. Ese nivel es el de Go,
  Java, C# o Python; Rust es más estricto. `Constante` sigue existiendo para valores de compilación, como opción.

Pero las declaraciones son **solo 3 de las 10 barreras** que hoy impiden pegar un programa clásico (§2). Si el objetivo
es «copiar, pegar y ejecutar», hay que decidir también el resto, y una de ellas (índices base 0 o 1) es la decisión más
cara de cambiar después de PG-N.

## 1. Objetivos que fija la persona

| ID | Objetivo |
|---|---|
| G1 | Un programa de pseudocódigo clásico se copia, se pega y se ejecuta sin retoques. |
| G2 | Vuelve `Definir a, b, c Como Tipo;`. |
| G3 | Desaparece `Mutable`; la constancia se infiere. No se obliga a escribir `Constante` para valores de ejecución. |
| G4 | Las palabras reservadas propias amplían el pseudocódigo clásico; no lo sustituyen. |
| G5 | Rigor, seguridad de memoria y eficiencia comparables, al menos en parte, con Go o Rust. |
| G6 | Sin retrocompatibilidad: lo nuevo es la forma oficial y se reescribe lo que haga falta antes de producción. |

G3 y G6 revierten por instrucción directa la decisión D-PG2-01 (opción A, 2026-10-24) y el requisito «vínculos inmutables
por defecto e inicialización en la declaración» de PG-2.05. Por la precedencia de `AGENTS.md`, la instrucción de la
persona prevalece. Hay que dejarlo registrado en el plan y en los README dueños cuando se autorice.

## 2. Evidencia: qué pasa hoy al pegar un programa clásico

Se probó `pseudo comprobar` (binario `apps/pseudolearn_cli/target/debug/pseudo` del 2026-11-05) con un programa típico
de curso (promedio de notas con arreglo) y con sondas de una construcción cada una.

| # | Construcción clásica | Resultado hoy | Gravedad para G1 |
|---|---|---|---|
| B1 | `Definir n, i Como Entero` | `expectedTypeConnector` | Bloquea casi todo programa |
| B2 | `Definir edad Como Entero` + `Leer edad` | `missingBindingInitializer`; con `<- 0`, `Leer` da `immutableBindingAssignment` | Bloquea casi todo programa |
| B3 | `suma <- suma + x` en un acumulador | `immutableBindingAssignment` | Bloquea casi todo programa |
| B4 | Sentencias sin `;` | `missingStatementTerminator` en cada línea | Bloquea muchos programas |
| B5 | `Para i <- 1 Hasta n Hacer` | `missingStepClause` | Bloquea casi todo programa con bucles |
| B6 | `Definir c Como Cadena <- "s"` | `incompatibleTypesInAssignment`: un literal de un carácter es `Caracter` | Bloquea menús y opciones (`"s"`/`"n"`) |
| B7 | `Definir v Como Real` + `Dimension v[10]` | `expectedTypeConnector`: `Dimension` exige `Como tipo` | Bloquea la forma clásica en dos pasos |
| B8 | `Para i <- 1 Hasta 10` sobre `v[10]` | Compila; `arrayIndexOutOfRange` en ejecución (índices base 0) | **Peor caso**: falla en ejecución o da resultados silenciosamente distintos |
| B9 | Biblioteca clásica | `Azar(n)`/`Aleatorio(a,b)`: aridad distinta; `Mayusculas`, `Minusculas`, `Concatenar`, `ConvertirANumero` no existen; `Subcadena` existe con **otra semántica** (inicio 0 y cantidad) | Mismo nombre con distinto significado: resultado silencioso distinto |
| B10 | `Funcion r <- doble(x)` | `expectedSubroutineLeftParenthesis` | Bloquea funciones al estilo clásico |

Ya funciona sin cambios: `Proceso`/`FinProceso`, `Funcion`/`FinFuncion` como alias de `SubProceso` (sin variable de
retorno), `Si … SiNo … FinSi`, `Segun … De Otro Modo`, `Mientras`, `Repetir … Hasta Que`, `=`, `<>`, `&`, `|`, `~`,
`MOD`, `%`, `^`, `Escribir … Sin Saltar`, `Leer`, `RC`, `trunc`, `Redon`, `Raiz`, `Ln`, `Exp`, `Sen`,
`Longitud`, `ConvertirATexto`.

Conclusión: G2 y G3 (B1–B3) son necesarios para G1, pero no bastan. B4–B10 son decisiones independientes y cada una
tiene su propia regla dueña.

## 3. Qué garantías se conservan y cuáles no

### 3.1 Tabla de garantías

| Garantía | Mecanismo hoy | Mecanismo propuesto | ¿Se pierde? |
|---|---|---|---|
| No se lee un local sin valor | Inicializador obligatorio, comprobado por el parser | Asignación definitiva sobre el flujo de control, en semántica | No. Misma garantía estática, sin valores ficticios |
| Sin valores por defecto inventados | `LANG.DECL.UNINITIALIZED#R1` | Igual | No. Más estricto que Go, que usa valores cero |
| Campos y elementos sin valor | Trampa `uninitializedVariableRead` en ejecución | Igual | No cambia |
| Las clausuras no comparten estado mutable | Se rechaza capturar un vínculo `Mutable` | Se rechaza capturar un vínculo que no sea efectivamente constante | No. Mismo entorno por copia, mismas raíces, misma ABI |
| Las tareas no comparten estado mutable | Transferibilidad por tipo (`LANG.TASK.ISOLATION`) | Igual: no depende de `Mutable` | No |
| Variable de control de `Para` intocable | `controlVariableModified` | Igual | No |
| Vínculos de `Para Cada` y de patrones inmutables | `immutableBindingAssignment` | Igual, solo para estos vínculos que introduce el lenguaje | No |
| SSA y rendimiento | El *lowering* construye SSA sin leer `mutable` | Igual | No (§3.2) |
| **Declarar que un valor de ejecución no cambia** | Omitir `Mutable` | No existe forma de declararlo | **Sí**: reasignar por accidente deja de ser error |
| Aviso de mutable innecesario | `mutableBindingNeverModified` | Desaparece: ya no hay nada que avisar | Sí, por diseño |

### 3.2 Por qué el rendimiento no cambia

El campo `HirLocal::mutable` lo leen solo `binding_checker.rs` (asignación a un inmutable), `capture_analysis.rs`
(captura) y `usage.rs` (aviso de mutable sin modificar). Ningún archivo de `pseudolearn_lowering`, `pseudolearn_ir`,
`pseudolearn_bytecode`, `pseudolearn_vm`, `pseudolearn_codegen` ni `pseudolearn_abi` lo consulta. La SSA se construye
a partir de las asignaciones reales, no de la palabra clave, así que una variable asignada una sola vez ya es un único
valor SSA aunque se escriba `Mutable`, y lo seguirá siendo sin ella. La eficiencia comparable a Go o Rust (G5) se juega en
PG-N (código nativo, recolector y agenda), no aquí.

### 3.3 Comparación honesta

| Lenguaje | Mutabilidad por defecto | Lectura sin valor | Captura en clausuras |
|---|---|---|---|
| Rust | Inmutable (`let mut`) | Error estático (asignación definitiva) | Préstamos comprobados |
| Go | Mutable | Imposible: valor cero implícito | Comparte la variable (fuente clásica de errores) |
| Java / C# | Mutable | Error estático (asignación definitiva) | Solo efectivamente constante (Java) |
| **PseudoLearn hoy** | Inmutable (`Mutable`) | Error estático (inicializador obligatorio) | Solo inmutables |
| **PseudoLearn propuesto** | Mutable, constancia inferida | Error estático (asignación definitiva) | Solo efectivamente constantes |

El resultado queda más estricto que Go en inicialización y en clausuras, igual que Java y C#, y por debajo de Rust solo en
la declaración explícita de la intención de inmutabilidad.

## 4. Diseño propuesto para las declaraciones (B1–B3)

### D-C1 · Forma de `Definir`

```
Definir n, i Como Entero;
Definir suma Como Real <- 0;
```

- `Definir nombre₁, …, nombreₙ Como tipo;` declara n vínculos sin valor. Un nombre de un carácter es válido y un nombre
  duplicado es error, como hoy.
- `<- expresión` es opcional. **Decisión pendiente**: con varios nombres, ¿se permite el inicializador?
  - **Recomendado**: solo con un nombre. `Definir a, b Como Entero <- 0;` produce un error nuevo con sugerencia. Evita
    decidir si `<- Nuevo Pila()` se evalúa una vez (alias compartido) o una vez por nombre (n objetos), una diferencia
    que un principiante no ve.
  - Alternativa: se evalúa una vez por nombre, en orden.
- Desaparecen la palabra `Mutable` (y `mutable` en inglés) del vocabulario y el diagnóstico `mutableBindingNeverModified`.
  Sin alias ni migrador (G6).

### D-C2 · Asignación definitiva

Una lectura de un local es válida solo si en **todos** los caminos desde la declaración hasta la lectura hubo una
asignación. Las reglas concretas, que son las que hay que fijar en el corpus con casos:

| Construcción | Efecto sobre «asignado» |
|---|---|
| `x <- e`, `Leer x` | Asigna `x` |
| `Si` con `SiNo` | Asignado después solo si se asigna en ambas ramas |
| `Si` sin `SiNo` | Lo asignado dentro no cuenta después |
| `Segun` | Cuenta si se asigna en todas las ramas y hay `De Otro Modo` o la cobertura es exhaustiva (enumerados) |
| `Mientras`, `Para`, `Para Cada` | Lo asignado en el cuerpo no cuenta después: el cuerpo puede no ejecutarse |
| `Repetir … Hasta Que` | El cuerpo se ejecuta al menos una vez: cuenta, también en la condición |
| `Retornar`, `Salir`, fallo propagado | El camino termina y no restringe la unión (una rama que retorna no obliga a asignar) |
| Literal de función | Una lectura dentro exige que el vínculo esté asignado en el punto de creación |

El diagnóstico reutiliza el código existente `variableUsedUninitialized` (ya está en el catálogo y en
`name_resolution.rs`), con error, origen relacionado en la declaración y un argumento que nombre el camino sin
asignación («si la condición de la línea 4 es falsa»). Es la mejora de mensajes que más impacto pedagógico tiene.

Estado actual del motor: la sesión semántica ya lleva un vector `initialized` por local y lo restaura en `Segun`
(`switch_checker.rs`) y en el cuerpo de `Para` (`for_checker.rs`). Hoy la restauración es conservadora (nada asignado
dentro de una rama cuenta después). Falta convertirla en una **intersección** de ramas, con el caso de caminos que
terminan, y aplicarla a `Si`, `Mientras`, `Repetir` y `Para Cada`. Es trabajo de un solo crate.

### D-C3 · Paso por referencia de una variable sin valor

Es frecuente en cursos: `Definir n Como Entero; LeerPositivo(n);`. **Decisión pendiente**:

- **Recomendado**: para llamadas directas (mundo cerrado, ya monomorfizado), el análisis calcula por subprograma qué
  parámetros por referencia quedan asignados en todos los caminos antes de ser leídos (parámetros de salida inferidos).
  Pasar una variable sin valor es válido solo a esos parámetros. Las llamadas indirectas (valores función) exigen
  argumento asignado.
- Alternativa más simple: todo argumento por referencia debe estar asignado. Rompe G1 en ese patrón.

### D-C4 · Constancia inferida y capturas

- Un local es **efectivamente constante** si tiene una sola asignación en cada camino (contando la inicialización y
  `Leer`) y nunca se reasigna, se pasa por referencia a un parámetro que lo modifica ni se usa como destino de `Leer`
  después de tener valor.
- Capturar en un literal de función un local que no sea efectivamente constante sigue siendo `mutableClosureCapture`,
  pero el mensaje cambia: señala la **línea de la modificación** como origen relacionado, no una palabra que falta.
- Requisito técnico: hoy el verificador recorre el cuerpo una sola vez y decide la captura al encontrarla, antes de ver
  las asignaciones posteriores. Hace falta una pasada previa por cuerpo que recoja los sitios de escritura de cada
  local. Es una pasada nueva y pequeña en `pseudolearn_semantic`.
- Opcional, de baja prioridad (`SCOPE-YAGNI` hasta que se pida): el *hover* del servicio podría mostrar «valor fijo
  (inferido)». No se propone ningún aviso que empuje a escribir `Constante`.

### D-C5 · Contradicción existente en el corpus

`LANG.DECL.VARIABLE#R1` dice que «las declaraciones locales no crean ámbitos de bloque», mientras que
`LANG.SUBPROGRAM.SCOPE#R1` y `LANG.DECL.UNINITIALIZED#R1` establecen ámbitos léxicos por rama y por cuerpo
(`bindingOutsideScope`). Al reescribir `LANG.DECL.VARIABLE#R1` se debe eliminar esa frase. Se reporta según
`CONFLICT-REPORT`; no se resolvió en este análisis.

## 5. Resto de barreras para G1 (B4–B10)

Cada una es una decisión de la persona. Se indica la recomendación técnica.

| ID | Barrera | Opciones | Recomendación | Coste |
|---|---|---|---|---|
| D-C6 | `;` obligatorio (B4) | a) Opcional: el fin de línea termina la sentencia salvo que la línea acabe en operador, coma o paréntesis abierto. b) Se mantiene | **Decidido: b.** El `;` forma parte de la identidad del lenguaje, mezclar líneas con y sin `;` sería incoherente y `missingStatementTerminator` ya es claro. G1 se entiende como «pegar con `;`» | — |
| D-C7 | `Con Paso` obligatorio (B5) | a) Opcional con paso 1. b) Opcional con paso −1 si inicial > final, como algunos intérpretes clásicos. c) Se mantiene | **a**: predecible, y un bucle que no se ejecuta es un comportamiento documentable | S |
| D-C8 | Literal de un carácter no es `Cadena` (B6) | a) Conversión implícita `Caracter → Cadena`, igual que `Entero → Real`. b) Se mantiene | **a**. Sin pérdida de información ni de seguridad | S |
| D-C9 | `Dimension` en dos pasos (B7) | a) `Dimension v[10];` acepta un nombre ya definido y toma su tipo. b) Se mantiene | **a**, conservando `Dimension v[10] Como Real;` | S |
| D-C10 | **Índices base 0 o 1 (B8)** | a) Base 0 (como hoy; Go, Rust, Python). b) Base 1 (pseudocódigo clásico; Pascal, Lua, Julia, Fortran) | **b si G1 es el norte del producto.** El rendimiento no cambia (el desplazamiento se resuelve al compilar). Es la única barrera que pasa la compilación y falla o miente en ejecución. Afecta a arreglos, cadenas y a toda la biblioteca con posiciones; **decidir antes de PG-N**, aunque se elija mantener la base 0 | L |
| D-C11 | Biblioteca clásica (B9) | Inventario de funciones clásicas: cada una o existe con la misma semántica o tiene un nombre distinto. Regla nueva: **nunca el mismo nombre con otra semántica** | Alinear `Subcadena`, `Azar`/`Aleatorio`; añadir `Mayusculas`, `Minusculas`, `Concatenar`, `ConvertirANumero` | M; depende de D-C10 |
| D-C12 | `Funcion r <- nombre(x)` (B10) | a) Se admite la forma con variable de retorno: `r` es un local que debe estar definitivamente asignado al salir (usa D-C2). b) No se admite | **a**, apoyada en la misma asignación definitiva | M |

## 6. Impacto medido

### 6.1 Huella de `Mutable`

`git grep "Mutable"` fuera de `docs/`, `target/` y `node_modules/`: **636 apariciones en 309 archivos**.

| Miembro | Archivos | Naturaleza |
|---|---|---|
| `apps/pseudolearn_app` | 164 | 125 contenidos de `assets/knowledge` (lecciones y ejercicios, muchos con el patrón `Definir Mutable x … <- 0; Leer x;`), 33 tests y 1 de código |
| `packages/pseudolearn_spec` | 66 | 270 programas con `Definir Mutable` en casos, además de reglas, catálogo y vocabulario |
| `packages/pseudolearn_engine` | 60 | 3 de código (parser, registro de locales, vista de programa); el resto son tests de servicio, banco de carga y fixtures |
| `apps/pseudolearn_vscode` | 8 | Gramática y pruebas |
| `apps/pseudolearn_cli` | 7 | Pruebas y ejemplos |
| `packages/pseudolearn_benchmarks` | 4 | Cargas de rendimiento |

La reescritura de programas es mecánica (quitar `Mutable `, quitar inicializadores ficticios). Los programas que ya
inicializan siguen siendo válidos. Los esperados de casos con `immutableBindingAssignment`,
`mutableBindingNeverModified` o `missingBindingInitializer` cambian de verdad y hay que derivarlos de la regla nueva
(`SPEC-INDEPENDENT-ORACLE`), no regenerarlos por captura.

### 6.2 Reglas del corpus que se editan

Edición en la misma identidad y versión, sin `cambio`, con reanclaje (`SPEC-VERSION-FREEZE`):

- **Declaraciones (D-C1–D-C5)**: `LANG.DECL.VARIABLE`, `LANG.DECL.UNINITIALIZED`, `LANG.TYPES.INFERENCE`,
  `LANG.TYPES.FUNCTION` (captura), `LANG.SUBPROGRAM.BY-REFERENCE` (si D-C3 = recomendado), `LANG.IO.INPUT` (`Leer`
  asigna), `LANG.PROFILE.VOCABULARY` (sin `mutableKeyword`), `LANG.TYPES.RECORD`, `LANG.TYPES.ENUM`,
  `LANG.TYPES.VARIANT`, `DIAG.CATALOG`, `DIAG.SEVERITY.POLICY`; ayuda y proyecciones del editor
  (`APP.EDITOR.COMPLETION`, `TOOL.SERVICE.*`).
- **Barreras B4–B10**: `LANG.STMT.TERMINATION`, `LANG.CONTROL.FOR`, `LANG.TYPES.RELATIONS` y
  `LANG.LEXICAL.TEXT-LITERAL`, `LANG.ARRAY.DIMENSION`, `LANG.ARRAY.ACCESS`, `LIB.CORE.TEXT` y las bibliotecas con
  posiciones, `LANG.SUBPROGRAM.DECLARATION` y `LANG.SUBPROGRAM.RETURN`.

### 6.3 Código por capa

| Capa | Declaraciones (D-C1–D-C5) | Barreras B4–B10 |
|---|---|---|
| `pseudolearn_lexicon` | Quitar `mutableKeyword` | — |
| `pseudolearn_syntax` | `declaration_parser.rs`: lista de nombres e inicializador opcional | Terminación por línea, `Con Paso` opcional, `Dimension` en dos pasos, `Funcion r <-` |
| `pseudolearn_semantic` | Asignación definitiva (intersección de ramas), pasada previa de escrituras, `capture_analysis.rs`, `usage.rs`, `binding_checker.rs`, parámetros de salida | Conversión `Caracter → Cadena`, variable de retorno |
| `pseudolearn_lowering` | Declaración sin valor: no emite almacenamiento | Desplazamiento de base de índices (D-C10) |
| RI, bytecode, VM, codegen, ABI, recolector | **Sin cambios** | Solo D-C10 y D-C11 tocan la biblioteca nativa y el runtime |
| `pseudolearn_service` | Completado, *hover*, fichas de ayuda, formateador | Formateador (`;` canónico) |
| App, extensión, CLI | Contenidos, gramática y pruebas | Contenidos de arreglos si D-C10 = base 1 |

## 7. Relación con PG-N y orden propuesto

Se propone una fase **PG-C · Pseudocódigo clásico** entre PG-S y PG-N:

- Las declaraciones (D-C1–D-C5) no tocan la RI, así que técnicamente no bloquean PG-N. Pero PG-N.08 y PG-N.11 exigen
  paridad nativa y cero diferencias VM/AOT sobre el corpus; reescribir 270 programas después obligaría a repetir esa
  campaña.
- D-C10 y D-C11 sí cambian el runtime y la biblioteca nativa: hacerlas después de PG-N.08 significa construir dos veces.

Bloques sugeridos, cada uno con su autorización (`PHASE-STOP`):

| Bloque | Contenido | Prioridad | Tamaño |
|---|---|---|---|
| C0 | Decisiones D-C1, D-C3, D-C6–D-C12 y registro de la reversión de D-PG2-01 en el plan | P0 | S |
| C1 | Corpus de declaraciones y asignación definitiva (especificación → casos) | P0 | M |
| C2 | Motor: parser, asignación definitiva, capturas y diagnósticos | P0 | M |
| C3 | Barreras baratas: D-C7, D-C8, D-C9 | P0 | S |
| C4 | Índices y biblioteca clásica: D-C10, D-C11 | P0 si D-C10 = base 1; P1 si se mantiene la base 0 | L |
| C5 | `Funcion r <- …` (D-C12) | P1 | M |
| C6 | Consumidores: servicio, extensión, app y reescritura de contenidos de `assets/knowledge` | P0 | M |
| C7 | **Suite de aceptación clásica**: N programas típicos de curso (entrada/salida, acumuladores, menús, arreglos, funciones) que deben ejecutarse sin un solo cambio, como caso del corpus | P0 | S |

C7 convierte G1 en una puerta verificable: sin ella, «se puede pegar pseudocódigo clásico» no tiene evidencia.

## 8. Decisiones que necesita la persona

Registro del 2026-11-05: la persona aceptó todas las recomendaciones (puntos 1–4 y 6, con D-C1 = solo un nombre con
inicializador, D-C3 = parámetros de salida inferidos, D-C7, D-C8, D-C9, D-C11 y D-C12 = a) salvo D-C6, donde se mantiene
el `;` obligatorio. D-C10 queda pendiente de explicación y decisión. Nada de esto autoriza iniciar PG-C ni editar el
corpus.

1. Confirmar G3: `Mutable` desaparece y la constancia solo se infiere, aceptando la pérdida de §3.1 (reasignar por
   accidente deja de ser error).
2. D-C1: ¿se permite inicializador con varios nombres? (Recomendado: no.)
3. D-C3: ¿parámetros de salida inferidos o argumento por referencia siempre asignado? (Recomendado: inferidos.)
4. D-C6–D-C9 y D-C12: ¿se adoptan las recomendaciones?
5. **D-C10: base 0 o base 1.** Es la decisión de mayor coste y debe tomarse antes de PG-N.
6. ¿Se crea PG-C entre PG-S y PG-N con los bloques de §7?

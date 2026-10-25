# Fase PG-2 · Tipos y abstracción — plan de ejecución

## 0. Metadatos

- Fase: PG-2; requisitos R-05–R-08 y R-17; capacidades C-04, C-05 y C-06.
- Decisiones rectoras: ADR-06 y ADR-07, con ADR-05 y las decisiones de la persona del 2026-10-22 y 2026-10-24.
- Riesgos principales: K-04 y K-05. Experimentos: E-PG-03, E-PG-04 y E-PG-10.
- Fecha de preparación: 2026-10-24, zona America/Lima.
- Revisión inicial: `74c0a03518a1cabe462837c76e08b4134ad40766`; árbol limpio al comenzar.
- Rama única: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
- Autorización documental: «Crea el plan de ejecución para `4.4 PG-2 · Tipos y abstracción` […] enfocado en el
  rendimiento, velocidad y totalmente personalizado para mi lenguaje de programación. Asegurate de dejar constancia
  de que en cada fase no se corren las pruebas de todo el monorepo, solo las pruebas acotadas a lo desarrollado para
  agilidad de desarrollo, ya que hay sesiones donde se demoran más de 10min por cada ejecución de pruebas y eso hace
  que la implementación de una fase dure màs de hora y media.»
- Estado: plan preparado, sin revisión de la persona (`PG-2.C02` pendiente). No autoriza especificación ni código de
  ningún punto; cada iteración de §10 requiere un mensaje nuevo (`PHASE-STOP`).
- Decisión de la persona del 2026-10-24: «Elijo D-PG2-01 opción A: reemplazo en 2026 con migración asistida.»
  Desbloquea el diseño de `.05`, `.06` y `.15` (§3.1); no autoriza todavía su implementación.
- Dependencia: PG-1.01–.13 están cumplidos; el cierre común de PG-1 (C01–C13) sigue abierto. Iniciar PG-2 con esa
  dependencia abierta es decisión de la persona (§9).

**Constancia de alcance de pruebas.** En ninguna iteración ni en el cierre de PG-2 se ejecutan las pruebas de todo el
monorepo ni las suites completas de un miembro por defecto. Cada iteración ejecuta solo las pruebas acotadas a lo que
desarrolló: los casos del corpus de las especificaciones que tocó, los tests espejo de los archivos que cambió, los
consumidores directos de una frontera que modificó y los verificadores estáticos de los miembros afectados. Motivo
registrado por la persona: hay sesiones en las que una sola ejecución de pruebas tarda más de 10 minutos, y eso lleva
la implementación de una fase a más de hora y media. La ampliación solo procede por los disparadores cerrados de §7.1,
y cada iteración registra lo ejecutado y lo omitido sin presentar una selección como suite completa.

Documento transitorio de `docs/`. Desarrolla el [plan general](plan-ejecucion-proposito-general.md) y la
[hoja de ruta](../hoja-de-ruta-proposito-general.md). Ningún archivo fuera de `docs/` lo cita
(`DOC-NO-TRANSIENT-REFS`). Las decisiones aceptadas se trasladan a los README dueños y el comportamiento observable al
corpus, sin depender de este texto.

## 1. Punto de partida

| Estado comprobado en la revisión inicial | Consecuencia |
|---|---|
| `LANG.DECL.VARIABLE#R1`: `Definir` sin inicializador ni ámbito de bloque; `LANG.SUBPROGRAM.SCOPE#R1`: «no hay globales ni ámbitos de bloque» | `.05` y `.06` cambian reglas estables de 2026; requieren la decisión D-PG2-01 antes de redactarse |
| `LANG.DECL.UNINITIALIZED#R1`: declarar no asigna; la lectura sin valor es trampa `uninitializedVariableRead` | La inicialización obligatoria convierte una comprobación dinámica en estática; la trampa sigue para los programas que la conserven |
| `LANG.TYPES.INFERENCE#R1`: en flexible, la primera asignación sin declaración fija el tipo | Choca con «inicialización en la declaración»; la decisión D-PG2-01 fija su destino |
| `LANG.CLASS.OUT-OF-SCOPE#R1` y su caso C1 esperan `unsupportedInterfaceConstruct` para `Interfaz X FinInterfaz`; también rechaza genéricos | `.08`/`.09` cambian esperados estables; editar texto oficial y reanclar requiere autorización (§9) |
| `LANG.CONTROL.SWITCH#R1`: etiquetas literales, sin exhaustividad, real rechazado, `De Otro Modo` opcional | `.04` amplía `Segun` a enumerados/variantes con exhaustividad sin cambiar el `Segun` actual sobre literales |
| `LANG.TYPES.ARRAY#R1`: el arreglo no es valor asignable, comparable ni retornable; `LANG.CLASS.COPY#R1`: copia superficial | `Vector` no se presenta como «arreglo genérico»; los registros no contienen arreglos como campo por valor |
| `pseudolearn_abi`: `frame`, `header`, `object_layout`, `array_layout`, `string_layout`, `sentinel`, `handle`, `word` | No existen disposiciones de registro, variante, entorno, vector ni diccionario; se añaden como datos compartidos VM/AOT |
| Motor: bancos escalar `u64` y de referencias `u32` sin etiquetas, marco bicameral, raíces exactas por punto seguro, recolector preciso sin movimiento | Toda representación nueva separa palabras escalares y de referencia para que los mapas de raíces sigan estáticos por tipo |
| RI: CFG SSA con parámetros de bloque, verificador, `dominance.rs`; bytecode de 8 bytes con operandos de 16 bits, gemelos rápido/sondeado, despacho generado | Las instrucciones nuevas nacen en `IR.INSTRUCTIONS` y el despacho se regenera; los límites de 16 bits acotan campos, variantes e instancias |
| Semantic: arenas con índices tipados, `class_registry`, `hierarchy`, `switch_checker`, `flow`; desvirtualización por jerarquía en mundo cerrado | Registrar enumerados, registros, variantes, interfaces e instancias en tablas contiguas; conservar desvirtualización |
| Codegen AOT: Cranelift, `class_table`, `shadow_stack`, `borrowed_roots`, `object_fast_path`, `fault_table` | Las mismas disposiciones de abi; raíces de entornos y variantes en la pila sombra; trampas con sitio exacto |
| Servicio: `help_catalog` generado desde el corpus; API `program_view*`; app proyecta `API.PROGRAM.VIEW` sin parser propio | Cada construcción nueva lleva ficha es/en y datos de proyección; PG-A dibuja, PG-2 no |
| `see conform` acepta `--only <ID>` y `--operation <op>`; `cargo xtask verify` ejecuta formato, Clippy, `cargo test --workspace`, `rust-checks`, `cargo deny`, export y conformidad engine completa | La selección acotada es viable con las herramientas actuales; `xtask verify` queda fuera de las iteraciones (§7.1) |
| Cierre de PG-H: margen iOS de `PERF.ARTIFACT.SIZE` aproximado de 0,32 % | Colecciones, variantes y entornos crecen el runtime; medir tamaño en cada iteración que toque runtime/library |

Alcance: constantes, enumerados, registros por valor, variantes con `Opcional`/`Resultado`, `Segun` exhaustivo,
vínculos inmutables, ámbitos de bloque, funciones como valores y clausuras, genéricos de primer orden, interfaces
nominales como restricción, `Vector`, `Diccionario`, `Para Cada`, salida anticipada con limpieza, verificador de RI,
paridad VM/AOT, diagnósticos ADR-07, migración asistida, vista pública y experimentos.

Fuera de alcance: metaprogramación, tipos de orden superior, especialización por el usuario, sobrecarga compleja,
valores de tipo interfaz con despacho dinámico, capturas entre tareas (PG-4), limpieza ante error de efecto (PG-3) o
cancelación (PG-4), facetas de biblioteca de PG-5, dibujo de diagramas (PG-A), migración desde el editor (PG-6A) y
toda optimización sin cambio observable (FUT-04).

## 2. Lectura realizada

- [x] `AGENTS.md`; plan general §2–§5 y §4.4; hoja de ruta §3, §6.2–6.3, ADR-05/06/07, K-04/05, E-PG-03/04/10 y
  trazabilidad F4/F7 de §12.1.
- [x] README de `pseudolearn_engine` (§4 por crate, §5–§7) y `architecture.yaml`; README de `pseudolearn_spec`
  (§2 y §7), argumentos de `see conform` y orden de `xtask verify`.
- [x] Corpus: `LANG.DECL.VARIABLE`, `LANG.DECL.UNINITIALIZED`, `LANG.DECL.UNUSED`, `LANG.SUBPROGRAM.SCOPE`,
  `LANG.TYPES.INFERENCE`, `LANG.TYPES.ARRAY`, `LANG.CLASS.OUT-OF-SCOPE`, `LANG.CLASS.COPY`, `LANG.CONTROL.SWITCH`.
- [x] Inventario de fuentes de abi, runtime, semantic, lowering, ir, codegen, vm, library, syntax, service y api.
- [x] Plan de PG-1 como referencia de formato y de verificaciones ya usadas.

Antes de cada iteración se leen el README del crate y los contratos que esa iteración modifique (`LANG.SYNTAX.GRAMMAR`,
`LANG.PROFILE.VOCABULARY`, `IR.INSTRUCTIONS`, `IR.WELL-FORMEDNESS`, `RT.ABI`, `MEM.*`, `DIAG.CATALOG`,
`API.PROGRAM.VIEW`, `TOOL.SERVICE.HOVER`, `PERF.*`), y se amplía §5 antes de editar archivos no previstos. Esta
lectura no es evidencia de conformidad ni de rendimiento actual.

## 3. Decisiones de diseño propuestas

Las formas de sintaxis que aparecen aquí son **candidatas**: la forma final la fija el corpus al redactar cada
contrato. Ninguna decisión crea un selector de edición, un segundo modo de lenguaje ni una dependencia externa sin
declararla antes en `architecture.yaml`.

### 3.1 Conflicto que se reporta antes de `.05`/`.06` (`CONFLICT-REPORT`)

`PG-1.11` dejó cumplido «programas sueltos 2026 intactos: corpus sin cambios de esperados». `PG-2.05`, `PG-2.06` y
`PG-2.15` piden vínculos inmutables por defecto, inicialización en la declaración, ámbitos de bloque y migración de
cambios incompatibles. Las reglas estables `LANG.DECL.VARIABLE#R1`, `LANG.SUBPROGRAM.SCOPE#R1`,
`LANG.DECL.UNINITIALIZED#R1` y `LANG.TYPES.INFERENCE#R1` dicen lo contrario. Las dos fuentes son del mismo nivel y la
elección cambia el trabajo, así que no se resuelve aquí:

| Opción D-PG2-01 | Efecto | Coste y riesgo |
|---|---|---|
| A. Reemplazo en 2026 con migración | Forma nueva por defecto; `Definir` sin inicializador y la inferencia flexible pasan a error con migración `.15` | Coherente con ADR-07 y con la decisión del 2026-10-22 sobre cambios incompatibles documentados. Edita esperados estables y reabre la garantía de `.11`; necesita autorización explícita para cambiar esperados |
| B. Coexistencia aditiva | Se añade la forma inmutable con inicialización; `Definir` sigue siendo legal y recibe una advertencia con migración opcional | No rompe programas ni la garantía de `.11`. «Inmutable por defecto» queda como recomendación pedagógica, no como regla |
| C. Distinto por modo (proyecto/archivo suelto) | — | Se descarta: crea un segundo lenguaje dentro de la edición única, que `.11.05` ya excluyó |

Recomendación técnica: A, porque elimina la trampa dinámica de lectura sin valor en los programas migrados, deja más
vínculos como valores SSA sin celda y es la única opción que cumple `.05` literalmente.

**Decisión registrada (2026-10-24): opción A.** Mensaje de la persona: «Elijo D-PG2-01 opción A: reemplazo en 2026 con
migración asistida.» Consecuencias para el plan:

- La forma inmutable con inicialización pasa a ser la forma por defecto de 2026. `Definir` sin inicializador y la
  declaración implícita por primera asignación en flexible pasan a ser error, con migración `.15`.
- `LANG.DECL.VARIABLE#R1`, `LANG.SUBPROGRAM.SCOPE#R1`, `LANG.DECL.UNINITIALIZED#R1` y `LANG.TYPES.INFERENCE#R1` se
  editan como texto oficial en su misma identidad y versión `1.0.0`, sin `cambio`, y se reanclan (`SPEC-VERSION-FREEZE`).
- Para esas reglas se reabre la garantía de `PG-1.11` («corpus 2026 sin cambios de esperados»). La incompatibilidad se
  documenta en los README dueños y en los contratos afectados, y la cubren casos de migración. El resto de la garantía
  de `PG-1.11` sigue vigente.
- La trampa `uninitializedVariableRead` se conserva mientras exista una forma que la pueda producir. Si deja de existir,
  el destino de la regla lo fija el corpus en la iteración 3.
- `.15` queda obligatorio: deja de ser posible el «No aplica» previsto para la opción B.
- La decisión no autoriza en bloque a editar esperados. Antes de tocar casos estables, la iteración 3 presenta la lista
  exacta de casos y esperados afectados, derivados de las reglas, y espera la autorización de esa lista (§9).

### 3.2 Decisiones de representación y compilación

| Decisión | Opciones | Criterio | Elección propuesta y dueño | Condición de reversión |
|---|---|---|---|---|
| D-PG2-02 Registros por valor | Objeto en montón con copia; agregado descompuesto | Sin etiquetas, sin asignación de montón, raíces estáticas | Disposición `RecordLayout` en abi con área escalar y área de referencias separadas, como el marco bicameral. En RI el registro es una tupla de valores SSA (un parámetro de bloque por campo) y se incrusta plano en marcos, objetos, vectores y variantes. Sin cabecera propia ni identidad. Tamaño infinito rechazado por ciclo de contención por valor. README abi/semantic/lowering | E-PG-03 muestra presión de registros o copia dominante en registros grandes; materializar en ranura de marco por encima de un umbral **medido**, con la misma semántica |
| D-PG2-03 Variantes | Etiqueta universal; unión por banco | Raíces estáticas y discriminante solo donde existe variante | Discriminante `u32` en banco escalar; carga útil como unión **por banco**: los escalares de las variantes se solapan entre sí y las referencias entre sí, nunca escalar con referencia. Las ranuras de referencia inactivas valen el centinela nulo, de modo que el mapa de raíces es fijo por tipo. `Opcional<T>` con `T` referencia usa el centinela como `Nada` sin discriminante. README abi/runtime | Medición muestra coste de limpiar ranuras inactivas dominante; evaluar mapa por discriminante con caso negativo de recolector |
| D-PG2-04 Enumerados y `Segun` | Cadena de comparaciones; tabla de saltos | Ordinales densos y exhaustividad estática | Ordinal denso `u32` desde 0 en orden de declaración. `Segun` sobre enumerado/variante con exhaustividad en semantic; terminador `switch` de RI con tabla densa si los ordinales lo permiten y cadena de comparaciones si no; Cranelift recibe `br_table` desde la misma RI. Sin rama implícita: la exhaustividad elimina la trampa de «sin coincidencia». README semantic/ir/codegen | `PERF.PG.MATCH` muestra tabla peor que cadena para pocos casos; elegir por cardinalidad con umbral medido y documentado |
| D-PG2-05 Constantes | Evaluar en ejecución al iniciar; evaluar en compilación | Pureza, presupuesto y mismo resultado que la ejecución | Evaluador en semantic sobre HIR puro con presupuesto de pasos y bytes de texto: literales, aritmética entera comprobada, `+ - * /` binary64, comparación, lógica, concatenación, ordinales y otras constantes. Ciclos entre constantes rechazados con cadena. Sin funciones de biblioteca ni potencia, para no duplicar `pseudolearn_library` ni cambiar la matriz. Resultado plegado como literal de RI. README semantic | Se necesita una función de biblioteca en constantes; ADR propio y cambio de matriz, nunca una copia de la función |
| D-PG2-06 Genéricos | Borrado; diccionarios; monomorfización acotada | ADR-06 ya recomienda monomorfización acotada | El cuerpo genérico se comprueba **una vez** contra sus restricciones (los errores salen en la definición, no por instancia). Semantic recoge el conjunto cerrado de instancias alcanzables desde la entrada con lista de trabajo iterativa y caché por `(identidad genérica, argumentos canónicos)`. Límite tipado de instancias y de profundidad de tipo con diagnóstico y cadena de instanciación; la recursión polimórfica expansiva agota el límite de forma definida. Lowering emite una función RI por instancia. README semantic/lowering | E-PG-03 supera tamaño o tiempo de compilación con controles correctos; compartir código entre instancias de igual disposición, comprobando su equivalencia |
| D-PG2-07 Interfaces | Objetos interfaz con tabla virtual; solo restricciones | `.09` y mundo cerrado | Interfaces nominales como restricciones de genéricos; realización explícita en la declaración del tipo; sin valores de tipo interfaz. Tras monomorfizar, cada llamada de interfaz es directa: cero despacho indirecto nuevo. README semantic | Una fase aprobada pide valores interfaz; ADR propio |
| D-PG2-08 Funciones y clausuras | Puntero a marco; entorno tipado | E-PG-04 y raíces completas | Valor función = identidad de código `u32` (banco escalar) + asa de entorno (banco de referencias, centinela si no captura). El entorno es un objeto con disposición tipada que guarda **solo** lo capturado, nunca el marco. Captura por valor de vínculos inmutables. La llamada a un nombre de función conocido sigue siendo directa; solo la llamada a un valor función es indirecta. README abi/semantic/lowering/vm/codegen | E-PG-04 supera 1,25× frente a llamada directa; eliminar el entorno no escapante es FUT-04 y necesita autorización propia |
| D-PG2-09 Captura mutable | Celda compartida; rechazo | ADR-07 y E-PG-04 | Rechazar captura de vínculo mutable con diagnóstico «captura mutable» (lugar de captura y vínculo). El estado compartido se expresa con un objeto explícito | E-PG-10 o revisión de la persona muestran barrera pedagógica; añadir celda local explícita sin compartir entre tareas |
| D-PG2-10 `Vector` | Arreglo de valores etiquetados; áreas por banco | Recorrido del recolector y localidad | Cabecera común + longitud + capacidad + área escalar `[len×S]` y área de referencias `[len×R]` separadas para elemento registro o variante. El recolector recorre solo el área de referencias. Crecimiento ×2 con aritmética comprobada y límite de bytes/elementos; contador de versión `u32` para invalidación. README abi/runtime/library | Recorrido de elementos registro peor que control en E-PG-03; evaluar disposición intercalada con la misma raíz estática |
| D-PG2-11 `Diccionario` | Árbol ordenado; tabla hash con orden de inserción | Orden observable definido sin heredar el de `HashMap` | Orden observable = orden de inserción. Entradas densas en orden + índice de direccionamiento abierto con índices `u32`. El borrado deja hueco y compacta al superar un umbral; el orden de los restantes se conserva. Claves: entero, carácter, cadena, lógico y enumerado; real y objetos rechazados. Función hash propia del runtime, sin dependencia nueva; resistencia a colisiones adversarias medida | Campaña adversaria degrada a cuadrático en cargas razonables; hash con clave por ejecución, que no altera observables porque el orden no depende del hash |
| D-PG2-12 Invalidación | Rechazo estático; versión dinámica | Alias y determinismo | Toda modificación estructural incrementa la versión; `Para Cada` la compara una vez por paso y produce trampa definida con sitio. La lectura y la escritura de elementos existentes no invalidan | Coste por paso medible frente a control; nunca quitar la comprobación sin prueba de imposibilidad |
| D-PG2-13 Salida y limpieza | Pila dinámica de manejadores; duplicación estructurada | Coste nulo sin limpieza y una ejecución por salida | Lowering emite la limpieza en cada arista de salida del ámbito (retorno, propagación, salida de bucle, fin normal), en orden inverso de registro. Sin estructura en ejecución si no hay limpieza. Una trampa del programa termina sin limpieza de usuario en PG-2, porque no hay recursos externos (PG-3 lo revisa). README lowering/ir | El crecimiento del código por duplicación supera lo medido; bloque de salida compartido con selector |
| D-PG2-14 `Resultado` | Excepciones; valor con propagación visible | ADR-07 | `Resultado<T,E>` como variante genérica; forma de propagación candidata con palabra del perfil, que rama por discriminante y retorna temprano pasando por la limpieza. Una llamada en posición de sentencia con tipo `Resultado` es error salvo descarte explícito con forma propia. Sin escape tipo `unwrap` | E-PG-10 muestra barrera; simplificar forma, nunca permitir el descarte silencioso |
| D-PG2-15 Bytecode | Instrucción ancha; formas nuevas de 8 bytes | Mantener el despacho de 8 bytes | Instrucciones nuevas (discriminante, carga útil, valor función, llamada indirecta, vector, diccionario, versión) con operandos de 16 bits; los límites de campos, variantes e instancias se derivan de esos 16 bits y se diagnostican antes de emitir. Superinstrucciones solo tras medir frecuencia de bigramas | Un programa razonable supera 16 bits; ADR propio para la ampliación |
| D-PG2-16 Migración | Reescritura al abrir; diff revisable | `.15` y D-PG2-01 = A | Operación de API que devuelve ediciones textuales revisables y diagnósticos de intervención manual; la CLI la muestra como diff y escribe solo con orden explícita; nunca reescritura al abrir ni en el servicio. README service/API/CLI | Obligatoria por la opción A; solo se revisa la forma de la operación, no su existencia |

### 3.3 Criterios de rendimiento propios de PseudoLearn

1. **Bicameral siempre.** Toda disposición nueva separa palabras escalares y de referencia. Así los mapas de raíces
   siguen estáticos por tipo, el recolector no consulta discriminantes y los bancos siguen sin etiquetas por valor.
2. **Resolver en compilación.** Exhaustividad, instancias genéricas, llamadas de interfaz, constantes y disposiciones
   se deciden antes de la RI. En el despacho no se buscan nombres, instancias ni tablas de interfaz.
3. **Un único dueño de disposición.** abi declara cada disposición una vez; VM, runtime y Cranelift la consumen. Un
   desplazamiento calculado en dos sitios es un defecto, no una optimización.
4. **Copias honestas.** Un registro se copia por palabras; la copia cuesta O(tamaño) y se mide (`PERF.PG.VALUE`), no
   se promete barata. Las colecciones son referencias: asignarlas no copia elementos.
5. **Camino caliente limpio.** Construcción de diagnósticos, cadenas de instanciación y trampas en rutas frías;
   comprobación de versión fuera del cuerpo del elemento cuando el lowering pueda hacerlo sin cambiar observables.
6. **Inmutabilidad útil.** Un vínculo inmutable no necesita celda ni recarga: se queda en valor SSA, se captura por
   copia y facilita el plegado que codegen ya hace. Se mide como efecto, no se usa para justificar optimizaciones
   FUT-04.
7. **Límites con terminación definida.** Pasos de constantes, instancias, profundidad de tipo, elementos y bytes de
   colección: rechazo tipado, aritmética comprobada antes de reservar y presupuestos inyectables en tests sin
   asignar gigabytes.
8. **Medir antes de afirmar.** Instrucciones, tamaño de RI/bytecode/objeto y asignaciones como señales tempranas
   baratas; CPU y percentiles solo en la campaña de `.17` bajo `PERF.PROTOCOL`. Contadores de caché o ramas son
   diagnóstico opcional, nunca condición de test.

Como referencia de método se toman la tabla compacta con orden de inserción de CPython y `indexmap` de Rust, y el
análisis de exhaustividad por matriz de patrones de OCaml/Rust, sin adoptar su sintaxis ni sus cifras. Lo tomado y lo
rechazado se registra en el README dueño al implementar (§3 de `AGENTS.md`).

## 4. Desglose por punto

Cada bloque sigue especificación → casos → tests → código → documentación → verificación. Los casos del lenguaje
viven en el corpus; los tests Rust prueban algoritmos, disposiciones, invariantes y fronteras, sin duplicar esos
programas. La tarea `.06` de cada bloque es **verificación acotada** según §7.1: nunca la suite completa.

### PG-2.01 · Constantes y enumerados

- [x] `PG-2.01.01` Especificar constante de módulo y local con inicializador puro, subconjunto evaluable (D-PG2-05), presupuesto de pasos/bytes, ciclos entre constantes y visibilidad de PG-1. Especificar enumerado: miembros, ordinal, igualdad, formato de salida, conversión explícita y prohibición de aritmética.
- [x] `PG-2.01.02` Casos: constante encadenada, desbordamiento entero en constante, división por cero en constante, ciclo directo/indirecto, presupuesto justo/encima, enumerado vacío, de un miembro, duplicado, miembro homónimo de otro enumerado, `Escribir` de enumerado en es/en.
- [x] `PG-2.01.03` Tests espejo del evaluador (orden, presupuesto inyectado, misma aritmética que runtime para enteros y binary64) y del registro de enumerados.
- [x] `PG-2.01.04` Gramática/vocabulario por generador; registro y evaluador en semantic; plegado como literal en lowering; ordinal `u32` en RI; ficha de ayuda es/en.
- [x] `PG-2.01.05` README syntax/semantic/lowering: subconjunto, presupuesto y por qué no se usa la biblioteca.
- [x] `PG-2.01.06` Verificación acotada: `--only` de los contratos tocados en engine/aot, tests espejo de semantic/lowering y conjunto centinela si cambió el vocabulario.

### PG-2.02 · Registros por valor

- [x] `PG-2.02.01` Especificar declaración de registro, construcción completa, acceso y actualización de campo, igualdad estructural, asignación y paso como copia, retorno por valor, campos permitidos (sin arreglos por valor) y rechazo de contención por valor recursiva.
- [x] `PG-2.02.02` Casos: registro de un campo, vacío si el corpus lo admite, anidado, autocontenido directo e indirecto, copia independiente tras mutación, campo referencia compartido tras copia, igualdad con campo real `-0`/NaN según `LANG.OPS.COMPARISON`.
- [x] `PG-2.02.03` Tests de `RecordLayout` (desplazamientos, áreas por banco, alineación, registro anidado aplanado) y del detector de ciclos de contención con grafos sembrados.
- [x] `PG-2.02.04` Disposición en abi; registro y ciclos en semantic; tupla SSA y copia en lowering; incrustación en marco/objeto/vector; mapas de raíces de campos referencia en VM y pila sombra AOT.
- [x] `PG-2.02.05` README abi/runtime/semantic/lowering/codegen; `RT.ABI`/`MEM.VALUE.COPY` editados como texto oficial si cambia su alcance.
- [x] `PG-2.02.06` Verificación acotada con recolección forzada (`--operation properties` del contrato) y medición de bytes de objeto/bytecode frente a control.

### PG-2.03 · `Opcional<T>` y `Resultado<T,E>`

- [x] `PG-2.03.01` Especificar ambos como variantes genéricas incorporadas, construcción, consulta, propagación visible (D-PG2-14), descarte rechazado y su forma explícita de descarte; relación con la trampa de lectura sin inicializar.
- [x] `PG-2.03.02` Casos: propagación en cadena de tres llamadas, propagación desde `Para Cada` con limpieza diferida explícitamente a PG-2.11, `Resultado` ignorado en sentencia, descartado explícito, `Opcional` de objeto con centinela, `Opcional<Opcional<T>>`, tipo de error distinto en propagación.
- [x] `PG-2.03.03` Tests de disposición de variante (unión por banco, centinela en ranuras inactivas, nicho para referencia) y del análisis de descarte.
- [x] `PG-2.03.04` Variantes en abi/semantic; propagación en lowering con aristas de retorno; limpieza de Para Cada diferida a PG-2.11; instrucciones de discriminante/carga útil en RI, bytecode y Cranelift.
- [x] `PG-2.03.05` README abi/semantic/lowering/ir/codegen; diagnóstico «resultado sin tratar» con caminos manejar/propagar en `DIAG.CATALOG`.
- [x] `PG-2.03.06` Verificación acotada VM/AOT y recolección forzada con ranuras de referencia inactivas.

### PG-2.04 · `Segun` exhaustivo y patrones básicos

- [x] `PG-2.04.01` Ampliar `LANG.CONTROL.SWITCH` como texto oficial: selector enumerado/variante, patrón literal, miembro, variante con vínculos de carga útil y comodín; exhaustividad y patrón inalcanzable; conservar sin cambios el `Segun` actual sobre literales.
- [x] `PG-2.04.02` Casos: variante omitida (con la lista de faltantes), duplicada, inalcanzable tras comodín, enumerado de un miembro, cero ramas sobre enumerado vacío, vínculo de carga útil sin usar, todos los casos previos de `Segun` intactos.
- [x] `PG-2.04.03` Tests del análisis de exhaustividad (matriz de patrones), del orden de diagnósticos y de la selección tabla/cadena por cardinalidad.
- [x] `PG-2.04.04` Análisis en `switch_checker`/semantic; terminador `switch` en RI y verificador; tabla en bytecode y `br_table` en Cranelift.
- [x] `PG-2.04.05` README semantic/ir/codegen; ficha de ayuda de «rama faltante».
- [x] `PG-2.04.06` Verificación acotada: `--only LANG.CONTROL.SWITCH` en engine/aot y LANG.TYPES.RELATIONS para patrones.

### PG-2.05 · Vínculos inmutables e inicialización en la declaración

D-PG2-01 resuelta con la opción A (§3.1); la edición de esperados estables espera la autorización de su lista.

- [x] `PG-2.05.01` Con la opción A, especificar vínculo inmutable por defecto, forma de mutación explícita e inicialización obligatoria; distinguir inmutabilidad del vínculo de la del objeto; `Definir` sin inicializador y la inferencia flexible por primera asignación como error sin migrador, por autorización posterior; destino de la trampa de lectura sin valor.
- [x] `PG-2.05.02` Casos: reasignación de inmutable, mutable sin mutar (advertencia), inicializador que lee el propio vínculo, objeto mutado a través de vínculo inmutable, nombre de un carácter, `Definir` sin inicializador rechazado sin migrador; casos previos editados solo tras autorizar su lista exacta.
- [x] `PG-2.05.03` Tests de `flow`/`flow_bindings` y del registro de locales con el nuevo atributo de mutabilidad.
- [x] `PG-2.05.04` Atributo de mutabilidad en semantic; lowering conserva los inmutables como valores SSA sin celda.
- [x] `PG-2.05.05` README semantic/lowering; registro de la sintaxis oficial de 2026 sin compatibilidad ni migrador.
- [x] `PG-2.05.06` Verificación acotada más conjunto centinela de archivo suelto (§7.1), porque toca declaraciones de todos los programas.

### PG-2.06 · Ámbitos léxicos de bloque

D-PG2-01 resuelta con la opción A (§3.1). La persona autorizó sustituir las restricciones y actualizar la edición
oficial sin migradores ni compatibilidad. El cierre se registra por subpunto comprobado; el bloque completo sigue abierto.

- [ ] `PG-2.06.01` Editar `LANG.SUBPROGRAM.SCOPE` como texto oficial: bloque de `Si`, `Mientras`, `Para`, `Repetir`, `Segun` y `Para Cada` como ámbito; sombreado (rechazado o advertido, a fijar en corpus); vida de vínculos y relación con clausuras.
- [x] `PG-2.06.02` Casos: uso fuera del bloque, sombreado de parámetro, mismo nombre en bloques hermanos, bloque vacío, anidación de tres niveles, variable de `Para` tras el bucle.
- [x] `PG-2.06.03` Tests de la pila de ámbitos (tabla contigua con marcas de nivel, sin mapas por bloque).
- [x] `PG-2.06.04` Resolución en semantic; reutilización de ranuras de marco por bloques disjuntos solo si no cambia observables de la vista de estado.
- [x] `PG-2.06.05` README semantic; diagnóstico «declaración fuera de ámbito» con origen y posible sombreado.
- [ ] `PG-2.06.06` Verificación acotada más conjunto centinela de archivo suelto.

Estado de cierre: `.02`, `.03`, `.04` y `.05` cumplidos con los casos del corpus, tests dirigidos y
verificadores registrados en §11.1.3. `.04` no introduce reutilización de ranuras. `.01` conserva pendiente
la regla de `Para Cada`, cuya integración corresponde a PG-2.11 según el alcance aprobado; `.06` conserva
pendiente completar el conjunto centinela de §7.1. El transporte de ámbitos a estado y raíces VM/AOT
sigue pendiente y, por tanto, no se cierra `PG-2.06` como capacidad completa.

### PG-2.07 · Funciones como valores y clausuras

- [ ] `PG-2.07.01` Especificar tipo función, referencia a subprograma como valor, literal de función candidato, captura por valor de inmutables, rechazo de captura mutable (D-PG2-09), igualdad (no comparables), formato de salida y escape del ámbito.
- [ ] `PG-2.07.02` Casos: clausura que sobrevive al marco, captura de registro y de objeto, clausura sin captura, recursión mediante valor, captura mutable rechazada, clausura guardada en `Vector`, recolección forzada con la clausura como única raíz.
- [ ] `PG-2.07.03` Tests de `ClosureLayout`, del cálculo del conjunto capturado (solo lo usado) y del mapa de raíces del entorno.
- [ ] `PG-2.07.04` Captura en semantic; entorno y llamada indirecta en lowering/RI/bytecode; tabla de funciones en VM y `call_indirect` en Cranelift; raíces del entorno en VM y pila sombra.
- [ ] `PG-2.07.05` README abi/semantic/lowering/vm/codegen; diagnóstico «captura mutable compartida» con cadena de tipos y lugar.
- [ ] `PG-2.07.06` Verificación acotada VM/AOT, propiedades con recolección forzada y señal temprana de E-PG-04.

### PG-2.08 · Genéricos de primer orden

- [ ] `PG-2.08.01` Editar `LANG.CLASS.OUT-OF-SCOPE` como texto oficial para retirar genéricos de lo rechazado; especificar parámetros de tipo en registros, variantes, funciones y clases, inferencia local de argumentos, comprobación única del cuerpo y límites de instancias/profundidad.
- [ ] `PG-2.08.02` Casos: instancia única, 10 instancias, recursión polimórfica expansiva, argumento de tipo que viola restricción, inferencia ambigua, genérico no instanciado (sin coste), límite justo/encima.
- [ ] `PG-2.08.03` Tests del recolector de instancias (lista de trabajo iterativa, caché canónica, independencia del orden de descubrimiento) y del límite con cadena.
- [ ] `PG-2.08.04` Parámetros de tipo en semantic; recolección cerrada de instancias; una función RI por instancia en lowering; nombres de instancia estables para mapas de fuente y fallos AOT.
- [ ] `PG-2.08.05` README semantic/lowering: monomorfización acotada, por qué no borrado ni diccionarios, y condición de reversión.
- [ ] `PG-2.08.06` Verificación acotada y medición de instancias, bytes de RI/bytecode/objeto y tiempo de compilación frente a control no genérico.

### PG-2.09 · Interfaces nominales mínimas

- [ ] `PG-2.09.01` Editar `LANG.CLASS.OUT-OF-SCOPE` para retirar interfaces de lo rechazado y actualizar sus casos con autorización; especificar interfaz como conjunto de firmas, realización explícita, restricción en genéricos, sin valores interfaz ni herencia múltiple de implementación.
- [ ] `PG-2.09.02` Casos: realización completa, firma faltante, firma incompatible, dos interfaces sobre un tipo, interfaz vacía, restricción no satisfecha con su cadena, intento de usar interfaz como tipo de valor.
- [ ] `PG-2.09.03` Tests de la tabla de realizaciones y de la resolución estática de la llamada tras monomorfizar.
- [ ] `PG-2.09.04` Registro de interfaces y realizaciones en semantic; llamadas directas en lowering; identidades de interfaz/realización/restricción en la vista pública.
- [ ] `PG-2.09.05` README semantic; ficha de ayuda de interfaz y realización.
- [ ] `PG-2.09.06` Verificación acotada; comprobar en RI que no aparece ninguna llamada indirecta por interfaz.

### PG-2.10 · `Vector` y `Diccionario`

- [ ] `PG-2.10.01` Especificar `Vector<T>` y `Diccionario<K,V>`: creación, longitud, acceso con trampa fuera de rango, inserción, borrado, búsqueda con `Opcional`, orden observable (inserción para diccionario), claves admitidas, formato de salida, límites de elementos/bytes e invalidación (D-PG2-12).
- [ ] `PG-2.10.02` Casos: vacío, un elemento, crecimiento por varias duplicaciones, borrar y reinsertar (posición al final), clave cadena con NFC distinto, clave real rechazada, límite justo/encima, vector de registros y de clausuras.
- [ ] `PG-2.10.03` Tests de runtime: crecimiento con aritmética comprobada, compactación de huecos, colisiones adversarias sembradas, áreas por banco y recorrido del recolector solo sobre referencias.
- [ ] `PG-2.10.04` Disposiciones en abi, estructuras en runtime, fachada en library, instrucciones en RI/bytecode/VM y llamadas al runtime AOT.
- [ ] `PG-2.10.05` README abi/runtime/library: diseño, hash, compactación y por qué no `HashMap`.
- [ ] `PG-2.10.06` Verificación acotada, recolección forzada y medición de tamaño iOS/Wasm (crece el runtime).

### PG-2.11 · `Para Cada`, salida anticipada y limpieza

- [ ] `PG-2.11.01` Especificar `Para Cada` sobre `Vector`, `Diccionario` y arreglo de una dimensión; salida anticipada de bucle; forma de limpieza candidata ligada al ámbito; orden inverso; ejecución exactamente una vez por salida; comportamiento ante trampa (D-PG2-13).
- [ ] `PG-2.11.02` Casos: colección vacía, modificación durante la iteración (trampa con sitio), salida en primera/última iteración, retorno y propagación dentro de limpieza anidada, dos limpiezas en orden inverso, limpieza sin salida anticipada.
- [ ] `PG-2.11.03` Tests de lowering que cuentan aristas de salida y bloques de limpieza (una ejecución por camino) y del orden.
- [ ] `PG-2.11.04` Sintaxis por generador; lowering estructurado con limpieza en cada arista de salida; comprobación de versión por paso.
- [ ] `PG-2.11.05` README lowering/ir; ficha de ayuda de cada forma nueva.
- [ ] `PG-2.11.06` Verificación acotada y diferencial de gemelos sobre los casos nuevos.

### PG-2.12 · Verificador de RI para disposiciones

- [ ] `PG-2.12.01` Editar `IR.WELL-FORMEDNESS` e `IR.INSTRUCTIONS` como texto oficial: tipos de registro/variante/función/colección, uso de carga útil dominado por la prueba de su discriminante, campo existente, banco correcto, entorno con disposición declarada y límites de 16 bits.
- [ ] `PG-2.12.02` Casos negativos de RI textual: campo inexistente, referencia en ranura escalar, carga útil sin prueba dominante, variante fuera de rango, entorno sin raíz declarada, instancia genérica sin definición.
- [ ] `PG-2.12.03` Tests del verificador con un caso negativo por código de rechazo, más ida y vuelta del formato textual.
- [ ] `PG-2.12.04` Ampliar `verifier`/`type_checker_*` en ir usando `dominance.rs`; el verificador de bytecode rechaza lo equivalente.
- [ ] `PG-2.12.05` README ir/bytecode.
- [ ] `PG-2.12.06` Verificación acotada de `--only IR.WELL-FORMEDNESS` e `IR.INSTRUCTIONS` y tests de ir/bytecode. Se desarrolla junto a cada iteración que añade instrucciones.

### PG-2.13 · Paridad VM/AOT

- [ ] `PG-2.13.01` Declarar en cada contrato nuevo los sujetos `engine` y `aot` y las capacidades necesarias; ningún caso se marca no aplicable en AOT sin motivo de capacidad.
- [ ] `PG-2.13.02` Por cada iteración, casos de trampa con sitio exacto en ambos motores (fuera de rango, invalidación, desbordamiento en registro, límite de colección).
- [ ] `PG-2.13.03` Diferencial de gemelos y comparación VM/AOT acotados a los contratos de la iteración.
- [ ] `PG-2.13.04` Corregir divergencias en el dueño de la disposición, nunca con ramas por motor.
- [ ] `PG-2.13.05` README engine: tabla de paridad de construcciones nuevas.
- [ ] `PG-2.13.06` Al cierre, `--only` de todos los contratos de PG-2 en engine y aot (lista en §11), sin conformidad aot completa.

### PG-2.14 · Diagnósticos pedagógicos ADR-07

- [ ] `PG-2.14.01` Añadir a `DIAG.CATALOG`/`DIAG.MESSAGES` «resultado sin tratar», «captura mutable compartida», «rama faltante», «declaración fuera de ámbito», límites de instancia/constante y realización incompleta, con argumentos tipados.
- [ ] `PG-2.14.02` Casos de cada diagnóstico en es/en con igual código y argumentos; un principal por causa.
- [ ] `PG-2.14.03` Verificadores existentes `SEE-MESSAGE-PARITY` y `SEE-MESSAGE-ARGUMENTS` sobre las plantillas nuevas, con su negativo ya presente.
- [ ] `PG-2.14.04` Plantillas generadas; argumentos desde semantic sin prosa en código.
- [ ] `PG-2.14.05` README diagnostics.
- [ ] `PG-2.14.06` Verificación acotada de los contratos DIAG y `see validate`. Se desarrolla con cada iteración que añade un diagnóstico.

### PG-2.15 · Migración asistida

Obligatorio por la opción A de D-PG2-01 (§3.1); depende de que `.05` y `.06` fijen las formas que se migran.

- [ ] `PG-2.15.01` Especificar operación de migración: entrada, ediciones textuales revisables, diagnóstico de intervención manual cuando no se preserva la semántica, idempotencia y ninguna escritura implícita; CLI con diff y escritura explícita.
- [ ] `PG-2.15.02` Casos: `Definir` + asignación única → vínculo inicializado, variable reasignada → mutable, lectura antes de asignar → intervención manual, programa ya migrado sin ediciones, comentarios y formato conservados.
- [ ] `PG-2.15.03` Tests de la migración sobre árbol sin pérdida y de la equivalencia de observables entre original y migrado.
- [ ] `PG-2.15.04` Migración en service sobre el árbol sin pérdida; operación en API; orden en CLI.
- [ ] `PG-2.15.05` README service/API/CLI.
- [ ] `PG-2.15.06` Verificación acotada: casos de migración, tests de service y CLI de la orden nueva; ejecutar los programas migrados del conjunto centinela.

### PG-2.16 · Vista pública del programa

- [ ] `PG-2.16.01` Editar `API.PROGRAM.VIEW` como texto oficial: identidades de enumerado, registro, variante, interfaz, realización, restricción, captura e iteración, con relaciones y procedencia.
- [ ] `PG-2.16.02` Casos de vista por construcción y negativo de relación con procedencia ajena.
- [ ] `PG-2.16.03` Tests de `program_view_*` y del consumidor Dart que la proyecta (solo lectura; PG-A dibuja).
- [ ] `PG-2.16.04` Datos en API; adaptar `rust_program_view.dart` solo si el payload lo exige.
- [ ] `PG-2.16.05` README API y app (sección de frontera), sin anunciar diagramas nuevos.
- [ ] `PG-2.16.06` Verificación acotada de `--only API.PROGRAM.VIEW` en engine/app y tests Dart del archivo tocado.

### PG-2.17 · Experimentos y métricas

- [ ] `PG-2.17.01` Fijar protocolos de E-PG-03 y E-PG-04 y los candidatos `PERF.PG.VALUE`, `.RESULT`, `.MATCH`, `.GENERICS`, `.CLOSURE`, `.COLLECTION` y `.CLEANUP`, separados de los PERF vigentes.
- [ ] `PG-2.17.02` Cargas sembradas y controles de igual semántica (§7.3–7.4).
- [ ] `PG-2.17.03` Tests del arnés con muestra ausente, salida incorrecta y mezcla de máquinas: ninguna campaña inválida produce verde.
- [ ] `PG-2.17.04` Ampliar `pseudolearn_bench_worker` con subcomandos documentados antes de usarlos.
- [ ] `PG-2.17.05` Materiales de E-PG-10 (tareas, guion, consentimiento, análisis) para la persona; registrar resultado o diferimiento suyo.
- [ ] `PG-2.17.06` Ejecutar campañas en segundo plano, registrar crudos y resumen, y reportar umbrales no alcanzados sin ajustar controles.

## 5. Capas y archivos

`E` = `packages/pseudolearn_engine/crates`, `S` = `packages/pseudolearn_spec`, `A` = `apps/pseudolearn_app`.
«Nuevo» es propuesta. Antes de cada iteración se fija la lista concreta y se responden otra vez las tres preguntas de
`AGENTS.md` §1.

| Archivos previstos | Capa; imports permitidos / prohibidos | Dueño y motivo; puntos |
|---|---|---|
| Este archivo; enlace de PG-2 en el plan general | Documentación transitoria / sin dependencia desde código o README | Plan detallado; preparación |
| `S/specifications/lang/`: `lang.decl.variable`, `lang.subprogram.scope`, `lang.decl.uninitialized`, `lang.types.inference`, `lang.class.out-of-scope`, `lang.control.switch` editados; nuevos de constantes, enumerados, registros, variantes, patrones, funciones, genéricos, interfaces, colecciones, iteración y limpieza | Datos normativos / sin código ni enlaces externos | Corpus; `.01`–`.11`. IDs definitivos tras auditoría de dueños |
| `S/specifications/{ir,diag,api,mem,rt,perf}/` afectados; `S/specifications/cases/migration.json` si aplica | Datos normativos | `.12`–`.17` |
| `E/pseudolearn_abi/src/`: nuevos `record_layout.rs`, `variant_layout.rs`, `closure_layout.rs`, `vector_layout.rs`, `dictionary_layout.rs` | Sin imports internos / sin runtime, ir ni codegen | Una disposición por archivo, consumida por VM y AOT; `.02`, `.03`, `.07`, `.10` |
| `E/pseudolearn_syntax/src/` y generados por `build.rs` | source/diagnostics/lexicon / sin semantic | Formas nuevas por generador (`GEN-NO-HAND-COPY`); `.01`–`.11` |
| `E/pseudolearn_semantic/src/`: nuevos `constant_evaluator.rs`, `enum_registry.rs`, `record_registry.rs`, `variant_types.rs`, `pattern_exhaustiveness.rs`, `generic_parameters.rs`, `instance_collector.rs`, `interface_registry.rs`, `capture_analysis.rs`, `block_scopes.rs`, `result_usage.rs`; `switch_checker.rs`, `flow*.rs`, `local_registry.rs` modificados | Matriz actual / sin library, runtime, ir ni codegen | Tipado, resolución y límites; `.01`–`.09`, `.14` |
| `E/pseudolearn_lowering/src/`: nuevos `statements_for_each.rs`, `cleanup_edges.rs`, `records.rs`, `variants.rs`, `closures.rs`, `instances.rs`; `statements_switch.rs`, `environment.rs` modificados | source/semantic/ir/diagnostics / sin runtime ni codegen | HIR → RI; `.02`–`.11` |
| `E/pseudolearn_ir/src/`: `types.rs`, `model.rs`, `verifier*.rs`, `type_checker_*`, `parser.rs`, `printer.rs` | source/abi / sin semantic | Tipos, instrucciones y verificador; `.12` |
| `E/pseudolearn_bytecode`, `E/pseudolearn_vm/src/{load,evaluate,dispatch}`, `E/pseudolearn_vm_dispatch` (generados) | Matriz actual | Instrucciones de 8 bytes y raíces; `.02`–`.11` |
| `E/pseudolearn_runtime/src/`: nuevos `vector/`, `dictionary/`, `record_copy.rs`, `environment.rs`; `heap/` raíces | abi/diagnostics / sin library ni VM | Estructuras y recolector; `.02`, `.07`, `.10` |
| `E/pseudolearn_library/src/`: nuevos `vector_operations.rs`, `dictionary_operations.rs` | runtime/diagnostics | Fachada de operaciones; `.10` |
| `E/pseudolearn_codegen/src/`: nuevos `lower_records.rs`, `lower_variants.rs`, `lower_closures.rs`, `lower_collections.rs`, `lower_switch_table.rs`; `shadow_stack.rs`, `class_table.rs`; `E/pseudolearn_aot_rt` llamadas | Matriz actual; `unsafe` solo donde ya está declarado | Paridad AOT; `.13` |
| `E/pseudolearn_service/src/`: `help_catalog.rs` generado, nuevo `migration.rs` | Matriz actual / sin VM ni AOT | Ayuda y migración; `.15`, C09 |
| `E/pseudolearn_api/src/`: `program_view*.rs`, nueva `migration_operations.rs` | Matriz actual | Vista pública y migración; `.15`, `.16` |
| `apps/pseudolearn_cli/src/`: nueva `migrate_command.rs` | Solo API pública | Diff y escritura explícita; `.15` |
| `A/lib/engine/rust/rust_program_view.dart` y su test espejo, solo si cambia el payload | engine → model/ports / sin Flutter | Lectura de la vista; `.16` |
| `E/pseudolearn_bench_worker/src/` subcomandos nuevos | Tooling, matriz actual | `.17` |
| README de cada crate tocado y `architecture.yaml` si cambia la matriz | Documentación dueña | Todos |

No se prevén cambios de matriz: las decisiones D-PG2-05 y D-PG2-11 evitan importar library desde semantic y añadir
dependencias externas al runtime. Si una iteración los necesitara, se declara y documenta antes del código. Los crates
nuevos o tocados conservan `#![forbid(unsafe_code)]` salvo los ya declarados. Cada fuente nueva tiene test espejo en
`tests/` o hermano `*_tests.rs`; los generados se regeneran desde su dueño.

## 6. Presupuestos de rendimiento y seguridad

### 6.1 Qué bloquea y qué se mide

| Tipo | Criterio y control | Tratamiento |
|---|---|---|
| Corrección obligatoria | Resultados derivados de reglas; igualdad VM/AOT; raíces completas bajo recolección forzada; verificador rechaza disposiciones inválidas | Pruebas deterministas; un fallo bloquea el punto |
| PERF vigentes | `PERF.AOT.LEVEL`, `PERF.ARTIFACT.SIZE`, `PERF.PROTOCOL`, `PERF.SUITE.CORE` | Se respetan y se vuelven a medir solo cuando la iteración toca su ruta; no se rebajan |
| Suite pura sin regresión | Candidata ≤2 % de sobrecoste sobre `PERF.SUITE.CORE` por infraestructura nueva inactiva (ADR-06) | Una medición al cierre en `.17`; señal temprana por iteración: instrucciones de bytecode de la suite sin cambios |
| E-PG-03 | Tiempo/bytes crecen como máximo proporcionalmente al número de instancias; recorrido ≤1,10× control no genérico; límite tipado ante expansión | Campaña de `.17`; si falla tamaño, evaluar compartir código de igual disposición |
| E-PG-04 | Cero pérdida o alias indebido; memoria liberable al cerrar el último dueño; llamada indirecta ≤1,25× control directo | Campaña de `.17`; si falla, reportar y pedir autorización antes de cualquier optimización FUT-04 |
| `PERF.PG.MATCH` | `Segun` exhaustivo frente a selección equivalente; tamaño de código | Candidato; sin ratio inventado |
| `PERF.PG.VALUE` | Asignaciones de montón (cero esperado para registros en marco) y copia por bytes | Candidato; contar asignaciones es determinista y puede ser test |
| `PERF.PG.RESULT` | Propagación frente a rama manual equivalente; bytes por variante | Candidato |
| `PERF.PG.COLLECTION` | Operaciones, colisiones adversarias, bytes por elemento, colección vacía | Candidato; peor caso adversario informado |
| `PERF.PG.CLEANUP` | Coste nulo sin limpieza (mismas instrucciones que control); cero doble ejecución | El primer criterio es comprobable como test determinista |
| Tamaño de artefactos | iOS arm64 ≤3 MiB y Wasm Brotli ≤600 KiB con margen iOS de ~0,32 % | Medir en `.10` y al cierre; si se supera, reportar sin quitar funcionalidad ni rebajar el presupuesto |

Los percentiles y cocientes de tiempo no se comprueban en `cargo test`. Sí son tests las magnitudes deterministas:
número de instancias, instrucciones emitidas, asignaciones de montón, bytes de disposición y aristas de limpieza. No se
exige cobertura de líneas del 100 %, cero asignaciones globales ni equivalencia entre máquinas.

### 6.2 Recursos y fronteras

- Presupuestos inyectables y con valor por defecto fijado en corpus tras medir: pasos de constante, bytes de texto en
  constante, instancias genéricas, profundidad de tipo, elementos y bytes de colección. Los tests prueban justo
  debajo, en el límite y encima, sin asignar memoria real grande.
- Aritmética comprobada antes de reservar o crecer; rechazo tipado ante tamaño no representable.
- Ningún pánico ante programas del corpus o generados; los defectos internos siguen `DIAG.ENGINE.INTERNAL-FAULT`.
- Las ranuras inactivas de variantes y las ranuras de bloques terminados no retienen objetos vivos indebidamente; se
  prueba con recolección forzada y contadores del montón.
- La migración nunca escribe sin orden explícita y nunca altera archivos fuera de lo pedido.

## 7. Pruebas y experimentos

### 7.1 Política de pruebas acotadas

Esta política aplica la decisión de la persona del 2026-10-24 y la constancia de §0. Es obligatoria en todas las
iteraciones de PG-2, incluido el cierre.

**Se ejecuta en cada iteración**, solo para lo desarrollado:

| Qué | Cómo se acota | Orden de referencia |
|---|---|---|
| Casos del corpus de cada contrato tocado | `--only <ID>` por contrato, sujeto `engine` y, si hay ejecución, `aot` | `cargo run --locked -p see_cli --bin see -- conform --subject engine --only <ID>` |
| Propiedades del contrato tocado | Solo si el contrato las declara | `… conform --subject aot --only <ID> --operation properties` |
| Tests espejo de los archivos cambiados | Por crate y por archivo de test | `cargo test -p <crate> --test <archivo>`, o filtro de nombre `cargo test -p <crate> <filtro>` |
| Consumidores directos de una frontera cambiada | Solo el consumidor que lee el dato cambiado | p. ej. `cargo test -p pseudolearn_api --test <archivo>`; `flutter test test/engine/rust/<archivo>_test.dart` |
| Verificadores estáticos del miembro | Rápidos y sin ejecutar programas | `cargo fmt --check`, `cargo clippy -p <crate> --all-targets -- -D warnings`, `rust-checks all .` |
| Integridad del corpus | Cuando se editó una especificación | `see validate`, `see lock --check`, `see export --check` |

**No se ejecuta por defecto** en ninguna iteración: `cargo xtask verify` de cualquier miembro, `cargo test
--workspace`, `see conform --subject <sujeto>` sin `--only`, `flutter test` completo, `bash tool/bridge.sh
clean-checkout`, `bash tool/wasm.sh test`, `cargo deny check` y las campañas de medición.

**Disparadores cerrados de ampliación.** Solo estos amplían la selección, y la ampliación se limita a lo que dispara:

| Disparador | Ampliación |
|---|---|
| Cambió el vocabulario o la gramática generados (palabra reservada nueva) | Conjunto centinela de archivo suelto: `--only` de `LANG.LEXICAL.KEYWORD`, `LANG.LEXICAL.IDENTIFIER`, `LANG.PROFILE.VOCABULARY`, `LANG.PROFILE.TRANSLATION`, `LANG.SYNTAX.GRAMMAR`, `LANG.PROGRAM.STRUCTURE` y `LANG.CLASS.OUT-OF-SCOPE`, más tests de syntax/lexicon |
| Cambió `IR.INSTRUCTIONS` o el despacho generado | Tests de ir, bytecode y vm_dispatch; diferencial de gemelos sobre los contratos de la iteración |
| Cambió el payload de API o del puente | Tests del consumidor Dart y `bash tool/test_bridge.sh`; `bash tool/wasm.sh test` solo si cambió el formato JSON que consume Wasm |
| Cambió una dependencia o `Cargo.lock` | `cargo deny check` del miembro |
| Cambió runtime, library o abi de forma que crece el binario | Medición de tamaño iOS/Wasm de `PERF.ARTIFACT.SIZE` |
| Falló una prueba dirigida por causa no explicada por el cambio | La suite del crate de esa prueba, una vez |
| La evidencia disponible no cubre un riesgo nombrado en §8 | La selección mínima que lo cubra, justificada en el registro |

**Prácticas de velocidad.** Las órdenes que pueden pasar de dos minutos se lanzan en segundo plano y se espera su
notificación, sin bucles de sondeo. No se ejecuta `cargo clean` ni se cambia de `CARGO_TARGET_DIR` entre iteraciones,
para reutilizar la compilación incremental. Una selección no se repite si su entrada no cambió desde la última
ejecución en verde. Las selecciones `--only` se agrupan en una sola invocación de shell para pagar una compilación de
`see_cli`. El objetivo orientativo de la verificación de una iteración es de pocos minutos de reloj; no es un test.

**Registro obligatorio.** Cada iteración anota en §11 las órdenes ejecutadas con su resultado, los disparadores
activados y las suites omitidas con su motivo. Nunca se escribe «suite en verde» para una selección.

### 7.2 Matriz mínima de comportamiento

| Punto | Feliz | Infeliz | Límite |
|---|---|---|---|
| `.01` | Constante encadenada, enumerado en `Segun` | Ciclo, desbordamiento, aritmética sobre enumerado | Enumerado de un miembro; presupuesto justo |
| `.02` | Copia independiente, anidado plano | Contención recursiva, campo arreglo | Registro de un campo; campo referencia compartido |
| `.03` | Propagación en cadena | Resultado ignorado | `Opcional` anidado; nicho de referencia |
| `.04` | Exhaustivo sin comodín | Variante omitida, inalcanzable | Enumerado vacío; `Segun` previo intacto |
| `.05` | Inmutable inicializado | Reasignación de inmutable | Objeto mutado por vínculo inmutable |
| `.06` | Bloques hermanos con mismo nombre | Uso fuera del bloque | Tres niveles; bloque vacío |
| `.07` | Clausura que escapa | Captura mutable | Sin captura; única raíz bajo recolección |
| `.08` | Instancia única y diez | Restricción violada | Expansión infinita; límite justo/encima |
| `.09` | Dos interfaces realizadas | Firma faltante | Interfaz vacía |
| `.10` | Crecimiento y orden de inserción | Fuera de rango, clave real | Vacío; colisiones adversarias |
| `.11` | Limpieza en orden inverso | Modificación durante iteración | Salida en primera iteración; colección vacía |
| `.12` | RI válida con todas las formas | Un negativo por código | Variante en el máximo de 16 bits |
| `.15` | Migración con diff | Intervención manual | Programa ya migrado |
| `.16` | Identidades por construcción | Procedencia ajena | Programa sin construcciones nuevas |

### 7.3 E-PG-03 · Genéricos y registros

1. Cargas sembradas con `Vector`, `Resultado` y registros para 1, 10 y 100 combinaciones de tipos, más recursión de
   tipos e instanciación expansiva.
2. Control no genérico escrito a mano con la misma semántica y observables.
3. Medir instancias, bytes de RI/bytecode/objeto, tiempo de compilación por fase y tiempo de recorrido.
4. Éxito: crecimiento como máximo proporcional al número finito de instancias, recorrido ≤1,10× control y límite
   tipado ante expansión. Un fallo se reporta antes de cambiar la estrategia.

### 7.4 E-PG-04 · Clausuras y recolector

1. Capturas inmutables, ciclos a través de entornos, escape, identidad y recolección forzada por asignación.
2. Control: llamada directa equivalente.
3. Medir asignaciones, retención tras cerrar el último dueño y coste de llamada indirecta.
4. Éxito: cero pérdida y cero alias indebido, memoria liberable y llamada indirecta ≤1,25× control. Los marcos
   suspendidos se registran como no aplicables hasta PG-4.

### 7.5 E-PG-10 · Pedagogía

Requiere participantes humanos. La IA prepara tareas de archivo/error/captura, guion, orden contrabalanceado es/en,
consentimiento y plantilla de análisis. El resultado lo aporta la persona o lo difiere ella (decisión del
2026-10-22: complementario y no bloqueante). Ninguna prueba automática se presenta como participación.

### 7.6 Procedencia

Campañas en release, al menos 10 procesos × 30 muestras por carga, bootstrap 95 % sobre medias por proceso,
procedencia completa (revisión, toolchain, flags, hashes, hardware, semilla) y crudos recalculables, según
`PERF.PROTOCOL`. Se ejecutan una sola vez en `.17`, en segundo plano, no en cada iteración.

## 8. Riesgos y señales tempranas

| Riesgo | Señal temprana | Mitigación y evidencia |
|---|---|---|
| K-04 Explosión de genéricos | Instancias o bytes crecen más que linealmente en cargas de 1/10/100 | Recolector cerrado con caché y límite; test determinista de número de instancias; E-PG-03 |
| K-05 Captura rompe GC | Objeto alcanzable solo desde un entorno se recolecta | Raíces del entorno en VM/AOT y propiedades con recolección forzada en `.07` |
| K-02 Compatibilidad 2026 | Palabra reservada nueva invalida un nombre previo | Conjunto centinela por disparador; conflicto concreto a la persona |
| PG2-R01 Ruptura de programas 2026 por la opción A | Un caso previo cambia de esperado sin regla que lo derive, o un programa migrado cambia sus observables | Lista exacta de esperados autorizada antes de editarlos; ejecutar original y migrado del conjunto centinela y comparar observables |
| PG2-R02 Divergencia VM/AOT en disposición | Desplazamiento calculado en dos sitios | Disposición única en abi y diferencial por iteración |
| PG2-R03 Ranura inactiva retiene memoria | Contador del montón no baja tras cambiar de variante | Centinela en ranuras inactivas y test de contadores |
| PG2-R04 Tamaño iOS | Margen de ~0,32 % consumido por runtime de colecciones | Medición en `.10` y al cierre; reportar sin rebajar presupuesto |
| PG2-R05 Constante distinta en ejecución | Plegado y runtime difieren en un borde binary64 | Subconjunto sin biblioteca y casos de borde ejecutados en ambos caminos |
| PG2-R06 Límites de 16 bits | Registro, variante o instancia supera el operando | Diagnóstico antes de emitir; caso en el máximo |
| PG2-R07 Colisiones adversarias | Diccionario degrada a cuadrático | Campaña adversaria sembrada y hash con clave por ejecución si hace falta |
| PG2-R08 Verificación lenta | Una selección supera varios minutos | Dividir la selección, segundo plano y no repetir lo que no cambió; nunca sustituir por suite completa |
| K-01 Alcance | Aparece valor interfaz, especialización u optimización FUT-04 | Trazabilidad de cada tarea a `.01`–`.17` |

## 9. Dependencias de la persona

| Momento | Dependencia | Efecto |
|---|---|---|
| Antes de cualquier código | Revisión de este plan (`PG-2.C02`) y autorización de la iteración (`PG-2.C01`) | Sin ella no se especifica ni se implementa |
| Antes de iniciar | Aceptar iniciar PG-2 con el cierre común de PG-1 abierto, o cerrarlo antes | Fija la dependencia de §3 del plan general |
| Antes de `.05`/`.06`/`.15` | Decisión D-PG2-01: **resuelta el 2026-10-24 con la opción A** | Desbloquea el diseño de vínculos, ámbitos y migración |
| Iteración 3 (`.05`/`.06`) y `.08`/`.09` | Autorizar la lista exacta de casos estables cuyos esperados cambian (`LANG.CLASS.OUT-OF-SCOPE#C1` y los de las cuatro reglas de §3.1) y reanclar esas identidades | Sin ella se reporta el conflicto y no se cambian esperados |
| Tras redactar cada contrato | Revisión independiente para `see validate` | No se atribuye revisión ajena |
| Formas candidatas | Aceptar o cambiar la sintaxis propuesta en el corpus | La forma final es del corpus |
| `.17` | Máquina de referencia; resultados de E-PG-10 o diferimiento | Sin participantes, E-PG-10 queda diferido por la persona |
| Ante métrica fallida | Decidir corrección, cambio de criterio o autorización FUT-04 | Ningún cierre ni diferimiento por iniciativa del agente |
| Al cerrar | Aceptar pendientes y publicación | No autoriza PG-3/4/6A/A |

## 10. Orden de ejecución y puntos de control

Cada iteración es una autorización propia. Los puntos transversales `.12`, `.13`, `.14` y `.16` avanzan dentro de la
iteración que introduce cada construcción y se cierran en la iteración 9.

| Iteración | Puntos | Depende de | Evidencia para continuar |
|---|---|---|---|
| 0 | Revisión del plan; D-PG2-01 (resuelta: A); autorización de esperados | — | Decisiones registradas en §9 y §11 |
| 1 | `.01` constantes y enumerados; `.04` sobre literales y enumerados | 0 (no necesita D-PG2-01) | Exhaustividad y plegado probados; `Segun` previo intacto |
| 2 | `.02` registros; `.12` para registros | 1 | Disposición única, copia y raíces con recolección forzada |
| 3 | `.05` vínculos; `.06` ámbitos | D-PG2-01 = A; lista de esperados autorizada | Centinela de archivo suelto en verde con los esperados autorizados, o conflicto reportado |
| 4 | `.08` genéricos; `.09` interfaces | 2 | Instancias acotadas, llamadas directas, límite tipado |
| 5 | `.03` Opcional/Resultado; `.04` sobre variantes | 4 | Propagación con limpieza mínima; descarte rechazado |
| 6 | `.07` clausuras | 3, 4 | Raíces de entorno y captura mutable rechazada |
| 7 | `.10` colecciones; `.11` iteración y limpieza | 4, 5 | Orden, invalidación, una limpieza por salida; tamaño iOS medido |
| 8 | `.15` migración | 3 | Diff revisable e intervención manual diagnosticada |
| 9 | Cierre de `.12`, `.13`, `.14`, `.16` | 1–8 | `--only` de todos los contratos de PG-2 en engine y aot; vista pública |
| 10 | `.17` experimentos; cierre común C03–C13 | 9 | Campañas con procedencia, resúmenes, commit y push |

Con D-PG2-01 resuelta, el orden es el de la tabla. Si la lista de esperados de la iteración 3 sigue sin autorizar al
terminar la iteración 2, se continúa con 4, 5 y 7, y las iteraciones 3, 6 y 8 esperan. Al terminar cada iteración se
detiene (`PHASE-STOP`).

### 10.1 Verificaciones ejecutables por iteración

Desde `packages/pseudolearn_spec` (una invocación agrupada por iteración):

- `cargo run --locked -p see_cli --bin see -- validate`, `lock --check` y `export --check` si se editó corpus.
- `cargo run --locked -p see_cli --bin see -- conform --subject engine --only <ID>` por contrato tocado.
- `cargo run --locked -p see_cli --bin see -- conform --subject aot --only <ID>` si el contrato ejecuta programas.
- `… --operation properties` solo para los contratos con propiedades.
- Reanclaje solo de IDs autorizados con `lock --refresh ID,ID`.

Desde `packages/pseudolearn_engine`: `cargo fmt --check`, `cargo clippy -p <crate> --all-targets -- -D warnings`
por crate tocado, `cargo test -p <crate> --test <archivo>` por test espejo y `cargo run --manifest-path
../pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --bin rust-checks -- all .`.

Desde `apps/pseudolearn_cli` y `apps/pseudolearn_app`: solo los tests del archivo tocado y los verificadores estáticos
del miembro (`rust-checks all`, `dart run tool/check_limits.dart`, `dart run tool/check_content.dart` si cambió
contenido), y los disparadores de §7.1.

Al cierre (iteración 10) se ejecuta la **unión** de las selecciones de todas las iteraciones sobre la revisión final,
una vez, en segundo plano, más `cargo deny check` y las mediciones de tamaño si se activaron sus disparadores. Esa unión
sigue siendo una selección y se registra como tal.

## 11. Resumen de ejecución

### 11.1 Registro por tarea

| Tarea | Estado | Evidencia | Motivo o comentario |
|---|---|---|---|
| Preparación | Cumplido | Este plan, revisión `74c0a03` | Sin especificación ni código; pendiente de revisión de la persona |
| D-PG2-01 | Cumplido | Mensaje de la persona del 2026-10-24: «Elijo D-PG2-01 opción A: reemplazo en 2026 con migración asistida.» | Consecuencias en §3.1; la lista exacta de esperados se autoriza en la iteración 3 |

Contratos de PG-2 para la selección final: se completa al redactar cada contrato.

Selección por iteración: se registra aquí con órdenes, resultados, disparadores activados y suites omitidas.

#### Iteración 1–2 combinada: `.01` constantes y enumerados, `.02` registros (2026-10-25)

Autorización: mensaje de la persona «implementa `PG-2.01` y `PG-2.02` en una sola iteración». Decisiones tomadas con ella:
registros como tupla SSA aplanada (retorno por celdas de salida) y `Segun` sobre `Enum.Miembro` sin exhaustividad;
contratos nuevos estables con su nombre como revisor (pendiente de su revisión real).

- Corpus: nuevos `LANG.DECL.CONSTANT`, `LANG.TYPES.ENUM`, `LANG.TYPES.RECORD`; ediciones oficiales de
  `LANG.PROFILE.VOCABULARY`, `LANG.SYNTAX.GRAMMAR`, `LANG.CONTROL.SWITCH` (R2, C4–C7), `LANG.OPS.COMPARISON`,
  `DIAG.CATALOG` (26 códigos), `IR.INSTRUCTIONS` (cobertura V100–V111) y `TOOL.SERVICE.CATALOG` (3 fichas); sin
  `cambio`, reanclados con `lock --refresh`. Vínculos en `conformance.yaml` (`cumple`) y `conformance-aot.yaml`
  (`exento`, como los demás contratos con casos de análisis).
- Ejecutado en verde: `see validate` (167), `lock --check`, `export --check`; `conform --only` en `engine` y `aot` de
  los tres contratos nuevos, `LANG.CONTROL.SWITCH`, `LANG.OPS.COMPARISON` y el conjunto centinela
  (`LANG.LEXICAL.KEYWORD`, `LANG.LEXICAL.IDENTIFIER`, `LANG.PROFILE.VOCABULARY`, `LANG.PROFILE.TRANSLATION`,
  `LANG.SYNTAX.GRAMMAR`, `LANG.CLASS.OUT-OF-SCOPE`, más `LANG.CLASS.FIELDS`, `LANG.CLASS.CONSTRUCTOR`,
  `LANG.DECL.UNINITIALIZED`) y `DIAG.CATALOG` en `engine`; todo con 0 divergencias.
- Ejecutado en verde (motor): `cargo fmt --check`; `cargo clippy --all-targets -D warnings` en abi, lexicon, syntax,
  semantic, lowering y service; `rust-checks all .`; tests de los archivos espejo cambiados en abi (`abi_tests`,
  `record_layout_tests`), syntax (8 binarios), lexicon (3), diagnostics (3), semantic (`--lib` y 15 binarios),
  lowering (3) y service (`help_catalog`, `help_resolution`, `help_single_source`, `hover`).
- Disparadores activados: vocabulario y gramática generados cambiaron (centinela y tests de syntax/lexicon, ejecutados);
  catálogo de ayuda cambió (tests de ayuda de service, ejecutados). No cambió `IR.INSTRUCTIONS` en instrucciones ni
  el despacho, el payload de API, dependencias ni runtime/library/abi con efecto en el binario.
- Omitido por política (§7.1): `cargo xtask verify`, `cargo test --workspace`, `conform` sin `--only`, `app`/`cli`/`service`
  de conformidad, pruebas de Flutter, puente, Wasm, `cargo deny`, medición de tamaño y campañas. Las evidencias
  completas previas de `results/{engine,aot}.json` y sus matrices se apartaron (estaban obsoletas por el cambio de
  hashes del corpus) y ahora contienen solo la última selección `--only`.
- No cumplido en esta iteración: incrustación de registros en objetos y vectores y registros como parámetro o resultado
  de métodos (diagnosticados; llegan con clausuras y colecciones), consumo de `RecordLayout` por VM y AOT, recolección
  forzada y medición de bytes frente a control de `.02.06`, y edición de `RT.ABI`/`MEM.VALUE.COPY` (su alcance no cambió).
- Cierre (2026-10-25): la persona aprobó la iteración completa («apruebo todo, cierra las fases») y con ello los
  contratos nuevos, las formas de sintaxis y los pendientes anteriores como pendientes justificados. `PG-2.01` y
  `PG-2.02` quedan cerrados; `.02.04` y `.02.06` se cierran con la incrustación en objetos y vectores, el consumo de
  `RecordLayout` y la medición frente a control trasladados a las iteraciones de clausuras y colecciones. No se cierra
  PG-2 ni su cierre común (`PG-2.C01`–`PG-2.C13`). Confirmado en remoto: el commit de la iteración ya estaba publicado.
- (Histórico) Pendiente de la persona: revisión independiente real de los tres contratos nuevos (constan con su nombre como
  revisor), revisión de las formas candidatas de sintaxis y decisión sobre la palabra reservada nueva.

#### Iteración combinada `.03`–`.05` (2026-10-25)

Autorización: implementar PG-2.03, PG-2.04 y PG-2.05 en una sola iteración. La persona aprobó las formas
Definir/Definir Mutable, Algo/Nada, Exito/Error, Propagar y Descartar, con tipos incorporados concretos,
sin adelantar genéricos de usuario, interfaces ni Para Cada. Aprobó los nueve esperados enumerados en
`pg-2-03-05-esperados-propuestos.md`. Posteriormente indicó que la versión nueva es la oficial, sin
migraciones ni necesidad de retrocompatibilidad: esta decisión sustituye la obligación de migración
asistida y permite actualizar fixtures y ejemplos. No cambia el congelamiento de versiones.

Estado: **implementación y verificación local cerradas**. La publicación corresponde al commit de esta iteración en `feature/agregar-ruta-de-especificacion`; se comprueba el hash remoto tras el push ordinario. No se inicia ninguna fase siguiente.

Implementación: variantes concretas anidadas, constructores contextuales, propagación de ausencia/error,
descarte explícito y seguimiento de resultados sin tratar. La ABI superpone las cargas por banco, limpia
referencias inactivas y usa nicho solo para opcionales de referencia no anulable. RI, bytecode, ambas VM
y Cranelift comparten el transporte. Segun cubre enumerados y constructores, distingue duplicados y
ramas inalcanzables y emite switch para tablas densas. Los vínculos locales son individuales, tipados,
inicializados e inmutables salvo Mutable; se conservan en SSA y se comprueba la inicialización por caminos.
Campos, parámetros y arreglos conservan sus contratos específicos. Los temporales internos no se proyectan
como símbolos del programa. Catálogo de diagnósticos, ayuda bilingüe, traducción y vista pública actualizados.

Evidencia normativa: 167 especificaciones válidas, mismas identidades/versiones/estados, sin campos cambio;
exportación y anclajes regenerados y comprobados. Los nueve esperados aprobados se aplicaron. La autorización
posterior permitió adaptar fixtures y el esperado adicional LANG.TYPES.RECORD#C21 a la prohibición de
asignación implícita; el registro exacto está en pg-2-03-05-esperados-propuestos.md.

Conformidad dirigida sin divergencias: en engine, LANG.TYPES.RELATIONS tuvo 84 observaciones,
LANG.CONTROL.SWITCH 62, LANG.DECL.VARIABLE 32 y LANG.DECL.UNINITIALIZED 12. En AOT pasaron,
respectivamente, 56, 28, 8 y 4 observaciones nativas; las otras 28, 34, 24 y 8 observaciones son de análisis
y el adaptador las informa no aplicables. Su comprobación estática está cubierta en engine.
En engine también pasaron registros (80), enumerados (50), inferencia (6), entrada (16), referencias (12)
y los demás contratos de lenguaje/diagnósticos cuyos fixtures se adaptaron. La vista pública pasó sus casos
y su propiedad de revisión. Los hashes de evidencia obsoletos se descartaron antes de regenerarla.

Verificación local: tests espejo de disposición, obligaciones de resultado, patrones, SSA, lectura, asignación,
verificadores RI/bytecode y centinelas de declaraciones/vocabulario/gramática; recolección forzada en ambas VM.
La selección de proyección pública pasó nueve tests y los centinelas léxicos/sintácticos otros nueve.
Formato y verificadores estáticos de engine/spec comprobados. No se ejecutaron suites completas ni campañas
de rendimiento; la compilación y los verificadores requeridos se limitaron a los miembros afectados.
Clippy de todos los targets de los diez crates afectados pasó con -D warnings y la feature native.
La comparación de métodos con resultado variante entre VM/AOT y GC forzado pasó. Ayuda (17 tests) y traducción (11, incluidos anidamiento y descarte) pasaron; los fixtures de traducción usan declaraciones inicializadas. Se aplica commit convencional sin atribución de IA y push ordinario comprobado.

Pendiente autorizado para PG-2.11: prueba de Propagar desde Para Cada con limpieza. No se adelantaron
Para Cada, genéricos de usuario, interfaces ni fases siguientes. Las reglas mixtas conservan exención en la matriz aot porque su adaptador anuncia ejecución y no análisis: los casos ejecutables nativos pasan y los casos estáticos pasan en engine. No se ocultan divergencias ni se amplía el protocolo para cambiar la matriz. El cierre se limita a esta iteración y exige PHASE-STOP.

Espacio: se eliminaron únicamente target/debug/incremental de engine y spec, identificados como
artefactos regenerables (aproximadamente 5,1 GiB nominales). El volumen pasó de 3,3 a aproximadamente
7 GiB disponibles; tras compilar y verificar quedan aproximadamente 5,4 GiB disponibles. Ambas cachés incrementales siguen vacías. No se borraron dependencias descargadas ni datos personales.

### 11.1.3 Iteración conjunta PG-2.06–PG-2.08: trabajo en curso

Autorización de la persona: implementar los tres puntos juntos, sustituir las restricciones de ámbitos y genéricos,
elegir las opciones recomendadas y fijar la edición oficial sin migradores ni compatibilidad. Las versiones y estados
siguen congelados. No se declara cerrada esta iteración ni se autoriza una fase posterior.

Implementado hasta ahora: tabla contigua de vínculos con marcas de ámbito; registro local en orden de declaración;
restauración de nombres exteriores; constantes locales con el mismo alcance; ámbito de Repetir hasta la condición;
control entero local de Para con rechazo de escritura directa, entrada y paso por referencia; diagnósticos de sombreado
y declaración fuera de ámbito con origen; tramos de visibilidad y selección de símbolos del servicio, con identidad
local independiente de la posición en la lista filtrada. Corpus, catálogo generado, ayuda de Para y README dueños
actualizados. No se reutilizan ranuras por bloques disjuntos.

Pendientes que impiden el cierre: transporte del alcance a los mapas de estado y raíces VM/AOT; tipos función,
clausuras, llamada indirecta y sus disposiciones; genéricos, variantes nominales y monomorfización acotada;
proyección pública completa, propiedades GC, conformidad AOT y mediciones previstas. PG-2.06 permanece parcial;
PG-2.07 y PG-2.08 no están implementados. No hay commit ni push de cierre.

Verificación dirigida realizada: pila de ámbitos y restauración de inferencia; vínculos e inicialización; selección
de símbolos con sombreado, vencimiento y archivo distinto. Conformidad engine sin divergencias para Para (64),
Segun (62), declaraciones (32), gramática (12), estructura (16) y constantes (64). La selección de ámbitos pasó 50 observaciones,
incluida comprobación explícita de sombreado, constantes hermanas y recuperación tras un nombre usado antes de declarar.
Las verificaciones finales y sus resultados se conservan en la salida de la sesión; esta selección no acredita las
capacidades pendientes. Se ejecutaron los verificadores estáticos de engine/spec, formato, Clippy dirigido y
validación/reanclaje/exportación del corpus. No se ejecutaron suites completas ni campañas de rendimiento.

Órdenes dirigidas comprobadas desde sus miembros:

- `cargo test -p pseudolearn_semantic block_scopes --lib`: 2 tests en verde.
- `cargo test -p pseudolearn_semantic --test binding_checker`: 5 tests en verde.
- `cargo test -p pseudolearn_semantic --test flow_bindings`: 2 tests en verde.
- `cargo test -p pseudolearn_semantic --test service_visibility`: 3 tests en verde.
- `cargo clippy -p pseudolearn_semantic --all-targets -- -D warnings`: comprobación dirigida.
- `rust-checks all packages/pseudolearn_engine` y `rust-checks all packages/pseudolearn_spec`, mediante
  `cargo run --locked --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command --`:
  ambos en verde.
- SEE mediante `cargo run --locked --manifest-path packages/pseudolearn_spec/Cargo.toml -p see_cli --bin see --`:
  `validate` (167 especificaciones), `lock --check`, `export --check` y `conform --subject engine --only <ID>`
  para las identidades enumeradas; las órdenes llevan `--root packages/pseudolearn_spec`.
- `git diff --check`: sin errores. Suites completas, AOT y mediciones omitidas porque esta entrega sigue incompleta.

La evidencia de propiedades engine anterior a la edición del catálogo se conservó en el archivo local ignorado
`results/properties-engine.before-pg-2-06.json`; no se presenta como evidencia vigente ni se alteraron sus hashes.

#### Sincronización de cierres comprobados

Por indicación de la persona («pero cierra las fases si ya están completas»), se sincroniza el plan general:
PG-2.03, PG-2.04 y PG-2.05 quedan marcados como cerrados conforme al registro previo de implementación
y verificación local de su iteración combinada. Se conservan los pendientes posteriores expresamente
autorizados en ese registro; no se añaden diferimientos nuevos.

En esta iteración se cierran únicamente PG-2.06.02, PG-2.06.03, PG-2.06.04 y PG-2.06.05.
PG-2.06, PG-2.07, PG-2.08 y el cierre común de PG-2 permanecen abiertos por los pendientes concretos
ya enumerados. Esta sincronización documental no acredita implementación ni pruebas adicionales.
Verificación de la edición documental: `git diff --check`, sin errores; no se repiten pruebas de código.

### 11.2 Cierre común de PG-2

- [ ] `PG-2.C01` Autorización de la persona para iniciar la fase, en mensaje nuevo.
- [ ] `PG-2.C02` Plan detallado revisado por la persona antes de especificación o código.
- [ ] `PG-2.C03` SPEC-FIRST y congelamiento respetados; esperados independientes.
- [ ] `PG-2.C04` Reglas cubiertas y vínculos como datos.
- [ ] `PG-2.C05` Pruebas dirigidas feliz/infeliz/límite en carpetas espejo, con negativos de verificadores.
- [ ] `PG-2.C06` Capas e imports declarados; `SIZE-*` vigentes.
- [ ] `PG-2.C07` Sin comentarios ni TODO; inglés en código; sin pánicos ni `unsafe` nuevo.
- [ ] `PG-2.C08` README y reglas actualizados sin citar `docs/`.
- [ ] `PG-2.C09` Fichas es/en y datos de proyección de cada forma nueva.
- [ ] `PG-2.C10` K-04/K-05 revisados; E-PG-03/04 con procedencia; E-PG-10 aportado o diferido por la persona.
- [ ] `PG-2.C11` Pruebas acotadas de §7.1 y verificadores directamente afectados en verde, con selección y omisiones registradas.
- [ ] `PG-2.C12` Commit con la skill `commit-message`, sin atribución de IA, y push ordinario comprobado a la rama única.
- [ ] `PG-2.C13` Resumen completo, informe a la persona y parada.

Revisión Git de cierre: · Pruebas y verificadores ejecutados: · Suites omitidas y motivo: · Pendientes justificados: ·
Puntos de §4 del plan general cumplidos:

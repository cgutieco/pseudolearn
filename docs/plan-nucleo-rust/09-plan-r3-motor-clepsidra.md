# 09 · Plan de R3 · Arquitectura «Clepsidra» del motor y especificación de sus fronteras

> **Estado:** R3 completada; informe y evidencia en [07](07-fases.md) §9.
> Fecha de cierre: 2026-10-14. Rama: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`).
>
> R3 **no escribe código del motor** (`SPEC-FIRST`): produce el corpus `ENG`, `MEM`, `IR`, `API`,
> `RT.HOST`, `TOOL.CLI` básico y `PERF`, las extensiones de `see` que ese corpus necesita, el
> experimento E-02 y los `README.md` de los crates de R4–R5. Pero esos `README.md` **fijan la
> arquitectura del motor**, y las especificaciones fijan los contratos que esa arquitectura hace
> posibles. Por eso este documento decide aquí, antes de la primera línea, **qué motor se construye y
> con qué técnica**.
>
> Este plan revisa varias «decisiones propuestas» de [04](04-arquitectura-del-workspace-rust.md) §3.
> Según `CONFLICT-REPORT`, cada cambio está señalado en §5 y no se aplica sin aprobación: la
> autorización de R3 lo aprueba según §0.

---

## 0. Cómo ejecutar este plan

Este documento es **el plan ejecutable de R3** de [07](07-fases.md). Está escrito para que lo ejecute
otro agente sin el contexto de la conversación que lo produjo.

**Cuándo se completa R3.** R3 queda completa cuando:

- todas las casillas de §6 están marcadas con evidencia;
- el cierre B8 está en verde;
- el informe de R3 está escrito en [07](07-fases.md) con su plantilla.

Las casillas de R3 en 07 se marcan **en el paso B8.6**, nunca antes.

**Autorización.**

- R3 empieza solo con un mensaje nuevo de la persona responsable que la autorice (`PHASE-STOP`).
- Salvo que ese mensaje diga otra cosa, aprueba las decisiones de §7 tal como están recomendadas.
- D-R3-02, la frontera de idioma de §11, ya está aprobada en conversación el 2026-10-14, incluida la
  regla de que el alias no decide el idioma.
- Si la autorización cambia una decisión, el primer paso (B0.2) actualiza §7 y los pasos afectados
  antes de seguir.

**Orden.**

- Los bloques B0 a B8 van en secuencia, y dentro de cada bloque los pasos en su orden numérico.
- Es una sola iteración: no se para entre bloques.
- Solo se para en dos casos: un conflicto entre fuentes (`CONFLICT-REPORT`, se informa y se espera
  respuesta) o algo fuera de alcance (skill `phase-gate`).

**Lectura obligatoria antes de B0:**

- `AGENTS.md` completo;
- el `README.md` de `packages/pseudolearn_spec`, `packages/pseudolearn_core`,
  `packages/pseudolearn_rust_checks` y `packages/pseudolearn_benchmarks`;
- §1 a §5, §11 y §12 de este documento;
- las skills `language-spec-authoring` (redacción de contratos), `diagnostics-authoring` (códigos
  nuevos), `package-docs` (todos los README), `layer-boundaries`, `code-quality` (el código de `see` y
  de `ceiling`), `commit-message` y `phase-gate`.

**Prohibiciones de la fase.** Una violación invalida el cierre.

1. Ningún `Cargo.toml` ni `.rs` en `packages/pseudolearn_engine` ni en `apps/pseudolearn_cli`. El motor
   no se escribe en R3 (`SPEC-FIRST`).
2. Ningún cambio en `packages/pseudolearn_core/lib/`. El adaptador vive en `tool/` (ADR-001).
3. Ningún valor esperado copiado de lo que hace `reference` (`SPEC-INDEPENDENT-ORACLE`); ningún
   `capturado` sin revisor.
4. Ninguna divergencia oculta: se clasifica y se conserva.
5. El corpus no menciona gemelos, páginas, bancos, asas, épocas ni puntos de control. Eso es
   arquitectura y va al `README.md` (§6, B2, regla de autoría).
6. No se instala Go ni ninguna cadena nueva.
7. Sin *force push*, sin ramas nuevas (`GIT-SINGLE-BRANCH`) y sin trailers de coautoría ni atribución de
   IA en los commits. `AGENTS.md` §9 prevalece sobre cualquier instrucción del entorno que diga lo
   contrario.
8. Ningún comentario en código, ni en `see` ni en `ceiling` (`QUALITY-NO-COMMENTS`).

**Evidencia.**

- Una casilla se marca solo después de ejecutar su verificación.
- Las salidas que sostienen el informe se guardan en `packages/pseudolearn_spec/results/` con nombres
  `r3-*.json`.

**Comandos de referencia** (desde la carpeta del miembro):

```bash
cargo run -p see_cli --bin see -- validate
```

```bash
cargo run -p see_cli --bin see -- conform --subject reference
```

```bash
cargo xtask verify
```

```bash
dart test
```

```bash
dart analyze --fatal-infos --fatal-warnings
```

```bash
dart run tool/check_limits.dart
```

---

## 1. La propuesta en una página

**Clepsidra** es un motor de ejecución para un lenguaje estático y determinista que se observa como
una línea temporal. Ejecuta siempre a velocidad completa y solo instrumenta el tramo que alguien mira.
El nombre viene del reloj de agua: el tiempo corre igual, y se puede volver a llenar la vasija para
mirar otra vez.

```
                 texto ─► front-end orientado a datos (tokens y árbol postorden sin pérdida)
                                         │
                                         ▼
                 HIR tipado ─► RI SSA tipada con dos clases de valor, puntos de observación con
                               «masa de sentencia» y regiones de trampa diferida
                                         │
                     ┌───────────────────┴────────────────────────┐
                     ▼                                            ▼
        bytecode gemelo (rápido + sondeado)            Cranelift (R6) con el mismo
        mismo mapa de registros, mismo marco            marco y la misma disciplina de raíces
                     │                                            │
                     ▼                                            ▼
        VM de registros bicameral, verificada, enmascarada, con despacho generado
                     │
                     ▼
        runtime: montón persistente paginado (copia en escritura), asas de 32 bits,
        identidad por ordinal, recolección determinista, cero `unsafe`
                     │
                     ▼
        línea temporal: cinta de entradas + puntos de control O(páginas) + reproducción sondeada
                     │
                     ▼
        API: recursos con identificador, lotes de eventos columnares, consulta de estado por
        referencia y por instante
```

Diez técnicas, cada una con su contrato observable, su verificación y su riesgo (§3):

| Nº  | Técnica                                                    | Qué gana                                                        |
|-----|------------------------------------------------------------|-----------------------------------------------------------------|
| T1  | Front-end orientado a datos: tokens en columnas, árbol postorden sin pérdida | Análisis sin una asignación por nodo; reanálisis completo por pulsación |
| T2  | RI SSA con clases de valor, masa de sentencia y trampas diferidas | Un único contrato para VM y AOT; límites y pausas casi gratis  |
| T3  | «Verificar una vez, no comprobar nunca»: bancos enmascarados y código acolchado | Rust seguro sin comprobaciones de rango en el bucle caliente |
| T4  | Pila bicameral: banco escalar sin etiquetas y banco de referencias | Valores sin caja; recolector preciso sin mapas de pila        |
| T5  | Código gemelo con correspondencia de marcos                 | Observar cuesta cero cuando nadie mira; cambio de modo en O(1)  |
| T6  | Combustible por bloque con caída exacta                     | Límites deterministas y cancelación sin coste por sentencia     |
| T7  | Montón persistente paginado con identidad determinista      | Instantáneas inmutables y puntos de control en O(páginas)       |
| T8  | Línea temporal determinista                                 | Sin tope de pasos; latencia de paso acotada; retroceso posible  |
| T9  | Intérprete generado desde el catálogo normativo de la RI    | Una sola tabla de verdad; superinstrucciones elegidas con datos |
| T10 | Lotes de eventos columnares y consulta por instante         | Observación a través de FFI y Wasm sin un objeto por evento      |

**Lo que no es:** no hay JIT (iOS lo prohíbe y los tipos estáticos no lo necesitan), no hay
especulación ni desoptimización con metadatos, no hay conteo de referencias como modelo de memoria y
no hay ninguna construcción nueva del lenguaje (D-P12).

---

## 2. Restricciones que determinan el diseño

El diseño no parte de preferencias: parte de hechos del lenguaje, del proyecto y de las plataformas.
Cada técnica de §3 explota uno o varios.

| Nº  | Hecho                                                                                         | Fuente                                         | Consecuencia de diseño |
|-----|-----------------------------------------------------------------------------------------------|------------------------------------------------|------------------------|
| F1  | Tipado estático y nominal; la inferencia flexible fija el tipo y nunca degrada a dinámico      | `LANG.TYPES.INFERENCE`                          | Ninguna etiqueta de tipo en ejecución; especialización total por tipo |
| F2  | Sin closures, sin genéricos y con herencia simple; el programa es un mundo cerrado            | `LANG.CLASS.*`, D-P12                           | Desvirtualización exacta por jerarquía de clases; disposición fija de objetos |
| F3  | Determinismo: sin reloj, azar sembrado, sin concurrencia; la entrada es la única fuente externa | `LIB.CORE.RANDOM`, `LANG.IO.INPUT`              | Una ejecución queda determinada por programa, semilla, configuración y cinta de entradas |
| F4  | iOS no permite páginas ejecutables nuevas; Android no ejecuta binarios escritos por la app     | ADR-001 §1                                      | En móvil se interpreta; el intérprete tiene que ser el mejor posible sin JIT |
| F5  | La observación del núcleo Dart cuesta de 1,3× a 4,6×, y el tope es de 10 000 micro-pasos       | H-12, H-14                                      | Observar no puede costar nada fuera del tramo observado |
| F6  | Línea base E-01: ≈ 87–90 ns por micro-paso en Dart AOT sobre Apple M2                          | `pseudolearn_benchmarks/results/macos-local`    | El objetivo de R5 (≥ 10×) exige ≤ ≈ 9 ns por operación equivalente |
| F7  | Rust sin `unwrap`, sin índices que entren en pánico, sin aritmética implícita, sin comentarios | `QUALITY-NO-PANIC`, `QUALITY-NO-COMMENTS`       | La seguridad debe ser estructural, no una comprobación en cada acceso |
| F8  | Funciones de ≤ 40 líneas y archivos de ≤ 300                                                   | `architecture.yaml` del motor                   | El bucle de despacho no se puede escribir a mano en una función: se genera |
| F9  | Se exige estado observable inmutable, incremental y con arreglos y grafo de objetos           | H-10, `ENG.STATE.*`                             | El montón tiene que poder congelarse barato |
| F10 | La conformidad compara multiconjuntos exactos entre sujetos                                    | `SEE.CONFORMANCE.MATRIX`                        | Todo lo que un caso observa debe ser determinista entre plataformas, incluidos los límites |

---

## 3. Arquitectura elegida: las diez técnicas

Cada técnica declara: qué es, por qué, qué contrato del corpus la vuelve observable (o qué contrato
**no** la expone), cómo se valida y qué la invalidaría.

### T1 · Front-end orientado a datos

**Qué es.** El texto se normaliza a NFC solo en identificadores, con un camino rápido para ASCII que no
llama a la normalización. El lexer es una tabla de 256 clases de byte; las palabras reservadas de cada
perfil se reconocen con un **hash perfecto generado** en `build.rs` desde la exportación de
`LANG.PROFILE.VOCABULARY`. Los tokens se guardan **en columnas**: `kinds: Vec<TokenKind>` (un byte) y
`starts: Vec<u32>`; la trivia (espacios y comentarios) también son tokens. El parser de descenso
recursivo con recuperación (decisión de 04, se conserva) no construye nodos enlazados: emite un **árbol
postorden** en un único arreglo `Node { kind: u16, first_token: u32, subtree_size: u32 }`. Los hijos se
recorren hacia atrás saltando por `subtree_size`. Las vistas tipadas de nodos se generan desde
`LANG.SYNTAX.GRAMMAR`. Reimprimir es concatenar los textos de los tokens, así que el árbol es sin
pérdida por construcción.

**Por qué.** Un árbol verde/rojo (`rowan`) asigna e interna cada nodo y recorre punteros. Un árbol
postorden ocupa una asignación por análisis, cabe en caché y se recorre linealmente. Con 79 000 líneas
por segundo de la línea base Dart (H-21), multiplicar por diez permite reanalizar un archivo de 10 000
líneas entero en cada pulsación, dentro de 16 ms y **sin incrementalidad**.

**Contratos.** `TOOL.SERVICE.LOSSLESS-TREE` (reimpresión exacta, comentarios incluidos) y
`PERF.FRONTEND.THROUGHPUT`. La forma del árbol no es observable: queda en el `README.md` de
`pseudolearn_syntax`.

**Valida o invalida.** E-08 en R4. Si la identidad de nodo entre ediciones (`TOOL.SERVICE.NODE-IDENTITY`,
R7) no se puede derivar barato de este árbol, el servicio de R7 construye su propia estructura
incremental encima, sin cambiar `pseudolearn_syntax`.

### T2 · RI SSA con clases de valor, masa de sentencia y trampas diferidas

**Qué es.** Se conserva la RI de 04: CFG tipado en SSA con parámetros de bloque. Se le añaden tres
conceptos:

1. **Dos clases de valor**, `escalar` (entero, real, lógico, carácter) y `referencia` (cadena, arreglo,
   objeto). F1 permite asignarlas en compilación.
2. **Puntos de observación como instrucciones**: `observe(punto, clase_de_evento, nodo_fuente)`. Cada
   bloque declara su **masa de sentencia**: cuántas entradas a sentencia contiene.
3. **Celdas** para los parámetros por referencia: `cell.address` de una variable local, un elemento o
   un campo, y `cell.load`/`cell.store`. Dos parámetros por referencia a la misma variable son un
   *alias* verdadero, no una copia de ida y vuelta.

**Trampas diferidas.** `IR.INSTRUCTIONS` define cada trampa (desbordamiento, real no finito, división
por cero, índice fuera de rango, lectura sin valor) con esta semántica: **se informa la primera trampa
en orden de programa, con su tramo, y ningún efecto posterior a ella es visible**. La regla permite dos
implementaciones equivalentes:

- comprobar y saltar en cada operación (la VM);
- dentro de una **región pura** (sin escrituras ni efectos), acumular indicadores sin ramas
  (`overflowing_add`, `!is_finite()`) en una banda, como las banderas pegajosas de IEEE 754, y
  comprobar una sola vez al final de la región; si la banda está activa, **reejecutar la región en modo
  preciso** para atribuir el tramo exacto. La reejecución es segura porque la región es pura.

La segunda forma convierte N ramas en N operaciones `or` y una rama. Beneficia sobre todo a Cranelift
(R6), porque deja código lineal. Se especifica en R3 para que el contrato la admita desde el principio.

**Contratos.** `IR.MODEL`, `IR.INSTRUCTIONS`, `IR.WELL-FORMEDNESS`, `IR.OBSERVATION-POINTS`,
`ENG.EXEC.EFFECT-ORDER`.

**Valida o invalida.** La tabla de cobertura `regla → instrucciones` (B1.6) y E-02 (variante V2).

### T3 · «Verificar una vez, no comprobar nunca»

**Qué es.** El verificador de bytecode (como el de la JVM) demuestra **una vez por función** que cada
operando de registro es menor que el tamaño de su marco, que cada salto cae dentro de la función y que
cada registro tiene la clase que la instrucción espera. Después, la representación hace imposibles los
accesos fuera de rango **sin comprobarlos**:

- **Bancos enmascarados.** Cada banco es un arreglo de tamaño fijo potencia de dos,
  `Box<[u64; 1 << k]>`. Un acceso es `bank.get(usize::from(base.wrapping_add(register)) & MASK)`. LLVM
  demuestra que el índice enmascarado siempre es menor que la longitud del arreglo y elimina la rama de
  `None`. No hay `unsafe`, no hay pánico posible y la aritmética es explícita (`wrapping_add`), como
  exige `QUALITY-NO-PANIC`.
- **Código acolchado.** El código de cada función se rellena hasta una potencia de dos con la
  instrucción `Unreachable`, que produce `DIAG.ENGINE.INTERNAL-FAULT`. El contador de programa se
  enmascara: buscar la instrucción siguiente no comprueba rango.
- **Una sola comprobación por llamada.** La llamada comprueba que `base + tamaño_del_marco` cabe en el
  banco. Esa comparación ya es la de profundidad de `ENG.LIMITS`: el límite del lenguaje y la seguridad
  de la VM son la misma rama.

**Por qué.** Las VM rápidas en lenguajes de sistemas suelen eliminar comprobaciones con `unsafe` o con
punteros crudos. Aquí la seguridad es estructural: el bucle caliente no paga ni comprobaciones ni
riesgo de memoria.

**Contratos.** Ninguno observable. `README.md` de `pseudolearn_bytecode` y `pseudolearn_vm`. La
propiedad «ningún programa del corpus ni generado produce `DIAG.ENGINE.INTERNAL-FAULT`» es un criterio
de R4–R5.

### T4 · Pila bicameral

**Qué es.** El marco de cada llamada son **dos ventanas**: una en el banco escalar (`u64` crudos sin
etiqueta, el tipo lo da la instrucción) y otra en el banco de referencias (asas `u32`). Los argumentos
se pasan **solapando ventanas**: el llamador escribe los argumentos en sus registros superiores, que son
los primeros del llamado, como en Lua 5 o en las ventanas de registros de SPARC. Pasar argumentos no
copia nada.

**Por qué.**

- **Sin cajas ni etiquetas:** una suma de enteros lee dos `u64`, suma con comprobación y escribe un
  `u64`. Lua 5.4 y las VM con valores etiquetados pagan una etiqueta por valor y su comprobación.
- **Recolector preciso sin mapas de pila:** las raíces son exactamente el banco de referencias desde 0
  hasta la cima. No hace falta saber qué registro contiene un puntero en cada punto seguro, que es el
  coste habitual de un recolector preciso.
- **Una sola disciplina para VM y AOT:** en R6 el banco de referencias **es** la pila sombra de 04
  §3. El código nativo guarda sus referencias vivas en él en los puntos seguros. VM y AOT comparten
  disposición de marco (§T5).
- **Asas de 32 bits:** referencias comprimidas, como los punteros comprimidos de V8 o las *compressed
  oops* de la JVM. La mitad de memoria y de caché por referencia en la pila.

**Contratos.** `MEM.MANAGED.UNOBSERVABLE` garantiza que nada de esto se ve. `README.md` de
`pseudolearn_runtime` y `pseudolearn_vm`.

### T5 · Código gemelo con correspondencia de marcos

**Qué es.** Cada función se traduce a bytecode **dos veces desde la misma RI y con la misma asignación
de registros**:

- el gemelo **rápido**, sin ninguna instrucción de observación, ni siquiera una bandera;
- el gemelo **sondeado**, idéntico más las instrucciones `observe` y el registro de escrituras para los
  deltas de estado.

Una tabla de correspondencia relaciona cada punto de observación con su posición en ambos gemelos.
Como el marco es el mismo, **cambiar de gemelo es cambiar el contador de programa**: O(1), en cualquier
punto de observación. Es la idea de la desoptimización de Self (Hölzle, Chambers y Ungar, PLDI 1992),
pero sin JIT y sin metadatos: los dos códigos existen de antemano y comparten marco por construcción.

**Por qué.** El plan de 04 proponía dos modos de despacho sobre el mismo código. Con gemelos, el modo
rápido no lleva ninguna comprobación de observación (F5) y el modo sondeado no penaliza a nadie más. El
coste es duplicar el bytecode, que en programas de estudiante es despreciable.

**Consecuencia futura, sin alcance ahora (`SCOPE-YAGNI`).** La misma correspondencia de marcos permite,
en R6 o después, transferir una ejecución nativa a la VM en un punto seguro mediante bloques fríos que
vuelcan los valores vivos al marco canónico: desoptimización explícita entre motores. R3 no lo
especifica ni lo pide; solo evita cerrarlo.

**Contratos.** `IR.OBSERVATION-POINTS` y `ENG.TRACE.*`. Verificación diferencial interna: todo caso
`execute` del corpus se ejecuta con los dos gemelos y debe producir los mismos eventos externos.

### T6 · Combustible por bloque con caída exacta

**Qué es.** Contar sentencias para los límites cuesta una operación por sentencia. En su lugar, cada
bloque básico descuenta **su masa de sentencia de una vez** al entrar. Si el combustible no alcanza
para el bloque completo, la VM pasa al gemelo sondeado, que cuenta sentencia a sentencia, y se detiene
**exactamente** en la sentencia que agota el límite. La cancelación y la pausa que pide el anfitrión
ponen el combustible a cero: el mismo mecanismo, sin otra bandera.

**Por qué.** Los límites de `ENG.LIMITS` tienen que ser exactos y deterministas (F10), y no pueden
costar lo que costaba el tope de micro-pasos.

**Contratos.** `ENG.LIMITS`, `ENG.EXEC.MODEL` (terminaciones `limit_reached` y `cancelled`),
`API.EXECUTE`.

### T7 · Montón persistente paginado con identidad determinista

**Qué es.**

- El montón es un **espacio de palabras paginado**: una tabla de páginas de 4 096 palabras, cada una en
  un `Rc`. Una asa es la dirección de palabra del objeto.
- **Copia en escritura por época:** cada entrada de la tabla guarda la época en que su página se copió
  por última vez. Escribir compara la época con la actual; si difiere, `Rc::make_mut` copia la página
  solo si está compartida con un punto de control. Sin puntos de control, la rama nunca se toma.
- **Objetos con prefijo de referencias:** cabecera (clase o tipo de arreglo, ordinal de asignación) y
  después los campos de referencia contiguos, seguidos de los escalares. Recorrer un objeto es recorrer
  un prefijo de longitud conocida por clase.
- **Arreglos planos:** cabecera, dimensiones y celdas contiguas en orden por filas, con indicador
  «celdas de referencia» o «celdas escalares».
- **Texto:** UTF-8 inmutable, con indicador «solo ASCII» (decisión de 04, se conserva) y además **migas**
  cada 64 puntos de código para que `CaracterEn` sea de coste constante amortizado también fuera de
  ASCII, como las *breadcrumbs* de las cadenas de Swift.
- **Recolector preciso, sin movimiento, de marcado y barrido** (decisión de 04, se conserva) con tres
  añadidos:
  1. las marcas viven en **mapas de bits laterales**, para que recolectar no ensucie páginas
     compartidas con puntos de control;
  2. el disparo es **determinista**: tras asignar un número de celdas proporcional a lo vivo en la
     última recolección, nunca por tiempo ni por memoria del sistema. Una reproducción repite el estado
     interno bit a bit;
  3. barrido perezoso por clase de tamaño con listas libres.
- **Identidad observable = ordinal de asignación**, guardado en la cabecera. Es determinista e
  independiente de que el recolector reutilice asas.
- **Cero `unsafe`.** `pseudolearn_runtime` declara `#![forbid(unsafe_code)]`. El riesgo RN-06 (errores
  de memoria en un recolector con `unsafe`) desaparece de la VM. El `unsafe` de la frontera con C queda
  para el crate de ABI de R6.

**Por qué.** Un punto de control es copiar la tabla de páginas: O(número de páginas) copias de
puntero, normalmente cientos. Una instantánea es inmutable por construcción (H-10). El delta entre dos
puntos de control es el conjunto de páginas copiadas, así que el estado incremental sale casi gratis.

**Coste reconocido.** Cada acceso al montón pasa por la tabla de páginas: una carga dependiente más que
un puntero directo. E-02 lo mide (V2 frente a V1) **antes** de comprometer R5 (§4.4).

**Contratos.** `MEM.IDENTITY` (identidad por ordinal), `MEM.VALUE.COPY`, `MEM.MANAGED.UNOBSERVABLE`
(misma salida con recolección forzada en cada asignación), `ENG.STATE.SNAPSHOT`.

### T8 · Línea temporal determinista

**Qué es.** Por F3, una ejecución queda determinada por el programa, la semilla, la configuración de
límites y la **cinta de entradas** (los valores entregados a `Leer`, con el índice del evento en que se
entregaron). La línea temporal guarda esa cinta y una serie de **puntos de control** tomados cada
cierta masa de sentencia ejecutada, con **raleo exponencial**: densos cerca del presente y espaciados
hacia el pasado, para acotar la memoria.

- **Avanzar observando** (siguiente sentencia, entrar, salir): gemelo sondeado desde la posición actual.
- **Ejecutar hasta el final**: gemelo rápido con puntos de control; no hay tope de pasos (H-14).
- **Consultar el estado en el evento k**: restaurar el punto de control anterior a k, reproducir con el
  gemelo sondeado hasta k y materializar el estado pedido. La latencia está acotada por el intervalo
  entre puntos de control, no por la longitud del programa.
- **Retroceder** (si se aprueba D-R3-05): es una consulta en el evento k − 1.

Es la técnica de los depuradores de grabación y reproducción (rr; O'Callahan et al., USENIX ATC 2017),
pero barata: no graba llamadas al sistema ni planificación de hilos, porque el lenguaje no tiene más
fuente de no determinismo que la entrada.

**Contratos.** `ENG.STATE.INCREMENTAL` (el estado reconstruido es igual al completo), `ENG.INPUT`,
`API.EXECUTE`, `API.STATE.QUERY`, `PERF.VM.STEP-LATENCY`.

### T9 · Intérprete generado desde el catálogo normativo

**Qué es.** `IR.INSTRUCTIONS` es un contrato del corpus y se exporta. El crate `pseudolearn_bytecode`
mantiene, como dato propio, la tabla de instrucciones de bytecode: cada instrucción de la RI
especializada por tipo y las **superinstrucciones**. `build.rs` genera desde las dos:

- el `enum Instruction` de 8 bytes (código de operación y hasta tres operandos de 16 bits);
- las tablas del verificador;
- el formato textual;
- **el `match` de despacho**, que es una sola tabla de saltos y llama a manejadores pequeños escritos a
  mano y marcados `#[inline(always)]`.

Las superinstrucciones (comparar y saltar, paso de bucle `Para` entero, carga y escritura de celda de
arreglo con índice entero, carga de campo) se eligen por **frecuencia de bigramas** medida sobre el
corpus y la suite AWFY ya traducidos, no por intuición (Ertl y Gregg, 2003). Con tipos estáticos no
hace falta la especialización adaptativa (*quickening*) de CPython 3.11.

**Por qué.** F8 impide un `match` de 150 brazos escrito a mano, y `GEN-NO-HAND-COPY` impide copiar el
catálogo. CPython 3.12 ya genera su intérprete desde un lenguaje de descripción; aquí la fuente es el
corpus normativo. El despacho por `match` con tabla de saltos se justifica con evidencia: en
procesadores modernos, la predicción de saltos indirectos borra la ventaja histórica del *threaded
code* (Rohou, Swamy y Seznec, CGO 2015). Rust estable no garantiza llamadas de cola, así que el
intérprete encadenado por llamadas de cola no es una opción segura.

**Contratos.** `IR.INSTRUCTIONS`. La tabla de bytecode no es observable.

### T10 · Lotes de eventos columnares y consulta por instante

**Qué es.** Los eventos viajan en **lotes en columnas**: un arreglo de clases de evento, otro de nodos
fuente, otro de marcos y otro de desplazamientos al pool de valores. Un lote de 4 096 eventos son
cuatro arreglos contiguos que Dart y JavaScript reciben como arreglos tipados, sin crear un objeto por
evento. El estado se consulta **por referencia**: marco, variable, objeto por identidad, arreglo
paginado, y **en un instante** (índice de evento) gracias a T8. El formato de intercambio tiene un solo
esquema con dos codificaciones: JSON canónico (conformidad y `--json` de la CLI) y binario columnar
(FFI y Wasm).

**Contratos.** `API.WIRE-FORMAT`, `API.EXECUTE`, `API.STATE.QUERY`, `ENG.TRACE.STEP`.

---

## 4. Comparación con las soluciones típicas

### 4.1 Tabla

Las valoraciones de Clepsidra son **hipótesis de diseño**, no mediciones. E-02 (R3), E-08 (R4) y
E-06/E-12 (R5) las confirman o las refutan. Los datos propios disponibles son los de E-01 y H-12.

| Solución típica                                   | Ejemplos                         | Sin observar        | Coste de observar          | Latencia de paso                 | Retroceso | iOS y Wasm | Memoria segura sin `unsafe` | Determinismo entre plataformas |
|---------------------------------------------------|----------------------------------|---------------------|----------------------------|----------------------------------|-----------|------------|-----------------------------|-------------------------------|
| Intérprete de árbol o de tareas                    | Núcleo Dart actual               | Muy lento (≈ 90 ns/micro-paso) | 1,3–4,6× siempre (H-12) | Crece con la pila (instantánea completa) | No  | Sí         | Sí (Dart)                   | Con `BigInt`                   |
| *Hook* de traza por línea con instantánea completa | Python Tutor, `sys.settrace`     | Lento               | Muy alto; topes de pasos    | Crece con el estado              | Sí, guardando todo | Servidor | Sí                       | No especificado                |
| VM de pila con valores en caja                     | CPython clásico, intérprete JVM  | Bajo-medio          | Comprobación por instrucción | Media                          | No        | Sí         | Depende                     | Depende                        |
| VM de registros con valores etiquetados            | Lua 5.4                          | Medio-alto          | *Hook* con contador         | Baja                             | No        | Sí         | Normalmente C               | Sí                             |
| Plan base de 04 §3                                 | —                                | Alto                | Cero en modo no observado   | Baja; instantánea incremental    | No        | Sí         | No (recolector con `unsafe`) | Sí                            |
| JIT escalonada                                     | V8, LuaJIT, HotSpot              | Muy alto tras calentar | Desoptimización compleja | Baja                             | No        | **No** (iOS) | No                        | Calentamiento impredecible    |
| Depurador sobre código nativo                      | lldb/gdb con DWARF               | Máximo              | Muy alto al pisar; optimizado no se pisa | Alta                | No        | No en app  | No                          | No                             |
| Grabación y reproducción del sistema               | rr, depuradores omniscientes     | Alto                | 1,2–2× al grabar           | Alta (reproducir procesos)       | Sí        | No         | No                          | No en Wasm/móvil               |
| **Clepsidra**                                      | —                                | Alto (objetivo ≥ 30× la línea base) | **Cero fuera del tramo observado** (T5) | **Acotada por el intervalo de puntos de control** (T8) | **Sí, por consulta** | **Sí** | **Sí: cero `unsafe` en VM y runtime** (T3, T7) | **Sí, incluidos los límites** (T6, T7) |

### 4.2 Por qué es mejor

1. **Separa ejecutar de observar.** Todas las soluciones típicas instrumentan lo que ejecutan: pagan la
   observación mientras corren (intérprete de árbol, *hooks*) o renuncian a observar lo optimizado
   (depuradores, JIT). Clepsidra corre siempre el gemelo rápido y reconstruye lo observado en el tramo
   que alguien mira. Es posible solo porque el lenguaje es determinista, y PseudoLearn es de los pocos
   lenguajes donde eso está garantizado por especificación.
2. **Quita el tope de pasos sin perder la pedagogía.** Python Tutor y el núcleo actual limitan los pasos
   porque guardan o construyen estado en cada uno. Aquí un ejercicio con datos grandes corre completo y
   después se inspecciona cualquier punto. Es la promesa de [06](../06-ejecucion-pedagogica-y-app.md)
   §5.3, convertida en arquitectura.
3. **Rendimiento con seguridad estructural.** Las VM rápidas suelen apoyarse en `unsafe`, punteros
   crudos o ensamblador. Aquí la velocidad sale del sistema de tipos del lenguaje (sin etiquetas, T4),
   del verificador (sin comprobaciones de rango, T3) y de la contabilidad por bloque (T6). El proyecto
   cumple `QUALITY-NO-PANIC` sin excepciones en el bucle caliente.
4. **Una sola disciplina de memoria para VM y AOT.** Banco de referencias como raíces, disposición de
   objetos con prefijo de referencias y marco compartido. El recolector preciso no necesita mapas de
   pila en ninguno de los dos motores, y RT.ABI de R6 hereda el diseño en vez de inventarlo.
5. **Determinismo total, incluso en los fallos por recursos.** Los límites se miden en marcos, masa de
   sentencia y celdas: un programa agota la memoria en la misma sentencia en iOS, en Wasm y en Linux. La
   conformidad puede comparar por igualdad también esos casos. Ninguna solución típica lo ofrece: miden
   en bytes del anfitrión o en tiempo.
6. **Una sola fuente de verdad para las instrucciones.** El catálogo normativo genera enum, verificador,
   formato textual y despacho; la cobertura `regla → instrucciones` es comprobable por `see`.

### 4.3 Dónde no es mejor, dicho de antemano

| Aspecto                                  | Quién gana                         | Por qué se acepta                                                       | Qué lo mediría o revertiría |
|------------------------------------------|------------------------------------|-------------------------------------------------------------------------|-----------------------------|
| Bucles calientes de larga duración       | JIT (LuaJIT, V8)                   | iOS lo prohíbe; en escritorio el camino es Cranelift (R6)               | `PERF.AOT.LEVEL` en R6      |
| Persecución de punteros en el montón     | Punteros directos                  | La tabla de páginas compra puntos de control O(páginas) e instantáneas inmutables | E-02 V2/V1 > 1,30 en la familia de objetos → montón directo con `unsafe` acotado y puntos de control por tarjetas sucias |
| Simplicidad                              | Lua 5.4 (un solo banco)            | Dos bancos dan recolector preciso sin mapas de pila                     | Complejidad medida en R5    |
| Reanálisis incremental fino              | `rowan` + `salsa`                  | Si el reanálisis completo cabe en 16 ms, la incrementalidad sobra en R4 | E-08 en R4; R7 decide       |
| Memoria en ejecuciones muy largas        | Motores sin línea temporal         | Raleo exponencial y presupuesto de puntos de control configurable        | E-06 en R5                  |

---

### 4.4 Experimento que valida la arquitectura antes de escribirla: E-02 ampliado

E-02 ya pertenece a R3: mide el **techo semántico**. Se amplía para medir también **el coste de la
representación Clepsidra**, de modo que la decisión de T4 y T7 se tome con datos antes de R5.

| Variante | Qué es                                                                                           | Cociente que informa |
|----------|--------------------------------------------------------------------------------------------------|----------------------|
| V0       | Rust idiomático en *release* (aritmética envolvente, `Vec`, índices)                              | Base                 |
| V1       | Semántica PseudoLearn con representación directa: aritmética e índices comprobados, reales finitos, texto por puntos de código | V1/V0 = techo semántico |
| V2       | V1 con la representación Clepsidra: asas, montón paginado con barrera de época, dos bancos, trampas diferidas | V2/V1 = coste de la representación |
| V3       | V2 con puntos de control activos cada ≈ 1 ms                                                     | V3/V2 = coste de grabar la línea temporal |

Núcleos traducidos a mano del subconjunto de Are We Fast Yet que el lenguaje vigente puede expresar
(sin closures ni colecciones): Sieve, Permute, Queens, Towers, List, Storage, Bounce, Mandelbrot,
NBody y Richards.

**Hipótesis provisional (D-07):** V1/V0 ≤ 1,5 en numérica y objetos; V2/V1 ≤ 1,25; V3/V2 ≤ 1,10.

**Criterio de decisión:** si V2/V1 > 1,30 en una familia, se revisa T7 antes de autorizar R5. No se
eliminan resultados desfavorables.

**Desviación respecto del método original:** E-02 pedía C y Go. Go no está instalado y añadirlo sería
una sexta cadena de herramientas, contra `AGENTS.md` §9. Rust compilado por LLVM ocupa el lugar de C. La
comparación con Go queda como decisión D-R3-04.

### 4.5 El diferencial y su encaje con la visión del lenguaje

**El dilema que se elimina.** Los lenguajes actuales obligan a elegir entre rapidez y observabilidad:

| Familia                         | Rápido | Observable paso a paso                         | El mismo programa con la misma semántica en ambos |
|---------------------------------|--------|------------------------------------------------|---------------------------------------------------|
| Rust, Go, C                     | Sí     | Solo con depurador; lo optimizado no se pisa   | No                                                |
| Python, JavaScript              | Medio (JIT) | Con *hooks* que frenan mucho               | Parcialmente                                      |
| Python Tutor, Scratch, PSeInt   | No     | Sí, con tope de pasos                          | Sí, porque nunca son rápidos                      |
| **PseudoLearn con Clepsidra**   | **Sí** | **Sí, también hacia atrás**                    | **Sí**                                            |

Clepsidra elimina esa elección gracias a una propiedad que casi ningún lenguaje garantiza por
especificación: **el determinismo total** (F3). Rust, Go o Python tienen hilos, reloj y E/S libre; no
pueden reconstruir una ejecución a partir de una cinta. PseudoLearn sí, y la arquitectura convierte esa
garantía semántica en rendimiento. La consecuencia para la visión del lenguaje es **un lenguaje que
crece de la enseñanza a la producción sin cambiar de motor ni de semántica**: el programa que se pisa
en el móvil es el mismo que corre compilado a nativo.

**Dónde gana, por dimensión** ([05](../05-rendimiento-motor-y-compilacion.md) §1.2):

| Dimensión | Qué gana Clepsidra                                                                                         | Frente a                       |
|-----------|------------------------------------------------------------------------------------------------------------|--------------------------------|
| P (VM)    | Elimina los tres costes típicos de una VM: etiquetas de tipo (T4), comprobación de observación (T5) y comprobaciones de rango (T3). Solo quedan el trabajo útil y el despacho. Es el techo práctico de un intérprete sin JIT, el único motor posible en iOS | Lua 5.4, CPython, plan base de 04 |
| P (AOT)   | No impone techo: RI, marco, raíces y disposición de objetos sirven a Cranelift y a LLVM                       | —                              |
| L         | Rendimiento previsible: sin calentamiento ni desoptimizaciones sorpresa (Barrett et al., OOPSLA 2017). La latencia de paso depende del intervalo entre puntos de control, no del tamaño del programa | JIT escalonadas, intérprete actual |
| O         | Coste cero fuera del tramo observado; sin tope de pasos; inspección retroactiva de cualquier instante        | Intérprete actual (1,3–4,6×), Python Tutor |
| M         | Asas de 32 bits, valores sin caja, instantáneas por páginas compartidas en vez de copias                      | VM con valores en caja         |
| X         | Límites deterministas: un programa agota recursos en la misma sentencia en iOS, Wasm y Linux; correctores automáticos justos y conformidad por igualdad | Límites en bytes o en tiempo |
| C         | Front-end orientado a datos: reanálisis completo por pulsación dentro de 16 ms                                 | Núcleo actual (H-21)           |
| Seguridad | Cero `unsafe` en VM y runtime: el motor incrustado en la app, la web y los editores no puede corromper memoria | VM en C, ensamblador o `unsafe` |

**Por qué es la mejor opción y no solo una buena.**

- Una JIT sería más rápida en bucles largos de escritorio, pero no puede ser el motor en iOS, rompe la
  previsibilidad y no aporta nada a la observación. Donde gana, el AOT la sustituye sin calentamiento.
- El AOT con depurador da el máximo rendimiento, pero no se pisa en móvil ni en código optimizado:
  pierde lo que hace distinto a PseudoLearn.
- Una VM clásica rinde parecido sin observar, pero conserva el tope o el coste de las instantáneas, no
  da retroceso y necesita un recolector con `unsafe`.
- Clepsidra es la única opción que queda cerca del máximo en cada dimensión **sin poner techo a
  ninguna**. Su coste es complejidad de implementación, y el criterio de la persona responsable es pagar
  ese coste si compra la mejor opción.

Todas las afirmaciones de esta sección son hipótesis de diseño hasta que E-02 (R3), E-08 (R4) y E-06 y
E-12 (R5) las confirmen. Los resultados desfavorables se publican (`PERF.PROTOCOL`).

**Ampliación propuesta (D-R3-07).** Con el tiempo de implementación fuera de la ecuación, se elevan a
objetivo tres capacidades que §T5 solo dejaba abiertas:

1. **Transferencia AOT → VM (R6).** Gracias a la correspondencia de marcos, un binario nativo puede pasar
   a la VM en un punto seguro mediante bloques fríos que vuelcan los valores vivos al marco canónico. Un
   fallo de un binario nativo se reproduce exactamente y se pisa hacia atrás: **depuración omnisciente de
   código de producción, portable e integrada en el lenguaje**. `RT.ABI` y `PERF.AOT.LEVEL` lo incluyen
   al especificarse en R6.
2. **Frontera grabable como regla de `RT.HOST.INTERFACE`.** Toda capacidad del anfitrión, presente o
   futura (archivos, red, tiempo), pasa por la cinta. Se escribe ya en R3, aunque hoy solo exista la
   entrada, para que la reproducibilidad sobreviva a la evolución posterior a R9.
3. **LLVM como nivel de *release* planificado** tras E-NR1, para perseguir N3 sin depender de que
   Cranelift alcance el nivel.


---

## 5. Cambios respecto de 04 y de su `architecture.yaml`

### 5.1 Decisiones internas de 04 §3

| Crate     | Decisión de 04 §3                                        | En este plan                                                               |
|-----------|----------------------------------------------------------|----------------------------------------------------------------------------|
| syntax    | Árbol verde/rojo (`rowan`)                                | **Se sustituye** por el árbol postorden en columnas (T1)                    |
| syntax    | Descenso recursivo a mano guiado por la gramática         | Se conserva                                                                 |
| semantic  | Arenas con índices tipados                                | Se conserva, también en columnas                                            |
| ir        | CFG SSA con parámetros de bloque                          | Se conserva, con clases de valor, masa de sentencia, celdas y trampas diferidas (T2) |
| vm        | VM de registros especializada por tipo                    | Se conserva y se concreta: bicameral, enmascarada, generada (T3, T4, T9)    |
| vm        | Dos modos de despacho                                     | **Se sustituye** por código gemelo con correspondencia de marcos (T5)       |
| vm        | Instantáneas incrementales con puntos de control          | **Se amplía** a montón persistente y línea temporal (T7, T8)                |
| runtime   | Recolector preciso sin movimiento de marcado y barrido   | Se conserva, con marcas laterales y disparo determinista (T7)               |
| runtime   | Texto UTF-8 con indicador ASCII                           | Se conserva, con migas cada 64 puntos de código                             |
| runtime   | `unsafe` permitido                                        | **Se retira**: `#![forbid(unsafe_code)]` (T7)                               |
| codegen   | Pila sombra                                               | Se conserva: la pila sombra **es** el banco de referencias (T4)             |
| api       | Recursos, lotes, consulta por referencia                  | Se conserva, con lotes columnares y consulta por instante (T10)             |
| service   | `salsa`                                                   | **Se aplaza** a la decisión de R7, con E-08                                 |

### 5.2 Crates

Dos crates nuevos para que ninguno tenga dos responsabilidades. La frase de `pseudolearn_vm` en 04
(«Compila la RI a bytecode **y** la ejecuta») tenía dos, contra la pregunta de una responsabilidad de
`AGENTS.md` §6.

| Nivel | Crate                    | Responsabilidad (una frase, sin «y»)                                                 | Puede depender de                         | `unsafe` |
|-------|--------------------------|--------------------------------------------------------------------------------------|-------------------------------------------|----------|
| 4     | `pseudolearn_bytecode`   | Traduce la RI verificada a bytecode gemelo con su asignación bicameral de registros    | ir, source                                | No       |
| 6     | `pseudolearn_vm`         | Ejecuta bytecode verificado emitiendo eventos observables                              | bytecode, runtime, library, diagnostics   | No       |
| 7     | `pseudolearn_timeline`   | Reconstruye el estado observable de cualquier instante mediante puntos de control       | vm, runtime, bytecode, diagnostics        | No       |
| 8     | `pseudolearn_api`        | Igual que en 04, un nivel más arriba                                                  | todas las capas inferiores                | No       |
| 9     | `pseudolearn_wasm`, `pseudolearn_conformance` | Igual que en 04                                                  | api                                       | Solo `wasm` (generado) |

`architecture.yaml` cambia en consecuencia:

- `unsafe_allowed: [pseudolearn_wasm]`;
- `external_dependencies` sin `rowan` ni `salsa`;
- `deterministic_output_crates` añade `pseudolearn_bytecode` y `pseudolearn_timeline`;
- `generated_sources` añade `crates/pseudolearn_bytecode/generated` y `crates/pseudolearn_vm/generated`.

---

## 6. Plan de ejecución de R3 en una sola iteración

Cada paso indica qué hacer, dónde y cuándo está hecho. Los recuentos de reglas son orientativos. Las
**intenciones normativas** de B2 dicen qué tiene que quedar garantizado; la redacción final de cada regla
sigue la skill `language-spec-authoring` y el formato `see/1`.

### B0 · Preparación

- [x] **B0.1 Estado del repositorio.**
  - `git branch --show-current` devuelve `feature/agregar-ruta-de-especificacion`.
  - El árbol está limpio y HEAD local coincide con el remoto (`git ls-remote`).
- [x] **B0.2 Decisiones.**
  - En [08](08-decisiones-riesgos-y-cambios-de-reglas.md) se añade §1.5 «Decisiones de R3», con D-R3-01 a
    D-R3-07, la fecha y la fuente: el mensaje de autorización y la conversación del 2026-10-14 para
    D-R3-02.
  - D-17 y D-21 salen de §1.4 (abiertas) y quedan resueltas.
  - Los riesgos RC-01 a RC-06 de §8 se añaden a 08 §2.
- [x] **B0.3 Línea de partida.**
  - Se ejecutan `cargo xtask verify` en `pseudolearn_spec` y en `pseudolearn_rust_checks`, y `dart test`
    en `pseudolearn_core`.
  - Se anotan las cantidades de tests y de observaciones de conformidad: son la referencia contra la que
    se comprueban las regresiones.
- [x] **B0.4 Inicio de autoría.** Se registra la marca de tiempo en `results/r3-authoring-start.json`,
  con el mismo formato que `authoring-start.json`, para medir minutos por regla como en E-15.

### B1 · Extensiones de `see`

Es código Rust en `packages/pseudolearn_spec`, permitido en R3. Cada extensión sigue el mismo
recorrido:

1. esquema `schemas/see-1.schema.json`;
2. `see_model`;
3. `see_format`;
4. la capa que corresponda (`see_validation`, `see_conformance`, `see_export` o `see_report`);
5. tests espejo con camino feliz e infeliz;
6. *fixture* negativo con comprobación del identificador de error;
7. actualización del `README.md` del paquete.

Todas son ampliaciones compatibles de `see/1` y de `see-protocol/1`: no cambian la versión mayor.

- [x] **B1.1 Operación `trace`.**
  - Casos con `"operacion": "trace"` y `espera.eventos`: una lista ordenada de
    `{ "clase", "linea", "datos" }`. `clase` pertenece al alfabeto de `ENG.TRACE.EVENTS`; `datos`
    depende de la clase (rama, texto, nombre llamado…).
  - Opcionalmente, `espera.estado_en`: `{ "evento": <índice o selector>, "estado": <vista de
    ENG.STATE.SNAPSHOT> }`.
  - La comparación es por secuencia exacta.
  - Rechazo: `SEE-TRACE-CLASS` si una clase no existe en el alfabeto. El alfabeto se lee de un bloque
    `definicion` de `ENG.TRACE.EVENTS`, nunca de una lista escrita en el código.
- [x] **B1.2 Operación `ir`.**
  - Casos con `programa_ri`: texto en el formato de `IR.TEXT-FORMAT`.
  - `espera.ri` es uno de: `{ "aceptada": true }`, `{ "aceptada": false, "regla": "IR.WELL-FORMEDNESS#Rn" }`
    o `{ "reimpresion": "<texto exacto>" }`.
  - Rechazo: `SEE-IR-EXPECTATION` si falta el resultado esperado.
- [x] **B1.3 Operación `cli`.**
  - Casos con `{ "argumentos": [...], "entorno": {...}, "entrada": "...", "archivos": {...} }`.
  - `espera` contiene `codigo_salida`, `salida`, `salida_error` y, opcionalmente, `json`.
  - Rechazo: `SEE-CLI-EXIT` si `codigo_salida` no está en la tabla de códigos de
    `TOOL.CLI.CONVENTIONS`. La tabla se lee de un bloque `definicion`.
- [x] **B1.4 Terminación `cancelled` y campo `limite`.**
  - El enum de `terminacion` añade `cancelled`.
  - `espera.limite` (`sentencias` o `tiempo`) es obligatorio con `limit_reached`.
  - Rechazo: `SEE-LIMIT-KIND`.
- [x] **B1.5 Bloque `medicion`.**
  - Nuevo bloque tipado:
    `{ "id", "metrica", "unidad", "suite", "comparador", "umbral", "provisional", "plataformas", "protocolo" }`.
  - Una regla puede listar mediciones en `verificacion`, y cuentan para `SEE-ORPHAN`.
  - Rechazo: `SEE-MEASUREMENT-PROTOCOL` si `protocolo` no apunta a una regla de `PERF.PROTOCOL`.
  - `see conform` no ejecuta mediciones: las informa como `no_aplicable` con su procedencia.
- [x] **B1.6 Bloques `instruccion` y `cobertura` y validación `SEE-IR-COVERAGE`.**
  - `instruccion`: `{ "id", "firma", "clases_de_valor", "semantica", "trampas", "efectos", "observacion" }`.
  - `cobertura`: `{ "regla": "LANG.X#Rn", "instrucciones": [...] }` o
    `{ "regla": ..., "sin_ri": "<motivo>" }`, para reglas que solo afectan al análisis estático.
  - Toda regla de `LANG` o `LIB` de clase `semantica`, `ejecucion` o `ampliacion` debe tener exactamente
    una entrada `cobertura`, y cada instrucción citada debe existir.
  - Rechazos: `SEE-IR-COVERAGE` (regla sin cobertura) y `SEE-IR-UNKNOWN` (instrucción inexistente).
  - `see matrix` publica la tabla `regla → instrucciones`.
- [x] **B1.7 Validación `SEE-PROFILE-OPENERS`.**
  - `TOOL.CLI.CONVENTIONS` declara en un bloque `definicion` las identidades de apertura de nivel
    superior: `algorithm`, `classKeyword` y la apertura de subprograma.
  - La validación normaliza caja y acentos según cada perfil y rechaza cualquier lexema o alias de
    apertura que coincida con un lexema, de cualquier identidad, del otro perfil.
- [x] **B1.8 Paridad de `TOOL.CLI.MESSAGES`.**
  - Se reutiliza el mecanismo de `DIAG.MESSAGES` (plantilla por idioma y argumentos tipados).
  - Rechazos: `SEE-MESSAGE-PARITY` (plantilla sin su par) y `SEE-MESSAGE-ARGUMENTS` (argumentos
    distintos entre idiomas).
  - `see export` incluye el catálogo.
- [x] **B1.9 Capacidad `observe` del protocolo.**
  - La negociación de `see-protocol/1` admite `observe`.
  - Un caso `trace` contra un sujeto sin la capacidad queda `pendiente`, nunca `cumple`.
  - Un sujeto que responde eventos sin anunciarla produce un error operativo.
  - Hay tests de protocolo con negociación, EOF, JSON corrupto y tiempo agotado.
- [x] **B1.10 Contratos SEE.** Se versionan con clasificación e impacto (`see diff`, `see impact`):
  `SEE.FORMAT` (en borrador), `SEE.VALIDATION`, `SEE.ADAPTER.PROTOCOL` y `SEE.CONFORMANCE.MATRIX`.
  También `see lock`.
- [x] **B1.11 Verificación.** `cargo xtask verify` en verde en `pseudolearn_spec`, con todos los
  *fixtures* negativos nuevos rechazados por su identificador.

### B2 · Corpus de R3

Treinta y nueve especificaciones nuevas en `experimental`, en `specifications/eng`, `mem`, `ir`, `rt`,
`api`, `tool` y `perf`. Cada una se crea con `see new <ID> --domain <dominio>`.

**Reglas de autoría para todas:**

- los esperados se derivan de la regla;
- casos en `es` y `en` y en los dos rigores, o exclusión justificada;
- cada regla con casos o mediciones;
- `sujetos` según [03](03-catalogo-de-especificaciones.md) §2, salvo `TOOL.CLI.MESSAGES` (sujeto `cli`);
- **ninguna mención a la arquitectura**: el corpus dice qué se observa, el `README.md` dice cómo.

#### B2.1 `ENG.LIMITS` (primera especificación de la fase)

- [x] Intenciones normativas:
  1. Los límites son recursos del entorno que el anfitrión configura. No cambian el resultado de un
     programa que no los alcanza. No requieren edición nueva, porque `LANG.SUBPROGRAM.RECURSION` y
     `LANG.ARRAY.DIMENSION` ya delegan la cuantificación.
  2. Las unidades son deterministas e independientes de la plataforma:
     - **profundidad** en marcos activos, contando el algoritmo principal como uno;
     - **sentencias** en entradas a sentencia ejecutadas;
     - **memoria** en celdas alcanzables. Celdas: una por objeto más una por campo; una por arreglo más
       una por elemento; una por cadena más una por cada 8 puntos de código, redondeando hacia arriba.
  3. Mínimos garantizados: 1 000 marcos y 2²² celdas. No hay mínimo de sentencias.
  4. **Recursos del programa frente a presupuesto del anfitrión.** Esta distinción mantiene el caso
     vigente `LANG.SUBPROGRAM.RECURSION#C3`, que espera un fallo con `recursionDepthExceeded`.
     - Agotar profundidad o celdas es un **fallo** del programa: terminación `failed`, con
       `recursionDepthExceeded` (existente) o `cellLimitExceeded` (nuevo).
     - Agotar el presupuesto de sentencias o la guarda de tiempo es `limit_reached`, con `limite` y el
       diagnóstico nuevo `statementBudgetExhausted`.
     - La guarda de tiempo no tiene diagnóstico propio: es la terminación con `limite: tiempo`.
  5. El límite se detecta exactamente en la sentencia o asignación que lo supera, con su tramo, y sin
     efectos posteriores.
  6. La guarda de tiempo es la única terminación no determinista. Ningún caso la observa con un valor
     distinto de «sin guarda».
  7. Ningún límite agota la pila del anfitrión ni produce `DIAG.ENGINE.INTERNAL-FAULT`.
  8. Valores por omisión, informativos y de clase `PUEDE`: app con 1 000 marcos; CLI con 100 000 marcos
     y sin presupuesto de sentencias.
- [x] Los códigos nuevos entran en `DIAG.CATALOG` con ficha bilingüe y clasificación de cambio (skill
  `diagnostics-authoring`).
- [x] Hay casos de borde: exactamente en el límite, uno por encima, recursión mutua y arreglo cuyo tamaño
  supera las celdas.

#### B2.2 `MEM`

- [x] `MEM.IDENTITY`:
  - la identidad observable de un objeto o arreglo es su **ordinal de asignación** dentro de la
    ejecución, empezando en 1;
  - no depende de la recolección;
  - dos nombres que comparten objeto muestran la misma identidad;
  - los ciclos son válidos.
- [x] `MEM.VALUE.COPY`:
  - los primitivos y las cadenas se copian al asignar y al pasar por valor;
  - arreglos y objetos se comparten por referencia;
  - `CopiaSuperficial` copia un nivel;
  - el parámetro por referencia es un alias de la celda: dos parámetros por referencia a la misma
    variable observan cada escritura.
- [x] `MEM.MANAGED.UNOBSERVABLE`:
  - ningún programa observa cuándo se recupera memoria;
  - propiedad: la misma salida, terminación y traza con recolección forzada en cada asignación y sin
    ella. Es la propiedad `Q1`, que la ejecuta `engine` en R5.

#### B2.3 Modelo de ejecución

- [x] `ENG.EXEC.MODEL`:
  - cinco terminaciones: `completed`, `failed`, `awaiting_input`, `cancelled` y `limit_reached`;
  - la ejecución es determinista para el mismo programa, perfil, rigor, semilla, configuración de
    límites y entradas;
  - la cancelación surte efecto en una entrada a sentencia y no deja efectos parciales.
- [x] `ENG.EXEC.EFFECT-ORDER`:
  - efectos observables: salida, petición de entrada, fallo y terminación;
  - se informa la **primera trampa en orden de programa**, con su tramo, y ningún efecto posterior es
    visible;
  - el orden de las subexpresiones sin efectos no es observable.
- [x] `ENG.INPUT`:
  - `Leer` suspende con `awaiting_input` y reanuda con el valor entregado;
  - la entrada puede darse por lotes;
  - la secuencia de valores entregados, con el evento en que se entregó cada uno, determina la ejecución
    junto con la semilla;
  - una entrada inválida repite la petición sin modificar el destino (`LANG.IO.INPUT`).

#### B2.4 Traza

- [x] `ENG.TRACE.EVENTS`:
  - alfabeto cerrado, en un bloque `definicion`: entrada a sentencia, salida de sentencia, decisión,
    llamada, retorno, salida de datos, petición de entrada, entrada recibida y fallo;
  - cada evento lleva el nodo fuente (línea y tramo) y sus datos;
  - el orden de los eventos es total.
- [x] `ENG.TRACE.STEP`:
  - un paso observable es el intervalo entre dos eventos consecutivos;
  - los lotes de eventos conservan el orden y no pierden eventos;
  - avanzar «hasta una condición» se define sobre eventos.

#### B2.5 Estado

- [x] `ENG.STATE.SNAPSHOT`:
  - máquina nocional con la pila de marcos (subprograma, receptor, parámetros y su alias por
    referencia) y las variables con estado «sin valor»;
  - arreglos con dimensiones y celdas (resuelve H-10);
  - grafo de objetos alcanzables con identidad (`MEM.IDENTITY`);
  - valores representados con `LANG.IO.VALUE-FORMAT`;
  - una vista es inmutable.
- [x] `ENG.STATE.INCREMENTAL`:
  - cada evento puede llevar el cambio de estado;
  - el estado reconstruido acumulando cambios es igual al completo en todo evento (propiedad);
  - la consulta del estado en un evento pasado da el mismo resultado que haberlo observado en su momento.

#### B2.6 Anfitrión

- [x] `RT.HOST.INTERFACE`:
  - capacidades inyectadas: salida, entrada y semilla;
  - no hay reloj, entorno, archivos ni azar implícitos;
  - **toda capacidad presente o futura es grabable**: su resultado se puede guardar y reproducir para
    obtener la misma ejecución (D-R3-07);
  - algoritmo de azar fijado:
    - xoshiro256\*\* sembrado con SplitMix64 desde la semilla con signo de 64 bits;
    - `azar` devuelve `(siguiente >> 11) × 2⁻⁵³`;
    - semilla por omisión 42, como en el corpus;
    - casos con los cinco primeros valores de las semillas 0, 42 y −1, calculados con un oráculo
      independiente en `see_oracles`.

#### B2.7 RI

- [x] `IR.MODEL`:
  - módulo, funciones, bloques con parámetros, valores SSA, tipos y las clases de valor `escalar` y
    `referencia`;
  - celdas para el paso por referencia.
- [x] `IR.INSTRUCTIONS`:
  - un bloque `instruccion` por instrucción;
  - trampas con la semántica de primera trampa (B2.3);
  - regiones puras: la semántica permite comprobar las trampas al final de una región sin efectos;
  - un bloque `cobertura` por regla de `LANG` y `LIB` (B1.6).
  - El catálogo se escribe **desde las reglas**: se recorre cada regla de ejecución de `LANG` y `LIB` y
    se pregunta qué operación exige.
- [x] `IR.WELL-FORMEDNESS`: dominancia, tipos y clases de valor por operando, terminador por bloque,
  aridad de los parámetros de bloque y masa de sentencia coherente con las instrucciones `observe`.
- [x] `IR.TEXT-FORMAT`: gramática del texto de la RI e ida y vuelta exacta; casos `ir` de reimpresión.
- [x] `IR.SOURCE-MAP`: cada instrucción con trampa u observación lleva su nodo fuente; un fallo informa
  el tramo de ese nodo.
- [x] `IR.OBSERVATION-POINTS`:
  - qué instrucciones producen qué eventos;
  - **masa de sentencia** por bloque;
  - regla «como si»: el código que no observa solo conserva los efectos externos.
- [x] `IR.LOWERING`: ejecutar la RI de `p` equivale a ejecutar `p` en todos los observables de
  `ENG.EXEC.*` y `ENG.TRACE.*`. Las propiedades las ejecuta `engine` en R5.

#### B2.8 API

- [x] `API.MODEL`: documento, análisis y ejecución son recursos con identificador y ciclo de vida.
- [x] `API.ERRORS`: todo resultado es un valor, con un tipo de error por familia; ningún pánico cruza la
  frontera, y `DIAG.ENGINE.INTERNAL-FAULT` es la última barrera.
- [x] `API.VERSIONING`: versión de la API, ediciones soportadas y negociación de capacidades: `observe`,
  `seek` (si se aprueba D-R3-05) e `idioma de interfaz`.
- [x] `API.WIRE-FORMAT`:
  - un esquema con dos codificaciones: JSON canónico, con claves ordenadas, y binario columnar para
    lotes de eventos;
  - ida y vuelta entre ambas;
  - claves independientes del idioma de interfaz.
- [x] `API.ANALYZE`: texto + perfil + rigor → diagnósticos ordenados (`DIAG.ORDERING`) y esquema.
- [x] `API.EXECUTE`:
  - iniciar con semilla, límites y entradas;
  - avanzar por lotes o hasta una condición;
  - entregar entrada y cancelar;
  - si se aprueba D-R3-05, posicionarse en un evento pasado.
- [x] `API.STATE.QUERY`:
  - consulta por referencia de marcos, variables, objeto por identidad y arreglo paginado;
  - **en un instante**, es decir, por índice de evento;
  - horizonte retenido declarado por la ejecución (RC-03).
- [x] La presentación en el idioma de interfaz es un parámetro del borde: el núcleo devuelve códigos y
  argumentos tipados (§11.3).

#### B2.9 Herramientas

- [x] `TOOL.CLI.CONVENTIONS`:
  - toda §11: órdenes canónicas en español con alias en inglés siempre aceptados, y opciones;
  - vocabulario autodeclarado con las identidades de apertura (B1.7) y `--vocabulario`;
  - cadena de resolución del idioma de interfaz, en la que no entran el alias ni el archivo;
  - códigos de salida en un bloque `definicion`: 0 éxito, 1 el programa tiene errores o falló,
    2 uso incorrecto, 3 error operativo;
  - `--json` con `API.WIRE-FORMAT`.
- [x] `TOOL.CLI.MESSAGES`: catálogo bilingüe de toda la prosa de la CLI (ayuda, errores de uso,
  progreso y narración de `--traza`), con paridad `es`/`en` (B1.8).
- [x] `TOOL.CLI.CHECK`: `pseudo comprobar` sobre archivos y directorios; diagnósticos y códigos de
  salida; casos `cli`.
- [x] `TOOL.CLI.RUN`: `pseudo ejecutar` con entrada estándar, `--semilla`, límites, `--traza` en el
  idioma de interfaz, salida del programa sin traducir y casos `cli` en los dos idiomas de interfaz.
- [x] `TOOL.CLI.IR`: `pseudo ri` imprime la RI en `IR.TEXT-FORMAT`.
- [x] `TOOL.SERVICE.LOSSLESS-TREE`: reimprimir el árbol da exactamente el texto, con comentarios,
  trivia, BOM y errores incluidos. Propiedad sobre todo el corpus.

#### B2.10 Rendimiento

- [x] `PERF.PROTOCOL`: el protocolo de E-01 pasa a ser normativo:
  - procesos por objetivo, iteraciones por proceso, semilla y procedencia capturada antes de compilar;
  - detección de puntos de cambio sin descartar muestras;
  - intervalos de confianza al 95 %;
  - límites de precisión del reloj;
  - publicación de todos los resultados, incluidos los desfavorables.
- [x] `PERF.BASELINE.REFERENCE`: B5.
- [x] `PERF.SUITE.AWFY-CORE`: los diez programas de §4.4 en PseudoLearn, en los dos perfiles, con salida
  esperada derivada del algoritmo.
- [x] `PERF.VM.THROUGHPUT`, `PERF.VM.STEP-LATENCY`, `PERF.FRONTEND.THROUGHPUT` y `PERF.ARTIFACT.SIZE`:
  bloques `medicion` con los umbrales provisionales de D-R3-03, marcados `provisional: true`.

#### B2.11 Cierre del corpus

- [x] Manifiesto `specifications/features/engine-r3.yaml` con las treinta y nueve especificaciones.
- [x] `see validate`, `see lock` y `see export` regenerados y vigentes.
- [x] La matriz publica la cobertura `regla → instrucciones` sin huecos.
- [x] El tiempo de autoría se cierra en `results/r3-authoring.json`, con minutos por regla, sin inferir
  tiempo humano.

### B3 · Contraste con `reference`

- [x] **B3.1 Adaptador.**
  - En `packages/pseudolearn_core/tool/conformance/` se añade la capacidad `observe`.
  - El adaptador traduce los eventos públicos del intérprete al alfabeto de `ENG.TRACE.EVENTS` y no usa
    nada de `lib/` fuera de la API pública.
  - Tests del adaptador con camino feliz e infeliz.
- [x] **B3.2 Primera ejecución.**
  - `see conform --subject reference` sobre `ENG.EXEC.MODEL`, `ENG.TRACE.EVENTS`, `ENG.INPUT`,
    `MEM.IDENTITY` y `MEM.VALUE.COPY`.
  - Resultado crudo en `results/r3-first-reference.json`.
- [x] **B3.3 Clasificación.** Cada divergencia termina como:
  - especificación corregida, solo si el caso estaba mal derivado de la regla;
  - `exento` con hallazgo nuevo en la tabla del `README.md` de `pseudolearn_spec`, en
    `results/r3-findings.json` y en `conformance.yaml`;
  - o decisión registrada en 08.
  - Divergencias esperables: arreglos ausentes, identidad no ordinal y unidades de micro-paso.
- [x] **B3.4 Verificación.**
  - `see conform` sin regresiones exigibles.
  - `dart test`, `dart analyze --fatal-infos --fatal-warnings` y `dart run tool/check_limits.dart` en
    verde en el núcleo.

### B4 · E-02 ampliado

- [x] **B4.1 Miembro.**
  - Workspace Rust anidado `packages/pseudolearn_benchmarks/ceiling`, con `README.md` (skill
    `package-docs`), `rust-toolchain.toml` con la misma versión exacta, `architecture.yaml`,
    `deny.toml`, `clippy.toml` y `xtask` encadenado a `pseudolearn_rust_checks`, como en
    `pseudolearn_spec`.
  - El `README.md` raíz y el de `pseudolearn_benchmarks` lo declaran.
- [x] **B4.2 Núcleos.**
  - Diez núcleos (Sieve, Permute, Queens, Towers, List, Storage, Bounce, Mandelbrot, NBody y Richards)
    en cuatro variantes (§4.4).
  - Cada variante produce la misma salida que el programa PseudoLearn de `PERF.SUITE.AWFY-CORE`, y un
    test lo comprueba.
  - Las variantes V2 y V3 implementan **dentro del núcleo de prueba** asas de 32 bits, tabla de páginas
    de 4 096 palabras con barrera de época, dos bancos y trampas diferidas.
  - No exponen biblioteca reutilizable: no son el motor.
- [x] **B4.3 Medición.**
  - Protocolo `PERF.PROTOCOL` en local (Apple M2).
  - Evidencia en `results/e02/` con manifiesto de captura y procedencia.
- [x] **B4.4 Informe.**
  - Cocientes V1/V0, V2/V1 y V3/V2 por núcleo y por familia, con intervalos.
  - Aplicar el criterio de §4.4: si V2/V1 > 1,30 en una familia, se informa como **condición previa a
    autorizar R5** y se mantiene el resultado. No se ajusta el diseño a mano durante R3.
- [x] **B4.5 Verificación.** `cargo xtask verify` en verde en `ceiling`.

### B5 · Línea base publicada

- [x] **B5.1** `PERF.BASELINE.REFERENCE` con los datos de E-01 ya conservados (local, `ci-r0-complete`)
  y sus limitaciones: resolución del reloj de JavaScript y grupos con candidatos de cambio.
- [x] **B5.2**
  - Medir los diez programas de `PERF.SUITE.AWFY-CORE` en `reference` con el arnés de
    `pseudolearn_benchmarks`, en los dos modos (con y sin observación).
  - Evidencia en `results/macos-r3-awfy/`.
  - Es la base de la puerta ≥ 10× de R5.
- [x] **B5.3** El arnés supera su verificación (`dart test` y sus verificadores) si se le añadieron
  cargas.

### B6 · `README.md` y reglas del motor

- [x] **B6.1** `packages/pseudolearn_engine/README.md` con las ocho secciones de `package-docs`:
  - la **filosofía** de §12.1 y la arquitectura completa de §3;
  - el flujo de datos;
  - decisiones con sus alternativas rechazadas (§4 y §5.1);
  - genealogía (§10);
  - verificación prevista (`cargo xtask verify`, `see conform --subject engine`);
  - pendientes declarados por fase.
  - Autosustentable: no cita este plan ni `docs/` (`DOC-NO-TRANSIENT-REFS`).
- [x] **B6.2** `packages/pseudolearn_engine/architecture.yaml` con la forma de §5.2: niveles, `may_depend_on`,
  `unsafe_allowed: [pseudolearn_wasm]`, dependencias externas sin `rowan` ni `salsa`, límites, nombres,
  fuentes generadas y salidas deterministas.
- [x] **B6.3** Un `README.md` por crate, en `packages/pseudolearn_engine/crates/<crate>/README.md`, con
  el contenido que fija §12.2: source, diagnostics, lexicon, syntax, semantic, ir, lowering, bytecode,
  abi, runtime, library, vm, timeline, api y conformance.
- [x] **B6.4** `apps/pseudolearn_cli/README.md` con la frontera de idioma de §11 y las órdenes de
  `TOOL.CLI.*`.
- [x] **B6.5** Verificador de capas.
  - Ejecutar `rust-checks layers` sobre `packages/pseudolearn_engine`.
  - Si exige manifiestos, se añade a `pseudolearn_rust_checks` un modo declarativo: comprueba que cada
    crate declarado tiene su carpeta con `README.md` y que no existe ninguna carpeta no declarada. Lleva
    caso negativo y tests. **No se crean crates vacíos** para satisfacer al verificador.
  - `cargo xtask verify` en verde en `pseudolearn_rust_checks`.

### B7 · Documentos del plan y raíz

- [x] **B7.1** [03](03-catalogo-de-especificaciones.md):
  - fila de `TOOL.CLI.MESSAGES` en §2.10;
  - totales de §1;
  - nuevos códigos de diagnóstico citados donde corresponda.
- [x] **B7.2** [04](04-arquitectura-del-workspace-rust.md):
  - tabla de crates y niveles de §5.2;
  - decisiones de §5.1;
  - `architecture.yaml` de §4;
  - CLI con órdenes en español (§7 de 04).
- [x] **B7.3** [08](08-decisiones-riesgos-y-cambios-de-reglas.md): coherente con B0.2.
- [x] **B7.4** `README.md` raíz: mapa de miembros con `ceiling`, y `packages/pseudolearn_engine` como
  miembro documentado sin código.
- [x] **B7.5** Puerta `DOC-NO-TRANSIENT-REFS` en verde: ningún archivo fuera de `docs/` cita `docs/`.

### B8 · Cierre (`phase-gate`)

- [x] **B8.1** Verificación completa, cada una con su salida real:

  | Comprobación                                                         | Miembro                          |
  |----------------------------------------------------------------------|----------------------------------|
  | `cargo xtask verify`                                                 | `pseudolearn_spec`, `pseudolearn_rust_checks`, `ceiling` |
  | `see validate`, `see lock --check`, `see export --check`, `see matrix` | `pseudolearn_spec`             |
  | `see conform --subject reference` sin regresiones                    | `pseudolearn_spec`               |
  | `dart test`, `dart analyze --fatal-infos --fatal-warnings`, `check_limits` | `pseudolearn_core`         |
  | Verificación del arnés                                               | `pseudolearn_benchmarks`         |
  | `flutter test` y verificadores de la app, solo si cambió un recurso que consume | `apps/pseudolearn_app`  |
  | `DOC-NO-TRANSIENT-REFS`                                              | Raíz                             |

- [x] **B8.2** Comparar con B0.3: ningún test ni observación que antes cumplía ha dejado de cumplir.
- [x] **B8.3** Hito «núcleo especificado»: todo el corpus del alcance de la reescritura está en
  `experimental` o superior, comprobado con `see matrix`. Las especificaciones de R6 a R8 no forman
  parte del hito.
- [x] **B8.4** Commits coherentes por bloque, con la skill `commit-message`, en inglés y sin coautoría.
- [x] **B8.5** Push ordinario a `origin/feature/agregar-ruta-de-especificacion` e igualdad de HEAD local
  y remoto comprobada con `git ls-remote`. Si el entorno pide confirmación para publicar, se pide a la
  persona responsable; nunca se fuerza.
- [x] **B8.6** En [07](07-fases.md):
  - marcar las casillas de R3, incluidas E-02 y «Fase terminada»;
  - escribir «§9 · Informe de ejecución R3» con la plantilla del §3 de 07;
  - marcar las casillas de este documento;
  - publicar el informe con un push ordinario y comprobar de nuevo la igualdad.
- [x] **B8.7** Parar. No se inicia R4 sin un mensaje nuevo (`PHASE-STOP`).

---

## 7. Decisiones que necesito de la persona responsable

| ID       | Pregunta                                         | Recomendación                                                                                                     |
|----------|--------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|
| D-R3-01 (D-17) | ¿Límites: regla del lenguaje o recurso del entorno? | **Recurso del entorno**, con mínimos garantizados y unidades deterministas. No exige edición nueva: `LANG.SUBPROGRAM.RECURSION` y `LANG.ARRAY.DIMENSION` ya delegan la cuantificación en el motor. Mínimos: 1 000 marcos (el valor vigente de la app) y 2²² celdas; sin mínimo de sentencias, que es un presupuesto del anfitrión. Profundidad y celdas son fallo del programa; sentencias y tiempo, `limit_reached` (B2.1). Valores por omisión: app 1 000 marcos; CLI 100 000 marcos sin tope de sentencias |
| D-R3-02 (D-21) | ¿Frontera de idioma de las herramientas? **Aprobada el 2026-10-14.** | **Español** canónico con el inglés como alias total; vocabulario autodeclarado por la palabra de apertura; idioma de interfaz resuelto por bandera > entorno > preferencias > sistema > español, nunca desde el archivo ni desde la forma de la orden (§11) |
| D-R3-03 (D-07) | ¿Umbrales provisionales?                    | VM sin observar ≥ 10× la línea base en media geométrica AWFY-core (puerta de R5), objetivo 30×, ninguna prueba < 5×. Paso observado p95 ≤ 1 ms en el dispositivo modesto y ≤ 0,1 ms en M2 como sustituto en R5. Sobrecoste del gemelo rápido con observador en pausa ≤ 2 %. Front-end ≥ 10⁶ líneas/s en M2. Biblioteca móvil ≤ 3 MiB por ABI; Wasm ≤ 600 KiB comprimido con brotli |
| D-R3-04  | ¿E-02 sin Go?                                     | Sí: Rust idiomático en lugar de C, sin Go. Si se quiere Go, solo en una comprobación remota manual autorizada, sin añadir Go a la verificación local |
| D-R3-05  | ¿`API.EXECUTE` incluye retroceder (consulta en un instante pasado)? | Sí, como capacidad declarada y negociada. No es una construcción del lenguaje (D-P12 no lo impide), sale gratis de T8 y resuelve la exclusión de la app. Si se rechaza, la consulta por instante queda limitada al presente y T8 se conserva solo para la latencia y el tope |
| D-R3-06  | ¿Se aprueban los cambios de §5 sobre 04?          | Sí, los cinco: árbol postorden, código gemelo, línea temporal, runtime sin `unsafe` y `salsa` aplazado |
| D-R3-07  | ¿Se elevan a objetivo las tres capacidades de §4.5? | Sí: transferencia AOT → VM en R6, frontera grabable en `RT.HOST.INTERFACE` desde R3 y LLVM como nivel de *release* tras E-NR1 |

---

## 8. Riesgos nuevos

| ID    | Riesgo                                                                                    | P | I | Mitigación                                                                                       | Señal temprana |
|-------|-------------------------------------------------------------------------------------------|---|---|--------------------------------------------------------------------------------------------------|----------------|
| RC-01 | La tabla de páginas y la barrera de época cuestan demasiado en cargas de objetos           | M | A | E-02 V2/V1 decide antes de R5; alternativa: montón directo con `unsafe` acotado y tarjetas sucias | V2/V1 > 1,30   |
| RC-02 | Los gemelos divergen                                                                      | B | A | Se generan desde la misma RI con una sola función parametrizada; conformidad diferencial interna obligatoria | Un caso que difiere entre gemelos |
| RC-03 | Memoria de puntos de control en ejecuciones largas                                        | M | M | Raleo exponencial y presupuesto configurable; `API.STATE.QUERY` declara el horizonte retenido     | E-06 en R5     |
| RC-04 | El árbol postorden dificulta la identidad de nodo de R7                                   | M | M | El servicio de R7 deriva la identidad o construye su estructura incremental encima                | E-08 en R4     |
| RC-05 | LLVM asigna mal registros en un `match` de despacho grande                                 | M | M | Manejadores pequeños, estado en variables locales, superinstrucciones; alternativa: despacho por familias | `PERF.VM.THROUGHPUT` al empezar R5 |
| RC-06 | Los bancos de tamaño fijo ocupan memoria en Wasm y móvil                                   | M | B | Tamaño por objetivo en el build (2¹⁸ ranuras en Wasm y móvil, 2²⁰ en escritorio); el mínimo de 1 000 marcos se cumple en ambos | `PERF.ARTIFACT.SIZE`, RSS en E-06 |

---

## 9. Correspondencia con los criterios de aceptación de R3

| Criterio de [07](07-fases.md) R3                                                   | Dónde se cumple |
|------------------------------------------------------------------------------------|-----------------|
| Especificaciones de R3 en `experimental`                                           | B2              |
| `ENG.EXEC.MODEL`, `ENG.TRACE.EVENTS` y `ENG.INPUT` contrastadas con `reference`     | B3              |
| Cobertura `IR.INSTRUCTIONS` comprobada por `see` con tabla `regla → instrucciones`  | B1.6 (`SEE-IR-COVERAGE`) y B2.7 |
| `PERF.BASELINE.REFERENCE` publicada con el protocolo                               | B5              |
| E-02                                                                               | B4              |
| `README.md` del motor y de cada crate de R4–R5, crates vacíos                       | B6              |
| Hito «núcleo especificado»                                                          | B8, con el corpus del alcance en `experimental` o superior |

---

## 10. Genealogía: qué se toma y qué se rechaza

| Fuente                                                     | Se toma                                                   | Se rechaza                                        |
|------------------------------------------------------------|-----------------------------------------------------------|---------------------------------------------------|
| Lua 5.0 (Ierusalimschy et al., 2005); Shi et al. (VEE 2005) | VM de registros; ventanas solapadas para argumentos        | Valores etiquetados (los tipos son estáticos)     |
| Ertl y Gregg (2003)                                         | Superinstrucciones estáticas                              | Elegirlas a mano                                  |
| Rohou, Swamy y Seznec (CGO 2015)                            | `match` con tabla de saltos basta en CPU modernas          | Dependencia de *computed goto* o ensamblador      |
| CPython 3.12                                                | Intérprete generado desde una descripción                 | Especialización adaptativa (innecesaria)          |
| Verificador de la JVM                                       | Verificar una vez antes de ejecutar                       | Comprobaciones redundantes en ejecución           |
| Self (Hölzle, Chambers y Ungar, PLDI 1992)                  | Cambiar de código en un punto seguro                      | JIT y metadatos de desoptimización                |
| rr (O'Callahan et al., USENIX ATC 2017)                     | Grabar solo el no determinismo y reproducir               | Grabación a nivel de sistema operativo            |
| Python Tutor (Guo, SIGCSE 2013); Sorva (TOCE 2013)          | La máquina nocional como objeto de enseñanza              | Instantánea completa por paso y tope de pasos     |
| Toolchain de Carbon; compilador de Zig                      | Tokens y árbol en columnas, postorden                     | Árbol de nodos enlazados                          |
| V8 y JVM (referencias comprimidas)                          | Asas de 32 bits                                           | Movimiento de objetos                             |
| Swift (*breadcrumbs* de cadenas)                            | Migas para acceso por posición en UTF-8                   | UTF-16 como representación                        |
| IEEE 754 (banderas pegajosas)                               | Acumular trampas sin ramas y comprobar una vez            | Perder el tramo del primer fallo                  |
| Immix, LXR, Perceus                                         | Nada en R3; quedan como alternativas medibles en E-12     | Conteo de referencias como modelo (ciclos, H-35)  |

Las fuentes son de consulta y no normativas (`AGENTS.md` §3). Al escribir los `README.md` en B6, esta
tabla se reparte por crate con lo que cada uno tomó y rechazó.

---

## 11. Frontera de idioma (D-R3-02)

### 11.1 Principio: cada decisión de idioma la toma su dueño

PseudoLearn ya separa dos cosas que la mayoría de herramientas mezcla. `LANG.PROFILE.MODEL` hace del
vocabulario un eje del programa, y `DIAG.MESSAGES` declara que «el idioma de prosa es independiente del
vocabulario del programa». La propuesta lleva esa separación a todas las herramientas, con **cuatro
planos y un dueño para cada uno**:

| Plano                    | Qué abarca                                                          | Dueño                    | Dónde se decide                                                     | ¿Se traduce? |
|--------------------------|---------------------------------------------------------------------|--------------------------|---------------------------------------------------------------------|--------------|
| Vocabulario del programa | Lexemas `es` o `en` de un archivo                                   | El texto                 | **Se autodeclara** con la palabra de apertura (§11.2)              | Solo reimprimiendo con `pseudo traducir` (R7) |
| Rigor                    | Estricto o flexible                                                 | El curso o el proyecto   | `--rigor`; en el manifiesto de paquete cuando exista (después de R9) | No aplica    |
| Idioma de interfaz       | Prosa de diagnósticos, ayuda, mensajes de la CLI y **narración de la depuración por consola** | La persona que lee | Cadena de resolución de §11.3; **nunca en el archivo fuente**      | Siempre      |
| Contrato de máquina      | `--json`, códigos de diagnóstico, códigos de salida, formato de intercambio | Las herramientas   | `API.WIRE-FORMAT`, `TOOL.CLI.CONVENTIONS`                            | Nunca        |

**Regla de oro: lo que el programa produce no se traduce nunca; lo que la herramienta dice, siempre.**
La salida de `Escribir` y la representación `Verdadero`/`true` son comportamiento del programa y
siguen su vocabulario (`LANG.IO.VALUE-FORMAT`). La narración de la traza, los diagnósticos y la ayuda
siguen el idioma de interfaz. Los fragmentos de código citados en esa prosa conservan los lexemas del
archivo, como ya exige `DIAG.MESSAGES`.

```text
$ pseudo ejecutar --traza burbuja.psl
burbuja.psl:7  entra en sentencia   Si a[j] > a[j + 1] Entonces
burbuja.psl:7  decisión             rama Entonces
burbuja.psl:8  asigna               aux <- 5

$ pseudo ejecutar --traza burbuja.psl --idioma en
burbuja.psl:7  enters statement     Si a[j] > a[j + 1] Entonces
burbuja.psl:7  decision             Entonces branch
burbuja.psl:8  assigns              aux <- 5
```

### 11.2 Vocabulario autodeclarado

Todo archivo empieza su primera unidad con una palabra de apertura: `Proceso`/`Algoritmo`/`algorithm`,
`Clase`/`class` o la apertura de subprograma de cada idioma. La comprobación hecha sobre
`specifications/cases/vocabulary.json` muestra que **ninguna palabra de apertura comparte lexema entre
idiomas**, ni siquiera ignorando caja y acentos. Los únicos lexemas alfabéticos compartidos son
`constructor`, `dimension`, `real`, `div`, `mod`, `super` y nombres de funciones, y ninguno abre una
unidad de nivel superior. Por tanto:

- la CLI, el LSP y la app **deducen el vocabulario de la primera palabra significativa**, tras BOM y
  trivia, sin anotación ni configuración;
- `--vocabulario es|en` (alias `--vocabulary`) lo fuerza cuando la deducción no es posible, por ejemplo
  en un texto vacío o que empieza con un error léxico. Si no se fuerza, se usa el español canónico con su
  diagnóstico de inicio;
- `API.ANALYZE` sigue recibiendo el perfil explícito: la deducción es de las herramientas
  (`TOOL.CLI.CONVENTIONS`) y no cambia el núcleo;
- `see` añade la validación `SEE-PROFILE-OPENERS`, que rechaza cualquier cambio de vocabulario que haga
  ambigua una palabra de apertura, con su caso negativo.

### 11.3 Idioma de interfaz: cadena de resolución

La primera fuente que da `es` o `en` decide:

1. Bandera `--idioma es|en` (alias `--language`).
2. Variable de entorno `PSEUDO_IDIOMA` (alias `PSEUDO_LANGUAGE`), útil en aulas y en integración continua.
3. Preferencias de usuario, en un archivo **declarativo** de datos en el directorio de configuración de
   cada plataforma. Se gestiona con una orden, como `git config --global`, para que nadie lo edite a
   mano: `pseudo preferencias idioma en` (alias `pseudo preferences language en`). Contenido:
   `idioma = "en"`.
4. Idioma del sistema (`LC_ALL`, `LC_MESSAGES`, `LANG`, o el idioma de interfaz en macOS y Windows),
   si empieza por `es` o `en`.
5. **Español, el canónico.**

El archivo fuente **no** está en la cadena, ni tampoco el vocabulario del programa: el idioma de
interfaz es de quien lee, no de quien escribió.

**La forma en que se escribe la orden tampoco está en la cadena** (decisión de la persona responsable,
2026-10-14). `pseudo run` y `pseudo ejecutar` producen exactamente la misma salida: si nada de los pasos
1 a 4 da un idioma, ambas responden en español. Motivos:

- un alias que cambiara el resultado dejaría de ser un alias y sería otra orden, contra el principio de
  que los alias amplían reconocimiento, no semántica;
- un tutorial o un script escrito con `pseudo run` no debe cambiar la salida de quien lo sigue en un aula
  hispana;
- una mezcla como `pseudo run --rigor estricto` no necesita ninguna regla de desempate;
- escribir `run` por costumbre de otros lenguajes no expresa una preferencia de lectura.

«Por omisión en español» significa: en español salvo que bandera, entorno, preferencias o idioma del
sistema digan otra cosa. En una máquina con el sistema en inglés y sin preferencias, la salida es
inglesa por el paso 4. El español es el último recurso y la forma de las órdenes, opciones y claves
canónicas.

Esto abarca **toda** la prosa de las herramientas: diagnósticos con su inspección y explicación, ayuda,
errores de uso de la CLI, mensajes de progreso y la narración de `--traza`.

Los demás anfitriones usan el mismo modelo y llevan su fuente al paso 1:

- el LSP usa el `locale` que el cliente envía en `initialize`, una convención ya estandarizada por el
  protocolo;
- la app usa su idioma de interfaz;
- la web usa el idioma que le pasa su anfitrión.

El núcleo no cambia: devuelve códigos y argumentos tipados, y la presentación ocurre en el borde (T10).

### 11.4 Órdenes y opciones: español canónico, inglés como alias total

| Canónica             | Alias          | Fase |
|----------------------|----------------|------|
| `pseudo comprobar`   | `check`        | R4   |
| `pseudo ejecutar`    | `run`          | R5   |
| `pseudo ri`          | `ir`           | R5   |
| `pseudo compilar`    | `build`        | R6   |
| `pseudo formatear`   | `format`       | R7   |
| `pseudo traducir`    | `translate`    | R7   |
| `pseudo lsp`         | —              | R7   |
| `pseudo preferencias`| `preferences`  | R4   |

Las opciones siguen el mismo patrón: `--idioma`/`--language`, `--rigor`/`--strictness`,
`--traza`/`--trace`, `--vocabulario`/`--vocabulary`; `--json` es igual en los dos idiomas. Los alias
se aceptan **siempre**, sea cual sea el idioma de interfaz, igual que los alias del vocabulario «amplían
reconocimiento, no semántica» (`LANG.PROFILE.VOCABULARY`). La ayuda muestra la forma del idioma de
interfaz y la otra como alias.

Toda la prosa de la CLI vive en un catálogo bilingüe, `TOOL.CLI.MESSAGES`: es una especificación nueva
de R3, con el mismo mecanismo que `DIAG.MESSAGES`. Se exporta, se genera y su paridad `es`/`en` la
comprueba `see`. Ningún literal destinado a una persona queda en el código Rust (`AGENTS.md` §7,
`GEN-NO-HAND-COPY`).

### 11.5 Opciones descartadas

| Opción                                                      | Por qué no sirve a PseudoLearn |
|-------------------------------------------------------------|--------------------------------|
| Configuración ejecutable (`vite.config.js`, `rsbuild.config.ts`) | Resuelve otro problema: tuberías de construcción con *plugins*. Ejecutar código para leer una preferencia exige un intérprete de configuración, es lento al arrancar y abre una puerta de seguridad en cada `pseudo ejecutar`. Además contradice el determinismo (F3) que sostiene la línea temporal |
| Anotación al inicio del archivo (`#idioma: en`, comentario mágico) | Mete la preferencia de quien lee dentro del código: un archivo compartido impone su idioma a todos, y cambiarlo ensucia el control de versiones. Sería una construcción nueva del lenguaje (D-P12), contra el principio de `LANG.EDITION.MODEL` de no poner metadatos en el texto. Un comentario con efecto contradice `LANG.LEXICAL.COMMENT`. Y es redundante para el vocabulario, que el texto ya declara |
| Manifiesto de proyecto (`pseudo.toml`) para el idioma de interfaz | Es el lugar correcto para lo que es del proyecto (rigor, edición, paquetes) cuando lleguen los paquetes después de R9, y crearlo ahora violaría `SCOPE-YAGNI`. Para el idioma de interfaz es el lugar equivocado: es una preferencia personal. Un aula que quiere los mensajes en inglés en todas las máquinas usa `PSEUDO_IDIOMA` |

### 11.6 Por qué es la mejor opción

- **Sin cambiar la sintaxis ni el lenguaje:** respeta la congelación D-P12 y las reglas vigentes de
  comentarios, ediciones y vocabulario.
- **Coherente con la filosofía existente:** extiende principios que el corpus ya contiene (prosa
  independiente del vocabulario, alias que amplían reconocimiento) en vez de inventar un mecanismo
  nuevo.
- **Un archivo sirve a todos:** quien enseña en español y quien aprende en inglés usan el mismo archivo,
  sin tocarlo, y cada uno lee la herramienta en su idioma.
- **No rompe el determinismo:** el idioma de interfaz nunca altera la salida del programa ni `--json`.
  La conformidad no depende de él; los casos `cli` fijan `--idioma` cuando observan prosa.
- **Una convención probada:** bandera > entorno > preferencias > sistema es el orden de `gettext`, `git`
  y la mayoría de CLI. El LSP ya trae el idioma estandarizado.
- **Español canónico de verdad, no de nombre:** órdenes, opciones, preferencias y valor por omisión en
  español, con el inglés como ciudadano completo y nunca degradado.

---

## 12. Guía de construcción del motor (contenido obligatorio de los `README.md` de B6)

Esta sección es la fuente de la que B6 escribe los `README.md`. Al copiarla a cada `README.md` se
redacta de forma autosustentable: sin citar este documento, `docs/` ni los identificadores T1–T10, que
solo existen aquí. Las especificaciones sí se citan por su identificador, porque `package-docs` lo
admite.

### 12.1 Filosofía de Clepsidra (sección 1 y 4 del `README.md` del workspace)

Siete principios. Cada decisión de los crates tiene que poder justificarse con uno de ellos.

1. **Ejecutar y observar son actividades distintas.** El motor ejecuta siempre a velocidad completa;
   observar es reconstruir, sobre un tramo, lo que la ejecución hizo. Nada que solo sirva para observar
   puede costar en el camino rápido.
2. **El determinismo es un recurso.** Como una ejecución queda definida por programa, configuración,
   semilla y cinta de entradas, el motor puede reproducir en lugar de registrar. Toda decisión interna
   que introduzca no determinismo, como recolectar por tiempo o identificar por dirección, está
   prohibida.
3. **Verificar una vez, no comprobar nunca.** Lo que se puede demostrar antes de ejecutar (tipos, rangos
   de registros, destinos de salto) se demuestra en el verificador. La representación hace imposible
   el resto sin ramas: potencias de dos y máscaras.
4. **Los tipos estáticos se cobran en ejecución.** Ningún valor lleva etiqueta de tipo. La clase de valor
   de cada registro (escalar o referencia) se conoce al compilar y decide en qué banco vive.
5. **Una sola disciplina para todos los motores.** VM y AOT comparten RI, disposición de marco,
   disposición de objetos y raíces del recolector. Una diferencia de representación entre motores es
   una divergencia esperando a ocurrir.
6. **Seguridad estructural.** Cero `unsafe` fuera de los puentes generados. La velocidad sale del diseño,
   no de saltarse las comprobaciones de Rust.
7. **Lo que no se mide no se afirma.** Cada técnica nombra el experimento o la métrica de `PERF.*` que la
   valida, y el resultado se publica aunque la refute.

### 12.2 Contenido por crate

Cada `README.md` de crate incluye, como mínimo:

- responsabilidad en una frase sin «y»;
- capa, dependencias permitidas y prohibidas;
- estructuras de datos;
- invariantes;
- algoritmos;
- contratos que cumple;
- estrategia de tests;
- pendientes declarados con su fase.

| Crate | Estructuras y técnica | Invariantes | Contratos | Fase |
|-------|-----------------------|-------------|-----------|------|
| `pseudolearn_source` | `SourceText` con los bytes originales; índice de inicios de línea; conversión perezosa de desplazamiento de byte a columna en puntos de código; detección de BOM; NFC solo para comparar nombres, con camino rápido ASCII | Los desplazamientos son siempre límites de carácter UTF-8; el texto original nunca se modifica | `LANG.SOURCE.*` | R4 |
| `pseudolearn_diagnostics` | `Diagnostic { code, class, severity, span, related, arguments }`; `enum DiagnosticCode` generado; plantillas bilingües generadas; ordenación de `DIAG.ORDERING` | Ningún texto de idioma dentro del modelo: se renderiza en el borde | `DIAG.*` | R4 |
| `pseudolearn_lexicon` | Tablas generadas de vocabulario y funciones por perfil; **hash perfecto** generado en `build.rs`; normalización de caja y acentos por perfil; identidades de apertura de nivel superior para autodeclarar el vocabulario | Ningún lexema escrito a mano en el código; ninguna apertura compartida entre perfiles (`SEE-PROFILE-OPENERS`) | `LANG.PROFILE.*`, `LIB.MODEL` | R4 |
| `pseudolearn_syntax` | Lexer por tabla de 256 clases de byte; tokens en columnas (`kinds: Vec<TokenKind>`, `starts: Vec<u32>`) con la trivia como tokens; parser de descenso recursivo con recuperación por conjuntos de sincronización; **árbol postorden** `Node { kind: u16, first_token: u32, subtree_size: u32 }`; vistas tipadas generadas de `LANG.SYNTAX.GRAMMAR` | Reimprimir los tokens da el texto exacto; todo texto produce árbol; recursión del parser acotada por la profundidad de anidación, con diagnóstico, sin agotar la pila | `LANG.LEXICAL.*`, `LANG.SYNTAX.*`, `TOOL.SERVICE.LOSSLESS-TREE` | R4 |
| `pseudolearn_semantic` | Arenas con índices tipados (`SymbolId`, `TypeId`, `ScopeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; desvirtualización por jerarquía de clases en mundo cerrado | No hay fases semánticas con errores sintácticos; un símbolo inválido no genera cascadas (`DIAG.CLASSES`) | `LANG.TYPES.*`, `LANG.DECL.*`, `LANG.SUBPROGRAM.*`, `LANG.CLASS.*` (estático) | R4 |
| `pseudolearn_ir` | CFG SSA con parámetros de bloque; clases de valor; celdas; `observe` con masa de sentencia; regiones puras; verificador; formato textual con ida y vuelta; catálogo generado de la exportación de `IR.INSTRUCTIONS` | Toda RI que sale de `lowering` pasa el verificador; ninguna instrucción sin nodo fuente si puede atrapar u observar | `IR.*` | R5 |
| `pseudolearn_lowering` | HIR → RI; orden de evaluación normativo; inserción de puntos de observación y cálculo de masa por bloque; paso por referencia como celda | La masa de sentencia de cada bloque coincide con las entradas a sentencia que contiene | `IR.LOWERING`, `IR.OBSERVATION-POINTS` | R5 |
| `pseudolearn_bytecode` | Salida de SSA con copias paralelas; asignación de registros **por clase** sobre dos ventanas; generación **gemela** (rápida y sondeada) con una sola función parametrizada; tabla de correspondencia de puntos de observación; superinstrucciones elegidas por frecuencia de bigramas; `enum Instruction` de 8 bytes con operandos de 16 bits; código acolchado a potencia de dos; verificador de bytecode; despacho generado en `build.rs` | Los dos gemelos comparten el mapa de registros; todo operando es menor que el tamaño de su ventana; todo salto está dentro de la función | Ninguno observable; lo cubre la conformidad diferencial entre gemelos | R5 |
| `pseudolearn_abi` | Disposición de valores, cabeceras de objeto (clase o tipo de arreglo, ordinal), prefijo de referencias, tamaño de página y forma del marco bicameral, como constantes y tipos compartidos | Una sola definición para VM, runtime y codegen | `RT.ABI` (R6) | R5 lo común, R6 el resto |
| `pseudolearn_runtime` | Espacio de palabras paginado (páginas de 4 096 palabras en `Rc`, tabla con época por página, copia en escritura); asas `u32`; asignación por avance más listas libres por clase de tamaño; recolector preciso sin movimiento con **marcas laterales** y **disparo determinista** por celdas; límite de celdas exacto (cota superior = vivas tras la última recolección + asignadas desde entonces; si la cota supera el límite, se recolecta y se decide con el valor exacto); texto UTF-8 con indicador ASCII y migas cada 64 puntos de código; aritmética comprobada; azar xoshiro256\*\* con SplitMix64; `#![forbid(unsafe_code)]` | La recolección nunca cambia un observable; el estado interno se repite bit a bit en una reproducción; la identidad es el ordinal | `MEM.*`, `RT.HOST.INTERFACE`, la ejecución de `LANG.TYPES.*` y `LANG.OPS.*`, `ENG.LIMITS` (celdas) | R5 |
| `pseudolearn_library` | Funciones incorporadas sobre los valores del runtime, sin estado global; azar desde la capacidad inyectada | Cada función respeta la firma de `LIB.MODEL` | `LIB.CORE.*` | R5 |
| `pseudolearn_vm` | Bancos escalar (`u64`) y de referencias (`u32`) de tamaño fijo potencia de dos (2²⁰ ranuras en escritorio, 2¹⁸ en móvil y Wasm), con acceso `bank.get(index & MASK)`; ventanas solapadas para los argumentos; una comprobación por llamada que es también la de profundidad; **combustible por bloque** con caída exacta al gemelo sondeado; cambio de gemelo en O(1); trampas como `Result` de manejadores pequeños `#[inline(always)]` | Ningún acceso puede salir de un banco; el gemelo rápido no contiene ninguna instrucción de observación | `ENG.EXEC.*`, `ENG.TRACE.*`, `ENG.LIMITS`, `ENG.INPUT` | R5 |
| `pseudolearn_timeline` | Cinta de entradas; puntos de control (copia de la tabla de páginas, región activa de los bancos, registros de la VM, estado del azar, cursor de salida) por masa de sentencia ejecutada, con **raleo exponencial** y presupuesto; consulta por instante = restaurar + reproducir con el gemelo sondeado; caché de vistas; deltas desde las páginas copiadas | El estado reconstruido es igual al observado en su momento; el horizonte retenido se declara | `ENG.STATE.*`, `API.STATE.QUERY` (por instante) | R5 |
| `pseudolearn_api` | Recursos con identificador; operaciones totales que devuelven `Result`; captura de defectos internos como `DIAG.ENGINE.INTERNAL-FAULT`; codificaciones JSON canónica y binaria columnar; negociación de capacidades; renderizado en el idioma de interfaz pedido | Ningún pánico cruza la frontera | `API.*`, `DIAG.ENGINE.INTERNAL-FAULT` | R4 y R5 |
| `pseudolearn_conformance` | Binario del protocolo `see-protocol/1` sobre la API, con las capacidades `analyze`, `execute`, `observe`, `ir` y `cli` (esta última a través del binario `pseudo`) | Solo API pública | `SEE.ADAPTER.PROTOCOL` | R4 |

`pseudolearn_codegen`, `pseudolearn_service` y `pseudolearn_wasm` no tienen `README.md` en R3: son de
R6 a R8. El `README.md` del workspace declara como pendientes, con su fase, lo que se espera de ellos:

- `codegen` usa el banco de referencias como pila sombra, trampas diferidas en regiones puras y bloques
  fríos de transferencia a la VM (D-R3-07);
- `service` construye su incrementalidad sobre el árbol postorden según E-08;
- `wasm` usa bancos de 2¹⁸ ranuras.

### 12.3 Orden de construcción futuro (pendientes declarados del workspace)

El `README.md` del workspace lista el orden que R4 y R5 seguirán. No se autoriza aquí:

- **R4:** `source` → `lexicon` → léxico de `syntax` → parser con recuperación → `semantic` (nombres) →
  `semantic` (tipos) → `diagnostics` renderizado → `api` (análisis) → `conformance` → `pseudo comprobar`.
- **R5:**
  1. `ir` y su verificador, después `lowering` de lo procedural;
  2. `bytecode` con el gemelo rápido, después `vm` no observada;
  3. `runtime` con aritmética comprobada, después `library`, arreglos, subprogramas, objetos y
     recolector;
  4. gemelo sondeado y eventos, después combustible y límites;
  5. `timeline`;
  6. `api` de ejecución, después `pseudo ejecutar` y `pseudo ri`.
- **Medición en cada etapa** contra `PERF.BASELINE.REFERENCE`: si un paso degrada una métrica de
  `PERF.*` respecto del anterior, se informa en el mismo cambio.

---

## 13. Estado de ejecución y cierre (2026-10-14)

R3 está completa. Los bloques B0–B8 tienen evidencia, las casillas de 07 están marcadas y el informe
completo está en 07 §9. El motor y la CLI siguen documentados sin código; R4 no está iniciada.

| Evidencia | Resultado |
|---|---|
| results/r3-verification.json de pseudolearn_spec | 950 tests y verificadores verdes |
| results/r3-regressions.json | Las 930 observaciones que cumplían siguen cumpliendo |
| results/r3-matrix.json | 124 especificaciones del alcance en experimental, cobertura de RI completa |
| results/r3-e02.json y pseudolearn_benchmarks/results/e02 | 12.000 muestras finales; captura inicial conservada; un punto real mínimo por muestra V3 |
| results/r3-awfy-baseline.json y pseudolearn_benchmarks/results/macos-r3-awfy | 6.000 muestras de reference; ambas configuraciones |
| results/r3-baseline-diff.json y r3-baseline-impact.json | Clasificación e impacto de PERF.BASELINE.REFERENCE 0.2.0 |

E-02 supera V2/V1 = 1,30 en todas las familias. RC-01 exige revisar la representación antes de
R5; el resultado se conserva sin rediseñar el motor en R3. La primera instrumentación omitía
puntos en Storage y Towers; se conserva su captura, se corrige y se prueba ese fallo. No se mezclan
muestras de ambas capturas. Los límites de interpretación y las hipótesis no confirmadas están
publicados en el informe de E-02.

Publicación ordinaria de implementación y evidencia: `2df395d1682d1c2f73078f9495d2af8e29c2919a`, con igualdad de HEAD
local/remoto comprobada. El commit de cierre publica este estado y el informe de 07; se confirma
otra vez su igualdad remota. Se para en R3 (`PHASE-STOP`).

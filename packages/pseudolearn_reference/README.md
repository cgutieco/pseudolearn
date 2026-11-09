# pseudolearn_reference

## 1. Qué es y qué no es

Compilador de los **dos libros** de PseudoLearn: la **Especificación ilustrada** (`content/`) y la **ruta de
aprendizaje** (`route/`). Lee las fuentes escritas en Markdown con directivas, las figuras SVG y la exportación
del corpus normativo; tokeniza, traduce y ejecuta cada fragmento de código con el motor real; verifica lo que
promete el texto y, en la ruta, cada ejercicio según su tipo; y publica dos **paquetes de datos neutrales**
(JSON y SVG) que la app Flutter pinta y que la web Astro podrá pintar.

La Especificación explica cómo se escribe y qué hace exactamente el lenguaje. La ruta enseña a resolver
problemas con el ciclo PseudoLearn y cinco paradigmas; enlaza a la Especificación en vez de reexplicarla y
nunca usa un término antes de su lección dueña.

No es el corpus normativo (`packages/pseudolearn_spec`) ni documentación de la arquitectura de otros
miembros. No se despliega: es una biblioteca y una herramienta de construcción. En la interfaz los libros se
llaman «Especificación» y «Ruta de aprendizaje»; el miembro se llama `reference` para no confundirse con el
corpus.

Relación con el corpus: **el corpus dice qué es verdad; la especificación ilustrada lo explica a personas y
demuestra cada afirmación ejecutándola**. Las anclas al corpus viven en la cabecera de cada fuente y en
`reference.lock.json`; nunca viajan al paquete ni se muestran a la persona lectora.

## 2. Guía operativa y ciclo de vida

Cadena: `cargo` y `rustup` con la versión fijada en `rust-toolchain.toml`, igual que el resto de miembros
Rust. Antes de compilar hace falta la exportación del corpus, que no se versiona:

```bash
(cd ../pseudolearn_spec && cargo run --locked -p see_cli --bin see -- export --root .)
```

Órdenes del binario `reference`, desde este directorio:

| Orden | Qué hace |
|---|---|
| `cargo run -p reference_cli -- build` | Compila las cuatro ediciones de los dos libros y escribe `../../apps/pseudolearn_app/assets/reference/` y `../../apps/pseudolearn_app/assets/route/`. Solo escribe si no hay violaciones |
| `cargo run -p reference_cli -- check` | Compila en memoria, ejecuta todos los verificadores y compara los dos paquetes versionados en la app (`REF-BUNDLE-STALE`, `RUTA-BUNDLE-STALE`) |
| `cargo run -p reference_cli -- coverage` | Informe de cobertura de la Especificación por área y de la ruta: términos por lección, ejercicios por tipo y nivel, secciones enlazadas y secciones que ninguna lección enlaza |
| `cargo run -p reference_cli -- lock` | Registra la huella actual de cada ancla después de revisar las secciones afectadas |

`--out DIR` cambia el destino de la Especificación, `--out-ruta DIR` el de la ruta y `--root DIR` el miembro. `--borrador` escribe aunque haya violaciones; solo
sirve para redactar y nunca se usa en verificación.

Verificación completa: `cargo xtask verify` (exportación del corpus, formato, Clippy estricto, tests,
cargo-deny, verificadores Rust del monorepo y `reference check`).

Flujo de una edición de contenido: editar `content/es/...` o `route/es/...` y su par en `en` → `reference check`
→ si un ancla cambió, revisar la sección y ejecutar `reference lock` → `reference build` → versionar las
fuentes y los paquetes generados juntos.

## 3. Arquitectura y modelo del sistema

```
corpus see/1 ──export.json──┐
                            ├──► reference (este miembro) ──► assets/reference/<idioma>/<perfil>/
fuentes .md + figuras .svg ─┤                                         │
motor (pseudolearn_api) ────┘                              app Flutter · web Astro (futuro)
```

Un crate por capa; la matriz de imports está en `architecture.yaml`.

| Capa | Responsabilidad |
|---|---|
| `reference_model` | Documento fuente, bloques, fragmentos en línea, sección publicada, violaciones y puerto `CodeEngine` |
| `reference_format` | Lector del Markdown con directivas |
| `reference_corpus` | Léxico, especificaciones con huella por regla, diagnósticos, fichas y gramática desde la exportación |
| `reference_engine` | Adaptador del puerto sobre `pseudolearn_api` (tokenizar, traducir, ejecutar, RI) |
| `reference_figures` | Contrato SVG, kit de piezas, capas por paso y diagramas de raíles |
| `reference_resolve` | Fuente → sección publicada para un idioma y un perfil |
| `route_resolve` | Lección y ejercicio fuente → lección y ejercicio publicados, con tarjetas de recuerdo, figuras de la Especificación incrustadas y las ejecuciones que verifican cada ejercicio |
| `reference_verify` | Verificadores de los dos libros y cobertura |
| `reference_export` | Paquetes por edición de cada libro con manifiesto de huellas |
| `reference_cli` | Binario `reference`; única capa que toca el disco |
| `xtask` | `cargo xtask verify` |

### 3.1 Árbol de contenido

```
content/<es|en>/partes.json                    partes del índice (número, prefijo, título, resumen)
content/<es|en>/<NN-parte>/<NN-MM-tema>.md     una sección por archivo; mismo id en ambos idiomas
figures/<id>.svg                               figuras con colores por rol y textos por clave
figures/strings/<es|en>.json                   textos de figuras, etiquetas de producciones y frases de interfaz
categories.json                                categoría de resaltado de cada identidad del vocabulario
coverage-exclusions.json                       exclusiones de cobertura con motivo
reference.lock.json                            huella revisada de cada ancla
fixtures/                                      violaciones deliberadas usadas por los tests
```

### 3.2 Formato fuente

Cabecera YAML: `id`, `numero`, `tipo` (`concepto`, `construccion`, `tipo`, `motor`, `apendice`),
`titulo` (admite código en línea), `anclas` (`ESPEC` o `ESPEC#Rn`), `fichas`, `diagnosticos` y `terminos`.

Cuerpo:

- `## Título {#id}`: encabezado numerado; `#funciona` marca «Cómo funciona».
- Párrafos, listas `-` y `1.`, tablas `| … |`.
- En línea: `` `código` ``, `**fuerte**`, `*énfasis*`, `«hueco»`, `[texto](#seccion)` y `[[término|texto]]`.
- Recuadros `::: tipo` … `:::` con `frase`, `limite`, `por-dentro`, `analogia`, `nota`, `partes`, `errores`,
  `resumen` y `vease`. No hay recuadros por rol: la app no distingue a quien enseña de quien aprende, y todo el
  que la abre viene a aprender. Un recuadro «para docentes» presentaba como material reservado confusiones típicas y
  pruebas que le sirven a cualquiera, así que ese contenido se escribe para quien lee: en la Especificación va en una
  `nota`; en una lección, en `profundizar titulo="Tropiezos frecuentes"` (las lecciones no llevan catálogos
  `errores`); en un ejercicio, en su `explicacion`, que solo aparece al pedir la respuesta. La directiva `docentes`
  ya no existe y el formato la rechaza como cualquier recuadro desconocido.
- Bloques cercados:

| Bloque | Atributos | Contenido |
|---|---|---|
| `forma` | — | Forma de escritura; `«hueco»` y opcionales `⟦…⟧` |
| `railes` | `produccion`, `contextuales` | Diagrama generado desde la gramática |
| `programa` | `id`, `titulo`, `ejecutar`, `termina` | Programa en perfil español |
| `salida` | — | Salida prometida del programa anterior |
| `diagnosticos` | — | Códigos prometidos, uno por línea |
| `entrada` | — | Entradas de `Leer`, una por línea |
| `anfitrion` | — | Documento JSON del anfitrión de memoria (archivos, reloj, HTTP) |
| `figura` | `id` | `pie:`, `paso:` y `panel <zona> <paso>: texto` |
| `ri`, `traza` | `programa` | Representación intermedia y traza generadas |
| `generado` | `catalogo` | `palabras`, `diagnosticos`, `funciones`, `gramatica`, `indice` |

En la edición inglesa los bloques `programa` y `forma` pueden ir vacíos: se reutiliza el de la sección
española con el mismo `id` (o la misma posición, para las formas) y el motor lo traduce. Una forma inglesa
no vacía se escribe en perfil inglés para que sus huecos estén en inglés.

### 3.3 Paquete publicado

`assets/reference/<idioma>/<perfil>/` contiene `toc.json`, `sections/<id>.json`, `search.json`,
`links.json` y `manifest.json`. El esquema está en `schemas/reference-bundle.schema.json`.

- Los bloques son `heading`, `paragraph`, `list`, `table`, `form`, `rails`, `program`, `figure`,
  `callout`, `summary`, `see_also`, `diagnostic`, `intermediate` y `trace`.
- Las corridas en línea son `text`, `strong`, `emphasis`, `code`, `slot`, `link` y `term`.
- Un token es `[texto]` o `[texto, categoría]`; las categorías son las de `HighlightCategory` del editor.
- Una figura trae `svg` (base), `layers` (`from_step`, `until_step`, `svg`), `steps` (texto por paso) y
  `panels` (zona, paso desde el que se muestra y texto). Para el paso *k* el consumidor inserta antes de
  `</svg>` cada capa con `from_step ≤ k ≤ until_step`.
- `links.json` resuelve qué sección explica cada ficha de ayuda (`cards`) y cada diagnóstico
  (`diagnostics`).
- `manifest.json` declara el formato `pseudolearn-reference/1`, idioma, perfil, huella de la exportación
  del corpus, huella del motor y el SHA-256 de cada archivo.

### 3.4 Figuras

Contrato (`REF-FIGURE-CONTRACT` y `REF-FIGURE-NARROW`):

- Elementos permitidos: `svg`, `g`, `path`, `rect`, `circle`, `ellipse`, `line`, `polyline`, `polygon`,
  `text`, `tspan`, y las piezas del kit `caja` y `flecha`. Sin `marker`, `style`, imágenes, enlaces ni
  comentarios.
- `viewBox` de exactamente 340 unidades de ancho; letra de 12 o más.
- `fill` y `stroke` solo `none` o `@rol`; cada forma declara su `fill`.
- Todo texto visible sale de `{{t:clave}}` (cadenas de la figura), `{{lex:identidad}}` (lexema del perfil)
  o `{{codigo:fragmento en español}}` (traducido al perfil). Fuera de ellos solo cifras y signos.
- `titulo` y `descripcion` de `strings/<idioma>.json` producen `<title>` y `<desc>`.
- Solo los grupos de primer nivel pueden llevar `data-paso`/`data-hasta`; se publican como capas.

Roles y centinelas, que cada consumidor sustituye por su tema:

| Rol | Centinela | Rol | Centinela |
|---|---|---|---|
| `tinta` | `#FF0001` | `texto` | `#FF0007` |
| `superficie` | `#FF0002` | `logico` | `#FF0008` |
| `acento-estructurado` | `#FF0003` | `exito` | `#FF0009` |
| `acento-procedimental` | `#FF0004` | `error` | `#FF000A` |
| `acento-objetos` | `#FF0005` | `atenuado` | `#FF000B` |
| `numero` | `#FF0006` | `hueco` | `#FF000C` |
| | | `tipo` | `#FF000D` |

Familias: `sans` se publica como `IBMPlexSans` y `mono` como `IBMPlexMono`, los nombres registrados en la
app.

Kit: `<caja x y ancho alto rol fondo esquina trazo discontinua texto tamano fuente negrita cursiva
colortexto/>` dibuja un rectángulo con su texto centrado (`¶` separa líneas); `<flecha puntos rol trazo
discontinua/>` dibuja una polilínea con punta.

### 3.5 Verificadores

| ID | Regla | Caso negativo |
|---|---|---|
| `REF-FORMAT` | La fuente sigue el formato; un bloque desconocido, sin cerrar o sin programa previo falla | `reference_format/tests` |
| `REF-EXAMPLE-VERIFIED` | Salida, diagnósticos y terminación prometidos coinciden con la ejecución; el programa traducido se comporta igual | Salida prometida falsa en `reference_verify/tests/examples.rs` |
| `REF-ANCHOR-VALID` | Toda ancla, ficha y diagnóstico citado existe; una sección narrativa necesita al menos un ancla | `fixtures/anchor/` |
| `REF-ANCHOR-STALE` | `reference.lock.json` coincide con la huella actual de cada ancla | Huella alterada |
| `REF-COVERAGE` | Vocabulario, palabras contextuales, fichas, diagnósticos y especificaciones `LANG`, `LIB`, `ENG`, `MEM`, `RT` cubiertos o excluidos con motivo | Identidad sin sección |
| `REF-ANATOMY` | Cada sección tiene los bloques obligatorios de su tipo | `fixtures/anatomy/` |
| `REF-PARITY` | `es` y `en` tienen las mismas secciones, cabeceras y estructura | `fixtures/parity-en/` |
| `REF-INLINE-CODE` | Una palabra reservada con mayúscula fuera del inicio de frase, o con mayúscula interna, va como código | `fixtures/inline-code/` |
| `REF-FIGURE-CONTRACT` | Contrato SVG | `fill="#ff0000"` |
| `REF-FIGURE-NARROW` | 340 de ancho y letra de 12 o más; raíles que caben | Figura de 760 de ancho |
| `REF-NO-INTERNAL-IDS` | Ningún texto publicado contiene identificadores del corpus | Párrafo con `LANG.CONTROL.IF` |
| `REF-LINK-VALID` | Todo enlace interno apunta a una sección existente | Enlace a una sección inexistente |
| `REF-BUNDLE-STALE` | El paquete versionado en la app es idéntico al que produce el compilador | Archivo editado, ausente o sobrante |

Anatomía por tipo:

| Bloque | Concepto | Construcción | Tipo | Motor |
|---|---|---|---|---|
| Frase, figura, resumen, véase | sí | sí | sí | sí |
| Forma | — | sí | sí | — |
| Partes | — | sí | — | — |
| «Cómo funciona» (`#funciona`) | sí | sí | sí | sí |
| Programas ejecutados | ≥ 1 | ≥ 2 | ≥ 2 | — |
| Errores frecuentes | — | sí | sí | — |
| Por dentro | — | sí | sí | — |
| Límite exacto | — | — | sí | — |

### 3.6 La ruta de aprendizaje: árbol de contenido

```
route/<es|en>/partes.json                                  unidad y partes: id, número, prefijo, título, lema, resumen
route/<es|en>/terminos.json                                id de término → etiqueta, formas, estricto, receta
route/<es|en>/<NN-parte>/<NN-MM-slug>/leccion.md           una lección
route/<es|en>/<NN-parte>/<NN-MM-slug>/ejercicios/<NN-slug>.md   un ejercicio por archivo
figures/ruta-*.svg                                         figuras propias de la ruta, con el contrato de §3.4
fixtures/route/                                            violaciones deliberadas de cada verificador RUTA-*
```

- `NN-parte` es `00-inicio`, `01-imperativo`, `02-procedimental`, `03-objetos`, `04-funcional`,
  `05-concurrente` o `06-exterior`; `NN-MM-slug` lleva el número de la lección y los proyectos usan `MM = 99`.
  El orden del libro es el orden de las rutas de archivo.
- La parte de una lección es el prefijo de su id (`imperativo.mientras` pertenece a la parte con prefijo
  `imperativo`).
- `terminos.json` solo trae etiquetas y formas. La lección dueña se calcula desde las cabeceras (`introduce`) y
  la frase de recuerdo sale del ítem etiquetado del resumen de la dueña: nada de eso se escribe a mano.
- La edición inglesa tiene los mismos archivos e ids. Sus bloques `programa` pueden ir vacíos para reutilizar el
  programa español con el mismo id, y sus cercas `casos`, `rompe`, `casos-solucion` y `vueltas` pueden ir vacías
  para reutilizar las del ejercicio español con el mismo id.

### 3.7 La ruta de aprendizaje: formato fuente

Extiende §3.2; todo lo que allí existe vale igual. Cabecera de lección: `id`, `numero`, `tipo` (`leccion`,
`apertura`, `proyecto`), `titulo`, `duracion`, `problema_breve`, `necesita`, `introduce`, `usa`, `pieza` y
`menciones_cotidianas`. Cabecera de ejercicio: `id`, `leccion`, `tipo`, `nivel` (`semilla`, `brote`, `arbol`),
`obligatorio` y `titulo`.

- Encabezados de fase: `## Entender {#entender fase=1}` o `{#entender fase=1-2}`; publican la tira del ciclo y
  el encabezado con insignia.
- Recuadros nuevos: `frase`, `problema`, `intento` seguido de `respuesta`, `ficha`, `roles`, `paradigma`,
  `recuerda termino=<id>` (vacío), `especificacion` (lista de ids de sección), `profundizar titulo="…"`,
  `practica` (lista de ids de ejercicio) y `siguiente`. En los ejercicios: `enunciado`, `restriccion`, `pistas`
  (cuatro, en lista), `variante` y `explicacion`. Un recuadro admite atributos `clave=valor` después
  de su nombre.
- `ficha` y `paradigma` son listas de zonas: `- entra: …`, `- sale: …`, `- relacion: …`, `- ejemplo: …` y
  `- pregunta: …`, `- metafora: …`, `- historia: …`, `- costo: …`. `roles` es una lista
  `- nombre | figura | descripción`.
- En línea: `[[def:termino|texto]]` define un término en su lección dueña; `[[termino|texto]]` lo menciona;
  `[texto](especificacion:seccion#ancla)` enlaza la Especificación y `[texto](ruta:leccion)` otra lección.
- Cada ítem del resumen lleva entre llaves los términos que resume: `- {contador,acumulador} …`.
- Cercas nuevas: `figura-especificacion seccion=… figura=…` (copia la figura ya resuelta de esa sección, sin
  cuerpo), `vueltas marca=<línea> inicio=<línea> columnas=a,b`, `casos`, `rompe`,
  `casos-solucion minimo=… maximo=…`, `pasos`, `categorias`, `elementos` (`texto | categoría`), `opciones`
  (`- [x] texto | justificación`) y `aserciones`.
- `programa rol=<objeto|inicial|referencia|defectuoso|mutante>` marca el papel de un programa de ejercicio; el
  id es opcional salvo para los mutantes. `sentencias=<n>` fija el presupuesto de sentencias de un programa.
- Casos: `visible | 14 ; 17 ; -1 | 14.0`, con las entradas separadas por ` ; `, las líneas de salida por ` ⏎ `
  y `—` cuando no hay entradas.

### 3.8 La ruta de aprendizaje: paquete publicado

`assets/route/<idioma>/<perfil>/` contiene `toc.json`, `lessons/<id>.json`, `exercises/<id>.json`,
`terms.json`, `spec-links.json` y `manifest.json` (formato `pseudolearn-route/1`, huella del motor, SHA-256 del
manifiesto de la Especificación de la misma edición y SHA-256 de cada archivo). El esquema está en
`schemas/route-bundle.schema.json` y un test de `reference_export` valida contra él cada archivo de un paquete.

- `toc.json` lista las partes con su lema y, por lección, cada ejercicio como objeto `{id, kind, level, required,
  title}`: la app arma el banco de ejercicios y el panel de progreso con el índice, sin abrir cada ejercicio.
- Una lección publicada reutiliza los bloques de la Especificación (`heading`, `paragraph`, `list`, `table`,
  `program`, `figure`, `summary`) y agrega `phrase`, `problem`, `attempt`, `cycle`, `phase_heading`, `brief`,
  `roles`, `paradigm`, `recall`, `spec_links`, `deepen`, `practice`, `next`, `spec_figure` y `callout`.
- Las corridas nuevas son `definition`, `spec_link` y `lesson_link`.
- Un ejercicio publicado trae sus bloques visibles y un objeto `evaluation` con los datos de su tipo:
  `predict`, `trace`, `order_program`, `order_steps`, `cases`, `break`, `design_tests`, `classify` y `choice`.
  La referencia, el programa defectuoso y los mutantes viajan solo ahí: la app los ejecuta y nunca los pinta.
- `spec-links.json` lleva cada sección de la Especificación a las lecciones que la enlazan, directamente o desde
  sus ejercicios. La Especificación no se vuelve a publicar por culpa de la ruta.

### 3.9 La ruta de aprendizaje: verificadores

| ID | Regla | Caso negativo |
|---|---|---|
| `RUTA-FORMAT` | Cabeceras completas, recuadros cerrados, `respuesta` justo después de `intento`, datos de ejercicio solo en ejercicios | `fixtures/route/format/` |
| `RUTA-ANATOMY` | Presencia y orden de frase, problema, intento, paradigma (solo aperturas), fases, resumen, práctica y siguiente | `fixtures/route/anatomy/` |
| `RUTA-TERM-OWNER` | Cada término tiene exactamente una lección dueña y exactamente una definición en ella | `fixtures/route/term-owner/` |
| `RUTA-TERM-ORDER` | Ningún término se usa antes de su dueña: ni marcado, ni en `usa` o `recuerda`, ni por sus formas si es estricto | `fixtures/route/term-order/` |
| `RUTA-RECALL-SOURCE` | Cada término introducido está en exactamente un ítem etiquetado del resumen; cada `recuerda` apunta a un término de `usa` | `fixtures/route/recall-source/` |
| `RUTA-PREREQ` | `necesita` solo tiene lecciones anteriores y alcanza a las dueñas de todos los términos de `usa` | `fixtures/route/prereq/` |
| `RUTA-SPEC-LINK` | Toda sección, ancla y figura de la Especificación citada existe | `tests/route.rs` de `reference_verify` y de `route_resolve` |
| `RUTA-LINK-VALID` | Todo enlace `ruta:` apunta a una lección existente | `tests/route.rs` de `reference_verify` |
| `RUTA-NO-SPEC-DUP` | Sin formas, raíles, RI, trazas, partes, límites ni catálogos de errores; «Bajo el capó» solo con párrafos y enlaces | `fixtures/route/no-spec-dup/` |
| `RUTA-EXAMPLE-VERIFIED` | `REF-EXAMPLE-VERIFIED` aplicado a cada programa de lección y de ejercicio | `fixtures/route/example-verified/` |
| `RUTA-EXERCISE-VERIFIED` | Las comprobaciones por tipo de §3.10 | `tests/route.rs` de `reference_verify` |
| `RUTA-EXERCISE-MIX` | Toda lección que no es proyecto tiene al menos 5 ejercicios, 3 tipos, 2 niveles y 3 obligatorios; práctica y archivos coinciden | `fixtures/route/exercise-mix/` |
| `RUTA-STATEMENT-NO-RECIPE` | Un problema o enunciado no nombra un término receta ni, si el ejercicio escribe código, una palabra reservada en código en línea | `fixtures/route/statement-no-recipe/` |
| `RUTA-HINTS` | Los tipos que ejecutan o diseñan código tienen cuatro pistas y una variante | `fixtures/route/hints/` |
| `RUTA-SCAFFOLD` | Fases separadas en la Unidad 0, la Parte I y los proyectos; `1-2`, `3`, `4`, `5` desde la Parte II | `fixtures/route/scaffold/` |
| `RUTA-PARITY` | `es` y `en` tienen los mismos archivos, cabeceras y estructura | `fixtures/route/parity/` |
| `RUTA-BUNDLE-STALE` | El paquete versionado en `assets/route/` es idéntico al producido | `bundle_files_tests.rs` |

`REF-FIGURE-CONTRACT`, `REF-FIGURE-NARROW`, `REF-INLINE-CODE` y `REF-NO-INTERNAL-IDS` se aplican también a la
ruta, con sus casos negativos de §3.5.

### 3.10 Verificación de cada tipo de ejercicio

| Tipo | Lo que comprueba el compilador |
|---|---|
| `predecir` | La salida prometida del programa `objeto` coincide con la ejecución |
| `rastrear` | Cada fila de `vueltas` coincide con lo que escribe el programa instrumentado; hay al menos una celda por completar, una celda por columna y `inicio` si hay fila «antes» |
| `ordenar` | Con programa, la referencia pasa los casos, hay al menos cuatro líneas móviles y el programa traducido tiene las mismas; con `pasos`, al menos tres pasos |
| `resolver` | La referencia pasa los casos: dos visibles y tres ocultos, o un caso visible si ningún caso tiene entradas |
| `encontrar-error` | La referencia pasa los casos y el programa inicial falla al menos uno |
| `modificar` | La referencia pasa los casos y el programa inicial falla al menos uno oculto. Si el ejercicio declara `aserciones`, el cambio pedido es de estructura y el inicial puede conservar la conducta: el compilador no evalúa aserciones, así que lo comprueba la compuerta de la app (`route_exercise_gate_test`), que exige que el inicial no pase su comprobador |
| `romperlo` | El defectuoso pasa los visibles y cada entrada de `rompe`, con tantos valores como lee el programa, hace que difiera de la referencia o falle |
| `disenar-pruebas` | Hay al menos tres mutantes; `casos-solucion` pasa en la referencia, atrapa a cada mutante y su cantidad está entre `minimo` y `maximo` |
| `clasificar` | Hay al menos dos categorías, cada una con un elemento, y cada elemento tiene una categoría existente |
| `explicar`, `comparar` | Una sola opción correcta y una justificación por opción |

Las `aserciones` deben pertenecer al catálogo cerrado de la app (`contiene`, `no-contiene`, `repite-como-mucho`,
`declara-subprograma` y `declara-miembro`, con construcciones `condicional`, `seleccion-multiple`,
`bucle-condicional`, `bucle-condicional-posterior`, `bucle-contado`, `arreglo`, `subprograma`, `clase` e `interfaz`)
y llevar el requisito que ve la persona.

Las salidas se comparan con la misma normalización que la app: espacios colapsados, líneas vacías finales
descartadas y números comparados con tolerancia relativa `1e-9`.

## 4. Decisiones de diseño y fundamentos técnicos

- **Problema:** la ruta necesita exactamente lo que este compilador resuelve para la Especificación: Markdown
  con directivas, programas ejecutados, traducción al perfil inglés, figuras con contrato, paquete neutral,
  verificación de obsolescencia y enlaces que sepan si una sección existe. **Elección:** un segundo libro en el
  mismo miembro, que comparte lector, motor, figuras, resaltado y exportación, con su modelo de lección y
  ejercicio, su grafo de términos, sus verificadores `RUTA-*` y el crate `route_resolve`. **Descartado:** un
  miembro nuevo, que duplicaría el lector, el puerto del motor, la escritura del paquete y la comprobación de
  obsolescencia y tendría que leer el índice de la Especificación desde fuera; y mantener Markdown y JSON
  interpretados por la app, que no ejecuta los programas al construir ni impide usar un concepto antes de
  explicarlo.
- **Problema:** las zonas de `ficha` y `paradigma` escritas como líneas sueltas se funden en un solo párrafo con
  el lector de §3.2. **Elección:** se escriben como ítems de lista con la zona como prefijo (`- entra: …`).
- **Problema:** la fila «antes» de una tabla por vuelta necesita saber dónde empieza el bucle. **Elección:** la
  cerca `vueltas` declara `inicio=<línea>` además de `marca=<línea>`, y la instrumentación escribe las columnas
  entre `⟦` y `⟧` para no confundirlas con la salida del programa. Las columnas son expresiones, así que un
  designador como `v[0]` también sirve.
- **Problema:** un programa defectuoso puede no terminar. **Elección:** cada ejecución de un ejercicio tiene un
  presupuesto de 100 000 sentencias, salvo que el programa declare otro con `sentencias=`, y una profundidad de
  1000 marcos, la misma que usa la app. Sin ese tope, una recursión sin caso base abría marcos hasta agotar el
  presupuesto de sentencias y tardaba minutos en el compilador; con él falla enseguida con
  `recursionDepthExceeded`, como le pasa a quien la escribe en la app.
- **Problema:** los enunciados de `predecir`, `comparar` y `explicar` muestran código porque el código es el
  objeto del ejercicio. **Elección:** `RUTA-STATEMENT-NO-RECIPE` solo rechaza palabras reservadas en código en
  línea de los problemas de lección y de los ejercicios que escriben código; los términos receta se rechazan
  siempre.
- **Problema:** la app compara números con tolerancia y no sabe si un caso es texto. **Elección:** la ruta
  compara siempre como la app compara valores numéricos: igual texto, o igual entero, o reales dentro de
  `1e-9` relativo. Así el compilador nunca acepta algo que la app rechace.
- **Problema:** las tarjetas de recuerdo y las etiquetas de término repetirían texto escrito en otra lección.
  **Elección:** se generan desde el resumen etiquetado de la dueña y desde `terminos.json`
  (`GEN-NO-HAND-COPY`).
- **Problema:** contenido escrito dos veces y pintado por dos consumidores diverge. **Elección:** se escribe
  una vez, se compila una vez y se publica como datos neutrales; los consumidores no analizan Markdown, no
  resaltan ni ejecutan. **Descartado:** widgets de Flutter como fuente, que no viajan a Astro, y un lenguaje
  de escenas con dos renderizadores.
- **Problema:** el plan agrupaba léxico, fichas y ejecución en `reference_resolve`. **Elección:** la
  lectura del corpus vive en `reference_corpus` y la frontera con el motor en `reference_engine`, detrás
  del puerto `CodeEngine`; así la resolución y la verificación se prueban con un motor falso.
- **Problema:** los ejemplos de archivos, tiempo y red necesitan un mundo exterior reproducible.
  **Elección:** `reference_engine` activa `test-host` de `pseudolearn_api`, que sustituye el anfitrión por
  el de memoria configurado con el bloque `anfitrion`; la semilla es siempre 42. El compilador no se
  distribuye, así que la característica no llega a ningún producto.
- **Problema:** mantener cada programa en dos perfiles. **Elección:** se escribe en español y el motor lo
  traduce con `translate_source`. Un programa que no analiza (los ejemplos de errores) se traduce token a
  token con la ortografía canónica del motor: mayúscula inicial de cada palabra en inglés, salvo acceso a
  miembros y llamadas. Los textos entre comillas de los programas quedan en español en la edición inglesa;
  la salida mostrada es siempre la de la ejecución real del programa traducido.
- **Problema:** una figura por pasos publicada como un SVG por paso multiplicaba el paquete por cinco.
  **Elección:** base más capas, y el consumidor compone. Las capas pintan por encima de la base.
- **Problema:** tokens como objetos `{text, category}` duplicaban el tamaño de los programas.
  **Elección:** pares `[texto, categoría]`.
- **Problema:** `flutter_svg` no admite marcadores, CSS ni `dominant-baseline`. **Elección:** el contrato
  los prohíbe y el kit dibuja las puntas de flecha como polígonos y centra el texto con un desplazamiento
  de 0,35 veces el cuerpo.
- **Problema:** la gramática usa `identifier` también para palabras contextuales (`Cada`, `En`).
  **Elección:** el bloque `railes` declara con `contextuales` qué apariciones de `identifier` son palabras,
  en orden de recorrido (`-` deja el hueco).
- **Problema:** la categoría de resaltado no existe en el corpus. **Elección:** `categories.json` la declara
  por identidad y el verificador de cobertura falla si una identidad del vocabulario no aparece en ninguna
  sección. Pendiente: proponer al corpus una propiedad de categoría para que el editor y este miembro
  la lean de la misma fuente.
- **Problema:** `REF-INLINE-CODE` no puede distinguir el «Si» de una oración española de la palabra
  reservada. **Elección:** solo marca palabras con mayúscula fuera del inicio de frase o con mayúscula
  interna (`FinSi`, `EndIf`).
- **Problema:** el vocabulario declaraba `Funcion` como alias de `SubProceso`, aunque la pureza depende de
  esa palabra, y el traductor del motor la canonizaba a `Subroutine`: el programa traducido perdía la pureza.
  El miembro lo parcheaba con una tabla `aliases.json` y una traducción léxica de los programas que la usaban.
  **Elección:** desde que el corpus declara `function`/`endFunction` como identidades propias, el traductor y el
  léxico del corpus escriben `Function`/`EndFunction` por identidad; la tabla, `AliasTable` y la traducción
  léxica de esos programas se retiraron porque no cubrían ninguna otra grafía.
- **Problema:** el vocabulario hacía canónico `Proceso` y casi todo lo demás escribía `Algoritmo`. **Elección:**
  con `Algoritmo` canónico en el corpus, los programas, las formas y la prosa del libro usan `Algoritmo` y
  `FinAlgoritmo`; `Proceso` aparece solo donde se explica como alias (2.5) o como estilo clásico (8.1).
- **Problema:** los diagnósticos son 284 y casi ninguno merece una sección propia. **Elección:** el
  Apéndice C los genera todos desde el corpus; `links.json` lleva cada código a la sección que lo explica
  (cabecera `diagnosticos`) o, si ninguna lo hace, al apéndice.

## 5. Reglas de legibilidad, estilo y estructura de código

Límites, capas y nombres en `architecture.yaml`. Código en inglés, sin comentarios, sin `unsafe` y sin
`allow`/`expect`. Contenido en español e inglés con paridad estructural. Las frases del cuerpo tienen
menos de 25 palabras; cada número exacto aparece en un recuadro «Límite exacto»; las analogías dicen
dónde dejan de valer; no se usan «simplemente», «obviamente» ni «es fácil».

## 6. Decisiones de producto que condicionan el código

- La persona lectora nunca ve identificadores del corpus (`REF-NO-INTERNAL-IDS`); sí ve los códigos de
  diagnóstico, porque son los mismos del editor.
- Toda palabra del lenguaje en la prosa es un fragmento de código y se pinta como píldora con los colores
  del editor; los huecos se pintan como en la hoja de ayuda.
- Figuras de 340 unidades de ancho para leerse a tamaño real en un teléfono de 375 puntos.
- Cada sección se publica en cuatro ediciones: idioma de interfaz × perfil de sintaxis.
- El índice final tiene trece partes y seis apéndices. Respecto del plan, se fundieron secciones que
  repetían una regla ya explicada: la terminación de sentencias vive solo en 2.9, los perfiles y la estrictez
  en 0.5 y 3.15, y la Parte IX agrupa atributos con clases, `Nuevo` con constructores y `Este`/`Super` y la
  sobrescritura con métodos y herencia. Así cada regla tiene una sección dueña y no dos textos que diverjan.
- Los ejemplos que dependen del azar muestran la salida de la semilla fija del anfitrión de memoria; la
  terminal usa otra semilla por omisión y puede mostrar otros números.
- El Apéndice E (glosario) se redacta a mano: el corpus no tiene definiciones de términos; los demás
  apéndices se generan desde el corpus.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` ejecuta todas las puertas. Los tests reflejan los módulos de cada crate, prueban
camino feliz, camino infeliz y límites, y cada verificador tiene su caso negativo (tabla de §3.5). La
resolución se prueba con un motor falso; `reference_engine` se prueba contra el motor real.

Pendientes declarados:

- La categoría de resaltado debería salir del corpus (ver §4).
- Los textos de los programas no se traducen en la edición inglesa.
- La comilla (`quote`) está excluida de la cobertura de vocabulario: nunca aparece como ficha suelta.
- Las aserciones estructurales de los ejercicios se validan en su forma, no contra la referencia: el puerto del
  motor del compilador no publica la vista del programa que la app usa para comprobarlas.
- La ruta no verifica mecánicamente que «La herramienta nueva» aparezca cuando una lección introduce una
  construcción: no hay forma de saber desde la cabecera qué término es una construcción. Se revisa con la lista de
  cierre de cada lección.

## 8. Fuentes consultadas y genealogía conceptual

La estructura por partes numeradas se inspira en ECMA-262; los diagramas de raíles, en la tradición de
los diagramas de sintaxis de Wirth. Se toma la idea de numeración estable y de anatomía por tipo de
sección; se rechaza el registro formal y las gramáticas como única explicación. PseudoLearn es dueño de su
formato y de su motor.

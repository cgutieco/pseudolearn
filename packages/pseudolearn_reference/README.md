# pseudolearn_reference

## 1. Qué es y qué no es

Compilador de la **Especificación ilustrada** de PseudoLearn. Lee las secciones escritas en Markdown con
directivas, las figuras SVG y la exportación del corpus normativo; tokeniza, traduce y ejecuta cada
fragmento de código con el motor real; verifica lo que promete el texto, y publica un **paquete de datos
neutral** (JSON y SVG) que la app Flutter pinta y que la web Astro podrá pintar.

No es el corpus normativo (`packages/pseudolearn_spec`), ni un tutorial, ni documentación de la
arquitectura de otros miembros. No se despliega: es una biblioteca y una herramienta de construcción.
En la interfaz se llama «Especificación»; el miembro se llama `reference` para no confundirse con el
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
| `cargo run -p reference_cli -- build` | Compila las cuatro ediciones y escribe el paquete en `../../apps/pseudolearn_app/assets/reference/`. Solo escribe si no hay violaciones |
| `cargo run -p reference_cli -- check` | Compila en memoria, ejecuta todos los verificadores y compara el paquete versionado en la app (`REF-BUNDLE-STALE`) |
| `cargo run -p reference_cli -- coverage` | Informe de cobertura por área: vocabulario, palabras contextuales, fichas, diagnósticos y especificaciones |
| `cargo run -p reference_cli -- lock` | Registra la huella actual de cada ancla después de revisar las secciones afectadas |

`--out DIR` cambia el destino y `--root DIR` el miembro. `--borrador` escribe aunque haya violaciones; solo
sirve para redactar y nunca se usa en verificación.

Verificación completa: `cargo xtask verify` (exportación del corpus, formato, Clippy estricto, tests,
cargo-deny, verificadores Rust del monorepo y `reference check`).

Flujo de una edición de contenido: editar `content/es/...` y su par `content/en/...` → `reference check`
→ si un ancla cambió, revisar la sección y ejecutar `reference lock` → `reference build` → versionar las
fuentes y el paquete generado juntos.

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
| `reference_verify` | Verificadores del libro y cobertura |
| `reference_export` | Paquete por edición con manifiesto de huellas |
| `reference_cli` | Binario `reference`; única capa que toca el disco |
| `xtask` | `cargo xtask verify` |

### 3.1 Árbol de contenido

```
content/<es|en>/partes.json                    partes del índice (número, prefijo, título, resumen)
content/<es|en>/<NN-parte>/<NN-MM-tema>.md     una sección por archivo; mismo id en ambos idiomas
figures/<id>.svg                               figuras con colores por rol y textos por clave
figures/strings/<es|en>.json                   textos de figuras, etiquetas de producciones y frases de interfaz
categories.json                                categoría de resaltado de cada identidad del vocabulario
aliases.json                                   grafías alternativas con significado propio y su pareja en el otro perfil
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
- Recuadros `::: tipo` … `:::` con `frase`, `limite`, `docentes`, `por-dentro`, `analogia`, `nota`,
  `partes`, `errores`, `resumen` y `vease`.
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

## 4. Decisiones de diseño y fundamentos técnicos

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
- **Problema:** el vocabulario declara `Funcion` como alias de `SubProceso`, pero la pureza depende de la
  grafía, y el traductor del motor la canoniza a `Subroutine`: el programa traducido pierde la pureza y
  `REF-EXAMPLE-VERIFIED` lo detecta. **Elección:** `aliases.json` declara como datos las grafías que hay que
  conservar (`Funcion` ↔ `Function`, `FinFuncion` ↔ `End Function`); el código en línea las traduce por
  pareja y un programa que las usa se traduce por léxico en vez de con el traductor. Pendiente: que el corpus
  resuelva el conflicto entre el alias y la regla de pureza y que el traductor conserve la familia de alias.
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
- `aliases.json` existe porque el traductor del motor canoniza `Funcion` a `Subroutine` y el corpus declara
  `Funcion` como alias de `SubProceso` aunque la pureza dependa de esa grafía (§4). Cuando el corpus y el
  traductor resuelvan el conflicto, la tabla y la traducción léxica de programas con alias se retiran.
- La comilla (`quote`) está excluida de la cobertura de vocabulario: nunca aparece como ficha suelta.

## 8. Fuentes consultadas y genealogía conceptual

La estructura por partes numeradas se inspira en ECMA-262; los diagramas de raíles, en la tradición de
los diagramas de sintaxis de Wirth. Se toma la idea de numeración estable y de anatomía por tipo de
sección; se rechaza el registro formal y las gramáticas como única explicación. PseudoLearn es dueño de su
formato y de su motor.

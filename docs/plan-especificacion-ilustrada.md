# Plan de ejecución — Especificación ilustrada de PseudoLearn

Estado: EI-0 aprobada (plan, arquitectura y muestras de lectura). EI-1 no ha empezado: necesita las
respuestas de §9 y una autorización nueva. Nada de este plan está implementado.
Ejemplos de lectura: carpeta [`especificacion-ilustrada-ejemplos/`](especificacion-ilustrada-ejemplos/).

---

## 1. Diagnóstico del módulo actual

El módulo **Especificación** de la app (`apps/pseudolearn_app/assets/knowledge/specification/`) tiene once
documentos `esp-i-*` y `esp-o-*` con 1165 líneas en total. El corpus normativo
(`packages/pseudolearn_spec/specifications/`) tiene 199 especificaciones, 93 de ellas solo del lenguaje. La
distancia entre los dos explica la sensación de que la especificación «no dice nada»:

| Hallazgo | Evidencia | Consecuencia |
|---|---|---|
| Cobertura mínima | 11 documentos frente a 93 especificaciones `LANG.*`, 16 `LIB.*`, 12 `ENG.*`, 3 `MEM.*`, 5 `RT.*`. No hay nada sobre tareas, canales, `Elegir`, `Opcional`, `Resultado`, `Segun` con patrones, registros, enumerados, variantes, genéricos, módulos, `Diferir`, `Salir`, `Para Cada`, JSON, HTTP, archivos ni tiempo | Un estudiante no puede descubrir más de la mitad del lenguaje |
| Contenido desactualizado | `esp-i-control` afirma que no hay salida anticipada de un bucle y que `Con Paso` es obligatorio; el corpus tiene `LANG.CONTROL.EXIT` y el motor acepta `Para` sin paso | La especificación contradice al motor |
| Promesas sin cumplir | `esp-i-tipos-primitivos` anuncia una tabla y luego solo desarrolla cadena, carácter y dos reglas numéricas; `Logico` no tiene sección | Lectura incompleta y confusa |
| Ninguna verificación del texto | `tool/check_content.dart` comprueba que los ejemplos citados se analicen y los diagnósticos citados existan, pero no ejecuta la salida que la prosa promete ni mide cobertura del corpus | La deriva no se detecta |
| Código sin resaltar en la prosa | `ParagraphBlock` es texto plano; `Si`, `Entonces`, `Como` se leen como palabras normales | Confusión entre lenguaje natural y código |
| Ilustraciones atadas a Flutter | `illustrationCatalog` mapea a widgets (`MemoryBoxesIllustration`); hay tres ilustraciones en total | No se pueden reutilizar en Astro; casi no hay figuras |
| Sin estructura de referencia | Once páginas planas, sin partes, sin índice jerárquico, sin anatomía común por sección | No se puede consultar como ECMA-262 |

Hallazgos laterales observados durante el análisis con la CLI compilada (se reportan, no se corrigen en este plan):

1. **Cascada de diagnósticos.** Un `Si` con dos `Sino` produce cinco errores (`unclosedIfStatement` y cuatro
   `unexpectedTokenOutsideProgramUnit`). El documento actual promete «un diagnóstico, no una cascada».
2. **Mensaje sin localizar.** `taskArgumentNotTransferable` muestra «`$vector<integer> en $`»: el tipo y la
   ruta llegan con su forma interna.
3. **Resaltado incompleto en la app.** `rust_syntax_highlighter.dart` clasifica a mano las palabras clave y
   no conoce `Tareas`, `Lanzar`, `Aguardar`, `Suspendible`, `Canal`, `Elegir`, `Registro`, `Enumerado`,
   `Opcional`, `Resultado`, `Propagar`, `Descartar` y otras. La categoría debería llegar del corpus
   (candidato a `GEN-NO-HAND-COPY`).
4. **Número de tipos primitivos.** El corpus define cinco (`Entero`, `Real`, `Logico`, `Caracter`, `Cadena`).
   La petición menciona seis. Ver §9, pregunta 1.

---

## 2. Qué es y qué no es la Especificación ilustrada

**Es** la descripción completa y legible del lenguaje y de su motor: cada palabra reservada, cada tipo,
cada construcción, cada límite y cada pieza del motor, con su forma escrita, figuras que muestran lo que
ocurre por dentro y ejemplos ejecutados de verdad. Se lee de principio a fin o se consulta por partes, como
ECMA-262, pero con lenguaje llano.

**No es** un tutorial (eso es la ruta de aprendizaje), ni la fuente normativa (eso es el corpus `see/1`), ni
documentación de la arquitectura interna de los paquetes (eso son los README).

Relación con el corpus, en una frase: **el corpus dice qué es verdad; la especificación ilustrada lo explica
a personas y demuestra cada afirmación ejecutándola**. Cada sección se ancla a reglas del corpus y cada
ejemplo se ejecuta contra el motor al construir. Si el corpus cambia, la sección afectada queda marcada
como pendiente de revisión; si el motor cambia una salida, la construcción falla.

**Las anclas son internas.** Viven en la cabecera del archivo fuente y en el candado del compilador, nunca en
lo que lee la persona: ni la app ni la web muestran identificadores como `LANG.CONTROL.IF` o `R1`, que no
significan nada para quien empieza. El lector solo ve explicaciones; la trazabilidad la usa el equipo para
saber qué revisar cuando cambia el corpus.

### 2.1 Público y capas de lectura

Un único texto, con capas que la persona elige leer:

| Capa | Para quién | Forma |
|---|---|---|
| Cuerpo | Cualquiera, desde los 10 años | Frases cortas, una idea por párrafo, analogías del mundo cotidiano sin tono infantil, figura antes que fórmula |
| «Límite exacto» | Quien necesita el número | Recuadro con el valor exacto, sin redondear: rangos, capacidades, profundidades |
| «Para docentes» | Docentes | Confusiones frecuentes, cómo detectarlas, preguntas para la clase |
| «Por dentro» | Curiosos, estudiantes avanzados | Representación intermedia real, bancos de registros, agenda, recolector; plegable |

El cuerpo nunca depende de las capas plegables: se puede saltar todo «Por dentro» sin perder el hilo.

---

## 3. Índice general (estructura tipo ECMA)

La numeración es estable y es parte del contrato: los enlaces desde el editor, los diagnósticos y la ruta de
aprendizaje apuntan a identificadores de sección, no a títulos.

**Parte 0 — Cómo leer esta especificación**
0.1 Qué vas a encontrar · 0.2 Convenciones tipográficas (código, palabras clave, huecos) · 0.3 Cómo leer una
forma de escritura · 0.4 Cómo leer las figuras · 0.5 Perfiles de sintaxis: español e inglés · 0.6 Ediciones

**Parte I — Visión general**
1.1 Qué es PseudoLearn · 1.2 El viaje de un programa: del texto a la ejecución · 1.3 Analizar, ejecutar y
observar · 1.4 Determinismo: el mismo programa da siempre lo mismo · 1.5 Cómo termina un programa ·
1.6 Errores, advertencias y fallos

**Parte II — Estructura léxica**
2.1 Texto fuente y codificación · 2.2 Espacios y saltos de línea · 2.3 Comentarios · 2.4 Identificadores ·
2.5 Palabras reservadas · 2.6 Literales numéricos · 2.7 Literales de texto y de carácter · 2.8 Operadores y
signos · 2.9 Fin de sentencia · 2.10 Errores léxicos

**Parte III — Tipos y valores**
3.1 Tipos primitivos (`Entero`, `Real`, `Logico`, `Caracter`, `Cadena`) · 3.2 Relaciones entre tipos y
ampliación · 3.3 Inferencia · 3.4 Arreglos · 3.5 Vectores · 3.6 Diccionarios · 3.7 Registros ·
3.8 Enumerados · 3.9 Variantes · 3.10 `Opcional` y `Resultado` · 3.11 Funciones como valores ·
3.12 Genéricos · 3.13 `Inmutable` e `Instantanea` · 3.14 Bytes · 3.15 Niveles de comprobación

**Parte IV — Expresiones y operadores**
4.1 Aritméticos · 4.2 División, `div` y `mod` · 4.3 Potencia · 4.4 Comparación · 4.5 Lógicos y
cortocircuito · 4.6 Concatenación · 4.7 Precedencia y asociatividad

**Parte V — Declaraciones y sentencias**
5.1 `Definir` · 5.2 `Constante` · 5.3 Asignación · 5.4 Designadores · 5.5 Variables sin valor ·
5.6 Variables sin usar · 5.7 Terminación de sentencias

**Parte VI — Control del flujo**
6.1 La decisión `Si` · 6.2 `Segun` · 6.3 `Mientras` · 6.4 `Repetir … Hasta Que` · 6.5 `Para` ·
6.6 `Para Cada` · 6.7 `Salir` · 6.8 `Diferir`

**Parte VII — Subprogramas**
7.1 Declaración · 7.2 Parámetros · 7.3 Paso por valor y por referencia · 7.4 Llamada · 7.5 `Retornar` ·
7.6 Ámbito · 7.7 Recursión y la pila de llamadas · 7.8 Pureza y capacidades

**Parte VIII — Programas, módulos y perfiles**
8.1 Estructura de un programa · 8.2 `Proceso` y `Algoritmo` · 8.3 Módulos, `Importar` y `Exportar` ·
8.4 Perfiles de vocabulario y traducción · 8.5 Estrictez

**Parte IX — Objetos**
9.1 `Clase` · 9.2 Atributos · 9.3 Métodos · 9.4 `Constructor` · 9.5 `Nuevo` · 9.6 Acceso a miembros ·
9.7 `Este` y `Super` · 9.8 `Hereda De` · 9.9 Sobrescritura · 9.10 Interfaces · 9.11 Copia de objetos ·
9.12 Lo que el lenguaje no tiene

**Parte X — Errores y diagnósticos**
10.1 Modelo de diagnóstico · 10.2 Clases · 10.3 Severidad · 10.4 Orden · 10.5 Fallo de efecto, trampa y
corte del anfitrión · 10.6 Catálogo completo (generado)

**Parte XI — Concurrencia y asincronía**
11.1 Concurrencia sin paralelismo · 11.2 Unidades `Suspendible` y `Aguardar` · 11.3 `Tareas` y
`Lanzar` · 11.4 Aislamiento: qué puede cruzar entre tareas · 11.5 Canales · 11.6 `Elegir` ·
11.7 Fallos y cancelación · 11.8 Esperar al mundo exterior: efectos

**Parte XII — Biblioteca**
12.1 Texto · 12.2 Conversión · 12.3 Matemáticas y redondeo · 12.4 Azar con semilla · 12.5 Copia ·
12.6 Consola · 12.7 Archivos · 12.8 JSON · 12.9 HTTP · 12.10 Tiempo y entorno · 12.11 Permisos y
capacidades

**Parte XIII — El motor por dentro**
13.1 Mapa de capas · 13.2 Análisis léxico y árbol sin pérdida · 13.3 Análisis semántico ·
13.4 Representación intermedia · 13.5 Bytecode · 13.6 La máquina virtual: bancos, marcos y despacho ·
13.7 Memoria: montón, celdas e identidad · 13.8 Recolector determinista · 13.9 Agenda de tareas ·
13.10 Efectos, anfitrión y cinta · 13.11 Observación: traza, puntos de control y línea de tiempo ·
13.12 Límites de ejecución · 13.13 Código nativo (AOT) · 13.14 El motor en el navegador (Wasm)

**Apéndices**
A. Gramática completa (generada) · B. Palabras reservadas español–inglés (generada) · C. Catálogo de
diagnósticos (generado) · D. Funciones incorporadas (generado desde las fichas) · E. Glosario · F. Índice
alfabético

Las partes generadas no se redactan a mano: se proyectan desde el corpus exportado (`GEN-NO-HAND-COPY`).

---

## 4. Anatomía de una sección

Cada sección declara un **tipo**, y el tipo fija qué bloques lleva y en qué orden. El verificador rechaza una
sección a la que le falta un bloque obligatorio.

| Bloque | Concepto | Construcción | Tipo | Pieza del motor |
|---|---|---|---|---|
| En una frase | obligatorio | obligatorio | obligatorio | obligatorio |
| Figura principal | obligatorio | obligatorio | obligatorio | obligatorio |
| Cómo se escribe (forma + diagrama de sintaxis) | — | obligatorio | literales | — |
| Cada parte | — | obligatorio | — | — |
| Cómo funciona | obligatorio | obligatorio | operaciones | obligatorio |
| Ejemplos ejecutados | ≥ 1 | ≥ 2 | ≥ 2 | opcional |
| En resumen (puntos en lenguaje llano, sin identificadores) | obligatorio | obligatorio | obligatorio | obligatorio |
| Límite exacto | si aplica | si aplica | obligatorio | si aplica |
| Errores frecuentes (diagnósticos reales) | opcional | obligatorio | obligatorio | opcional |
| Por dentro | opcional | obligatorio | obligatorio | — (toda la sección lo es) |
| Para docentes | opcional | recomendado | recomendado | opcional |
| Véase también | obligatorio | obligatorio | obligatorio | obligatorio |

### 4.1 Convenciones visuales que resuelven la confusión entre texto y código

- **Código en línea**: toda palabra del lenguaje dentro de la prosa va como fragmento de código (`Si`,
  `Definir edad Como Entero`). El constructor la tokeniza con el motor real y guarda la categoría de cada
  token; el consumidor la pinta como **píldora con fondo sombreado** y los mismos colores del editor.
- **Huecos** de una forma de escritura: `«condición»`, `«instrucciones»`, como píldoras de otro color, iguales
  que las de la hoja de ayuda del editor (`HelpSlotChip`).
- **Bloques de programa**: numeración de líneas, título, resultado esperado debajo («Salida»), terminación y
  diagnósticos, y un botón «Probar en el editor».
- **Diagrama de sintaxis** (raíles) para cada construcción, derivado de la gramática del corpus.
- **Figuras** con pie numerado («Figura 6.1-2»), texto alternativo y descripción larga accesible.
- **Sin identificadores internos**: nada de códigos de reglas del corpus en pantalla. Los códigos de diagnóstico
  (`integerOverflow`) sí se muestran, porque son los mismos que la persona ve en el editor.

### 4.2 Mobile first

La app se diseña primero para un teléfono de 375 puntos y se amplía hacia tableta y escritorio, nunca al
revés:

- **Lector**: una columna con márgenes de 16 puntos; la tabla de contenidos es una hoja inferior en el
  teléfono y una columna lateral solo a partir de 1080 puntos de ancho.
- **Figuras**: se dibujan a **340 unidades de ancho**, el ancho útil de un teléfono, con texto de al menos
  12 unidades. Así en el teléfono se ven a tamaño real, sin pellizcar. En pantallas anchas se muestran a un
  máximo de 420 puntos, centradas; no hay versión ancha que mantener aparte.
- **Composición vertical**: todo lo que avanza (tiempo, recorrido, pasos) avanza hacia abajo. La línea de
  tiempo de tareas pone el tiempo en vertical y las tareas en columnas estrechas; los diagramas de sintaxis
  se parten en filas como vías de tren.
- **Lo que cambia o es texto largo va en el lector, no en el dibujo**: los paneles de memoria, salida y traza
  de una figura por pasos, y las zonas de la agenda, son componentes del lector que se recolocan solos
  (una columna en teléfono, tres en escritorio). El SVG queda para lo que de verdad es un dibujo.
- **Programas**: tipografía de 14 puntos en el teléfono; las líneas largas se desplazan en horizontal dentro
  del bloque, nunca la página.
- **Cabecera de un programa**: título, sello y botón se reparten en dos líneas si no caben en una.

---

## 5. Arquitectura propuesta

### 5.1 Principio

El contenido se escribe **una vez**, se compila **una vez** y se publica como un **paquete de datos neutral**
(JSON + SVG). Flutter y Astro solo lo pintan: ninguno de los dos analiza Markdown, resuelve palabras clave,
resalta código, ejecuta ejemplos ni interpreta el corpus. Toda la inteligencia vive en el compilador de la
especificación, que es Rust porque necesita al motor para tokenizar, resaltar y ejecutar.

```
corpus see/1 ──export.json──┐
                            ├──► compilador de la especificación ──► paquete de la especificación
fuentes .md + figuras .svg ─┤        (pseudolearn_reference)            (JSON por idioma × perfil + SVG)
motor (pseudolearn_api) ────┘                                                │
                                                       ┌─────────────────────┼─────────────────────┐
                                                       ▼                     ▼                     ▼
                                                 app Flutter           web Astro            (futuro: VS Code,
                                                (asset del build)    (build estático)        LSP «ver más»)
```

### 5.2 Nuevo miembro: `packages/pseudolearn_reference`

Biblioteca y herramienta de compilación que no se despliega; por eso vive en `packages/`. Nombre «reference»
para no confundirse con `pseudolearn_spec`, que es el corpus normativo. En la interfaz se sigue llamando
«Especificación».

```
packages/pseudolearn_reference/
  README.md                     arquitectura, formato, verificadores, decisiones
  architecture.yaml             capas, imports, límites
  rust-toolchain.toml           misma versión exacta que el resto de miembros Rust
  content/
    es/  00-como-leer/…  03-tipos/03-01-tipos-primitivos.md  06-control/06-01-si.md …
    en/  (misma estructura, mismos identificadores de bloque)
  figures/
    tipos-cajas.svg  si-ordinograma.svg  agenda-fifo.svg …   SVG con roles de color
    strings/es.json  strings/en.json                         textos de las figuras
  schemas/reference-bundle.schema.json
  crates/
    reference_model      documento, bloques, fragmentos en línea, anclas
    reference_format     lectura de Markdown con directivas
    reference_resolve    léxico, fichas de ayuda, gramática y diagnósticos desde la exportación del corpus
    reference_verify     ejecución de ejemplos, anclas, cobertura, paridad, contrato de figuras
    reference_figures    sustitución de textos y roles en SVG, variantes por idioma y perfil
    reference_export     paquete JSON y SVG final
    reference_cli        `reference build`, `reference check`, `reference coverage`
  fixtures/              violaciones deliberadas, una por verificador
  xtask/                 `cargo xtask verify`
```

Dependencias: lee `packages/pseudolearn_spec/specifications/export.json` como **dato** y usa
`pseudolearn_api` por ruta, igual que la frontera nativa de la app. No importa nada de Flutter ni de Astro.

### 5.3 Formato fuente

Markdown con directivas en cercas. Ejemplo de la sección 6.1:

````markdown
---
id: control.si
numero: "6.1"
tipo: construccion
titulo: La decisión Si
anclas: [LANG.CONTROL.IF#R1, LANG.OPS.LOGICAL#R1]   # internas: no se publican
fichas: [ifStatement]
---

::: frase
`Si` elige entre dos caminos según una pregunta que solo puede responderse con `Verdadero` o `Falso`.
:::

```forma
Si «condición» Entonces
  «instrucciones»
[Sino
  «instrucciones»]
FinSi
```

```figura id=si-ordinograma
```

```programa id=montana titulo="¿Puedo subir?" ejecutar
Proceso Montana
  Definir estatura Como Entero <- 128;
  Si estatura >= 120 Entonces
    Escribir "Puedes subir a la montaña rusa";
  …
```

```salida
Puedes subir a la montaña rusa
```

::: por-dentro
```ri programa=montana
```
:::
````

- Las palabras de una `forma` y de un `programa` se escriben en el perfil del documento; el compilador las
  identifica con el motor y genera la variante en inglés por traducción léxica (`LANG.PROFILE.TRANSLATION`),
  de modo que no hay que mantener dos programas.
- `salida` es la promesa; el compilador ejecuta y compara.
- `ri` y `traza` no se escriben: se generan desde el programa citado.

### 5.4 Paquete de salida (contrato con los consumidores)

`reference-bundle/<idioma>/<perfil>/` con:

- `toc.json`: partes, capítulos y secciones con identificador, número, título y resumen.
- `sections/<id>.json`: lista de bloques tipados. Los bloques en línea son corridas `texto`, `énfasis`,
  `código{tokens[{texto, categoria}]}`, `enlace{seccion}`, `termino{glosario}`. Los bloques son `encabezado`,
  `parrafo`, `lista`, `forma{segmentos}`, `raíles{svg}`, `programa{lineas tokenizadas, salida, terminacion,
  diagnosticos}`, `figura{svg, alt, pie, descripcion, pasos[]}`, `recuadro{tipo}`, `resumen{puntos}`,
  `tabla`, `diagnostico{codigo, severidad, mensaje}`, `ri{lineas tokenizadas}`, `traza{eventos}`, `plegable`.
- `figures/<id>.svg`: SVG con colores centinela por rol.
- `search.json`: índice de búsqueda por términos, palabras clave y códigos de diagnóstico.
- `manifest.json`: versión del formato, revisión del corpus, huella del motor y huellas de cada archivo.

Las anclas al corpus **no viajan en el paquete**: se quedan en las fuentes y en el candado del compilador.
Los enlaces desde el editor hacia la especificación usan identificadores de sección, fichas de ayuda y
códigos de diagnóstico, nunca reglas del corpus.

Las categorías de token son las mismas de `HighlightCategory` del editor. Los **roles de color** de las
figuras (`tinta`, `superficie`, `acento-estructurado`, `acento-procedimental`, `acento-objetos`, `numero`,
`texto`, `logico`, `exito`, `error`, `atenuado`) se codifican con colores centinela; cada consumidor los
sustituye por los tokens de su tema claro u oscuro (Flutter con el `ColorMapper` del cargador SVG, Astro
con variables CSS). El paquete no decide colores de interfaz.

### 5.5 Figuras

Se dibujan como SVG a mano con un kit de piezas recurrentes (caja de variable, banco de registros, cola,
flecha de control, flecha de dato, marco de pila, tarea) y se validan mecánicamente:

- solo elementos y atributos permitidos, `viewBox` obligatorio, sin imágenes rasterizadas ni enlaces externos;
- solo colores de rol, nunca hexadecimales libres;
- todo texto visible viene de `strings/<idioma>.json` o de un lexema (`{{lexema:ifKeyword}}`), así la figura
  se traduce y cambia de perfil sin redibujarla;
- `<title>` y `<desc>` obligatorios;
- `viewBox` de **340 unidades de ancho** y texto de **12 unidades o más** (§4.2); el alto es libre;
- los paneles que cambian con los pasos (memoria, salida, traza, zonas de una agenda) no se dibujan: se
  declaran como bloques del lector dentro de la figura;
- figuras **por pasos**: un mismo SVG con grupos `data-paso="n"` que el consumidor muestra
  progresivamente con controles «anterior / siguiente». Es la forma de contar la agenda de tareas, el
  recorrido de un `Para` o una llamada recursiva.

Se descartan: imágenes rasterizadas (no cambian de tema ni de idioma), widgets Flutter como fuente (no viajan
a Astro) y un lenguaje de escenas propio con dos renderizadores (dos implementaciones que divergen).

### 5.6 Verificadores (lo que impide volver al estado actual)

| ID | Regla | Caso negativo |
|---|---|---|
| `REF-EXAMPLE-VERIFIED` | Todo `programa` con `ejecutar` se ejecuta con el motor; salida, terminación y diagnósticos deben coincidir exactamente | Fixture con salida prometida falsa |
| `REF-ANCHOR-VALID` | Toda ancla existe en la exportación; una sección sin anclas no compila | Ancla a una regla inexistente |
| `REF-ANCHOR-STALE` | Un candado guarda la huella de cada regla anclada; si cambia, la sección queda «pendiente de revisión» y `check` falla hasta revisarla | Huella alterada |
| `REF-COVERAGE` | Cada identidad del vocabulario (101), cada ficha de ayuda (209), cada diagnóstico del catálogo y cada especificación `LANG`, `LIB`, `ENG`, `MEM`, `RT` está cubierta por al menos una sección o figura en una lista de exclusiones con motivo | Identidad sin sección |
| `REF-ANATOMY` | Cada sección contiene los bloques obligatorios de su tipo | Construcción sin «Cómo se escribe» |
| `REF-PARITY` | `es` y `en` tienen las mismas secciones y los mismos identificadores de bloque | Bloque presente solo en un idioma |
| `REF-INLINE-CODE` | Una palabra reservada canónica con mayúscula inicial fuera de un fragmento de código es error (`FinSi`, `Entonces`, `Definir`…) | Prosa con `FinSi` sin marcar |
| `REF-FIGURE-CONTRACT` | Contrato SVG de §5.5 | Figura con `fill="#ff0000"` |
| `REF-NO-INTERNAL-IDS` | Ningún texto publicado contiene identificadores del corpus (`LANG.`, `ENG.`, `LIB.`, `#R1`…) | Párrafo que cita `LANG.CONTROL.IF` |
| `REF-FIGURE-NARROW` | Toda figura mide 340 de ancho y ningún texto baja de 12 unidades | Figura de 760 de ancho |
| `REF-BUNDLE-STALE` | El paquete versionado en la app coincide con lo que produce el compilador | Paquete editado a mano |

El informe de cobertura (`reference coverage`) da un porcentaje por parte y la lista de lo que falta: es la
métrica de avance de las fases de redacción.

### 5.7 Consumidor Flutter (este plan)

Reemplazo completo del módulo actual:

- **Se elimina**: `assets/knowledge/specification/`, las entradas `specification` de `manifest_<lang>.json`,
  `SpecificationDocument`, `SpecificationSection`, `SpecificationSectionDefects`, `SpecificationCubit` y su
  estado, `SpecificationDetailView`, los marcadores de motor usados solo por la especificación y sus tests.
- **Se añade** (respetando `architecture.yaml` de la app):
  - `domain/model/reference/`: modelo propio de sección, bloque, corrida en línea, figura y entrada de índice.
  - `domain/port/`: puerto `ReferenceRepository`.
  - `data/reference/`: adaptador que lee el paquete empaquetado como asset y lo transforma al modelo propio.
  - `application/reference/`: cubits de índice, sección y búsqueda.
  - `presentation/reference/`: mobile first según §4.2. Índice por partes con numeración, lector de una
    columna con tabla de contenidos en hoja inferior (lateral solo a partir de 1080 puntos), píldoras de código, bloques de programa con salida y «Probar en el editor»,
    figuras por pasos, recuadros plegables, búsqueda, enlaces entre secciones.
- **Enlaces de entrada**: la hoja de ayuda del editor y cada diagnóstico ofrecen «Ver en la especificación»
  hacia la sección que explica esa ficha o ese código; la ruta de aprendizaje enlaza por identificador.
- **Dependencia nueva**: un cargador SVG con sustitución de colores (`flutter_svg`). Se registra en el README
  de la app con su motivo y la alternativa descartada (pintar escenas con `CustomPainter`).
- `constructSpecificationSections` y la proyección de cobertura del panel apuntan a los nuevos
  identificadores de sección.

### 5.8 Consumidor web (preparado, fuera de este plan)

Astro lee el mismo paquete en tiempo de build con un cargador de colecciones de contenido y lo pinta con
componentes propios; las figuras se insertan en línea y sus roles se convierten en variables CSS. La decisión
entre la página principal y un subdominio no afecta al paquete. Más adelante, el módulo Wasm del motor
permitirá «Probar» en el navegador.

---

## 6. Fases

Cada fase termina en verde (`PHASE-GREEN`), actualiza los README afectados en el mismo cambio
(`DOC-README-TRUTH`), publica con push ordinario a `feature/agregar-ruta-de-especificacion` y se detiene
hasta autorización nueva (`PHASE-STOP`).

| Fase | Contenido | Cierre verificable |
|---|---|---|
| **EI-0** | Aprobación de este plan, respuestas de §9, revisión de los tres ejemplos | Decisiones registradas |
| **EI-1** | Miembro `pseudolearn_reference`: README, `architecture.yaml`, `reference_model`, `reference_format`, esquema del paquete, `xtask verify`, comprobación de comentarios y límites | Tests y casos negativos de formato en verde |
| **EI-2** | `reference_resolve` y `reference_verify`: léxico, fichas, gramática, diagnósticos; tokenizar y ejecutar con `pseudolearn_api`; anclas, candado, anatomía, paridad, código en línea, cobertura | Los tres ejemplos compilan; cada verificador rechaza su fixture |
| **EI-3** | `reference_figures`: contrato SVG, kit de piezas, textos por idioma, lexemas en figuras, pasos | Las figuras de los ejemplos pasan el contrato |
| **EI-4** | `reference_export` y `reference_cli`; paquete versionado en la app con `REF-BUNDLE-STALE` | Paquete reproducible bit a bit |
| **EI-5** | App: modelo, puerto, adaptador, cubits, lector, índice, búsqueda, figuras, enlaces desde ayuda y diagnósticos; eliminación del módulo actual | `flutter test`, verificadores de la app y humo en simulador iOS en verde |
| **EI-6** | Redacción: Partes 0, I y II | Cobertura léxica 100 % |
| **EI-7** | Redacción: Partes III, IV y V | Cobertura de tipos, operadores y declaraciones 100 % |
| **EI-8** | Redacción: Partes VI, VII y VIII | Cobertura de control, subprogramas y módulos 100 % |
| **EI-9** | Redacción: Partes IX y X, Apéndice C | Cobertura de objetos y diagnósticos 100 % |
| **EI-10** | Redacción: Partes XI y XII, Apéndice D | Cobertura de tareas y biblioteca 100 % |
| **EI-11** | Redacción: Parte XIII, Apéndices A, B, E y F | Cobertura `ENG`, `MEM`, `RT` 100 % o exclusiones motivadas |
| **EI-12** | Cierre: accesibilidad (contraste, lector de pantalla, tamaño de texto), rendimiento de carga, capturas de tienda afectadas, README raíz con el miembro nuevo | Informe de cobertura final y auditoría de accesibilidad |

Las fases EI-6 a EI-11 son de contenido y pueden reordenarse; la app muestra lo que ya existe y el índice
marca las secciones aún no publicadas como «en redacción» en lugar de esconderlas.

### 6.1 Volumen estimado

Unas 115 secciones redactadas, 6 apéndices generados, entre 90 y 130 figuras y entre 250 y 350 programas
ejecutados. Una sección de construcción mide entre 150 y 300 líneas fuente; los tres ejemplos dan la medida.

---

## 7. Criterios de calidad del texto

1. Una idea por párrafo; frases de menos de 25 palabras en el cuerpo.
2. Primero el ejemplo o la figura, después la regla.
3. Cada afirmación sobre comportamiento observable tiene un programa ejecutado o un ancla al corpus.
4. Cada número es exacto y aparece en «Límite exacto».
5. Las analogías se declaran como analogías y se dice dónde dejan de valer.
6. Nada de «simplemente», «obviamente», «es fácil».
7. Los errores se muestran con el mensaje real del motor y se explica cómo arreglarlos.
8. Se usan las palabras canónicas del perfil (`Proceso`, `FinProceso`); los alias se mencionan una vez en la
   sección de vocabulario.

---

## 8. Riesgos

| Riesgo | Mitigación |
|---|---|
| Volumen de redacción | Cobertura medida, lotes por parte, secciones de biblioteca generadas desde fichas |
| Deriva respecto al motor | `REF-EXAMPLE-VERIFIED` y `REF-ANCHOR-STALE` en cada `check` |
| Figuras incoherentes entre sí | Kit de piezas y contrato SVG |
| Traducción desigual | `REF-PARITY`; programas traducidos por el motor |
| Tamaño del asset en la app | Paquete por idioma y perfil activo; SVG sin metadatos; medición en EI-5 |
| La Parte XIII envejece rápido | Anclas a `ENG.*`/`IR.*` y RI generada, nunca copiada |

---

## 9. Preguntas que bloquean EI-1

1. **Tipos primitivos.** El corpus define cinco (`Entero`, `Real`, `Logico`, `Caracter`, `Cadena`). ¿Cuál es el
   sexto que esperabas? Si es `Bytes`, `Opcional` o `Resultado`, en el corpus son tipos incorporados no
   primitivos; cambiarlo sería un cambio del corpus, no de la especificación ilustrada.
2. **Nombre del miembro.** Se propone `packages/pseudolearn_reference`.
3. **Dependencia SVG en la app.** Se propone `flutter_svg`.
4. **Hallazgos de §1.** ¿Se abren como trabajo aparte (cascada de `Sino`, mensaje sin localizar,
   resaltado incompleto) o se esperan hasta que la redacción los toque?

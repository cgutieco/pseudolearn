# 01 — Arquitectura

## 1. Punto de partida verificado

| Pieza | Estado al escribir este plan | Consecuencia |
|---|---|---|
| `packages/pseudolearn_reference` | Implementado. Compila la Especificación ilustrada (`content/<es\|en>/…`, 105 secciones, figuras con contrato SVG, programas ejecutados con el motor, verificadores `REF-*`) y publica `apps/pseudolearn_app/assets/reference/<idioma>/<perfil>/` | La ruta reutiliza esta cadena en vez de inventar otra |
| Lector de la Especificación en la app | `data/reference`, `application/reference`, `presentation/reference` (bloques, figuras por capas, píldoras de código, enlaces) | La ruta reutiliza sus vistas de bloque |
| Ruta actual | `apps/pseudolearn_app/assets/knowledge/` con `manifest_<idioma>.json` v2, 15 módulos `CON-*`, 96 ejercicios JSON, ejemplos `.pseudo`, parsers en `data/knowledge`, cubits en `application/knowledge/{route,bank,prediction,session}`, ilustraciones Flutter en `presentation/knowledge/illustrations`, verificador `tool/check_content.dart` | Se elimina entera, sin retrocompatibilidad (§7) |
| Comprobación de ejercicios | Puerto `ExerciseChecker`, `RustExerciseChecker`, `engine/exercise/*` (casos visibles y ocultos, normalización, aserciones estructurales) | Se conserva para los tipos que ejecutan el programa del estudiante; los tipos nuevos agregan evaluadores |
| Progreso | Tabla `progress(user_id, content_id text, visited, completed, …)` en Supabase y almacén local SQLite | Sin cambios de esquema: los identificadores nuevos son filas nuevas |
| Palabra de programa | El corpus hace canónico `Algoritmo`/`FinAlgoritmo`; `Proceso` es alias | Todos los programas de la ruta usan `Algoritmo` |

Antes de empezar, el agente confirma cada fila con el código. Si algo cambió, lo reporta antes de seguir.

---

## 2. Decisiones

### D1. La ruta es un segundo libro del compilador `pseudolearn_reference`

- **Problema:** la ruta necesita exactamente lo que el compilador ya resuelve para la Especificación: Markdown con
  directivas, programas ejecutados con el motor, traducción al perfil inglés, figuras con contrato, paquete neutral,
  verificación de paquete obsoleto y enlaces a secciones. Además necesita enlazar secciones de la Especificación
  sabiendo que existen.
- **Elección:** `pseudolearn_reference` pasa a compilar dos libros: `especificacion` (el actual, sin cambios de
  contenido) y `ruta`. Comparten lector de formato, motor, figuras, resaltado y exportación. La ruta agrega su modelo
  de lección y de ejercicio, su grafo de términos y sus verificadores.
- **Descartado:**
  - *Un miembro nuevo `pseudolearn_route`:* duplicaría el lector, el puerto del motor, la escritura del paquete y la
    comprobación de obsolescencia, y necesitaría leer el índice de la Especificación desde fuera.
  - *Mantener Markdown y JSON en `assets/knowledge` interpretados por la app:* es el modelo actual. Los programas no se
    ejecutan al construir, la app analiza Markdown y nada impide usar un concepto antes de explicarlo.
- **Obligación documental:** el README de `pseudolearn_reference` deja de decir «No es un tutorial». Se reescriben §1
  (qué es: compilador de dos libros), §3 (arquitectura, árbol de contenido, formato y paquete de la ruta), §3.5
  (verificadores `RUTA-*`), §4 (esta decisión con su descarte) y §7 (pendientes). Va en el mismo cambio que el código
  (`DOC-README-TRUTH`).

### D2. Capas del compilador

El agente respeta la matriz de `architecture.yaml` y sus límites (300 líneas por archivo, 40 por función, cuatro
parámetros posicionales). Reparto propuesto; si un límite obliga a otro reparto, se documenta en el README:

| Capa | Qué agrega para la ruta |
|---|---|
| `reference_model` | Cabecera de lección (`LessonHeader`), cabecera de ejercicio (`ExerciseHeader`), tipos de ejercicio, bloques nuevos de fuente y de publicación, `ExerciseCheck` (lo que hay que verificar de cada ejercicio) |
| `reference_format` | Lectura de `leccion.md` y de cada ejercicio: cabeceras nuevas, recuadros y cercas nuevos (02 §2 y §3) |
| `route_resolve` (crate nuevo) | Fuente de lección → lección publicada: tarjetas de recuerdo, enlaces a la Especificación, figuras de la Especificación incrustadas, bloques de ejercicio resueltos y ejecuciones para su verificación. Importa `reference_model`, `reference_corpus`, `reference_figures`, `reference_format` y `reference_resolve` |
| `reference_verify` | Módulos `route_*` con los verificadores `RUTA-*` (02 §5) |
| `reference_export` | Paquete de la ruta (§4) y su manifiesto |
| `reference_cli` | El espacio de trabajo carga `route/`; `build`, `check` y `coverage` procesan los dos libros; `build` escribe los dos destinos |

`architecture.yaml` declara `route_resolve` con su `may_import` (`LAYER-DECLARED`). `cargo xtask verify` cubre el
crate nuevo sin cambios en el orden de las puertas.

### D3. Árbol de contenido de la ruta

```
packages/pseudolearn_reference/
  route/
    <es|en>/partes.json                                   unidad y partes: id, número, título, lema, resumen
    <es|en>/terminos.json                                 id de término → etiqueta visible
    <es|en>/<NN-parte>/<NN-MM-slug>/leccion.md            una lección
    <es|en>/<NN-parte>/<NN-MM-slug>/ejercicios/<NN-slug>.md   un ejercicio por archivo
  figures/ruta-*.svg                                      figuras propias de la ruta (mismo contrato)
  figures/strings/<es|en>.json                            cadenas de figuras; claves de la ruta con prefijo ruta-
  fixtures/route/…                                        violaciones deliberadas de cada verificador RUTA-*
```

- `NN-parte`: `00-inicio`, `01-imperativo`, `02-procedimental`, `03-objetos`, `04-funcional`, `05-concurrente`,
  `06-exterior`.
- `NN-MM-slug`: número de lección y slug del id (`01-03-mientras` para `imperativo.mientras`). Los proyectos usan
  `MM = 99` (`01-99-proyecto`).
- `terminos.json` solo trae etiquetas: «caso borde», «acumulador». La definición vive en la lección dueña; la
  dueña se calcula desde las cabeceras (`introduce`), nunca se escribe a mano.
- La edición inglesa tiene los mismos archivos y los mismos ids. Sus bloques `programa` pueden ir vacíos para reusar
  el programa español traducido por el motor, igual que en la Especificación.

### D4. Enlaces entre libros

| Desde | Hacia | Sintaxis en la fuente | Verificador |
|---|---|---|---|
| Ruta | Sección de la Especificación | `[texto](especificacion:control.mientras)` o con ancla `especificacion:control.mientras#funciona` | `RUTA-SPEC-LINK` |
| Ruta | Figura de la Especificación | cerca `figura-especificacion seccion=control.mientras figura=mientras-ciclo` | `RUTA-SPEC-LINK` |
| Ruta | Otra lección | `[texto](ruta:imperativo.mientras)` | `RUTA-LINK-VALID` |
| Especificación | Ruta | No se escribe en la fuente de la Especificación. El paquete de la ruta publica `spec-links.json` (sección → lecciones que la enlazan) y la app muestra «Aprender en la ruta» al pie de la sección | Generado |

Así la Especificación no cambia ni se vuelve a publicar por culpa de la ruta.

Una figura de la Especificación incrustada se publica **copiada desde la sección ya resuelta**, con su SVG, sus
capas, sus pasos y su pie. Nadie la redibuja ni reescribe su pie (`GEN-NO-HAND-COPY`). En la app se ve igual que en la
Especificación y lleva el rótulo «De la Especificación §6.3».

### D5. Ediciones

Igual que la Especificación: idioma de interfaz (`es`, `en`) × perfil de sintaxis (español, inglés), cuatro
ediciones. Los programas se escriben en perfil español y el motor los traduce. Los textos entre comillas de los
programas quedan en español en la edición inglesa (pendiente heredado del compilador).

---

## 3. Modelo de la lección publicada

Una lección publicada tiene una cabecera y una lista ordenada de bloques.

**Cabecera:** `id`, `numero`, `parte`, `titulo`, `duracion_minutos`, `niveles` (los que tienen sus ejercicios),
`necesita` (ids de lecciones), `introduce` (ids de términos, con etiqueta), `problema_breve` (una línea para el índice),
`anterior` y `siguiente`.

**Bloques reutilizados del libro de la Especificación** (mismo esquema, mismas vistas en la app): `heading`,
`paragraph`, `list`, `table`, `program`, `figure`, `callout` (`analogia`, `docentes`, `por-dentro`, `nota`), `summary`,
`diagnostic`.

**Bloques nuevos:**

| Bloque | Contenido | Para qué |
|---|---|---|
| `phrase` | Frase de una o dos oraciones | La idea de la lección, igual que «En una frase» de la Especificación |
| `problem` | Enunciado en corridas en línea | El gancho; el borde rosado de las muestras |
| `attempt` | Consigna visible y respuesta oculta | «Inténtalo»: la persona resuelve o predice antes de seguir |
| `cycle` | Fase activa (1 a 5) o par de fases (`1-2`) | La tira del ciclo PseudoLearn que precede a cada fase |
| `phase_heading` | Número de fase y título | Encabezado de fase con su insignia de color |
| `brief` | Zonas `entra`, `sale`, `relacion`, `ejemplos` | La ficha del problema |
| `roles` | Lista de roles: nombre, descripción, figura de icono | Roles de variables |
| `paradigm` | Zonas `pregunta`, `metafora`, `historia`, `costo` | Apertura de un paradigma |
| `recall` | Término, frase generada, lección dueña | Tarjeta «Recuerda» |
| `spec_links` | Lista de `{seccion, numero, titulo}` resueltos | Píldoras «Especificación §x.y» |
| `practice` | Ids de ejercicios en orden | La sección «Practica» |
| `next` | Lección siguiente y frase de enganche | Cierre |

**Corridas en línea nuevas:** `definition` (primera aparición de un término en su lección dueña, con el id del término)
y `spec_link` (enlace en línea a una sección).

---

## 4. Paquete publicado de la ruta

`apps/pseudolearn_app/assets/route/<idioma>/<perfil>/`:

| Archivo | Contenido |
|---|---|
| `toc.json` | Partes con sus lecciones: id, número, título, `problema_breve`, duración, niveles, `necesita` |
| `lessons/<id>.json` | Lección publicada (§3) |
| `exercises/<id>.json` | Ejercicio publicado (02 §3.4) |
| `terms.json` | Término → etiqueta, lección dueña y frase de recuerdo |
| `spec-links.json` | Sección de la Especificación → lecciones que la enlazan |
| `manifest.json` | Formato `pseudolearn-route/1`, idioma, perfil, huella del motor, huella del paquete de la Especificación de la misma edición y SHA-256 de cada archivo |

El esquema vive en `packages/pseudolearn_reference/schemas/route-bundle.schema.json` y lo valida un test del
compilador. `RUTA-BUNDLE-STALE` compara el paquete versionado con el que produce `check`, igual que
`REF-BUNDLE-STALE`.

---

## 5. La app

La app sigue su README y su `architecture.yaml`. Antes de escribir código, el agente lee las secciones del README
sobre capas (§3), cubits (§4.1), navegación (§4.5), inyección (§4.6), base de conocimiento (§4.18), comprobación de
ejercicios (§4.19), progreso (§4.25) y el lector de la Especificación (§4.62).

### 5.1 Responsabilidades nuevas

| Capa | Qué se agrega |
|---|---|
| `domain/model/route/` | Lección, bloques de lección, ejercicio con una variante por tipo, respuesta del estudiante por tipo, resultado de evaluación |
| `domain/ports/` | `RouteRepository` (índice, lección, ejercicio, términos, enlaces inversos) |
| `data/route/` | Lector del paquete `assets/route/`, en espejo de `data/reference/`. Reutiliza los parsers de bloques y corridas de `data/reference` para los bloques compartidos |
| `engine/route_exercise/` | Un evaluador por tipo de ejercicio (§5.3). Los que ejecutan programas usan los puertos de ejecución que ya usa `RustExerciseChecker` |
| `application/route/` | Cubit del índice, cubit de la lección y cubit de ejercicio. El cubit de ejercicio recibe un mapa tipo → evaluador inyectado; agregar un tipo no modifica el cubit |
| `presentation/route/` | Índice de la ruta, lector de lección, una vista por bloque nuevo, una vista de respuesta por tipo de ejercicio, la escalera de pistas y el revelado |
| Composición | Registro de dependencias y rutas: `/conocimiento/ruta`, `/conocimiento/ruta/:leccion`, `/conocimiento/ruta/:leccion/:ejercicio` |

Las vistas de bloques compartidos (`program`, `figure`, `callout`, `table`, `summary`) se reutilizan desde
`presentation/reference/blocks/`. Si hace falta moverlas a una carpeta común porque ya no son solo de la
Especificación, el movimiento se hace en la misma fase y se documenta en el README de la app.

### 5.2 Dónde se responde cada tipo de ejercicio

| Tipo | Se responde en | Qué ve la persona al fallar |
|---|---|---|
| `resolver`, `modificar`, `encontrar-error` | El editor, con `ExerciseStrip` y el `starterCode`, como hoy | El primer caso oculto que falla (política actual, sin notas ni porcentajes) |
| `predecir` | La página del ejercicio: campo de texto multilínea | «No coincide» y la línea donde difiere; la respuesta queda detrás de «Ver la respuesta» |
| `rastrear` | Tabla con celdas editables | Las celdas incorrectas marcadas, sin revelar su valor |
| `ordenar` | Lista de bloques que se arrastran o se mueven con botones | El primer caso que falla del programa armado |
| `romperlo` | Campo para una entrada (una línea por `Leer`) | Si la entrada no rompe el programa, se dice qué respondieron los dos programas |
| `disenar-pruebas` | Lista editable de casos (entradas y salida esperada) | Qué caso no pasa la referencia, o cuántas versiones defectuosas siguen sin detectarse |
| `clasificar`, `explicar`, `comparar` | Opciones o casillas | Qué elementos están mal ubicados; la justificación de cada opción tras responder |

### 5.3 Evaluadores

| Tipo | Regla de acierto | Datos que trae el paquete |
|---|---|---|
| `predecir` | La respuesta normalizada con `OutputNormalizer` es igual a la salida publicada | Programa, entradas, salida verificada |
| `rastrear` | Cada celda editable coincide con la tabla publicada, normalizada como valor | Programa, columnas, filas verificadas, celdas que la persona debe completar |
| `ordenar` | El programa armado pasa los casos (no se exige el orden exacto: dos órdenes válidos cuentan) | Bloques, casos |
| `romperlo` | Con la entrada propuesta, la salida del programa defectuoso difiere de la de la referencia, o el defectuoso falla y la referencia no | Programa defectuoso, referencia, cantidad de `Leer` esperados |
| `disenar-pruebas` | Todos los casos pasan en la referencia y cada mutante falla al menos un caso | Referencia, mutantes, mínimo y máximo de casos |
| `clasificar` | Cada elemento en su categoría | Elementos, categorías, asignación correcta |
| `explicar`, `comparar` | Opción correcta | Opciones con justificación por opción |
| `resolver`, `modificar`, `encontrar-error` | Lo que ya hace `ExerciseChecker` | Casos visibles y ocultos, aserciones estructurales opcionales, `starterCode` |

Los programas de referencia, defectuosos y mutantes **viajan en el paquete** porque la app los ejecuta para evaluar.
La app nunca muestra un mutante.

### 5.4 Progreso

- Identificadores: `ruta.leccion:<id>` y `ruta.ejercicio:<id>`.
- Una lección es **visitada** al abrirla y **completada** cuando todos sus ejercicios marcados `obligatorio` están
  resueltos.
- Los identificadores de la ruta anterior (`CON-*`) quedan en la base sin uso: las proyecciones los ignoran. No hay
  migración ni borrado remoto.
- El tablero (`application/dashboard/`) y la incorporación (`application/onboarding/`) cambian de «tramos y módulos» a
  «partes y lecciones»: siguiente paso = primera lección no completada cuyo `necesita` está completo.

### 5.5 Base de conocimiento

`KnowledgePage` conserva tres secciones: **Ruta de aprendizaje** (índice nuevo), **Especificación** (sin cambios) y
**Banco de ejercicios**, que pasa a ser una proyección de todos los ejercicios de la ruta, filtrable por parte, tipo y
nivel. El banco no tiene ejercicios propios.

---

## 6. Fuera de alcance

- La web Astro (`apps/pseudolearn_web`) no consume la ruta en este plan; el paquete neutral la deja preparada.
- Patrones de diseño: release posterior.
- Calificar las fases Entender y Planear fuera de los proyectos.
- Regenerar capturas de producto y material de tiendas: solo si la persona lo autoriza en la fase RA-7.

---

## 7. Lo que se elimina

Sin retrocompatibilidad. Antes de borrar, el agente hace el inventario con búsquedas y lo lista en el informe de la
fase RA-3. Puntos de partida conocidos:

- `apps/pseudolearn_app/assets/knowledge/manifest_*.json`, `modules/`, `exercises/` y `examples/`.
- `lib/data/knowledge/*`, `lib/engine/knowledge/*`, `lib/application/knowledge/{route,bank,prediction}` y lo que solo
  ellos usen; `lib/domain/model/knowledge/*` que quede sin uso; `lib/presentation/knowledge/{illustrations,detail}` y
  componentes de módulo.
- `tool/check_content.dart` y su paso en la verificación del README, reemplazados por `reference check`.
- Tests espejo de todo lo anterior.
- Entradas de `pubspec.yaml` que declaran los activos borrados.

**Excepciones que se conservan, moviéndolas si hace falta:** todo archivo de `assets/knowledge/examples/` que use otra
parte de la app (por ejemplo, `guided_demo_*.pseudo` para la demo guiada y las capturas de producto). Se mueve a una
ruta neutral (por ejemplo `assets/demo/`) y se actualizan sus consumidores y el README. Lo que use
`application/knowledge/session` para abrir ejercicios en el editor se adapta, no se borra.

---

## 8. Riesgos conocidos y cómo se acotan

| Riesgo | Acotación |
|---|---|
| Los ejercicios de módulos (2.7) necesitarían varios archivos y `ExerciseChecker` ejecuta uno | En 2.7 los ejercicios son `clasificar`, `ordenar` y `explicar`. Los programas de la lección se verifican en el compilador si este ya ejecuta proyectos de varios módulos (lo comprueba el agente en la sección `programas.modulos`); si no, la lección usa figuras y no programas ejecutados, y se declara como pendiente |
| Archivos y HTTP (Parte VI) dependen del anfitrión | El compilador usa el anfitrión de memoria (bloque `anfitrion`). En la app, los ejercicios de la Parte VI que ejecutan programas solo prueban la parte pura (funciones que reciben texto y devuelven valores). Los programas completos se ofrecen para abrir en el editor, sin comprobación |
| La traza del motor no publica valores de variables | `rastrear` se verifica instrumentando: el compilador inserta `Escribir v1, "|", v2, …;` antes de la línea marcada como fin de vuelta y lee una fila por línea de salida (02 §3.3). El programa instrumentado nunca se publica |
| Formato de reales (`14.0`, `14.333333333333334`) | Los problemas eligen datos con salidas legibles. Si un número feo es inevitable, se explica en la lección o se redondea con la biblioteca |
| Concurrencia y orden de salida | El motor es determinista; las salidas se verifican igual que las demás. Una lección nunca promete un orden que dependa del reloj |
| Tamaño del paquete | 41 lecciones, unos 250 ejercicios y cuatro ediciones. Si el paquete pasa de 8 MB, se reporta antes de seguir |

# Autocompletado agresivo: diagnóstico y diseño

Análisis previo a la implementación. No modifica código ni especificaciones; propone el diseño y las fases.
Cada fase requiere autorización explícita (`PHASE-STOP`).

---

## 1. Informe de diagnóstico

### 1.1 Qué declaran las especificaciones

| Contrato                              | Estado       | Compromiso                                                                                                                                                                                                                                         |
|---------------------------------------|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `TOOL.SERVICE.COMPLETION@0.1.0`       | estable      | R1 candidatos por contexto (sentencia, expresión, tipo, miembro, cabecera) e inertes en comentarios y literales; R2 símbolos visibles por alcance y miembros por clase estática; R3 cierre del bloque más interno como primer candidato; R4 bilingüismo; R5 determinismo; R6 calidad medida (top‑5 ≥ 85 %, top‑1 ≥ 60 %, **ahorro de pulsaciones ≥ 35 %**); P1 toda plantilla insertada analiza sin errores nuevos; M1 p95 ≤ 50 ms |
| `APP.EDITOR.COMPLETION@0.1.0`         | experimental | R1 el editor consulta el servicio y no mantiene tablas paralelas; R2 cursor UTF‑16 ↔ UTF‑8 y rechazo dentro de pares sustitutos; R3 revisión monotónica y descarte de respuestas obsoletas; R4 perfil del pseudocódigo e idioma de interfaz independientes                                    |
| `TOOL.LSP.CAPABILITIES@0.1.0`         | estable      | `completionProvider` y resto de proveedores; no declara `onTypeFormattingProvider` ni formato *snippet*                                                                                                                                            |
| `APP.ENGINE.BOUNDARY`                 | —            | La app «no reimplementa análisis, ejecución, completado, semántica ni recorridos del lenguaje»                                                                                                                                                     |
| `LANG.SYNTAX.RECOVERY`                | —            | Un bloque sin cerrar produce **un** diagnóstico principal con tramo relacionado de apertura, sin cascada — base determinista para el autocierre                                                                                                    |
| `LANG.STMT.TERMINATION`               | —            | Estricto exige `;` incluso antes del cierre — base para el terminador automático                                                                                                                                                                   |

**Vacíos del corpus.** Ningún contrato define: (a) *tab stops* ni marcadores navegables; la plantilla es texto
plano y el marcador (`condicion`, `indice`) es un identificador legal; (b) asistencia al teclear (Enter tras una
apertura, realineado de cierres, pares `(`/`"`); (c) la presentación del completado en escritorio; (d) un ajuste
de usuario para activarlo; (e) ordenación dirigida por el tipo esperado; (f) inserción de llamadas a partir de la
firma.

### 1.2 Qué existe en el motor (`pseudolearn_service`, `pseudolearn_api`)

El núcleo **ya es headless y mayoritariamente completo** para R1–R5:

- `cursor_context` clasifica el cursor en `Inert | Member | TypeSlot | StatementStart | Expression` a partir de
  tokens y calcula la pila `open_blocks`.
- `completion_sources` / `completion_symbols` / `completion_members` extraen candidatos del `ServiceAnalysis`
  (variables visibles, campos, métodos, superclases, funciones de usuario y estándar).
- `completion_pool` ordena por `(nivel, no-exacto, etiqueta plegada, etiqueta)` y deduplica: determinista.
- `completion_keywords::keyword_entry` emite las estructuras como `CompletionKind::Snippet` con `insert_text`
  = plantilla de `completion_templates`.
- `template_validity` verifica P1. El servidor LSP (`pseudo lsp`) reutiliza la misma consulta.

Brechas del motor:

| # | Brecha                                                                                                                                                                                                   | Consecuencia                                                                                    |
|---|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------|
| M1 | Plantillas como `String` sin estructura: no hay *tab stops*, roles ni posición final                                                                                                                   | El cliente no puede seleccionar `condicion`; el marcador queda como variable no declarada       |
| M2 | La plantilla no conoce la sangría de la línea destino; la re-sangría vive en Dart (`RustSourceEditor._indentForInsertion`, comparando la primera palabra con `block_openers`)                           | Lógica de lenguaje duplicada en el cliente; un segundo editor tendría que copiarla              |
| M3 | No existe servicio de asistencia al teclear (Enter, cierres, pares, `;`)                                                                                                                                 | El «cierre automático de bloques» solo existe como candidato que hay que elegir                 |
| M4 | La API `complete` es sin estado: crea un `DocumentSession` por llamada; el editor además llama a `analyze` aparte                                                                                       | Dos análisis completos por pulsación; la sesión incremental del motor no se aprovecha en la app |
| M5 | `detail` se emite con prosa fija en el idioma del **perfil** («Estructura», «Cerrar bloque», «Equivalente de…»)                                                                                         | Contradice `APP.EDITOR.COMPLETION` R4 (la prosa sigue al idioma de interfaz)                    |
| M6 | Sin tipo esperado en el contexto: tras `Si`, en argumentos o en el lado derecho de `<-` el orden no considera compatibilidad                                                                            | Menor precisión top‑1 en expresiones                                                            |
| M7 | Funciones y subprocesos se insertan solo por nombre                                                                                                                                                      | El usuario teclea paréntesis y argumentos a mano                                                |
| M8 | LSP anuncia `insertText` plano (sin `insertTextFormat: 2`) y sin `onTypeFormattingProvider` ni `triggerCharacters`                                                                                     | El editor independiente no recibiría plantillas navegables                                      |

### 1.3 Qué existe en la app (`apps/pseudolearn_app`)

La tubería **sí está conectada**, pero la superficie visible es casi nula:

- `EditorCubit.updateSourceCode` y `updateCompletionCursor` consultan `ContextualCompletionSource`
  (`RustCompletionSource`) con revisión monotónica y conversión UTF‑16/UTF‑8: R1–R3 de `APP.EDITOR.COMPLETION`
  se cumplen.
- La **única** presentación es `EditorTemplateRow`, segunda fila **plegada** de `EditorKeyBar`.
- `EditorSurface._offersKeyBar` exige `canvas.isKeyboardVisible`, que es `viewInsets.bottom > 0`
  (teclado en pantalla), y `EditorState.showsKeyBar` nace de `hasOnscreenTextEntry`.
  **En escritorio el completado nunca se muestra**; en móvil exige desplegar la fila y tocar.
- `EditorKeyShortcuts` asigna `Tab` a sangrar; no hay `Ctrl+Espacio`, navegación de lista ni modo plantilla.
- `RustSourceEditor._applyCompletion` coloca el cursor al final del texto insertado y **no re-sangra** las
  plantillas multilínea (el camino `EditorKeyKind.template` sí lo hace, con lógica propia).
- `DevicePreferences` no tiene ajuste alguno de asistencia.

**Diagnóstico.** La brecha no es la ausencia del motor de completado, sino: (1) la falta de un *modelo de
edición estructurada* (plantillas con paradas, asistencia al teclear, aceptación con ediciones) en el núcleo, y
(2) la falta de una superficie de cliente que lo haga visible y operable por teclado. Además hay lógica de
lenguaje filtrada al cliente (M2) que debe volver al núcleo antes de que exista un segundo editor.

---

## 2. Modelo de separación de responsabilidades

### 2.1 Criterio

Pertenece al núcleo todo lo que dependa del texto, la gramática, el vocabulario, el análisis semántico o la
sangría canónica. Pertenece al cliente solo lo que dependa de píxeles, foco, teclas físicas o preferencias del
usuario. Prueba de corte: *si el editor independiente tuviera que reescribirlo, está en el lugar equivocado*.

| Núcleo (`pseudolearn_service`)                                                 | Cliente (app Flutter o editor independiente)                                   |
|--------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| Clasificación del cursor y tipo esperado                                       | Capturar pulsaciones y mapearlas a peticiones (`Ctrl+Espacio`, `Tab`, `Enter`)  |
| Candidatos, ordenación, deduplicación, pistas bilingües                        | Dibujar la lista emergente, el resaltado de paradas y su accesibilidad          |
| Plantillas estructuradas: texto, paradas, espejos, roles, parada final         | Ajuste «asistencia de edición» (desactivado por defecto) y decidir si pregunta  |
| Sangría de la inserción relativa a la línea destino                            | Convertir UTF‑16 ↔ UTF‑8 (ya existe `SourceOffsetIndex`)                         |
| Ediciones de aceptación (texto principal + ediciones adicionales)              | Descartar respuestas de revisiones obsoletas (ya existe)                        |
| Asistencia al teclear: autocierre, realineado, pares, terminador               | Aplicar la lista de ediciones devuelta al búfer, sin interpretarla              |
| Seguimiento de paradas activas bajo ediciones (`snippet session`)              | Localizar `detail_key` al idioma de interfaz                                    |
| Claves de detalle (`close_block`, `structure`, `bilingual_equivalent`)          | Temporización (debounce) y cancelación                                          |

### 2.2 Fachada única y dos transportes

```
                    pseudolearn_service
   ┌──────────────────────────────────────────────────┐
   │ EditAssist (fachada pura, sin E/S)                │
   │  complete · accept · on_type · navigate_stop      │
   │        ▲ usa DocumentSession (incremental)        │
   └────────┼───────────────────────────┼─────────────┘
            │                           │
   pseudolearn_api (FFI/Wasm)     lsp_session (JSON-RPC)
   recurso "edit_session"         completion + snippet,
            │                     onTypeFormatting,
     app Flutter                  completionItem/resolve
                                        │
                              editor independiente / VS Code
```

Ambos transportes serializan **la misma estructura**; el formato LSP de *snippet* (`${1:condicion}`) se deriva
de ella, nunca se escribe a mano (`GEN-NO-HAND-COPY` en espíritu).

### 2.3 Contrato de comunicación (API de la app)

Nuevo recurso con estado en `pseudolearn_api`, propiedad de la sesión y la revisión (`APP.ENGINE.BOUNDARY`):

| Operación               | Entrada                                                          | Salida                                                                  |
|-------------------------|------------------------------------------------------------------|-------------------------------------------------------------------------|
| `open_edit_session`     | `program`, `profile`, `strictness`                               | `session`, `revision`                                                    |
| `apply_edit`            | `session`, `revision`, `edits[{start_utf8,end_utf8,text}]`       | `revision` nueva, diagnósticos (sustituye al `analyze` paralelo)         |
| `complete`              | `session`, `revision`, `cursor_utf8`, `trigger` (`invoked\|typed\|character`) | `candidates[{id,label,kind,detail_key,detail_args,bilingual_origin}]`, `replace{start,end}` |
| `accept`                | `session`, `revision`, `candidate_id`                            | `Insertion` (ver §3.3)                                                   |
| `on_type`               | `session`, `revision`, `cursor_utf8`, `character`                | `edits[]`, `selection` opcional, `snippet` opcional                      |
| `navigate_stop`         | `session`, `revision`, `direction` (`next\|previous\|exit`)      | `selection{start,end}` o `exited`                                        |
| `release`               | `session`                                                        | —                                                                        |

Invariantes: toda respuesta lleva la `revision` a la que responde; una petición sobre revisión no vigente
devuelve `staleRevision` sin efectos; posiciones en UTF‑8 en el cable, UTF‑16 en el dominio Dart.
La operación `complete` sin estado actual se conserva para conformidad y compatibilidad.

---

## 3. Mecanismo de inferencia y completado

### 3.1 Resolución de contexto

`CursorContext` se amplía con una **ranura esperada** derivada de tokens previos y del árbol recuperado:

```
ExpectedSlot =
  | Statement   { open_blocks }                       // inicio de sentencia
  | Expression  { expected_type: Option<StaticType> }  // tras Si/Mientras → Logico; tras x <- → tipo de x
  | Argument    { callee, index, parameter_type }     // dentro de f( … , | )
  | Type                                               // tras Como / :
  | Member      { receiver_class }                     // tras p.
  | DeclarationName                                    // tras Definir / Para: no se ofrecen candidatos
  | Inert                                              // comentario o literal
```

El tipo esperado sale de `ServiceAnalysis` (tipos declarados o inferidos en flexible según
`LANG.TYPES.INFERENCE`); si el análisis no lo determina, es `None` y no altera el orden.

### 3.2 Tabla de símbolos y orden determinista

Visibilidad: un símbolo es candidato si su alcance contiene el cursor y su declaración comienza antes del
cursor (para subprogramas y clases de nivel superior, en cualquier punto del documento). Clave total de orden:

```
(nivel, compatibilidad_de_tipo, no_exacto, distancia_a_declaración, etiqueta_plegada, etiqueta)
```

- `nivel`: el actual (cierre del bloque, locales y miembros, estructuras, estándar, operadores, pistas).
- `compatibilidad_de_tipo`: 0 idéntico, 1 ampliable (Entero→Real, `LANG.TYPES.RELATIONS`), 2 sin dato,
  3 incompatible (se conserva pero al final; nunca se oculta).
- `distancia_a_declaración`: bytes entre la declaración y el cursor; favorece lo local sin depender del reloj ni
  del historial.

Coincidencia de prefijo ampliada para palabras compuestas: además de `starts_with`, se aceptan iniciales de
segmentos (`fm` → `FinMientras`, `ddm` → `De Otro Modo`) con un nivel de coincidencia inferior al prefijo
directo. Es determinista y reduce la verbosidad sin introducir abreviaturas en el lenguaje.

### 3.3 Plantillas estructuradas

Las plantillas dejan de ser `String` y pasan a un tipo del núcleo:

```rust
struct Template { construction: Construction, segments: Vec<Segment> }
enum Segment { Text(String), Keyword(KeywordKind), NewLine, Indent, Stop(StopSpec) , Final }
struct StopSpec { index: u8, role: StopRole, placeholder: MarkerKind, mirror_of: Option<u8> }
enum StopRole { NewIdentifier, Expression { expected: Option<TypeHint> }, Type, Body }
```

El renderizador produce, para un perfil y una sangría de línea:

```json
{
  "edit": {"start_utf8": 120, "end_utf8": 123, "text": "Mientras condicion Hacer\n    \n  FinMientras"},
  "additional_edits": [],
  "stops": [
    {"index": 1, "role": "expression", "ranges": [{"start": 9, "end": 18}]},
    {"index": 2, "role": "body", "ranges": [{"start": 29, "end": 29}]}
  ],
  "final_stop": 29,
  "lsp_snippet": "Mientras ${1:condicion} Hacer\n\t$0\nFinMientras"
}
```

Decisiones:

- **El marcador sigue siendo un identificador válido.** Así el árbol analiza sin errores mientras se rellena
  (se preserva P1) y el contexto de alcance funciona dentro de la plantilla. Lo que cambia es que el marcador
  es una parada seleccionada, no texto olvidado.
- **Espejos** (`mirror_of`) para nombres que se repiten; hoy ninguna plantilla los necesita, por `SCOPE-YAGNI`
  el campo solo se introduce si una construcción del corpus lo exige.
- **Sangría en el núcleo**: el renderizador recibe la sangría de la línea destino y la unidad de sangría del
  documento (la del formateador), y elimina `RustSourceEditor._indentForInsertion` del cliente (M2).
- **Llamadas desde la firma** (M7): aceptar un subproceso con parámetros genera
  `nombre(${1:param1}, ${2:param2})`; sin parámetros, `nombre()` con el cursor tras el paréntesis.
- **Sesión de plantilla**: el `EditSession` guarda las paradas activas y las desplaza con cada `apply_edit`;
  la sesión termina al salir de la última parada, al pulsar Esc o cuando una edición cae fuera de todas las
  paradas. Los clientes LSP usan su propio motor de *snippets* con `lsp_snippet`.

### 3.4 Asistencia al teclear (`on_type`)

Reglas deterministas, todas basadas en tokens, árbol recuperado y diagnósticos estructurales:

| Disparador     | Condición                                                                                       | Ediciones                                                                    |
|----------------|--------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------|
| `\n`           | La línea anterior abre un bloque y el análisis informa ese bloque como **no cerrado** (`LANG.SYNTAX.RECOVERY`) | Sangría +1 en la línea nueva e inserción del cierre canónico en la línea siguiente, alineado con la apertura |
| `\n`           | La línea anterior abre un bloque ya cerrado                                                      | Solo sangría +1                                                              |
| `\n`           | Perfil estricto y la línea anterior es sentencia simple completa sin `;`                         | Inserta `;` al final de la línea anterior                                    |
| fin de palabra | La palabra es un cierre o `Sino`/`De Otro Modo` mal sangrado                                    | Realinea con la apertura correspondiente                                     |
| `(` `"` `'` `[`| Cursor fuera de comentario y literal, y el siguiente carácter no es identificador                 | Inserta el par; teclear el cierre sobre un cierre insertado lo atraviesa     |

Propiedad exigible: aplicar `on_type` nunca aumenta el número de diagnósticos sintácticos respecto del texto
anterior a la pulsación, y es idempotente (no duplica un cierre ya presente).

### 3.5 Ajuste del usuario

`DevicePreferences.editorAssistance: bool = false` (preferencia de dispositivo, como tamaño de letra o
números de línea). Con el ajuste desactivado el cliente no emite `complete` con `trigger: typed`, ni `on_type`,
ni muestra la lista emergente; la invocación explícita (`Ctrl+Espacio` y la fila de plantillas existente) se
mantiene. El núcleo no conoce el ajuste: la decisión de preguntar es del cliente.

### 3.6 Presentación en el cliente

Dos formas de mostrar la misma respuesta del núcleo:

- **Sugerencia en línea (texto fantasma).** Es el texto gris tras el cursor que se acepta con `Tab`, como en
  los IDE con IA, pero sin modelo probabilístico. El núcleo marca un candidato como `inline` solo cuando es
  inequívoco: el cierre del bloque más interno en una línea vacía, o un único candidato que coincide con el
  prefijo. Si la respuesta no trae ningún candidato `inline`, no se muestra texto fantasma. Las plantillas se
  muestran en línea solo en su primera línea; al aceptarlas se insertan completas y se entra en modo plantilla.
- **Lista de candidatos.** Aparece al escribir dos caracteres en una ranura con candidatos o al invocarla.

Escritorio: lista emergente anclada al cursor; flechas para recorrerla, `Enter` o `Tab` para aceptar, `Esc` para
cerrar, `Ctrl+Espacio` para invocar. En modo plantilla, `Tab` y `Mayús+Tab` saltan entre paradas y la parada
activa se resalta.

Móvil (iPhone, Android): no hay `Tab` ni `Ctrl+Espacio` y una lista flotante taparía el código. Se usa la barra
sobre el teclado que ya existe (`EditorKeyBar`):

- La fila de candidatos deja de estar plegada y se muestra mientras hay candidatos, al estilo de la barra
  predictiva de iOS; el primero es el mejor y se acepta con un toque.
- El texto fantasma se acepta tocándolo o con una tecla «aceptar» de la barra.
- En modo plantilla, la barra muestra «anterior» y «siguiente» parada y «terminar».
- `Enter` del teclado del sistema dispara la asistencia al teclear igual que en escritorio.
- El campo de código desactiva la autocorrección, las sugerencias y las comillas y guiones tipográficos del
  sistema. Hoy `CodeField` no lo hace: en iOS, `"` se convierte en `“` y el corrector puede reescribir palabras
  clave o identificadores.

---

## 4. Plan de trabajo técnico

Cada fase sigue especificación → casos → tests → código, actualiza el README del paquete en el mismo cambio,
cierra en verde (`PHASE-GREEN`) y se detiene (`PHASE-STOP`).

| Fase | Paquete                       | Alcance                                                                                                                                                                                                                                       | Cierre                                                                     |
|------|-------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| F0   | `pseudolearn_spec`            | Reglas y casos nuevos dentro de `0.1.0`: `TOOL.SERVICE.COMPLETION` (paradas, roles, sangría, tipo esperado, llamadas por firma, `detail_key`), contrato nuevo `TOOL.SERVICE.ON-TYPE@0.1.0`, `TOOL.LSP.CAPABILITIES` (`insertTextFormat`, `onTypeFormattingProvider`), `APP.EDITOR.COMPLETION` (ajuste desactivado por defecto, lista emergente, navegación de paradas). `see lock --refresh` sin cambiar versiones | `see validate`, `see lock --check`, `see export --check`                   |
| F1   | `pseudolearn_service`         | Tipo `Template` estructurado, renderizador con sangría, `stops`, `final_stop`, `lsp_snippet`; P1 ampliada: cada parada cae sobre un token del rol declarado                                                                                  | `cargo xtask verify`, `see conform --subject service`                      |
| F2   | `pseudolearn_service`         | `ExpectedSlot`, tipo esperado, nueva clave de orden, coincidencia por iniciales, aceptación con firma; marca `inline` para candidatos inequívocos; `detail_key` en lugar de prosa (M5)                                                                                                    | Conformidad + mediciones E09 (top‑1, top‑5, ahorro de pulsaciones)          |
| F3   | `pseudolearn_service`         | `on_type` y sesión de plantilla (`navigate_stop`); propiedades de no regresión sintáctica e idempotencia                                                                                                                                       | Conformidad de propiedades                                                  |
| F4   | `pseudolearn_api`, LSP, CLI   | Recurso `edit_session` incremental; paridad LSP (`insertTextFormat: 2`, `onTypeFormatting`, `triggerCharacters: ["."]`); M1 medido sobre la sesión incremental                                                                                | `cargo xtask verify` del motor y la CLI; latencia p95                      |
| F5   | `pseudolearn_app`             | Ajuste en `DevicePreferences` y pantalla de ajustes (l10n es/en); puerto `EditAssistSource` en `domain/ports`; adaptador en `engine/rust`; texto fantasma; lista emergente en escritorio y fila de candidatos y paradas visible en la barra móvil; campo de código sin autocorrección ni puntuación tipográfica; atajos `Ctrl+Espacio`, `Tab`/`Mayús+Tab` en modo plantilla, Esc; eliminación de la re-sangría en Dart | Suite completa, test de arquitectura, `see conform --subject app`           |
| F6   | Transversal                   | Campaña de medición en ambos idiomas y actualización de resultados                                                                                                                                                                             | Umbrales de R6 y M1 en verde                                                |

F1–F3 son independientes del cliente; el editor independiente puede consumir el LSP desde el cierre de F4.

---

## 5. Conflictos resueltos

La persona confirmó los conflictos y resolvió por instrucción directa, que tiene precedencia sobre
`AGENTS.md` (`CONFLICT-REPORT` cumplido). Ninguna fase se inicia con esta resolución.

| # | Conflicto                                                                                       | Resolución vinculante                                                                                                                                                                                                                                                                       |
|---|-------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 1 | `SPEC-CHANGE-CLASSIFIED` exige registrar clasificación e impacto; la instrucción prohíbe campos de cambio | No se añaden campos `cambio`, diferencias ni notas de versión. Los bloques `cambio` que ya existen en los contratos se conservan intactos. Si `see validate` o `see diff` exigen el registro para los ajustes, se reporta en la fase F0 antes de modificar el verificador |
| 2 | Ampliar contratos `estable` sin cambiar versión                                                 | Las versiones están congeladas: los ajustes se redactan como parte integral de `0.1.0` en los contratos existentes (`TOOL.SERVICE.COMPLETION`, `TOOL.LSP.CAPABILITIES`, `APP.EDITOR.COMPLETION`), con `see lock --refresh` de los identificadores afectados. Lo que no tenga contrato dueño, como la asistencia al teclear, nace en `0.1.0` |
| 3 | `APP.EDITOR.COMPLETION` R4 frente a la prosa del núcleo en el idioma del perfil (M5)            | El núcleo emite claves de detalle con argumentos; el cliente las localiza al idioma de interfaz                                                                                                                                                                                             |
| 4 | Alcance del ajuste desactivado                                                                  | Desactivado por defecto. Apaga solo los comportamientos no solicitados (lista y sugerencia en línea mientras se teclea, asistencia al teclear). La invocación explícita y la fila de plantillas actual siguen disponibles                                                                    |

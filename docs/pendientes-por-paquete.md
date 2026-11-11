# Pendientes por paquete

Registro único de los pendientes técnicos de cada paquete y app, a resolver más adelante. Cada sección se alimenta al reescribir el README del paquete correspondiente. Antes de actuar sobre un pendiente hay que contrastarlo con el código, porque pudo resolverse o cambiar.

## pseudolearn_engine

Confirmados contra el código:

- El backend nativo (`aot`) está exento de traza, estado y entrada incremental (`ENG.INPUT#R3` e `IR.OBSERVATION-POINTS#R3` figuran `exento` en `conformance-aot.yaml`).

Heredados de un README anterior, sin confirmar:

- Persistencia histórica completa de tareas.
- Registro concurrente de efectos abandonados: `pseudolearn_aot_rt` ya tiene lógica de efectos abandonados, así que puede estar resuelto en parte.
- El ejecutable nativo distribuido no enlazaría anfitrión físico (sus efectos terminarían `interrumpido`): `pseudolearn_aot_rt` tiene un `physical_provider`, así que puede estar obsoleto.
- El nivel optimizado del backend nativo está fuera del contrato: ningún backend lo implementa.

## pseudolearn_rust_checks

Heredados de un README anterior, sin confirmar:

- La licencia de publicación del paquete es una decisión pendiente (hoy `publish = false`; el directorio ya contiene `LICENSE` y `NOTICE`, así que puede estar resuelto).

## pseudolearn_benchmarks

Heredados de un README anterior, sin confirmar:

- El benchmark del agente (`tool/agent_benchmark.dart run`) nunca se ha ejecutado contra el proveedor real; espera la autorización de la persona.
- Los datos de fotogramas siguen ausentes hasta su captura en plataforma, y las campañas de macOS e iOS aguardan autorización para medir.
- El presupuesto vigente de la biblioteca ios-arm64 es 8 MiB (ampliado con autorización) y el de Wasm 900 KiB; contrastar con `PERF.*` del corpus.

## pseudolearn_spec

Heredados de un README anterior, sin confirmar:

- Vínculos de los contratos de tareas, canales, aislamiento, memoria y depuración (DAP) que permanecían `pendiente` de conformidad en ambos sujetos.
- Propiedades sin generador propio: ida y vuelta ISO de `LIB.TIME` (hoy solo cubierta por el caso `C15`) y ida y vuelta de `Decimales` sobre reales sembrados (hoy solo casos fijos).
- No existe exportador de las operaciones D2 de formato de números a otros lenguajes; se declara «sin equivalente».
- `LIB.HTTP#R6` y su caso `C8` discrepan sobre la reproducción de cintas con credenciales redactadas; falta resolverlo en el contrato.
- Los esperados de `TOOL.FORMAT.STYLE` C5–C7 y `TOOL.TRANSLATE.ROUND-TRIP` C5 no llevan `revisado_por` y requieren revisión humana independiente.
- El caso `LIB.IO` de incertidumbre en `Renombrar` solo se cubre en una prueba de `pseudolearn_api` porque la búsqueda por evento no soporta aún un efecto fallido incierto.

## pseudolearn_cli

Confirmados contra el código:

- Varios vínculos `pendiente` de `conformance.yaml` resuelven en `adaptador-dap-y-depuracion`: el sujeto `cli` aún no verifica las reglas de depuración que lo usan.
- `architecture.yaml` lista `hyper`, `tokio`, `rustls`, `http`, `bytes` y otras en `external_dependencies`, pero `Cargo.toml` del miembro no las declara; el transporte vive en `pseudolearn_host`. La lista parece desfasada.

Heredados de un README anterior, sin confirmar:

- La ayuda (`--ayuda`) no lista `bloquear`, `--proyecto` ni `--entrada`, porque el caso de ayuda vigente fija su texto exacto; requiere decisión de la persona sobre ese esperado.
- Las dependencias `locked` (con digest) no se leen desde disco: el lock que escribe `bloquear` registra solo paquetes locales.
- `ejecutar --nativo` y el sujeto `aot` no implementan `error_ranges` (salida de error por tramos).
- `ejecutar --nativo` no ofrece anfitrión físico completo.
- La paridad nativa de registros, genéricos, variantes y liberación por ámbito queda pendiente de la paridad del sujeto nativo; sus programas de aceptación no se ejecutan en nativo.
- Verificación de ejecución de los programas de aceptación de la biblioteca solo en macOS arm64; Linux y Windows no se ejecutaron localmente.

## pseudolearn_reference

Confirmados contra el código:

- La comilla (`quote`) está excluida de la cobertura de vocabulario en `coverage-exclusions.json`.

Heredados de un README anterior, sin confirmar:

- La categoría de resaltado (`categories.json`) debería salir del corpus como propiedad propia.
- Los textos entre comillas de los programas no se traducen en la edición inglesa.
- Las aserciones estructurales de los ejercicios se validan en su forma, no contra la referencia, porque el puerto del motor no publica la vista del programa.
- La ruta no verifica mecánicamente que «La herramienta nueva» aparezca cuando una lección introduce una construcción.

## pseudolearn_brand

Confirmados contra el código:

- La app no tiene `android/app/src/main/res` (sin `mipmap` de Android) ni `web/icons`; el README anterior los daba por pendientes.

Heredados de un README anterior, sin confirmar:

- Los íconos de iOS y macOS se generan localmente desde la geometría Dart y se validan con `xcrun actool`; no se ejecutó esa validación al reescribir el README.
- Las medidas de la marca existen en Python y en Dart (la app las redibuja); `BRAND-DART-DRIFT` solo vigila las constantes declaradas como `static const` en `brand_metrics.dart`.

## pseudolearn_store_media

Confirmados contra el código:

- Los perfiles de recorte del encabezado y la búsqueda por dispositivo (`ViewportProfile`) existen como mecanismo, pero
  todavía no hay datos medidos: se miden en Preview de App Store Connect durante F4.
- El locale de español neutro de Microsoft Store está fijado provisionalmente en `es-MX`; falta confirmarlo contra el
  Centro de partners.
- La voz sonora (`CALIBRATION_VOICE`) es de calibración; la definitiva se decide con la persona.

## pseudolearn_backend

Confirmados contra el código:

- `supabase/deferred/20260914000002_drop_delete_account.sql` sigue sin moverse a `supabase/migrations/`: elimina `public.delete_account()` y espera a que se publique el build de `apps/pseudolearn_app` que invoca `delete-account`.
- `architecture.json` solo declara `file_lines`; el tamaño de función no se verifica mecánicamente.

Heredados de un README anterior, sin confirmar:

- Prueba en sandbox de App Store y de Paddle con productos, URLs de notificación y un build firmado; los tests cubren firmas y contratos con datos de prueba.
- Confirmar en sandbox que la suscripción de Paddle hereda `custom_data.user_id` de la transacción; si no, el primer evento queda sin dueño.
- Medir el consumo real de créditos por `turn_id` en `agent_ledger_events` para confirmar los 300 créditos del plan.
- Segundo proveedor de modelo mediante otro `ModelGateway`.
- Prueba de extremo a extremo de `delete-account` contra Apple real.

## pseudolearn_web

Heredados de un README anterior, sin confirmar:

- El instalador de Windows de descarga directa no lleva firma Authenticode; la guía de SmartScreen de la descarga directa depende de ello.

Confirmados con la versión 2.0.0:

- VS Code y la terminal se anuncian como «Próximamente» sin enlace de descarga; al publicar la extensión o binarios de `pseudo`, sus tarjetas pasan a disponibles con su acción.
- No hay captura de VS Code: el generador de la app no la produce y no se versiona ninguna a mano.
- `entities/nodo-plan` repite las constantes de créditos y días del backend; no hay un artefacto generado que las comparta.
- `NodoGlyph` repite la geometría del glifo de la app; debería pasar al motor de marca junto al símbolo.
- La fecha de 2.0.0 en `CHANGELOG.json` es provisional (2026-11-09) hasta el día real de publicación en las tiendas.
- Los programas de la ruta en la edición inglesa conservan identificadores y textos en español (el código se escribe una vez y solo se traduce el vocabulario). La web ya no los muestra; afecta a la app en inglés; corregirlo es trabajo de contenido en `packages/pseudolearn_reference/route/en`.
- Los productos de App Store Connect y Paddle deben existir con los identificadores `pseudolearn.nodo.*` antes de publicar.

## pseudolearn_vscode

Confirmados contra el código:

- `pnpm package` incluye en el VSIX de escritorio cualquier archivo bajo `dist/`, porque `allowedPrefixes` admite `dist/` completo; un `dist/web/test/index.js` residual de una compilación local entró en el VSIX de prueba. El contrato debería limitar el prefijo de escritorio a `dist/extension.js`.

Heredados de un README anterior, sin confirmar:

- Las verificaciones pesadas en VS Code real (completar, diagnosticar, navegar, renombrar, ejecutar con entrada, detener y limpieza tras cierre) y la ayuda desde un segundo cliente quedan pendientes.
- Escribir un valor concreto en el cuadro de entrada de `Leer` y en el selector de entrada se comprueba a mano; la automatización solo acciona comandos del workbench.
- Campañas de host web completas, evidencias reales de navegador, resultados de medición y revisión de cobertura quedan pendientes; las comprobaciones puntuales no los certifican.
- Firefox, WebKit y Windows no se verificaron; el escenario de propósito general del host web no se ejecutó en Firefox.
- El camino exitoso de HTTP en el host web se ejerce sobre HTTP: Chromium y WebKit rechazan el certificado autofirmado, así que no hay cobertura de TLS exitoso.
- El kit físico de medición (32 combinaciones) no tiene resultados: «no evaluado físicamente»; WebKit no equivale a Safari en iPhone.
- La métrica normativa nueva del benchmark web permanece sin aprobación.
- El código de salida de la consola (`console_set_exit_code`) se valida pero el presentador web no lo usa, y la salida de error no tiene estilo propio.

## pseudolearn_app

Confirmados contra el código:

- No existe la carpeta `web/`; solo hay `ios/`, `macos/` y `windows/`. El comportamiento en navegador, incluida la barra de teclas sin teclado físico, no está verificado.

Heredados de un README anterior, sin confirmar:

- Purga local sin lápidas en «Cerrar sesión y borrar datos de este dispositivo»: `AccountCubit.signOut(deleteLocalData: true)` borraría por `SyncingDocumentRepository`, que encola una lápida por documento.
- Inicio de sesión en la nube desde el `.zip` portable de Windows: falta registrar `pseudolearn://` en `HKCU` o avisar en la descarga de que el portable solo sirve sin cuenta.
- Firma Authenticode del instalador directo de Windows (Inno Setup).
- Petición de reseña en Microsoft Store: `in_app_review` solo ofrece el diálogo nativo en iOS y macOS.
- Campaña de medición E-NR2 con muestras independientes en dispositivo, escritorio y navegador.
- Pruebas de widgets con el puente real: los widgets se prueban con fakes.
- Valor de un parámetro `Canal` en la vista Variables: se muestra aplanado como `stream.identity = Nulo`; la API debería publicarlo como valor propio.
- Capturas de producto y material de tiendas regenerados con la ruta de aprendizaje; las imágenes versionadas muestran la base de conocimiento anterior.
- Ancla interior al seguir un enlace de especificación desde la ruta: `ReferenceSectionPage` no desplaza a ella.
- Compras reales del agente: falta la compra de prueba en sandbox de App Store y de Paddle con un build firmado.
- Clave del proveedor del agente (`OPENAI_API_KEY` en el servidor y `AGENT_BACKEND=proxy`, `AGENT_PROXY_URL` al compilar); sin ella el agente responde «no disponible».
- Enlaces externos en las respuestas del agente: se muestran pero no se abren.
- Diagramas Mermaid del chat distintos de `flowchart`: se muestran como código.
- Medición del agente con `packages/pseudolearn_benchmarks` contra el gateway real; requiere autorización.
- Ampliar el código equivalente según los pendientes del transpilador.
- Los vínculos `pendiente` de `conformance.yaml` esperan la proyección de eventos de tarea para la app (`resuelve_en: eventos-de-tarea-para-app`).

---

# Plan de ejecución (una sola iteración)

Objetivo: que un agente lleve **cada pendiente de arriba a un estado final** en una sola pasada: o bien lo resuelve en código/corpus/README, o bien demuestra con evidencia que ya no es válido y lo elimina, o bien lo deja marcado como bloqueado por algo externo que solo la persona puede aportar. Ningún pendiente queda «sin confirmar».

## 0. Reglas de ejecución

Respetar `AGENTS.md` sin excepciones. Lo que más se incumple:

- **Orden de lectura por paquete** antes de tocar archivos: `README.md` del paquete, luego su `architecture.yaml`/`architecture.json`, y responder las tres preguntas del §1 de `AGENTS.md`.
- **Rama única**: `feature/agregar-ruta-de-especificacion` (`GIT-SINGLE-BRANCH`). Sin ramas nuevas; push ordinario al cerrar.
- **Árbol sucio de partida**: hay cambios sin commitear en `packages/pseudolearn_engine/crates/pseudolearn_service` y en `tool.service.completion.md`. No revertirlos ni mezclarlos: no tocar esos archivos salvo que un pendiente lo exija, y commitear lo propio por separado.
- **Idioma**: código, tests y commits en inglés; README, corpus y este documento en español. Cero comentarios en código (`QUALITY-NO-COMMENTS`); el porqué va al README del paquete.
- **Corpus**: especificación → casos → tests → código. Versiones y estados congelados (`SPEC-VERSION-FREEZE`): se edita el texto oficial sin campos `cambio` y se reancla. Los esperados se derivan de la regla, no de la salida del código (`SPEC-INDEPENDENT-ORACLE`).
- **Sin coautoría ni atribución de IA** en los commits (lo fija `AGENTS.md` §9).
- **Edición quirúrgica**: nada de `dart format`, formateadores ni ida y vuelta de JSON sobre archivos existentes. Nada de bucles de sondeo: las tareas largas van en segundo plano y se espera su notificación.
- **Conflictos entre fuentes** (`CONFLICT-REPORT`): no se resuelven en silencio; se anotan en el informe final con la propuesta y se sigue con el resto.
- **YAGNI**: si ninguna regla ni fase pide lo que el pendiente describe, la resolución correcta es documentar la decisión en el README y borrar el pendiente, no implementarlo.

### Disco y pruebas

- Pruebas **acotadas**: solo las del paquete tocado y sus verificadores (`Cómo se verifica` de su README). No se ejecutan campañas de medición, benchmarks completos, matrices de plataforma ni suites de toda la raíz. Si una prueba no cabe en unos pocos minutos, se corre su subconjunto relevante y se anota lo no ejecutado.
- Antes de cada lote pesado (compilar Rust/Flutter, `pnpm install`, empaquetar) ejecutar `df -h /`. Si quedan menos de ~15 GiB libres, o una prueba falla por falta de espacio, **liberar y reintentar**: solo cachés regenerables, de a un directorio, empezando por lo más grande (`cargo clean` en el miembro Rust que se terminó de usar, `target/` residuales, `build/` y `.dart_tool/` de Flutter, `dist/` y `.vite` de web/VS Code, `~/Library/Developer/Xcode/DerivedData`, cachés de `pnpm`/`cargo`/`deno` que se vuelvan a descargar). Nunca borrar código, corpus, `*.lock` versionados, datos de la persona ni artefactos que no se puedan regenerar. Anotar en el informe qué se limpió.

## 1. Fase A — Triage de todos los pendientes (primero, sin editar código)

Para **cada** viñeta de este documento, en este orden de paquetes, contrastarla contra el código actual (búsqueda de símbolos, lectura de los archivos de conformidad, `Cargo.toml`, `pubspec.yaml`, contratos y README vigente) y clasificarla en una de cuatro categorías. Registrar la tabla en el directorio temporal de la sesión (no en el repositorio):

| Categoría | Significado | Acción |
|---|---|---|
| **Obsoleto** | El código o el corpus ya lo resolvió, o la premisa es falsa | Eliminar la viñeta; si hay trazas en README o conformidad, corregirlas |
| **Vigente-resoluble** | Sigue siendo cierto y un agente puede cerrarlo con cambios en el repo | Fase B |
| **Vigente-decisión** | Cierto, pero la solución depende de una decisión de producto o del corpus que no está escrita | Elegir la opción mínima coherente con el corpus y el README si es inequívoca; si no, `CONFLICT-REPORT` y seguir |
| **Bloqueado-externo** | Exige credenciales reales, dispositivos, certificados, tiendas, autorización explícita de la persona o revisión humana independiente | Dejar listo todo lo previo (scripts, documentación, pruebas con datos de prueba) y registrar la acción exacta de la persona |

Heredados «sin confirmar»: la clasificación inicial se decide por evidencia, no por lo que dice este documento. Pistas ya detectadas que conviene comprobar primero: `physical_provider` en `pseudolearn_aot_rt`, lógica de efectos abandonados en `pseudolearn_aot_rt`, `LICENSE`/`NOTICE` en `pseudolearn_rust_checks`, ausencia de `android/app/src/main/res` y `web/icons`.

## 2. Fase B — Resolución por lotes (orden por dependencias)

Cada lote termina con sus verificadores en verde antes de pasar al siguiente (`PHASE-GREEN`). Si un lote queda bloqueado, se registra y se continúa con el siguiente.

**Lote 1 · `pseudolearn_spec` (corpus, base de todo lo demás)**
- Cerrar vínculos `pendiente` de conformidad que ya tengan sujeto implementado; los que dependan de lotes posteriores se cierran al final de este plan (Lote 8 y cierre).
- Añadir generadores propios: ida y vuelta ISO de `LIB.TIME` y de `Decimales` sobre reales sembrados.
- D2 de formato de números: o exportador, o declaración «sin equivalente» ya vigente → decidir por `SCOPE-YAGNI` y documentar.
- `LIB.HTTP#R6` vs caso `C8`: derivar el esperado de la regla; si la regla misma es ambigua, `CONFLICT-REPORT`.
- Caso de `LIB.IO` con `Renombrar` incierto: extender la búsqueda por evento para efectos fallidos inciertos y mover la cobertura desde la prueba de `pseudolearn_api` al corpus, si es viable sin romper la frontera de capas.
- `revisado_por` de `TOOL.FORMAT.STYLE` C5–C7 y `TOOL.TRANSLATE.ROUND-TRIP` C5: **bloqueado-externo** (revisión humana independiente). No inventar el revisor.
- Verificar con `see validate` y los verificadores del README.

**Lote 2 · `pseudolearn_engine`**
- Backend `aot`: si sigue exento de traza, estado y entrada incremental, implementarlo y pasar `ENG.INPUT#R3` e `IR.OBSERVATION-POINTS#R3` a verificado en `conformance-aot.yaml`; si el costo rompe límites de tamaño/capas, dividir en archivos nuevos.
- Persistencia histórica de tareas, registro concurrente de efectos abandonados y proveedor físico del ejecutable nativo: comprobar contra `pseudolearn_aot_rt`; implementar lo que falte, borrar lo resuelto.
- Nivel optimizado del backend nativo: sin backend ni regla que lo pida → decisión documentada en el README y fuera de pendientes.
- Actualizar `architecture.yaml` si aparecen archivos o capas nuevas; correr los verificadores del paquete (comentarios, nombres, `unsafe` con su tabla de invariantes).

**Lote 3 · `pseudolearn_cli` y `pseudolearn_rust_checks`**
- `cli`: resolver `error_ranges` y anfitrión físico completo en `ejecutar --nativo` (depende del Lote 2); paridad nativa de registros, genéricos, variantes y liberación por ámbito; lectura de dependencias `locked` con digest y escritura correspondiente en `bloquear`; cerrar vínculos `pendiente` de DAP y depuración cuando el sujeto ya los verifique.
- Ayuda `--ayuda`: añadir `bloquear`, `--proyecto` y `--entrada` **solo si** el caso vigente se actualiza en el corpus (Lote 1) con esperado derivado de la regla; si la regla fija el texto, `CONFLICT-REPORT`.
- Alinear `external_dependencies` de `architecture.yaml` con el `Cargo.toml` real del miembro.
- Programas de aceptación de la biblioteca: ejecutar en macOS arm64; Linux y Windows quedan **bloqueado-externo** salvo que haya acceso.
- `rust_checks`: licencia de publicación. Si `LICENSE` y `NOTICE` existen y son coherentes con `publish = false`, documentar la decisión y borrar el pendiente; si no, preguntar a la persona (decisión legal).

**Lote 4 · `pseudolearn_reference`**
- Sacar `categories.json` del corpus como propiedad propia; resolver o justificar la exclusión de `quote` en `coverage-exclusions.json`.
- Traducir los textos entre comillas de los programas de la edición inglesa (y los identificadores en español de `route/en`, ver Lote 7); validar aserciones estructurales contra la vista del programa si el motor ya la publica.
- Añadir la verificación mecánica de «La herramienta nueva» cuando una lección introduce una construcción, con su caso negativo.

**Lote 5 · `pseudolearn_brand` y `pseudolearn_store_media`**
- `brand`: borrar el pendiente de `mipmap`/`web/icons` si se confirma que ya no aplica; ejecutar la validación con `xcrun actool` (local, ligera) y cerrar el pendiente; evaluar si `BRAND-DART-DRIFT` puede vigilar también las medidas no `static const` sin sobrecomplicar.
- `store_media`: perfiles de recorte medidos en App Store Connect y locale `es-MX` de Microsoft Store son **bloqueado-externo**; la voz definitiva de `CALIBRATION_VOICE` es **decisión de la persona**.

**Lote 6 · `pseudolearn_backend`**
- Mover `supabase/deferred/20260914000002_drop_delete_account.sql` a `supabase/migrations/` **solo si** el build de `pseudolearn_app` que invoca `delete-account` ya está publicado; si no, dejarlo y registrarlo como bloqueado por publicación.
- Añadir verificación mecánica de tamaño de función a `architecture.json` (hoy solo `file_lines`) o reconocer la limitación en el README si el intérprete del paquete no lo soporta sin dependencias nuevas.
- Medir consumo de créditos por `turn_id` con un script sobre datos de prueba; sandbox de App Store y Paddle, `custom_data.user_id`, prueba real de `delete-account` contra Apple y segundo `ModelGateway` real: **bloqueado-externo** (credenciales y cuentas). El segundo proveedor solo se implementa si una fase aprobada lo pide (`SCOPE-YAGNI`).

**Lote 7 · `pseudolearn_web` y `pseudolearn_vscode`**
- `web`: compartir constantes de créditos y días con el backend mediante un artefacto generado (`GEN-NO-HAND-COPY`); mover la geometría de `NodoGlyph` al motor de marca; corregir los programas de la ruta en inglés (trabajo de contenido en `packages/pseudolearn_reference/route/en`, coordinado con el Lote 4).
- `web`: fecha provisional de 2.0.0, tarjetas «Próximamente», captura de VS Code, firma Authenticode e identificadores `pseudolearn.nodo.*` en las tiendas: **bloqueado-externo** (publicación y cuentas).
- `vscode`: limitar `allowedPrefixes` de escritorio a `dist/extension.js` con su caso negativo (un `dist/web/test/index.js` residual no debe entrar al VSIX); usar `console_set_exit_code` en el presentador web y dar estilo a la salida de error.
- Verificaciones en VS Code real, Firefox/WebKit/Windows, kit físico de 32 combinaciones, TLS exitoso y aprobación de la métrica normativa: **bloqueado-externo**.

**Lote 8 · `pseudolearn_app` (último, consume los demás)**
- Purga local: hacer que `AccountCubit.signOut(deleteLocalData: true)` no encole lápidas por documento (operar por debajo de `SyncingDocumentRepository`), con pruebas de camino feliz e infeliz.
- Valor del parámetro `Canal` en Variables: publicarlo como valor propio en la API y mostrarlo en la vista.
- Ancla interior de `ReferenceSectionPage` al seguir un enlace de especificación.
- Enlaces externos en respuestas del agente: abrirlos con control de esquema seguro; diagramas Mermaid que no sean `flowchart`: renderizarlos o degradar con mensaje claro.
- Pruebas de widgets con el puente real, donde se pueda sin infraestructura pesada; el resto sigue con fakes y se anota.
- Ampliar el código equivalente según el transpilador (dependiente del Lote 2/3); proyección de eventos de tarea para la app (`eventos-de-tarea-para-app`) y cierre de sus vínculos `pendiente`.
- Registrar `pseudolearn://` en `HKCU` desde el portable de Windows, o avisar en la descarga de que el portable solo sirve sin cuenta; decidir por el menor costo coherente.
- Directorio `web/` de la app: decidir si se soporta navegador; si no hay fase que lo pida, documentarlo como fuera de alcance.
- Capturas y material de tiendas regenerados con la ruta de aprendizaje, reseña en Microsoft Store, E-NR2, compras reales, clave del proveedor del agente y medición con `pseudolearn_benchmarks`: **bloqueado-externo** (autorización, credenciales o dispositivos).
- `pseudolearn_benchmarks`: dejar listo `tool/agent_benchmark.dart run` y sus presupuestos coherentes con el corpus `PERF.*`; ejecutarlo contra el proveedor real solo con autorización explícita; fotogramas y campañas de macOS/iOS: **bloqueado-externo**.

## 3. Fase C — Cierre

1. Reescribir el README de cada paquete tocado con la skill `rewrite-package-readme`, dentro del **mismo cambio** que el código (`DOC-README-TRUTH`), actualizando su sección de pendientes declarados con lo que realmente queda.
2. Reducir este documento: eliminar toda viñeta resuelta u obsoleta; las que sigan deben pertenecer a **Bloqueado-externo** o **Vigente-decisión**, cada una con la acción exacta de la persona. Si no queda ninguna en un paquete, retirar su sección.
3. Ejecutar los verificadores de cada paquete tocado (comentarios, límites, arquitectura, nombres, `see validate`, pruebas) y la puerta de referencias transitorias (`DOC-NO-TRANSIENT-REFS`).
4. Commits por paquete, mensajes en inglés con la skill `commit-message`, sin atribución de IA; push ordinario a la rama única y comprobar que llegó.
5. Informe final en español (en el chat): tabla con cada pendiente y su categoría final, qué se cambió, qué verificadores y pruebas se ejecutaron, qué **no** se ejecutó y por qué, qué espacio se liberó, y la lista consolidada de acciones que solo la persona puede hacer.

## 4. Criterios de «hecho»

- Ninguna viñeta de este documento queda como «heredado sin confirmar».
- Todo lo resoluble desde el repositorio está resuelto, con pruebas de camino feliz e infeliz y verificadores en verde.
- Lo no resoluble está en una lista corta de bloqueos, cada uno con quién lo desbloquea y cómo.
- READMEs, corpus, `architecture.*` y conformidad coinciden con el código; sin comentarios, sin `TODO`, sin documentos citados desde el código.
- Todo publicado en `feature/agregar-ruta-de-especificacion`.

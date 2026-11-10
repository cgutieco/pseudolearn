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

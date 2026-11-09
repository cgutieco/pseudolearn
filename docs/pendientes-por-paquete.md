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

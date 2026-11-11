# Pendientes por paquete

Registro único de lo que sigue abierto en cada paquete y app. Cada viñeta es una de dos cosas: una acción que solo la persona puede hacer (credenciales, dispositivos, tiendas, autorización o revisión humana independiente) o una decisión que el corpus y los README todavía no toman. Todo lo demás se resolvió, se retiró por obsoleto o quedó documentado como decisión en el README del paquete. Antes de actuar sobre una viñeta hay que contrastarla con el código.

## pseudolearn_engine

Decisión pendiente:

- La agenda de tareas y sus colas no se guardan en las imágenes históricas (`MachineImage`): la consulta del pasado con tareas se reconstruye por reproducción de la cinta. Ninguna regla del corpus exige la imagen completa, así que no se implementa; si se quisiera, primero hay que aprobar la regla y la fase.

## pseudolearn_spec

Bloqueado por revisión humana independiente:

- Los esperados de `TOOL.FORMAT.STYLE` C5–C7 y `TOOL.TRANSLATE.ROUND-TRIP` C5 no llevan `revisado_por`. Acción: que otra persona los revise y los firme; el agente no inventa revisor.

Decisión pendiente:

- El caso `LIB.IO` de incertidumbre en `Renombrar` solo se cubre en una prueba de `pseudolearn_api`, porque la búsqueda por evento no soporta un efecto fallido incierto. Mover la cobertura al corpus exige extender esa búsqueda (cambio de motor y de la regla de consulta del pasado).

## pseudolearn_cli

Bloqueado por máquinas:

- Los programas de aceptación de la biblioteca solo se ejecutaron en macOS arm64. Acción: correrlos en Linux y en Windows (`cargo test`).

## pseudolearn_reference

Decisión pendiente:

- Los programas de la ruta en la edición inglesa conservan identificadores y textos entre comillas en español, porque cada programa se escribe una vez. Corregirlo exige duplicar unos 400 programas por edición con su salida verificada. Acción: decidir si se autoriza ese trabajo de contenido.
- Las aserciones estructurales de los ejercicios se validan en su forma, no contra la referencia, porque el puerto `CodeEngine` no publica la vista del programa. Acción: aprobar que el puerto exponga `API.PROGRAM.VIEW`.

## pseudolearn_store_media

Bloqueado por cuentas de tienda:

- Los perfiles de recorte del encabezado y la búsqueda por dispositivo (`ViewportProfile`) existen como mecanismo sin datos medidos. Acción: medirlos en Preview de App Store Connect durante F4.
- El locale de español neutro de Microsoft Store está fijado provisionalmente en `es-MX`. Acción: confirmarlo en el Centro de partners.

Decisión de la persona:

- La voz sonora (`CALIBRATION_VOICE`) es de calibración; la definitiva se decide con la persona.

## pseudolearn_backend

Bloqueado por publicación y cuentas:

- `supabase/deferred/20260914000002_drop_delete_account.sql` sigue sin moverse a `supabase/migrations/`: elimina `public.delete_account()` y debe esperar a que se publique el build de `apps/pseudolearn_app` que invoca `delete-account`. Acción: moverlo tras publicar ese build.
- Prueba en sandbox de App Store y de Paddle con productos, URLs de notificación y un build firmado; los tests cubren firmas y contratos con datos de prueba.
- Confirmar en sandbox que la suscripción de Paddle hereda `custom_data.user_id` de la transacción; si no, el primer evento queda sin dueño.
- Medir el consumo real de créditos por `turn_id` en `agent_ledger_events` para confirmar los 300 créditos del plan (la consulta está en el README).
- Prueba de extremo a extremo de `delete-account` contra Apple real.

Decisión pendiente:

- Un segundo proveedor de modelo mediante otro `ModelGateway` no se implementa mientras ninguna fase lo pida.

## pseudolearn_web

Bloqueado por publicación y cuentas:

- El instalador de Windows de descarga directa no lleva firma Authenticode; la guía de SmartScreen depende de ello. Acción: contratar el certificado y firmar.
- VS Code y la terminal se anuncian como «Próximamente» sin enlace; al publicar la extensión o los binarios de `pseudo`, sus tarjetas pasan a disponibles con su acción.
- No hay captura de VS Code: el generador de la app no la produce. Acción: capturarla cuando la extensión se publique.
- La fecha de 2.0.0 en `CHANGELOG.json` es provisional (2026-11-09) hasta el día real de publicación en las tiendas.
- Los productos de App Store Connect y Paddle deben existir con los identificadores `pseudolearn.nodo.*` antes de publicar.

## pseudolearn_vscode

Bloqueado por hardware, navegadores y autorización:

- Las verificaciones pesadas en VS Code real (completar, diagnosticar, navegar, renombrar, ejecutar con entrada, detener y limpieza tras cierre), la ayuda desde un segundo cliente y escribir un valor concreto en el cuadro de entrada de `Leer` y en el selector de entrada se hacen a mano: la automatización solo acciona comandos del workbench.
- Campañas de host web completas, evidencias reales de navegador, resultados de medición y revisión de cobertura; Firefox, WebKit y Windows no se verificaron.
- El camino exitoso de HTTP en el host web se ejerce sobre HTTP porque Chromium y WebKit rechazan el certificado autofirmado; no hay cobertura de TLS exitoso.
- El kit físico de medición (32 combinaciones) no tiene resultados: «no evaluado físicamente»; WebKit no equivale a Safari en iPhone.
- La métrica normativa nueva del benchmark web permanece sin aprobación de la persona.

## pseudolearn_app

Bloqueado por firmas, tiendas, credenciales y autorización:

- Firma Authenticode del instalador directo de Windows (Inno Setup).
- La petición de reseña en Microsoft Store no tiene diálogo nativo (`in_app_review` solo lo ofrece en iOS y macOS).
- Campaña de medición E-NR2 con muestras independientes en dispositivo, escritorio y navegador.
- Capturas de producto y material de tiendas regenerados con la ruta de aprendizaje; las imágenes versionadas muestran la base de conocimiento anterior.
- Compras reales del agente: falta la compra de prueba en sandbox de App Store y de Paddle con un build firmado.
- Clave del proveedor del agente (`OPENAI_API_KEY` en el servidor y `AGENT_BACKEND=proxy`, `AGENT_PROXY_URL` al compilar); sin ella el agente responde «no disponible».
- Medición del agente con `packages/pseudolearn_benchmarks` contra el gateway real.

Decisión pendiente:

- Un parámetro `Canal` se muestra aplanado en la vista Variables (`stream.identity = Nulo`). Publicarlo como valor propio exige ampliar el modelo de valores de `API.MODEL` / `API.STATE.QUERY` en el corpus, el motor y la app. Acción: aprobar esa ampliación.
- Ampliar el código equivalente según los pendientes del transpilador depende de que el transpilador cubra más construcciones.

## pseudolearn_benchmarks

Bloqueado por autorización y plataformas:

- El benchmark del agente (`tool/agent_benchmark.dart run`) nunca se ha ejecutado contra el proveedor real. Acción: autorizarlo.
- Los datos de fotogramas siguen ausentes hasta su captura en plataforma, y las campañas de macOS e iOS aguardan autorización para medir.

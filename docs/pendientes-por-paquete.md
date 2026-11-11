# Pendientes por paquete

Registro único de lo que sigue abierto en cada paquete y app. Cada viñeta es una de dos cosas: una acción que solo la persona puede hacer (credenciales, dispositivos, tiendas, autorización o revisión humana independiente) o una decisión que el corpus y los README todavía no toman. Todo lo demás se resolvió, se retiró por obsoleto o quedó documentado como decisión en el README del paquete. Antes de actuar sobre una viñeta hay que contrastarla con el código.

## pseudolearn_engine

Decisión pendiente:

- La agenda de tareas y sus colas no se guardan en las imágenes históricas (`MachineImage`): la consulta del pasado con tareas se reconstruye por reproducción de la cinta. Se revisó contra el código actual: ningún caso de `API.STATE.QUERY` ni de `ENG.TRACE.*` exige la imagen completa (los casos con tareas pasan por reproducción, y el canal de `API.STATE.QUERY` R9 también), así que persistirla sería trabajo sin regla que lo pida (`SCOPE-YAGNI`). Si se quisiera por rendimiento, primero hay que aprobar la regla y la fase.

## pseudolearn_cli

Bloqueado por máquinas:

- Los programas de aceptación de la biblioteca solo se ejecutaron en macOS arm64. Acción: correrlos en Linux y en Windows (`cargo test`).

## pseudolearn_reference

Contenido pendiente de una decisión de alcance:

- Los programas de la ruta en la edición inglesa que no tienen versión propia siguen compartiendo identificadores y textos entre comillas con el español. El mecanismo (programa propio en `route/en`, `RUTA-PARITY` sobre su esqueleto, salida verificada por el motor en cada edición) está implementado y migró la lección 0.2 y el ejercicio «Repartir caramelos»; quedan unos 300 programas, con la prosa, la `salida` y los `casos` que los citan. Acción: autorizar el trabajo de redacción de contenido, que es mecánico pero extenso.

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

- Acotar `NSAllowsArbitraryLoads` de iOS a `NSAllowsLocalNetworking`: la red de los programas va por sockets (`hyper`) y la app por `dart:io`, así que App Transport Security no debería gobernarla, pero la excepción está fijada como decisión D-08 y falta comprobarlo en un dispositivo iOS con un servicio `http://` local y otro público. Acción: decidir y verificar en dispositivo.
- Ampliar el código equivalente: las construcciones que el transpilador deja pendientes (operaciones de capacidad y de biblioteca de efectos; red HTTPS y JSON sin equivalente en la biblioteca estándar de Rust; limpiezas de `Diferir` de tareas canceladas, `Instantanea` de objetos y métodos suspendibles de jerarquías en Rust) no tienen una regla del corpus que las exija: `API.PROGRAM.VIEW` R17 admite declararlas pendientes por destino. Acción: aprobar la regla de cada una antes de traducirla.

## pseudolearn_benchmarks

Bloqueado por autorización y plataformas:

- El benchmark del agente (`tool/agent_benchmark.dart run`) nunca se ha ejecutado contra el proveedor real. Acción: autorizarlo.
- Los datos de fotogramas siguen ausentes hasta su captura en plataforma, y las campañas de macOS e iOS aguardan autorización para medir.

## Pendientes de la última iteración, por punto

Trabajo que se pudo hacer y quedó sin hacer o sin verificar. Cada viñeta indica qué falta y cómo se cierra.

### Punto 1 — Ruta en inglés con programas propios (`pseudolearn_reference`)

- Migrar los unos 300 programas restantes de `route/en` (hoy solo la lección 0.2 y «Repartir caramelos»). Cada migración lleva el cuerpo del programa con identificadores y textos en inglés, la `salida` y los `casos` en inglés y la prosa que los cita. Se cierra cuando `reference check` y `cargo xtask verify` pasan sin programas vacíos que compartan nombres españoles.
- Revisar las lecciones y ejercicios posteriores que mencionan nombres de la lección 0.2 (`edad`, `porciones`, `invitados`…) y adaptarlos a los nombres ingleses.

### Punto 4 — Agenda y colas en `MachineImage` (`pseudolearn_vm`, `pseudolearn_timeline`)

- Escribir en el corpus la regla mínima que exija la imagen completa (tareas y colas de espera) con sus casos, implementar la persistencia en `MachineImage` y medir `engine` y `aot`. Después actualizar el README de `pseudolearn_runtime`, que hoy declara el límite.

### Punto 7 — Verificaciones que quedaron sin repetir o sin ejecutar

- Repetir `flutter test` completo y `flutter analyze` completo en `apps/pseudolearn_app`: se cambiaron cadenas del canal y se añadieron pruebas después de la última pasada completa.
- Repetir `pnpm check:all` en `apps/pseudolearn_web`: los paquetes de la ruta se regeneraron después de la última pasada.
- Ejecutar `cargo deny check` en `packages/pseudolearn_engine` y, con más disco libre, `cargo xtask verify` completo (hoy solo se corrieron sus pasos por lotes).
- Regenerar la evidencia y medir el sujeto `app` (`see conform --subject app --operation properties` y luego `see conform --subject app`): su evidencia quedó obsoleta al cambiar el corpus.
- Verificar la extensión de VS Code (`apps/pseudolearn_vscode`) y `pseudolearn_store_media` con sus cadenas `pnpm`.
- Diagnosticar el aviso de la CLI: no se construye el runtime para `x86_64-unknown-linux-musl`.

### Punto 3 — Canal en la vista Variables

- Comprobar qué muestran el LSP, el DAP y el MCP de la CLI ahora que la variable se llama `stream` y no `stream.identity`, y documentarlo en el README de `pseudolearn_cli` si cambia algo observable.
- Decidir si se publican los elementos de la cola (hoy solo su cantidad): exige conocer el tipo del canal y manejar referencias.

### Punto 9 — Código equivalente (`pseudolearn_transpiler`)

- Por cada construcción pendiente (operaciones de capacidad y de biblioteca de efectos, limpiezas de `Diferir` de tareas canceladas, `Instantanea` de objetos y métodos suspendibles de jerarquías en Rust): escribir su regla en el corpus con casos, implementarla y medir el barrido diferencial. HTTPS y JSON no tienen equivalente en la biblioteca estándar de Rust y se mantienen como pendientes por destino.

### Punto 10 — App

- Verificar en un dispositivo iOS si `NSAllowsArbitraryLoads` puede acotarse a `NSAllowsLocalNetworking` (servicio `http://` local y otro público) y, si procede, cambiar `Info.plist` y la prueba `platform_host_configuration_test.dart`.

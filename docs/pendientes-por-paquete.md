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

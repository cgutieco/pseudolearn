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

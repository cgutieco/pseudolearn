# Plan de arquitectura: núcleo de PseudoLearn en Rust guiado por especificaciones

> **Estado:** **propuesta de plan**, pendiente de aprobación explícita (`PHASE-STOP`). Fecha:
> 2026-10-13. Rama: `feature/agregar-ruta-de-especificacion`.
>
> Este plan **concreta** la investigación de `docs/01` a `docs/18` para una decisión que la persona
> responsable tomó en conversación el 2026-10-13: **reescribir el núcleo completo en Rust** (front-end,
> servicio de lenguaje, VM, compilador, runtime y biblioteca estándar), **en paralelo** al núcleo Dart
> vigente hasta que el nuevo esté completo, con las **especificaciones ejecutables como única fuente de
> verdad del comportamiento**. Esa decisión sustituye a la recomendación REC-05 (trayectoria A3) de
> [14](../14-recomendaciones.md) y resuelve [D-05](../17-riesgos-preguntas-y-decisiones.md#d-05) a favor
> de A2. El resto de la investigación se toma como base coherente.
>
> Nada de este plan modifica todavía `AGENTS.md`, los `README.md` de los paquetes, las skills ni
> `language-spec.md`. Los cambios de reglas que el plan necesita están enumerados en
> [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §3 para que se aprueben uno a uno.

---

## Cómo leer este plan

| Nº | Documento                                                                     | Responde a                                                                                         |
|----|-------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------|
| 00 | [ADR-001 · Núcleo en Rust con referencia Dart en paralelo](00-adr-001-nucleo-en-rust.md) | Por qué Rust para todo el núcleo, qué alternativas se descartaron y qué consecuencias se aceptan |
| 01 | [Principios y reglas de trabajo](01-principios-y-reglas.md)                    | Especificación → caso → test → código; nombres semánticos; código sin comentarios; idiomas         |
| 02 | [Modelo de especificaciones y granularidad](02-modelo-de-especificaciones.md)  | Dominio, área, especificación y elemento; qué se especifica y qué va al `README.md`; cuándo partir |
| 03 | [Catálogo de especificaciones](03-catalogo-de-especificaciones.md)             | Inventario completo de especificaciones a escribir, con identificador, origen, sujetos y fase      |
| 04 | [Arquitectura del workspace Rust](04-arquitectura-del-workspace-rust.md)       | Crates como capas, grafo de dependencias, API pública, puente con Flutter, Wasm, CLI, verificadores |
| 05 | [Sistema de especificaciones y conformidad](05-sistema-de-especificaciones.md) | Herramienta `see`, protocolo de adaptador por proceso, sujetos Dart y Rust, matriz                  |
| 06 | [Flujo de trabajo por especificación](06-flujo-de-trabajo.md)                  | El ciclo de vida de una unidad de trabajo, definición de «terminado» y revisión                    |
| 07 | [Fases de implementación](07-fases.md)                                         | Fases R0–R9 con entradas, contenido, criterios de aceptación y experimentos                       |
| 08 | [Decisiones, riesgos y cambios de reglas](08-decisiones-riesgos-y-cambios-de-reglas.md) | Qué está decidido, qué se asume, qué falta; riesgos; cambios a `AGENTS.md` y skills          |
| 09 | [Plan de R3 · Arquitectura «Clepsidra»](09-plan-r3-motor-clepsidra.md) | Arquitectura y técnica del motor, comparación con soluciones típicas y ejecución de R3 en una iteración |
| 10 | [Plan de R4 · Front-end de Clepsidra](10-plan-r4-frontend.md) | Diseño del análisis, generación, recuperación, conformidad, E-08 y ejecución verificable de R4 |
| 11 | [Plan de R5 · «Remanso»](11-plan-r5-ejecucion-remanso.md) | Diagnóstico de E-02 y resolución de RC-01; RI, VM, runtime, biblioteca, línea temporal, experimentos y ejecución verificable de R5 |
| 12 | [Relevo histórico de R5](12-relevo-r5.md) | Estado anterior a B2/B3; conservado como historial |
| 13 | [Relevo de B4 · Remanso](13-relevo-b4-remanso.md) | Estado actual por bloque, evidencia parcial, fallos pendientes y comandos para continuar B4 |
| 14 | [RFC-014 · Diagnóstico arquitectónico y especificación ejecutable de cierre de B7](14-rfc-cierre-b7-arquitectura-y-rendimiento.md) | Evidencia medida de B7, causas raíz, decisiones aprobadas (D1, D2, D3-a) y especificación paso a paso de las 6 etapas de cierre |

Orden de lectura recomendado: 00 → 02 → 03 → 04 → 07. Para cerrar B7 en R5, seguir **14**.

---

## El plan en una página

```
                      ┌──────────────────────────────────────────────┐
                      │  Corpus de especificaciones (español)        │
                      │  packages/pseudolearn_spec/specifications/    │
                      │  LANG · DIAG · IR · ENG · RT · MEM · LIB ·    │
                      │  API · TOOL · PERF · SEE                      │
                      └───────────────┬──────────────────────────────┘
                                      │ casos y propiedades (datos)
                                      ▼
                      ┌──────────────────────────────────────────────┐
                      │  see  (herramienta Rust)                     │
                      │  valida · grafo · impacto · conformidad       │
                      └───────┬──────────────────────────┬───────────┘
              protocolo JSON  │                          │ protocolo JSON
              por stdio       ▼                          ▼
          ┌─────────────────────────────┐   ┌─────────────────────────────────┐
          │ Sujeto «reference»          │   │ Sujeto «engine» (y «aot»)       │
          │ pseudolearn_core (Dart)     │   │ packages/pseudolearn_engine     │
          │ congelado, solo correcciones│   │ (workspace Cargo, Rust)         │
          └─────────────────────────────┘   └───────────────┬─────────────────┘
                                                            │ FFI · Wasm · binario
                                    ┌───────────────────────┼─────────────────────┐
                                    ▼                       ▼                     ▼
                           app Flutter (puente)     web (Wasm)          pseudo (CLI, LSP)
```

1. **Primero se especifica, después se prueba, al final se programa.** Ninguna línea de Rust del motor
   existe sin una especificación en estado `experimental` o superior que la exija
   ([01](01-principios-y-reglas.md) §1).
2. **La especificación describe lo observable; el `README.md` del crate describe cómo se consigue.** Es
   la frontera que impide que la implementación Dart se cuele en el nuevo núcleo
   ([02](02-modelo-de-especificaciones.md) §4).
3. **El núcleo Dart pasa a ser el sujeto `reference`**: oráculo de contraste, congelado, que se retira
   cuando la matriz de conformidad del sujeto Rust esté completa ([07](07-fases.md) R9).
4. **Lo que no tiene especificación no se porta.** Así se poda código muerto y funciones a medias
   (catálogo de poda: [03](03-catalogo-de-especificaciones.md) §4).
5. **Cada crate es una capa.** La dirección de dependencias la impone Cargo al compilar, no un test
   ([04](04-arquitectura-del-workspace-rust.md) §2).
6. **En móvil se interpreta; en escritorio se compila.** La VM de bytecode es el motor en iOS, Android
   y web; Cranelift genera código nativo en escritorio y CLI ([00](00-adr-001-nucleo-en-rust.md) §5).

---

## Relación con la investigación

| Documento de investigación                          | Qué toma este plan                                                                  | Qué cambia                                                         |
|-----------------------------------------------------|--------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| [11](../11-especificaciones-ejecutables-diseno.md)  | Formato, estados, versionado, dependencias, conformidad, contrato R2                 | La herramienta se escribe en Rust, no en Dart (D-10 revisada)       |
| [12](../12-especificaciones-ejecutables-ejemplos.md) | Ejemplos como plantillas de cada dominio                                             | Los sujetos pasan de `nucleo`/`vm` a `reference`/`engine`/`aot`    |
| [13](../13-arquitecturas-candidatas.md)             | Componentes lógicos (§1)                                                             | Se adopta A2 en lugar de A3                                         |
| [15](../15-evolucion-y-hoja-de-ruta.md)             | Contenido de F0–F8 y sus criterios                                                  | Se reordena en R0–R9 alrededor de la reescritura                    |
| [06](../06-ejecucion-pedagogica-y-app.md), [09](../09-gestion-de-memoria.md) | Contrato de observación (D-18) y memoria administrada (D-04)       | Se especifican antes de escribir la VM y el runtime                 |
| [05](../05-rendimiento-motor-y-compilacion.md)      | Sin JIT; AOT; dimensiones de rendimiento                                             | Primer backend: Cranelift (D-06 resuelta en [08](08-decisiones-riesgos-y-cambios-de-reglas.md)) |

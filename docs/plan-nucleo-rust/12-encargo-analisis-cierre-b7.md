# Encargo de análisis independiente para cerrar B7

Documento de trabajo para quien tome el cierre de B7 con criterio propio. Es un encargo, no una receta: el
objetivo es fijo, el camino no.

## 1. Objetivo que no se negocia

PseudoLearn debe ser un lenguaje de programación **rápido, optimizado y eficiente**. La reescritura en Rust es
un medio, no la meta: el rendimiento depende también de la arquitectura (representación intermedia, bytecode,
despacho, montón, puntos de control, observación, API), de lo que se mide y de cómo se prueba. Si el análisis
concluye que una decisión de arquitectura vigente es la causa de un coste o de un cuello de botella, debe
decirlo y proponer su sustitución, aunque contradiga una decisión previa (D-R5-xx). Se admite cuestionar el
plan; no se admite hacerlo en silencio.

## 2. Qué debe cerrarse (estado verificado el 2026-10-16)

Fuente de verdad: `11-plan-r5-ejecucion-remanso.md` (§ B7, «Estado de implementación y pendientes de B7» y
«Relevo de B7»). Resumen de lo abierto:

- **E-16, mutación (B7.8):** `pseudolearn_timeline` mide 71/147 = 48,3 % frente a ≥ 85 %, con 76 supervivientes
  (`deltas` 19, `inspect` 17, `thinning` 10, `array_view` 8, `cell_view` 8, `timeline` 7…). Faltan `lowering`,
  `bytecode`, `runtime`, `library` y `vm` (~2 500 mutantes más). Cada superviviente es equivalente (con argumento)
  o hueco (se cierra con caso derivado de la regla o test espejo).
- **E-17 (B7.8):** repetir paridad nativo/Wasm sobre los binarios finales; el reporte está en `partial`.
- **B7.7 rendimiento:** repetir AWFY sobre fuentes finales (hoy 16,4× de media geométrica y 7,5× de mínimo frente
  a `macos-r3-awfy`; el objetivo de diseño era 30×), completar M4 y latencias.
- **B7.1 coste físico:** imágenes de suspensión que aún copian bancos; consultas históricas que reproducen
  instrucciones; avance rápido por contador de eventos no implementado.
- **B7.4:** alcance del diferencial con `reference` pendiente de decisión de la persona.
- **Verificación y publicación finales** de los miembros afectados, README al día, casillas solo con evidencia.

Ya acreditado: robustez B7.6 (0 hallazgos en 3 × 1500 casos), `cargo xtask verify` del motor y de spec en verde,
conformidad del motor y de la CLI cerrada, 29/29 propiedades.

## 3. Lo que se pide a quien analice

1. **Investigar antes de proponer.** Leer los README de los paquetes, `architecture.yaml`, el corpus y los
   resultados en `packages/*/results/`. Medir, no suponer: reproducir los números que cite.
2. **Diagnosticar por qué el rendimiento y las pruebas cuestan lo que cuestan.** Entre otras preguntas:
   ¿por qué 16× y no 30×?; ¿qué parte del coste es despacho, montón, comprobaciones, observación o puntos de
   control?; ¿por qué la mutación de un solo crate tarda tanto y deja tantos supervivientes (¿tests débiles,
   API demasiado amplia, código muerto, falta de propiedades?); ¿qué diseño haría más baratas la restauración y
   la reproducción?
3. **Buscar la solución mejor, no la más cercana.** Contrastar con prácticas de máquinas virtuales de registros,
   montones planos, puntos de control diferenciales, mutación dirigida y pruebas por propiedades. Documentar qué
   se toma y qué se rechaza de cada fuente consultada (las fuentes de terceros no son normativas).
4. **Considerar alternativas de arquitectura**, incluidas las que reduzcan el trabajo de B7 (por ejemplo,
   simplificar una API cuya superficie genera supervivientes, o cambiar la estrategia de captura), y valorar su
   coste, riesgo y efecto sobre el corpus y los contratos.
5. **No ejecutar nada sin límite.** Hubo un incidente real de memoria (más de 26 GB) por lanzar pruebas sin tope.
   Toda ejecución costosa va en segundo plano con vigilante de memoria y tiempo; la mutación con `--jobs` ≤ 2 y
   vigilando disco (hoy hay ~4 GiB libres y el `target` del motor ocupa ~4,6 GiB). Comprobar que cualquier
   bucle de lexer/parser avanza.

## 4. Entregable

Un **ADR o RFC** en español, en `docs/plan-nucleo-rust/`, que contenga:

- **Problema:** evidencia medida, con comandos y datos reproducibles, de qué falla o cuesta y por qué.
- **Análisis de causas:** qué es del lenguaje Rust y qué es de la arquitectura.
- **Opciones consideradas** con sus compromisos, y la **decisión recomendada** con su fundamento.
- **Plan de cierre de B7** ordenado, con criterios verificables, estimación de coste y riesgos, y qué decisiones
  necesita de la persona responsable.
- **Cambios de arquitectura propuestos**, si los hay, con su impacto en README, corpus y contratos.

Debe respetar `AGENTS.md` (cero comentarios en código, capas, `PHASE-STOP`). Primero se entrega el ADR/RFC y se
espera aprobación; no se implementa un cambio de arquitectura sin ella.

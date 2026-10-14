# ADR-001 · Núcleo completo en Rust, con el núcleo Dart como referencia en paralelo

**Estado:** Propuesto (decisión tomada en conversación por la persona responsable el 2026-10-13;
pendiente de registrarse en `AGENTS.md` y en el `README.md` raíz cuando se apruebe la fase R0)
**Fecha:** 2026-10-13
**Decide:** la persona responsable del proyecto
**Resuelve:** [D-05](../17-riesgos-preguntas-y-decisiones.md#d-05) (arquitectura) y
[D-06](../17-riesgos-preguntas-y-decisiones.md#d-06) (primer backend); revisa
[D-10](../17-riesgos-preguntas-y-decisiones.md#d-10) (lenguaje de la herramienta de especificaciones)

---

## 1. Contexto

- El foco del proyecto cambia: **el producto principal es el lenguaje**, muy optimizado, de propósito
  general y con sintaxis de pseudocódigo deliberadamente verbosa. La app pasa a ser un consumidor más.
- El núcleo Dart funciona, pero el diagnóstico ([02](../02-diagnostico-del-sistema-actual.md)) encontró
  37 hallazgos, once de ellos divergencias entre lo escrito y lo ejecutado. Sus tests verifican lo que
  el código hace, no lo que el lenguaje debe hacer.
- La documentación vigente se contradice en varios puntos (H-02, H-04, H-07, H-18, H-37) porque **no
  es ejecutable**.
- Restricciones de plataforma ([05](../05-rendimiento-motor-y-compilacion.md) §3.4):
  - iOS prohíbe generar código ejecutable en tiempo de ejecución, así que en la app no hay JIT;
  - una app no puede compilar el programa del alumno a nativo y ejecutarlo: iOS no carga código nuevo y
    Android, desde la API 29, no ejecuta binarios escritos en los directorios de la app.

  En móvil, los programas PseudoLearn **se interpretan**.
- Semántica numérica vigente: `entero` de 64 bits con signo, error de ejecución al desbordar, igual en
  todos los objetivos (`language-spec.md` §12.2). En Dart compilado a JavaScript eso obliga a usar
  `BigInt` en todas partes.

## 2. Decisión

1. **Todo el núcleo se escribe en Rust** como un workspace de Cargo en `packages/pseudolearn_engine`:
   - texto fuente, léxico y sintaxis sin pérdida;
   - semántica (nombres y tipos);
   - representación intermedia (RI);
   - VM de bytecode observable;
   - runtime y memoria administrada;
   - biblioteca estándar;
   - servicio de lenguaje;
   - generador de código nativo;
   - API pública.
2. **El núcleo Dart (`packages/pseudolearn_core`) se congela** como sujeto de conformidad `reference`.
   Solo recibe correcciones cuando una especificación lo exige, y se retira al cerrar la fase R9.
3. **La fuente de verdad del comportamiento es el corpus de especificaciones** (contrato R2 de
   [11](../11-especificaciones-ejecutables-diseno.md#transicion-readme)). Los `README.md` conservan la
   arquitectura, la operación y el porqué de la implementación.
4. **Orden de trabajo obligatorio:** especificación → casos → tests → código
   ([01](01-principios-y-reglas.md) §1).
5. **Primer backend nativo: Cranelift** (generación de objetos AOT), con la RI diseñada para que un
   backend LLVM pueda añadirse después sin tocar el front-end.
6. **La herramienta de especificaciones (`see`) también se escribe en Rust**, y habla con cada sujeto
   por un protocolo JSON sobre la entrada y salida estándar. Así el lenguaje de cada sujeto no importa.

## 3. Opciones consideradas

### Opción A2 · Núcleo completo en Rust (elegida)

| Dimensión                         | Valoración                                                                                   |
|-----------------------------------|----------------------------------------------------------------------------------------------|
| Complejidad                       | Alta                                                                                         |
| Coste                             | Reescritura completa; quinta cadena de herramientas (Rust)                                   |
| Techo de rendimiento (programas)  | Máximo: VM sin cajas en móvil, Cranelift y después LLVM en escritorio                        |
| Rendimiento (herramientas)        | Alto: análisis incremental sin pausas de recolector del anfitrión                            |
| Familiaridad del equipo           | Baja al principio; se mitiga empezando por `see`, que es Rust sin dificultad de dominio       |
| Semántica                         | **Una sola implementación** compartida por VM, runtime nativo, servicio de lenguaje y CLI    |

**A favor**

- Una sola fuente de semántica: biblioteca estándar, aritmética comprobada y representación de texto
  existen una vez.
- `i64` exacto en nativo y en Wasm, sin `BigInt`.
- Se puede incrustar en todas partes: FFI para Flutter, Wasm para web, binario para CLI y LSP.
- Ecosistema maduro para compiladores: `rowan`, `salsa`, `logos`, `cranelift`, `tower-lsp`, `proptest`.
- El orden de capas lo impone el compilador: cada capa es un crate.
- Las partes más difíciles en Rust (runtime, recolector, generación de código) había que escribirlas en
  Rust de todos modos.

**En contra**

- Hay que diseñar la frontera FFI con Flutter: compilación cruzada por plataforma, tamaño, depuración a
  través de la frontera.
- Observar la ejecución a través de esa frontera exige eventos por lotes y consultas por referencia.
- Se pierde el valor de los 772 tests Dart como tests (no como oráculo).
- Curva de aprendizaje de Rust y compilaciones más lentas.

### Opción A3 · Front-end y VM en Dart, backend y runtime en Rust (descartada)

| Dimensión                         | Valoración                                                                    |
|-----------------------------------|-------------------------------------------------------------------------------|
| Complejidad                       | Media-alta                                                                    |
| Coste                             | Menor a corto plazo; **doble implementación de la semántica** a largo plazo   |
| Techo de rendimiento en móvil     | El de una VM en Dart: sin uniones sin caja ni control del diseño de memoria   |
| Familiaridad del equipo           | Alta                                                                          |

**Por qué se descarta:**

- Obliga a mantener para siempre dos implementaciones del mismo significado: la VM en Dart y el runtime
  en Rust.
- Limita el rendimiento en móvil, que es exactamente donde no hay alternativa a interpretar.
- Su principal argumento era conservar los tests del núcleo Dart, y este plan los reemplaza por el
  corpus de especificaciones.

### Opción A1/A4 · Todo en Dart emitiendo C o Go (descartada)

- Mismo techo en móvil que A3.
- A4 convierte a PseudoLearn en «una piel de Go» y depende de una cadena de herramientas ajena.
- Ninguna de las dos resuelve el `i64` en la web.

### Opción «reescribir sin núcleo de referencia» (descartada)

Retirar el núcleo Dart al empezar pierde el único oráculo independiente disponible. La política de
[11](../11-especificaciones-ejecutables-diseno.md) §10 exige **dos sujetos** para estabilizar una regla
del lenguaje. Mantener el núcleo Dart en paralelo cumple esa política gratis.

## 4. Análisis de compromisos

- **Coste presente frente a coste permanente.** A3 es más barata hoy y más cara cada vez que el lenguaje
  cambia. A2 paga una vez.
- **Comodidad de la app frente a calidad del lenguaje.** Lo que A3 conserva es comodidad de la app (sin
  FFI, recarga en caliente). Con el foco en el lenguaje, pesa menos que tener una sola semántica.
- **Riesgo de reescritura.** Se mitiga con tres cosas:
  1. el corpus de especificaciones como oráculo previo a la reescritura;
  2. el núcleo Dart como segundo sujeto;
  3. el avance por áreas medido en la matriz de conformidad, en vez de un «big bang».

## 5. Ejecución por plataforma

| Plataforma          | Cómo se entrega el núcleo                       | Cómo se ejecuta el programa del alumno               | Observación paso a paso |
|---------------------|-------------------------------------------------|------------------------------------------------------|-------------------------|
| iOS / iPadOS        | Biblioteca estática (`.a`, en `xcframework`)    | VM de bytecode                                       | Sí                      |
| Android             | Biblioteca dinámica (`.so` por ABI)             | VM de bytecode                                       | Sí                      |
| macOS / Windows / Linux (app) | Biblioteca dinámica                    | VM de bytecode; compilación nativa opcional (R6)     | Sí en la VM             |
| Web                 | Módulo Wasm (`wasm32-unknown-unknown`)          | VM de bytecode en Wasm                               | Sí                      |
| CLI `pseudo`        | Binario nativo                                  | `pseudo run` (VM) o `pseudo build` (Cranelift → binario enlazado con el runtime) | Solo en la VM |

El generador de código (`pseudolearn_codegen`) y Cranelift **no se incluyen** en los builds de móvil ni
de web: quedan detrás de una *feature* de Cargo que solo activan la CLI y la app de escritorio.

## 6. Consecuencias

**Más fácil**

- Cambiar el lenguaje: una especificación, una implementación, un corpus que lo verifica.
- Llevar el lenguaje a otros anfitriones (editores, web, terceros).
- Afirmar el rendimiento con datos: la suite `PERF.*` se ejecuta contra binarios reales.

**Más difícil**

- Compilar la app: el núcleo Rust se compila para cada plataforma y el puente se genera.
- Depurar de punta a punta, porque una falla puede estar a cualquiera de los dos lados de la frontera.
- Incorporar a otras personas, que necesitan Rust además de Dart.

**Hay que revisar**

- Cuando exista la VM: si el coste de observar a través de la frontera cumple `PERF.VM.STEP-LATENCY`
  (E-06).
- Cuando exista el backend: si Cranelift alcanza el nivel de rendimiento acordado en D-07 o si hace falta
  LLVM.
- Antes de R9: si algo de la app depende todavía del núcleo Dart.

## 7. Tareas que se derivan

1. [ ] Aprobar el plan y registrar ADR-001 en el `README.md` raíz y en `AGENTS.md` §9 (fase R0).
2. [ ] Aprobar los cambios de reglas de [08](08-decisiones-riesgos-y-cambios-de-reglas.md) §3.
3. [ ] Instalar la cadena Rust (`rustup`, `stable` fijado en `rust-toolchain.toml`) y añadirla a la CI.
4. [ ] Ejecutar las fases R1 a R9 de [07](07-fases.md), con `PHASE-STOP` entre fases.

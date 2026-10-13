# 13 · Arquitecturas candidatas

> **Estado:** investigación, no normativo. Ninguna arquitectura está aprobada. Las decisiones
> correspondientes son [D-05](17-riesgos-preguntas-y-decisiones.md#d-05),
> [D-06](17-riesgos-preguntas-y-decisiones.md#d-06) y [D-10](17-riesgos-preguntas-y-decisiones.md#d-10).
> Formato inspirado en la skill de arquitectura (opciones, compromisos, consecuencias), sin forzar ADR.

Integra [05](05-rendimiento-motor-y-compilacion.md), [06](06-ejecucion-pedagogica-y-app.md),
[07](07-herramientas-y-autocompletado.md), [09](09-gestion-de-memoria.md) y
[11](11-especificaciones-ejecutables-diseno.md) en vistas de sistema completo. Responde a V-01, V-29 y
V-73.

---

## 1. Componentes lógicos, independientes de cómo se implementen

| Componente                         | Responsabilidad                                                                         | Hoy                                   |
|------------------------------------|-----------------------------------------------------------------------------------------|---------------------------------------|
| **Front-end**                      | Léxico sin pérdida, sintaxis resiliente, nombres, tipos, diagnósticos                   | `pseudolearn_core` (con pérdida, no incremental) |
| **Servicio de lenguaje**           | Consultas por posición, autocompletado, formateo, acciones, resolución de módulos       | No existe (fragmentos en la app)       |
| **Representación intermedia (RI)** | Contrato entre front-end y motores; tipada; independiente del perfil                    | No existe                              |
| **VM observable**                  | Ejecutar RI con eventos y estado observable; app, web, iOS                              | El intérprete de tareas cumple el papel sobre el AST |
| **Compilador AOT**                 | RI → código nativo o traducción a otro lenguaje                                         | No existe                              |
| **Runtime**                        | Memoria, cadenas, colecciones, E/S, arranque                                            | Dentro del intérprete (Dart)           |
| **Biblioteca estándar**            | Colecciones, texto, archivos, errores, matemáticas; bilingüe                            | 18 funciones incorporadas              |
| **Herramientas**                   | CLI, LSP, DAP, formateador, migrador, gestor de paquetes                                | No existen                             |
| **Sistema de especificaciones**    | Corpus, validación, conformidad, impacto                                                | No existe                              |
| **App**                            | Experiencia pedagógica                                                                  | `pseudolearn_app`                      |

---

## 2. Candidatas

### A1 · Dart-céntrica

Todo en Dart: front-end, servicio, RI, VM, CLI, LSP y un backend que **emite C o Go** e invoca su
compilador. Runtime nativo mínimo en C (si se emite C) o el de Go (si se emite Go).

```
 Dart: front-end → servicio → RI ─┬→ VM observable (app, web, iOS)
                                   └→ emisor C/Go → compilador externo → binario
```

| Dimensión                         | Valoración                                                                 |
|-----------------------------------|----------------------------------------------------------------------------|
| Complejidad                       | Media                                                                      |
| Cadenas nuevas                    | Ninguna en el monorepo (C o Go solo como herramienta externa)              |
| Techo de rendimiento de programas | El del compilador C o de Go                                                |
| Rendimiento del compilador        | El de Dart AOT; probablemente suficiente (a medir, E-08)                   |
| Integración con la app            | Directa, en proceso                                                        |
| Familiaridad del equipo           | Alta                                                                       |
| Riesgo                            | Dependencia de un compilador externo instalado o empaquetado               |

### A2 · Núcleo nativo en Rust

Front-end, servicio, VM, compilador y runtime en Rust; la app usa el núcleo por FFI; la web por Wasm;
el LSP es un binario Rust.

```
 Rust: front-end → servicio → RI → { VM, Cranelift/LLVM } + runtime
          ▲ FFI (app)    ▲ Wasm (web)    ▲ stdio (LSP)
```

| Dimensión                         | Valoración                                                                 |
|-----------------------------------|----------------------------------------------------------------------------|
| Complejidad                       | Alta                                                                       |
| Cadenas nuevas                    | Rust (quinta cadena del monorepo)                                          |
| Techo de rendimiento de programas | Máximo (Cranelift o LLVM)                                                  |
| Rendimiento del compilador        | Alto                                                                       |
| Integración con la app            | Por FFI: frontera de serialización y ciclo de compilación más complejo     |
| Familiaridad del equipo           | Baja (a evaluar)                                                           |
| Riesgo                            | **Reescritura completa** del núcleo, con 772 tests y ocho skills que hoy funcionan |

### A3 · Híbrida por contrato de RI

Front-end, servicio y VM en Dart (todo lo que la app y los editores consumen); backend y runtime nativos
en un lenguaje de sistemas, consumiendo la RI **serializada y especificada** (`IR.*` en el corpus).

```
 Dart:  front-end → servicio → RI ──► VM observable (app, web, iOS)
                                  │
                         RI serializada (contrato especificado)
                                  ▼
 Sistemas: backend (C emitido, Cranelift o LLVM) + runtime → binario
```

| Dimensión                         | Valoración                                                                 |
|-----------------------------------|----------------------------------------------------------------------------|
| Complejidad                       | Media-alta                                                                 |
| Cadenas nuevas                    | Una de sistemas (C, Rust o Zig), acotada al backend y al runtime           |
| Techo de rendimiento de programas | Alto a máximo, según backend                                               |
| Rendimiento del compilador        | Front-end en Dart; backend nativo                                          |
| Integración con la app            | Directa para todo lo que la app usa                                       |
| Familiaridad del equipo           | Alta en la parte de la app; nueva en el backend                            |
| Riesgo                            | La RI como contrato estable entre dos mundos; mitigado porque se especifica |

### A4 · Anfitrión maduro

Front-end y VM en Dart; el backend **traduce a Go** y delega recolector, concurrencia, compilación
cruzada y biblioteca de sistema en la cadena de Go.

| Dimensión                         | Valoración                                                                 |
|-----------------------------------|----------------------------------------------------------------------------|
| Complejidad                       | Baja-media                                                                 |
| Cadenas nuevas                    | Go como dependencia de quien compila                                       |
| Techo de rendimiento de programas | El de Go con la semántica de PseudoLearn (desbordamiento emitido a mano, herencia emulada) |
| Rendimiento del compilador        | Alto (Go compila rápido)                                                   |
| Integración con la app            | Directa para la VM                                                         |
| Familiaridad del equipo           | Media                                                                      |
| Riesgo                            | Identidad («PseudoLearn como piel de Go»); depuración a través de otro lenguaje; tamaño de la cadena a distribuir |

**[INFERENCIA]** Ventaja no evidente: acceso a la biblioteca de Go (red, archivos, concurrencia) por
interoperabilidad, que acortaría mucho el camino a «propósito general» (§2 de
[04](04-filosofia-y-modelo-del-lenguaje.md)).

### A5 · Autoalojada (horizonte)

El compilador se escribe en PseudoLearn. Demuestra propósito general y permite que la comunidad
contribuya en su idioma. Solo viable cuando el lenguaje tenga módulos, colecciones, errores y un
backend; requiere arranque desde A1, A3 o A4.

---

## 3. Análisis de compromisos

| Criterio                                   | A1     | A2     | A3     | A4     |
|--------------------------------------------|--------|--------|--------|--------|
| Tiempo hasta el primer binario nativo      | Corto  | Largo  | Medio  | Muy corto |
| Techo de rendimiento                       | Alto   | Máximo | Alto–máximo | El de Go |
| Conservación del núcleo y sus tests        | Total  | Ninguna | Total | Total  |
| Integración con app, web, iOS              | Directa | Por FFI/Wasm | Directa | Directa |
| Cadenas de herramientas que mantener       | 4 (+C/Go externos) | 5 | 5 | 4 (+Go externo) |
| Control semántico (desbordamiento, Unicode, memoria) | Total (C) / medio (Go) | Total | Total | Medio |
| Encaje con el sistema de especificaciones  | Alto   | Alto   | **Muy alto** (la RI se vuelve un contrato especificado) | Alto |
| Reversibilidad                             | Alta: el emisor se cambia | Baja | Alta: el backend se cambia | Alta: el emisor se cambia |

**Lectura [INFERENCIA]:**

- A2 maximiza el techo y minimiza lo que se conserva; es la opción de mayor riesgo para un equipo
  pequeño con un núcleo que funciona.
- A1, A3 y A4 comparten la mitad que importa a la app (front-end, servicio y VM en Dart) y difieren
  solo en el backend. Esa mitad común es **la primera decisión que no hay que tomar todavía**: se puede
  construir ya.
- A3 y A1 son la misma arquitectura con el backend en distinto lado de la RI. Diseñar la RI como
  contrato especificado deja abierta la elección.
- A4 es la forma más barata de medir y de llegar a «propósito general», y la menos diferenciada.

---

## 4. Recomendación (propuesta)

**Trayectoria A3, empezando por la mitad común**:

1. Front-end sin pérdida e incremental, servicio de lenguaje y VM observable en Dart (comunes a A1, A3
   y A4).
2. RI tipada especificada en el corpus.
3. Primer backend elegido por E-05 entre **emisión de C** (A1/A3) y **traducción a Go** (A4).
4. Backend propio (Cranelift o LLVM) solo si E-02 y E-05 muestran que el primero no alcanza el nivel de
   rendimiento acordado.
5. Autoalojamiento (A5) como objetivo de comunidad, no técnico.

**Consecuencias:**

- Más fácil: conservar el núcleo, sus tests y su disciplina; dar valor pronto a la app (servicio de
  lenguaje, VM sin tope).
- Más difícil: mantener la RI estable entre dos mundos; formar al equipo en una cadena de sistemas
  cuando llegue el backend.
- A revisar: la elección del backend tras E-05; la del lenguaje del runtime si A4 no se elige.

**Qué me haría cambiar de opinión:** que E-08 muestre que el front-end en Dart no cumple latencias de
servidor de lenguaje en archivos grandes (entonces A2 gana peso para el front-end); que la persona
responsable priorice llegar cuanto antes a programas reales sobre la identidad técnica (A4 primero);
o que la licencia elegida ([D-01](17-riesgos-preguntas-y-decisiones.md#d-01)) haga deseable separar
físicamente compilador y app (entonces conviene un repositorio aparte para el compilador abierto).

---

## 5. Disposición propuesta del monorepo

La visión autoriza proponer cambios en la arquitectura del monorepo (V-73). Esta disposición sigue la
regla vigente de `packages/` («reutilizable, sin interfaz, sin despliegue») y `apps/` («lo que se
despliega»), sin carpetas de raíz nuevas.

```
packages/
  pseudolearn_spec/             sistema de especificaciones (Dart)            [nuevo]
  pseudolearn_core/             front-end: léxico, sintaxis, nombres, tipos   [evoluciona]
  pseudolearn_language_service/ servicio de lenguaje                          [nuevo]
  pseudolearn_ir/               RI tipada y su traducción desde el AST         [nuevo]
  pseudolearn_vm/               VM observable sobre la RI                      [nuevo]
  pseudolearn_stdlib/           biblioteca estándar (PseudoLearn + intrínsecos) [nuevo]
  pseudolearn_runtime/          runtime nativo (C, Rust o Zig según D-05)       [nuevo, cadena nueva]
  pseudolearn_brand/            sin cambios
apps/
  pseudolearn_app/              consume servicio y VM                          [evoluciona]
  pseudo_cli/                   orden `pseudo`: ejecutar, compilar, lsp, dap…  [nuevo, se distribuye]
  pseudolearn_vscode/           extensión de VS Code (TypeScript)              [nuevo]
  pseudolearn_intellij/         plugin de IntelliJ (Kotlin), si hace falta     [nuevo, opcional]
  pseudolearn_backend/          sin cambios
  fe-pseudolearn/               sin cambios
```

Dirección de dependencias propuesta (todas hacia abajo; `pseudolearn_spec` solo como dependencia de
desarrollo):

```
pseudo_cli ─┬─► pseudolearn_language_service ─► pseudolearn_core
            ├─► pseudolearn_vm ─► pseudolearn_ir ─► pseudolearn_core
            └─► (backend) ─► pseudolearn_ir
pseudolearn_app ─► pseudolearn_language_service, pseudolearn_vm
pseudolearn_runtime ◄── binarios generados (enlazado)
todos ··(dev)··► pseudolearn_spec
```

**Cambios de reglas del monorepo que esto implicaría (no aplicados):**

| Regla vigente (README raíz)                                | Cambio que requeriría                                                                                     |
|------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------|
| §1.3: sin orquestador multi-paquete                        | Con siete miembros Dart, los espacios de trabajo de pub (Dart 3.6) eliminan resoluciones duplicadas sin herramienta externa; exige un `pubspec.yaml` de raíz, hoy excluido |
| §1.3: sin CI de verificación                               | Sin CI, la conformidad no es continua y el sistema de especificaciones pierde su razón de ser ([D-23](17-riesgos-preguntas-y-decisiones.md#d-23)) |
| §3.2: una única arista de compilación                      | Pasaría a un grafo de varias aristas; el verificador del par `(app, núcleo)` se generalizaría             |
| §4.4: versión de producto con núcleo anclado               | Se separan edición del lenguaje, versión de la cadena de herramientas y de la biblioteca estándar ([04](04-filosofia-y-modelo-del-lenguaje.md) §5.1) |
| Licencia propietaria (commit `b44b2dd`)                    | Posible separación por licencia entre compilador y app ([D-01](17-riesgos-preguntas-y-decisiones.md#d-01)) |

**Lo que no cambia:** la arquitectura hexagonal de la app, las capas del núcleo, la marca, el backend y
la web. El núcleo **sigue siendo Dart puro** sin `dart:io`; la E/S de los programas PseudoLearn vive en
el runtime y en la biblioteca estándar, no en el analizador.

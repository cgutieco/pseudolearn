# AGENTS.md — Reglas transversales del monorepo PseudoLearn

Aplica a **todos** los paquetes. No describe la arquitectura de ningún paquete: capas, límites numéricos y decisiones de
diseño viven en el `README.md` de cada uno, porque el núcleo del lenguaje y la app de Flutter no comparten arquitectura
ni criterios.

---

## 1. Antes de tocar un archivo

1. Localiza el paquete (`packages/<nombre>/` o `apps/<nombre>/`).
2. Lee su `README.md`: es la fuente de verdad técnica. Si no existe, escríbelo antes que cualquier código.
3. Lee su archivo de reglas, si existe (`architecture.yaml`, o `architecture.json` donde el intérprete no lee YAML sin
   dependencias adicionales): capas, imports permitidos y prohibidos, límites de tamaño.
4. Responde antes de escribir:
    - ¿En qué capa vive el archivo?
    - ¿Qué puede y qué no puede importar esa capa?
    - ¿Ya existe un archivo dueño de esta responsabilidad, o estoy añadiendo una segunda razón de cambio a uno
      existente?

Si la respuesta a la última es «estoy mezclando», el código va en un archivo nuevo, en su capa.

---

## 2. Reglas

Cada regla tiene un ID estable. Úsalo para reportar una violación o justificar una decisión.

| ID                          | Regla                                                                                                                                                                                                                                                          | Verificación                                                                                                                                                 |
|-----------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DOC-README-TRUTH`          | El `README.md` del paquete es la fuente de verdad de arquitectura, operación y por qué; el corpus lo es del comportamiento observable. Un cambio de arquitectura o de diseño actualiza el README **en el mismo cambio**                                        | Revisión del cambio                                                                                                                                          |
| `DOC-NO-TRANSIENT-REFS`     | Ningún archivo cita documentos, secciones o decisiones de planificación transitoria; corpus y README se sustentan solos. Se permite la documentación propia de cada paquete o aplicación                                                                       | Puerta local de referencias con casos negativos                                                                                                              |
| `DOC-NO-ORPHAN-DECISION`    | Ninguna decisión de diseño vive solo en el código o solo en un mensaje de commit                                                                                                                                                                               | Revisión del cambio                                                                                                                                          |
| `LANG-EN-CODE`              | Todo el código —identificadores, nombres de test, comentarios, mensajes de commit— en inglés                                                                                                                                                                   | Revisión del cambio                                                                                                                                          |
| `LANG-ES-DOCS`              | `AGENTS.md`, los `README.md`, las skills y el corpus de especificaciones en español neutro                                                                                                                                                                     | Revisión del cambio                                                                                                                                          |
| `QUALITY-NO-COMMENTS`       | Prohibido cualquier comentario en código. El código se explica con nombres, tipos y funciones pequeñas; el por qué vive en el README. Excepción: en Python, un *docstring* por módulo, clase y función que declara la responsabilidad, nunca la implementación | Script de límites del paquete (`tool/check_limits.dart`, `tool/check_limits.py`, `scripts/check-no-comments.mjs`, `rust-checks comments`) y su caso negativo |
| `QUALITY-NO-NOISE-COMMENTS` | Prohibido el comentario que repite lo que el código ya dice                                                                                                                                                                                                    | Revisión del cambio                                                                                                                                          |
| `QUALITY-NO-DOC-REFS`       | Prohibido citar un documento o sección desde el código (`// ver AGENTS.md §2`). Se describe la restricción, nunca dónde está escrita                                                                                                                           | `grep` en revisión                                                                                                                                           |
| `QUALITY-WHY-ONLY`          | El por qué, incluso el local, va en el README; no habilita comentarios                                                                                                                                                                                         | Revisión del cambio                                                                                                                                          |
| `LAYER-DIRECTION`           | Una capa solo importa de sí misma o de las capas que el archivo de reglas del paquete le permite. Sin excepciones                                                                                                                                              | Test de arquitectura del paquete                                                                                                                             |
| `LAYER-DECLARED`            | Toda carpeta de capa está declarada en el archivo de reglas, y toda capa declarada tiene su carpeta                                                                                                                                                            | Test de arquitectura del paquete                                                                                                                             |
| `SIZE-*`                    | Los límites de tamaño de archivo, función, parámetros, anidación y métodos públicos son los del archivo de reglas del paquete                                                                                                                                  | Script de límites del paquete                                                                                                                                |
| `GEN-NO-HAND-COPY`          | Un artefacto producido por un generador del monorepo no se edita, pega ni reescribe a mano en un consumidor: se importa, se genera o se verifica                                                                                                               | Verificador del generador y del consumidor (`BRAND-*-STALE`, `FE-BRAND-GENERATED`)                                                                           |
| `TEST-BOTH-PATHS`           | Cada pieza se prueba en camino feliz **y** camino infeliz, más casos límite explícitos                                                                                                                                                                         | Revisión del cambio                                                                                                                                          |
| `TEST-MIRROR`               | La carpeta de tests refleja la de código. Sin `all_tests.dart` común                                                                                                                                                                                           | Revisión del cambio                                                                                                                                          |
| `SCOPE-YAGNI`               | No se implementa lo que ninguna fase aprobada pide. Una abstracción que solo sirve a algo fuera de alcance no se escribe                                                                                                                                       | Revisión del cambio                                                                                                                                          |
| `GIT-SINGLE-BRANCH`         | Todo cambio posterior se hace directamente sobre `master`; no se crean ramas de trabajo adicionales. La publicación usa push ordinario                                                                                                                         | `git branch --show-current` y destino del push                                                                                                               |
| `PHASE-STOP`                | Al cerrar una fase se espera confirmación explícita en un mensaje nuevo. Describir una fase terminada no es luz verde para la siguiente                                                                                                                        | Disciplina de trabajo                                                                                                                                        |
| `PHASE-GREEN`               | Ninguna fase se cierra sin tests y verificadores del paquete en verde                                                                                                                                                                                          | Verificación de fase                                                                                                                                         |
| `CONFLICT-REPORT`           | Ante un conflicto entre fuentes, se reporta a la persona en vez de resolverlo por cuenta propia                                                                                                                                                                | Disciplina de trabajo                                                                                                                                        |
| `SPEC-BEHAVIOR-TRUTH`       | El comportamiento observable del núcleo vive en el corpus de especificaciones                                                                                                                                                                                  | Conformidad desde R1                                                                                                                                         |
| `SPEC-FIRST`                | Especificación → casos → tests → código; sin motor Rust antes del hito de R3                                                                                                                                                                                   | Revisión y conformidad                                                                                                                                       |
| `SPEC-NO-ORPHAN-RULE`       | Cada regla tiene casos o propiedades que la cubren                                                                                                                                                                                                             | `see validate` desde R1                                                                                                                                      |
| `SPEC-BINDING-AS-DATA`      | Los vínculos regla–código viven en archivos de conformidad, nunca en código                                                                                                                                                                                    | Revisión                                                                                                                                                     |
| `SPEC-CHANGE-CLASSIFIED`    | Cada cambio de versión de una especificación declara clasificación e impacto                                                                                                                                                                                   | `see validate` desde R1                                                                                                                                      |
| `SPEC-INDEPENDENT-ORACLE`   | Los resultados esperados se derivan de la regla; las capturas requieren revisión                                                                                                                                                                               | Revisión del corpus                                                                                                                                          |
| `SPEC-SELF-CONTAINED`       | El corpus no enlaza ni cita documentación externa; puede enlazar identidades internas del propio corpus                                                                                                                                                        | `see validate` y caso negativo                                                                                                                               |
| `QUALITY-SEMANTIC-NAMES`    | En Rust, nombres por papel, mínimo tres caracteres salvo id/io/ir/vm/gc/os; sin abreviaturas, relleno ni archivos utils/helpers/common/misc                                                                                                                    | `rust-checks names`                                                                                                                                          |
| `QUALITY-NO-PANIC`          | En Rust, sin unwrap/expect, panic/todo/unimplemented/unreachable, índices inseguros, aritmética implícita ni conversiones numéricas con pérdida                                                                                                                | Clippy estricto                                                                                                                                              |

---

## 3. Precedencia ante conflictos

De mayor a menor autoridad:

1. Instrucción directa de la persona en la conversación.
2. Este `AGENTS.md`.
3. Corpus (comportamiento observable) y `README.md` del paquete (arquitectura, operación y por qué). Sus ámbitos son
   disjuntos: si chocan, hay una clasificación incorrecta que se reporta.
4. Documentación de terceros.

- **Reportar, no resolver.** Si dos fuentes del mismo nivel se contradicen, o una superior contradice a una inferior de
  modo que cambia el trabajo, se dice explícitamente y se espera respuesta.
- **Lo externo no es normativo.** PseudoLearn es dueño de su motor y su gramática; se inspira en otras herramientas, no
  las copia. Lo que se tome de una fuente externa, y lo que se rechace, se registra en el README del paquete.

---

## 4. Calidad de código

El código lleva cero comentarios porque el *por qué* está en el `README.md` del paquete. Quitar comentarios sin escribir
el README no es limpieza, es pérdida de información.

- Prohibido todo comentario (`//`, `/* */`, `///`, `#`); los verificadores lo rechazan mecánicamente. Única excepción:
  el *docstring* de Python descrito en `QUALITY-NO-COMMENTS`.
- El código se explica con nombres completos, funciones pequeñas, tipos explícitos y una responsabilidad por archivo.
- Nunca se referencia un documento o sección desde el código.
- Prohibido `TODO` en el código: los pendientes técnicos van en la sección de pendientes declarados del README del
  paquete.

**Rust.** Además se prohíben los comentarios de documentación y los atributos `#[doc]`, `#[allow]` y `#[expect]`; no hay
excepción de docstring. `unsafe` solo se permite en los crates que declara `architecture.yaml`, dentro de funciones
breves
cuyo nombre expresa el invariante y que tengan fila en la tabla «Invariantes de `unsafe`» de su README (el verificador
exige correspondencia en ambos sentidos). Los demás crates declaran `#![forbid(unsafe_code)]`.

---

## 5. Testing

- La carpeta de tests refleja la de código, y cada test vive junto al comportamiento que prueba.
- Camino feliz, camino infeliz y casos límite: entradas vacías, colecciones de tamaño cero, recursión profunda, bordes
  numéricos, identificadores de un carácter, programas vacíos.
- Ninguna excepción sin control cruza la frontera pública de un paquete: un fallo esperable es un valor de retorno.
- Si un test necesita instanciar tres o cuatro clases para probar una, hay acoplamiento que la inyección de dependencias
  debió evitar.
- Los verificadores también se prueban: cada uno lleva un caso negativo con una violación deliberada.

**Rust.** Los tests de caja negra viven en `tests/`, espejo de `src/`; los internos, en archivos hermanos
`<módulo>_tests.rs` declarados con `#[cfg(test)]`, nunca en línea. Los casos del corpus no se duplican como tests de
Rust. Los fixtures de violaciones deliberadas se excluyen del recorrido ordinario y se verifican como casos negativos.

---

## 6. Checklist antes de dar un archivo por terminado

- **Una responsabilidad:** ¿puedo describirlo en una frase sin «y»?
- **Abierto/cerrado:** ¿un caso nuevo exige modificar este archivo, o solo añadir uno al lado? Las variantes de
  comportamiento se inyectan como datos, no se ramifican con condicionales sobre la configuración.
- **Contratos consistentes:** ¿una segunda implementación de esta interfaz rompería a algún consumidor?
- **Interfaces segregadas:** ¿obliga a implementar métodos que un consumidor no necesita?
- **Dependencias invertidas:** ¿depende de una implementación concreta pudiendo depender de una interfaz? Si un test
  necesita infraestructura real para ejercitar lógica, sí.
- **YAGNI:** ¿lo pide una fase aprobada?
- **DRY con límite:** ¿es duplicación real del mismo concepto, o coincidencia superficial? Es preferible una duplicación
  pequeña y honesta a una abstracción prematura que une conceptos que van a divergir.

Señales de capa mezclada: imports que `architecture.yaml` no permite; el mismo `switch` sobre un tipo repetido en más de
dos lugares; texto destinado a personas fuera de la capa responsable; más parámetros posicionales que el límite del
paquete; un comentario que explica *qué* hace la línea siguiente; un cambio de arquitectura sin cambio en el README.

---

## 7. Skills

En `.agents/skills/`:

| Skill            | Cuándo usarla                                                    |
|------------------|------------------------------------------------------------------|
| `commit-message` | Formato de los mensajes de commit del repositorio y sus paquetes |

---

## 8. Entorno

- **Núcleo:** Rust. El corpus es el oráculo normativo y todo cambio observable sigue especificación → casos → tests
  → código.
- **Cadenas de herramientas** (cada miembro usa solo la suya, todas en el `PATH`; los comandos se documentan sin rutas
  absolutas):
    - `dart` y `flutter`: recolectores de métricas y app.
    - `python3` con `fonttools`: motor de marca.
    - `deno` con la CLI de `supabase`: backend (`apps/pseudolearn_backend`).
    - `node` con `pnpm`: frontend web (`apps/pseudolearn_web`), extensión (`apps/pseudolearn_vscode`, Node 26.13.1 y
      pnpm 12.18.0) y motor de assets de tienda (`packages/pseudolearn_store_media`), que además requiere `ffmpeg` y
      `ffprobe` como dependencia del sistema.
    - `cargo` y `rustup`: verificadores Rust, `pseudolearn_spec`, `pseudolearn_engine`, `pseudolearn_cli`,
      `pseudolearn_reference`, `pseudolearn_benchmarks` y los puentes. Cada miembro Rust fija la misma versión exacta en `rust-toolchain.toml`; no
      hay workspace Cargo raíz.
- **Ubicación:** `packages/` aloja lo reutilizable que no se despliega; `apps/`, lo que se despliega. El criterio es el
  papel del miembro, no su lenguaje.
- **Git:** monorepo. Los paquetes de librería no versionan su `pubspec.lock`; las aplicaciones sí. La salida de un
  generador no se versiona salvo que un build ajeno la consuma.
- **Fases:** cada fase resuelve sus observaciones pertinentes, informa implementación, pruebas, verificadores y
  pendientes
  justificados, y publica su rama con push ordinario comprobado. Sin coautoría ni atribución de IA en commits.
  `PHASE-GREEN` exige verificaciones locales en verde, y la remota solo cuando la fase la pide y la persona la autoriza.
  `PHASE-STOP` exige autorización nueva.
- **CI:** GitHub Actions se reserva para despliegues productivos y comprobaciones manuales puntuales; no verifica cada
  push ni PR.
- **Comandos:** los de cada paquete están en la sección «Cómo se verifica» de su README.

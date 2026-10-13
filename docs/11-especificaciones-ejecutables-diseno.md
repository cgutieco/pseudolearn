# 11 · Especificaciones ejecutables: diseño propuesto

> **Estado:** **propuesta** de diseño, no aprobada. No cambia `DOC-README-TRUTH`, `AGENTS.md`, ninguna
> skill ni `language-spec.md`. Los cambios que harían falta en esas reglas se enumeran en §13 para que
> la persona responsable decida ([D-09](17-riesgos-preguntas-y-decisiones.md#d-09)).
> Ejemplos completos en [12](12-especificaciones-ejecutables-ejemplos.md).

Responde a V-45, V-47 y V-50 a V-63. El nombre provisional del sistema es **SEE** (Sistema de
Especificaciones Ejecutables); el nombre definitivo es decisión de la persona responsable.

---

## 1. Requisitos de diseño

| ID      | Requisito                                                                                                             | Origen                                   |
|---------|-----------------------------------------------------------------------------------------------------------------------|------------------------------------------|
| SEE-R1  | Cada afirmación normativa tiene identidad estable, versión y estado                                                   | V-52, V-58                               |
| SEE-R2  | Cada afirmación declara cómo se verifica, con nivel N0–N5 ([10](10-especificaciones-ejecutables-fundamentos.md) §2.2) | V-48                                     |
| SEE-R3  | Estructura normalizada y validable por máquina                                                                        | V-51                                     |
| SEE-R4  | Dependencias con rangos de versión y anclaje exacto                                                                   | V-53                                     |
| SEE-R5  | Detección de cambios, clasificación preliminar y propagación de impacto                                               | V-54, V-55                               |
| SEE-R6  | Vínculos con implementación, pruebas y documentación **como datos** (el código no admite comentarios)                 | V-56, `QUALITY-NO-COMMENTS`              |
| SEE-R7  | Independencia de oráculos como política del sistema                                                                    | V-57                                     |
| SEE-R8  | Propuestas visibles pero no exigibles                                                                                  | V-58, `SCOPE-YAGNI`                      |
| SEE-R9  | Consumible por las cuatro cadenas del monorepo (Dart, Python, Deno, Node)                                             | `AGENTS.md` §9                           |
| SEE-R10 | Prosa en español; identificadores y código en inglés                                                                  | `LANG-ES-DOCS`, `LANG-EN-CODE`           |
| SEE-R11 | Casos de lenguaje ejecutables en los dos perfiles                                                                      | Identidad bilingüe                       |
| SEE-R12 | Artefactos derivados generados y verificados, nunca copiados                                                           | `GEN-NO-HAND-COPY`                       |
| SEE-R13 | Coste de autoría bajo para la regla típica (minutos, no horas)                                                         | Riesgo de burocracia ([17](17-riesgos-preguntas-y-decisiones.md) R-05) |

---

## 2. Estados y ciclo de vida

```
 borrador ──► propuesta ──► experimental ──► estable ──► obsoleta ──► retirada
     │            │               │
     └────────────┴───────────────┴──► rechazada
```

| Estado        | ¿Normativa?                     | ¿Exigible en CI?                                     | Quién debe conformar               | Cambios admitidos                               | Visible en documentación pública |
|---------------|---------------------------------|------------------------------------------------------|------------------------------------|-------------------------------------------------|----------------------------------|
| borrador      | No                              | Solo validación estructural                          | Nadie                              | Cualquiera                                       | No                               |
| propuesta     | No                              | Estructural; sus casos pueden ejecutarse como «esperado fallo» | Nadie                     | Cualquiera, con registro                         | Como propuesta, marcada          |
| experimental  | Sí, **detrás de una activación explícita** en el manifiesto del paquete | Sí, para sujetos que la declaren       | Sujetos que la implementan         | Incompatibles admitidos con registro             | Marcada como experimental        |
| estable       | Sí                              | Sí, para todos los sujetos declarados                | Todos los sujetos declarados       | Solo con clasificación (§6); incompatibles solo con edición nueva si es del lenguaje | Sí |
| obsoleta      | Sí, con aviso                   | Sí                                                   | Todos; deben emitir el aviso        | Solo editoriales                                 | Sí, con fecha o edición de retirada |
| retirada      | No                              | Sus casos se conservan como «ya no aplica»          | Nadie                              | Ninguno (lápida)                                 | Solo en historial                |
| rechazada     | No                              | No                                                   | Nadie                              | Ninguno                                          | Solo en historial                |

Condiciones de paso (propuesta):

- **propuesta → experimental:** decisión de la persona responsable; todas las reglas con verificación
  declarada; impacto en el presupuesto reservado medido si añade vocabulario.
- **experimental → estable:** todos los casos verdes en al menos **dos sujetos** cuando la regla es del
  lenguaje (intérprete de referencia y VM, cuando exista; antes, núcleo y un oráculo independiente);
  casos revisados por alguien distinto de quien escribió la regla; sin preguntas abiertas.
- **estable → obsoleta:** existe reemplazo o justificación; migración especificada.
- **obsoleta → retirada:** ha pasado al menos una edición (lenguaje) o el plazo declarado (resto).

El estado responde a V-58: una propuesta es **visible** (se lee, se discute, sus casos pueden ejecutarse
en modo «esperado fallo») pero **no exigible**, y no hay forma de confundirla con un contrato aprobado
porque su estado es un dato que el validador, el ejecutor y los generadores de documentación leen.
Esto encaja con `SCOPE-YAGNI`: especificar una propuesta no autoriza implementarla.

---

## 3. Anatomía de una especificación

### 3.1 Metadatos

| Campo            | Obligatorio | Contenido                                                                                               |
|------------------|-------------|---------------------------------------------------------------------------------------------------------|
| `id`             | Sí          | Identificador estable (§5)                                                                              |
| `titulo`         | Sí          | En español; opcionalmente `titulo_en`                                                                   |
| `dominio`        | Sí          | `lenguaje`, `ri`, `motor`, `memoria`, `biblioteca`, `herramienta`, `app`, `rendimiento`, `proceso`       |
| `estado`         | Sí          | §2                                                                                                      |
| `version`        | Sí          | `MAYOR.MENOR.REVISION` (§6)                                                                             |
| `edicion`        | Lenguaje    | Edición del lenguaje en que entra o cambia (`introducida_en`, `retirada_en`)                             |
| `duenos`         | Sí          | Personas o roles responsables                                                                           |
| `sujetos`        | Sí          | Qué implementaciones deben conformar (p. ej., `nucleo`, `vm`, `aot`, `app`, `lsp`)                      |
| `depende_de`     | No          | Lista de `{id, version: rango, tipo}` (§7)                                                              |
| `reemplaza` / `reemplazada_por` | No | Identificadores                                                                                  |
| `resumen`        | Sí          | Un párrafo                                                                                              |

### 3.2 Cuerpo normativo

| Elemento               | Forma                                                                                                                 | Comentario                                                                                          |
|------------------------|-----------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| **Definiciones**       | `D1`, `D2`…: término y definición; o enlace a un glosario especificado                                               | Los términos definidos se citan en las reglas; el validador comprueba que existan                    |
| **Reglas**             | `R1`, `R2`…: texto con fuerza **DEBE / NO DEBE / DEBERÍA / NO DEBERÍA / PUEDE** (adaptación de RFC 2119 y RFC 8174), clase y verificación declarada | Una regla, una afirmación. La fuerza va en mayúsculas para que el validador la reconozca |
| **Invariantes**        | `I1`…: afirmaciones que valen siempre                                                                                 | Candidatas naturales a propiedades (N3)                                                             |
| **Precondiciones**     | `P1`…: lo que debe valer antes de una operación                                                                       | Para funciones incorporadas, acciones de la app, consultas del servicio de lenguaje                 |
| **Resultados**         | `S1`…: lo que vale después                                                                                            | Poscondiciones                                                                                       |
| **Errores**            | `E1`…: situación → clase (léxico, sintáctico, semántico, ejecución, recurso) → código de diagnóstico → clase de severidad (A–E) | La forma de las tablas «Situación / Clase de error» de la especificación vigente, ahora con identidad |
| **Casos**              | `C1`…: ejecutables (§3.3); los de borde llevan la etiqueta `limite`                                                   | Incluye el «ejemplo mínimo válido y mínimo inválido» que la skill vigente ya exige                  |
| **Propiedades**        | `Q1`…: generador, propiedad, oráculo                                                                                  | N3                                                                                                  |
| **No objetivos**       | Lista                                                                                                                 | Lo que la especificación deliberadamente no cubre                                                    |

Cada regla declara su **verificación**: lista de casos o propiedades que la cubren, una comprobación
estructural, o `revision_humana` con justificación obligatoria. Una regla sin verificación ni
justificación es un error de validación (**ninguna regla huérfana**).

### 3.3 Casos

Un caso de **lenguaje** fija: perfiles en que se ejecuta, nivel y rigor, programa, entradas, y lo
esperado entre: diagnósticos (código, clase, tramo y tramos relacionados), salida, eventos observables
(proyección de la traza, [06](06-ejecucion-pedagogica-y-app.md) §1.2), estado observable en puntos
dados, o terminación con fallo. Un caso de **app** o **herramienta** fija un estado inicial, una acción
y un resultado observable a través del adaptador (por ejemplo, lista de autocompletado en una posición).
Un caso de **rendimiento** fija carga, plataforma, método estadístico y umbral.

Cada valor esperado lleva su **origen**: `escrito` (por una persona), `derivado` (de una propiedad o de
otra regla) o `capturado` (de una ejecución; exige `revisado_por`). Ver §10.

**Casos en los dos perfiles.** Un caso de lenguaje se escribe en un perfil y declara en cuáles se
ejecuta. Para ejecutarlo en el otro, el ejecutor **reimprime el flujo de tokens** con el léxico del
perfil de destino: es una operación del plano léxico, sin intervención del parser ni del motor, y está
verificada por sus propios casos (ida y vuelta idéntica). Si el programa contiene un identificador que
sería palabra reservada en el otro perfil (por ejemplo, una variable `step`), el validador lo detecta y
exige que el caso incluya explícitamente el texto en ese perfil o que lo excluya con justificación. Los
valores esperados que contienen lexemas (como `Verdadero`/`true` en una salida) se expresan con
marcadores de lexema (`{{lexema:booleanTrue}}`, el mecanismo que ya usa la base de conocimiento) para
que un solo valor esperado sirva en los dos perfiles.

### 3.4 Cuerpo no normativo

Motivación, alternativas descartadas y su porqué, fuentes consultadas, preguntas abiertas (solo en
`borrador` y `propuesta`). **El porqué de una regla de comportamiento vive con la regla**, no en un
`README.md`; el `README.md` de un paquete conserva el porqué de su arquitectura (§13).

---

## 4. Formato y validación

### 4.1 Formato propuesto

**Markdown con metadatos YAML al principio y bloques cercados tipados**: prosa legible y fácil de revisar
en un diff, con estructura extraíble por máquina.

````markdown
---
id: LANG.CONTROL.FOR
titulo: Bucle contado
dominio: lenguaje
estado: estable
version: 2.0.0
edicion: { introducida_en: "2026" }
sujetos: [nucleo]
depende_de:
  - { id: LANG.TYPES.INTEGER, version: "^1", tipo: usa }
---

# Bucle contado

```regla
id: R3
fuerza: DEBE
clase: semantica
texto: >
  Los valores inicial, final y paso se evalúan exactamente una vez, en ese orden,
  antes de la primera prueba.
verificacion: [C4, C5]
```
````

(El bloque `regla` usa YAML dentro de un cercado con etiqueta de información; los casos pueden ir en
línea o en archivos aparte bajo `casos/` cuando incluyen programas largos.)

**Alternativas consideradas:**

| Formato                                 | A favor                                       | En contra                                                        |
|-----------------------------------------|-----------------------------------------------|------------------------------------------------------------------|
| **Markdown + YAML + bloques tipados** (propuesto) | Legible; la app ya procesa Markdown (`package:markdown`); revisable | Dos analizadores (Markdown y YAML)                     |
| YAML o TOML puro                        | Un solo analizador                            | Prosa larga incómoda; peor revisión en diffs                      |
| CUE o Pkl                               | Validación potente integrada                  | Herramienta ajena a las cuatro cadenas; curva                    |
| Gherkin                                 | Legible, con palabras clave en español        | No modela reglas, versiones ni dependencias; solo casos           |
| DSL propio tipo SpecTec                 | Máximo poder (genera intérpretes)             | Coste de diseño enorme; horizonte para la semántica central       |

### 4.2 Capas de validación

1. **Esquema** (JSON Schema versionado, `see/1`) de metadatos y de cada tipo de bloque.
2. **Integridad referencial:** identificadores únicos; referencias resueltas; dependencias satisfacibles;
   códigos de diagnóstico existentes en el catálogo; términos definidos.
3. **Reglas del sistema:** ninguna regla huérfana; nada de preguntas abiertas en `estable`; los valores
   `capturado` tienen revisor; un estado `estable` tiene casos en todos sus sujetos.
4. **Coherencia de contenido:** el hash del contenido normativo coincide con la versión declarada (§6.3);
   los programas de los casos analizan según lo esperado en ambos perfiles.
5. **Estilo:** fuerza normativa en mayúsculas; una afirmación por regla (heurística, con aviso).

---

## 5. Identidad

### 5.1 Esquema de identificadores (propuesta)

```
<DOMINIO>.<ÁREA>.<TEMA>[@<versión>][#<elemento>]

LANG.CONTROL.FOR              especificación
LANG.CONTROL.FOR@2.0.0        versión exacta
LANG.CONTROL.FOR#R3           regla 3 (versión vigente)
LANG.CONTROL.FOR@2.0.0#C5     caso 5 de una versión exacta
```

- Mayúsculas ASCII, sin tildes, para que funcionen igual en rutas, URLs, YAML y las cuatro cadenas.
- **Nunca se reutilizan.** Un renombre es una especificación nueva con `reemplaza`.
- Los elementos internos (`R3`, `C5`) **nunca se renumeran**; un elemento retirado deja lápida.
- Los códigos de diagnóstico existentes (`expectedDoKeyword`) se convierten en entidades del corpus
  (`DIAG.SYNTAX.EXPECTED-DO-KEYWORD`, por ejemplo), con su ficha bilingüe.
- Los dominios propuestos: `LANG`, `IR` (representación intermedia), `ENG` (motor), `MEM`, `LIB`,
  `TOOL`, `APP`, `PERF`, `DIAG`, `SEE` (el propio sistema).

El idioma de los mnemónicos (inglés, coherente con los identificadores de regla de `AGENTS.md`, o
español, coherente con la identidad) es [D-20](17-riesgos-preguntas-y-decisiones.md#d-20).

### 5.2 Granularidad

Una especificación agrupa reglas que **cambian juntas** (misma razón de cambio, como un archivo de
código). `language-spec.md` tiene catorce secciones; su migración produciría del orden de cuarenta a
sesenta especificaciones (una por construcción o subconstrucción: bucle contado, selección múltiple,
parámetros, retorno, visibilidad…).

---

## 6. Versionado y clasificación de cambios

### 6.1 Dos audiencias, dos compatibilidades

Un cambio puede ser compatible para quien **usa** lo especificado (programas, personas usuarias de la
app, consumidores de una API) e incompatible para quien lo **implementa**, o al revés. Ejemplo: añadir
`Para Cada` es compatible para los programas (ninguno deja de ser válido) y obliga a todos los motores.
Por eso la clasificación registra ambas:

| Clase de cambio            | Efecto sobre usuarios           | Efecto sobre implementaciones    | Versión       | Lenguaje: ¿edición nueva? |
|----------------------------|---------------------------------|----------------------------------|---------------|---------------------------|
| **Editorial**              | Ninguno                         | Ninguno                          | REVISIÓN      | No                        |
| **Verificación añadida** (caso o propiedad nuevos para una regla existente) | Ninguno si todos los sujetos cumplen | Puede revelar incumplimientos | REVISIÓN | No |
| **Aclaración**             | Ninguno si todos los sujetos ya la cumplían | Ninguno o arreglo          | MENOR (con revisión) | No                 |
| **Ampliación**             | Compatible (más programas válidos, más capacidades) | Nueva obligación         | MENOR         | No                        |
| **Restricción**            | Incompatible (programas válidos dejan de serlo) | Nueva obligación        | MAYOR         | **Sí**                    |
| **Cambio de significado**  | Incompatible (mismo programa, otro resultado) | Nueva obligación          | MAYOR         | **Sí**                    |
| **Deprecación**            | Avisos                          | Emitir avisos                    | MENOR         | No                        |
| **Retirada**               | Incompatible                    | Quitar                           | MAYOR         | **Sí**                    |

### 6.2 Clasificación preliminar automática

El sistema compara el **contenido normativo normalizado** de dos versiones y propone una clase; una
persona la confirma y la confirmación queda registrada.

| Diferencia detectada                                              | Clase preliminar                         |
|-------------------------------------------------------------------|------------------------------------------|
| Solo cambia prosa no normativa                                    | Editorial                                |
| Texto de una regla cambiado                                       | **Requiere revisión**                    |
| Regla añadida                                                     | Ampliación, **marcada para revisión** si afecta a construcciones existentes |
| Regla retirada                                                    | Retirada                                 |
| Fuerza normativa endurecida (PUEDE → DEBE)                        | Restricción candidata                    |
| Valor esperado de un caso existente cambiado                      | **Cambio de significado candidato**      |
| Caso añadido                                                      | Verificación añadida; se ejecutan todos los sujetos y, si alguno falla, pasa a revisión |
| Definición cambiada                                               | Requiere revisión, con propagación a todas las reglas que la usan |
| Rango de dependencia estrechado                                   | Requiere revisión                         |
| Estado `estable → obsoleta`                                       | Deprecación                              |

Es el mismo principio que cargo-semver-checks o `elm diff` aplican a una API, extendido a contratos de
comportamiento. La clasificación de significado no puede ser totalmente automática
([10](10-especificaciones-ejecutables-fundamentos.md) §6).

### 6.3 Hash de contenido

Cada versión guarda el hash de su contenido normativo canónico. Si el contenido cambia sin cambiar la
versión, la validación falla. Así una edición «inocente» no puede alterar un contrato estable sin
pasar por la clasificación.

---

## 7. Dependencias y anclaje

### 7.1 Tipos de dependencia

| Tipo        | Significado                                                                            | Ejemplo                                                      |
|-------------|----------------------------------------------------------------------------------------|--------------------------------------------------------------|
| `usa`       | Cita definiciones o reglas de la otra                                                   | `LANG.CLOSURE.CAPTURE` usa `LANG.SCOPE.BLOCK`                |
| `refina`    | Añade detalle sin contradecir                                                           | `LANG.CONTROL.FOR-EACH` refina `LANG.CONTROL.FOR`            |
| `restringe` | Limita en un contexto (perfil, nivel)                                                   | Un nivel pedagógico restringe construcciones                  |
| `requiere`  | Debe implementarse antes                                                                | `TOOL.LSP.COMPLETION` requiere `TOOL.SERVICE.LOSSLESS-TREE`  |

**El grafo es acíclico.** Si dos especificaciones se citan mutuamente, lo común se extrae a una tercera
(glosario o fundamento). Es la misma regla que `LAYER-DIRECTION` aplica al código.

### 7.2 Rangos y anclaje

- Las dependencias entre especificaciones usan **rangos** (`^2` = cualquier 2.x).
- El corpus tiene un **archivo de bloqueo** generado (`especificaciones.lock`) con la versión exacta y
  el hash de cada especificación en el commit; es lo que hace reproducible un informe de conformidad.
- Los **vínculos** de implementación y prueba (§9) anclan versiones **exactas**: una implementación
  dice «cumplo `LANG.CONTROL.FOR@2.0.0`», no «cumplo la 2.x».

---

## 8. Detección de cambios e impacto

Al publicarse una versión nueva `v'` de una especificación `X`:

1. **Especificaciones dependientes** cuyo rango no incluye `v'` → estado derivado **«revisión
   requerida»**; deben revisarse y ampliar su rango (o fijarse en la anterior y declararlo).
2. **Vínculos** de implementaciones y pruebas anclados a `v` → **«desactualizado»**; en CI, un vínculo
   desactualizado de una especificación `estable` falla, salvo que exista una entrada `pendiente` con
   la fase que lo resolverá.
3. **Artefactos generados** que dependen de `X` (léxicos, gramáticas de editor, plantillas, referencia
   publicada en la base de conocimiento) → se regeneran; el verificador de artefactos falla si están
   desactualizados (el patrón del motor de marca: `python3 -m pseudolearn_brand check`).
4. **Documentación** que cita `X` (los `README.md`, la base de conocimiento) → aviso con la lista de
   lugares; si la cita es a un elemento retirado, error.
5. Se produce un **informe de impacto** (texto y JSON) adjuntable a la revisión del cambio.

La «advertencia a consumidores» es, por tanto, un dato que la CI y la revisión leen; no requiere ningún
servicio externo. (Ejemplo de informe en [12](12-especificaciones-ejecutables-ejemplos.md) §8.)

---

## 9. Vínculos con implementación, pruebas y documentación

### 9.1 Archivo de conformidad por sujeto

Cada paquete que es sujeto de especificaciones declara, **en un archivo de datos**, qué cumple y cómo se
verifica:

```yaml
sujeto: nucleo
paquete: packages/pseudolearn_core
vinculos:
  - regla: LANG.CONTROL.FOR@2.0.0
    verificacion: ejecutor
    estado: cumple
  - regla: LANG.SYNTAX.RECOVERY@1.0.0#R3
    verificacion: ejecutor
    estado: pendiente
    resuelve_en: F2
  - regla: ENG.TRACE.SNAPSHOT@1.0.0#R2
    verificacion: test/evaluation/events/snapshot_builder_test.dart
    estado: cumple
```

- `ejecutor`: los casos de la especificación los ejecuta el ejecutor de conformidad a través del
  adaptador del sujeto.
- Ruta de test: un test escrito a mano que verifica la regla. El vínculo vive aquí y no en un
  comentario del test.
- `pendiente`: incumplimiento conocido con fase de resolución; no rompe la CI mientras la fase no se
  cierre.
- `exento`: no aplica a este sujeto, con justificación.

### 9.2 Matriz de cobertura

El informe de conformidad cruza especificaciones × vínculos × resultados: por regla y por sujeto,
`cumple`, `incumple`, `pendiente`, `exento` o `sin vínculo`. Es la «matriz regla × sujeto» que sustituye
a la pregunta «¿pasan los tests?».

### 9.3 Documentación

- Los `README.md` citan identificadores (`LANG.CONTROL.FOR`) en prosa. Un verificador ligero comprueba
  que existan y no estén retirados (N1). El `README.md` sigue siendo prosa escrita por personas.
- La base de conocimiento de la app (`esp-i-*`, `esp-o-*`) se **genera o se comprueba** contra las
  especificaciones; la columna «Proyectada en» de `language-spec.md` pasa a ser un dato del corpus.
- `language-spec.md` se migra al corpus por etapas (§13.3) y termina siendo una **vista generada** o
  desaparece.
- El código no cita identificadores de especificación (sin comentarios y sin acoplar `lib/` al
  corpus); solo los ejecutores, los adaptadores y los artefactos generados los llevan, como datos.

---

## 10. Independencia de oráculos como política

Las contramedidas de [10](10-especificaciones-ejecutables-fundamentos.md#errores-compartidos) se
convierten en reglas del sistema (ellas mismas especificadas en el dominio `SEE`):

1. **Origen de cada valor esperado** obligatorio; `capturado` sin revisor no valida.
2. **El ejecutor de conformidad solo usa la API del adaptador**; importar internos del sujeto es una
   violación de capas del paquete del sistema.
3. **Dos sujetos** para estabilizar reglas del lenguaje (§2).
4. **Mutación periódica** del sujeto (los casos deben matar mutantes) y de la especificación (alterar
   una regla debe hacer fallar algún caso); el resultado se publica como métrica de salud, no como
   puerta.
5. **Ejecución en todos los objetivos** (nativo, JavaScript, Wasm) del corpus del lenguaje.
6. **Relaciones metamórficas** obligatorias para casos de lenguaje: cada caso se ejecuta en los dos
   perfiles y su traza debe coincidir salvo lexemas.

---

## 11. Paquete independiente

### 11.1 Propuesta

Un miembro nuevo `packages/pseudolearn_spec` (Dart, coherente con el núcleo y la app), que según la
regla vigente de `packages/` es «reutilizable, sin interfaz, sin despliegue»:

```
packages/pseudolearn_spec/
├── README.md               fuente de verdad de la arquitectura del sistema
├── architecture.yaml       capas y límites del paquete
├── especificaciones/       el corpus (datos; sin código)
│   ├── lang/  ir/  eng/  mem/  lib/  tool/  app/  perf/  diag/  see/
│   └── especificaciones.lock   (generado)
├── esquemas/               JSON Schema del formato, versionado
├── lib/src/
│   ├── model/              entidades: especificación, regla, caso, vínculo
│   ├── format/             lectura de Markdown + YAML
│   ├── validation/         capas de §4.2
│   ├── graph/              dependencias, impacto, ciclos
│   ├── change/             hash canónico, diff, clasificación
│   ├── conformance/        interfaz de adaptador, ejecutor, resultados
│   └── report/             matriz, impacto, exportación JSON
├── bin/                    orden `see` (validar, grafo, impacto, diff, cobertura, exportar)
└── test/
```

### 11.2 Dependencias y ausencia de ciclos

```
packages/pseudolearn_spec   ← no depende de ningún miembro del monorepo
        ▲ (dev_dependency)
        ├── packages/pseudolearn_core     adaptador en test/ implementa la interfaz de conformidad
        ├── apps/pseudolearn_app          adaptador en test/ para especificaciones APP y TOOL
        └── (futuros: vm, compilador, servicio de lenguaje)

Consumidores en otras cadenas (backend en Deno, web en Node, marca en Python):
leen la exportación JSON generada por `see exportar`, verificada como artefacto.
```

- El sistema define la interfaz del adaptador (**inversión de dependencias**); cada sujeto la implementa
  en sus tests. El núcleo no depende del sistema en `lib/`.
- El corpus no contiene código; los programas de los casos son datos para el sujeto.
- **Fuente única:** cada afirmación normativa vive en una sola especificación; las vistas (documentación
  generada, exportación JSON) llevan la marca «generado desde `ID@versión`» y un verificador las compara.

### 11.3 Alternativas descartadas o aplazadas

| Alternativa                                               | Por qué no (por ahora)                                                                                 |
|-----------------------------------------------------------|--------------------------------------------------------------------------------------------------------|
| Especificaciones dentro de cada paquete                   | Las reglas transversales (traza de ejecución, la consumen núcleo, VM y app) no tienen un único dueño; se duplicarían |
| Dos paquetes (corpus y herramientas)                      | Separación útil cuando el corpus tenga ritmo propio; hoy añade un miembro sin problema que resolver (`SCOPE-YAGNI`) |
| Repositorio aparte                                        | Pierde el cambio atómico «regla + implementación + caso» en un mismo commit                           |
| Herramienta en Python o TypeScript                        | El núcleo y la app, que son los sujetos principales, son Dart                                          |
| Carpeta de raíz `specs/`                                  | Contradice la regla de §4.5 del `README.md` raíz (nada de carpetas de raíz por excepción)              |

Decisión en [D-10](17-riesgos-preguntas-y-decisiones.md#d-10).

---

## 12. Las especificaciones como base arquitectónica verificable

**[INFERENCIA]** El campo `sujetos` de cada especificación es, leído en conjunto, un **mapa de qué
componente responde de qué comportamiento**. Junto con los archivos de conformidad, permite comprobar
mecánicamente afirmaciones arquitectónicas que hoy son prosa:

- «La app no contiene lógica de lenguaje» → ninguna especificación `LANG` tiene a `app` como sujeto.
- «Todos los motores producen la misma traza» → `ENG.TRACE.*` tiene como sujetos `nucleo`, `vm`, `aot`
  (en modo reproducción) y la conformidad cruza los tres.
- «La representación intermedia es el contrato entre front-end y backends» → `IR.*` tiene como sujetos
  el front-end (productor) y cada backend (consumidor).
- «Las herramientas comparten un resolutor» → `TOOL.RESOLVE.*` tiene un único sujeto implementador y
  varios consumidores que lo declaran.

Combinado con los `architecture.yaml` vigentes (que verifican el **cómo** dentro de cada paquete), el
corpus verifica el **qué** entre paquetes.

---

<a id="transicion-readme"></a>

## 13. Evolución del contrato «el `README.md` es la fuente de verdad»

### 13.1 Situación

**[COMPROBADO]** `DOC-README-TRUTH` hace del `README.md` de cada paquete la fuente de verdad técnica; la
skill `package-docs` prohíbe carpetas de decisiones fuera de él y exige presente normativo sin
historia; `language-spec.md` es la fuente de verdad de la gramática (`AGENTS.md` §3, nivel 4). Ya hay
excepciones de hecho (H-29). La visión pide analizar cómo debe evolucionar este contrato sin
resolverlo aquí (V-63).

### 13.2 Opciones

| Opción | Contrato                                                                                                                                       | A favor                                                         | En contra                                                                                   |
|--------|------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| R1     | Sin cambios: el `README.md` manda; las especificaciones son pruebas                                                                            | Ningún cambio de reglas                                         | Dos textos normativos sobre lo mismo; vuelve a producir H-02 a H-07                          |
| **R2** | **Reparto por naturaleza:** las especificaciones son la fuente de verdad del **comportamiento observable** (qué); el `README.md`, de la **arquitectura, operación y porqué de la implementación** (cómo); cada uno cita al otro por identificador | Cada afirmación tiene un único dueño; los `README.md` adelgazan sin perder su papel | Cambia `DOC-README-TRUTH`, `package-docs`, `language-spec-authoring` y el orden de precedencia |
| R3     | Las especificaciones son la fuente de todo; los `README.md` se generan                                                                          | Una sola fuente                                                 | La prosa de arquitectura y operación no se genera bien; burocracia                            |
| R4     | El `README.md` como índice delgado de especificaciones                                                                                          | Simple                                                          | Pierde el porqué de la arquitectura, que hoy es su mayor valor                                |

**Recomendación: R2.** Es la que mejor conserva lo que funciona (el `README.md` como explicación de una
arquitectura, que el código sin comentarios necesita) y elimina la duplicación de afirmaciones de
comportamiento.

### 13.3 Qué habría que cambiar (no aplicado)

| Elemento                              | Cambio que R2 requeriría                                                                                                     |
|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| `AGENTS.md` §2                        | Reglas nuevas propuestas: `SPEC-BEHAVIOR-TRUTH` (el comportamiento observable vive en el corpus), `SPEC-NO-ORPHAN-RULE`, `SPEC-BINDING-AS-DATA`, `SPEC-CHANGE-CLASSIFIED`, `SPEC-INDEPENDENT-ORACLE`; acotar `DOC-README-TRUTH` a arquitectura y operación |
| `AGENTS.md` §3 (precedencia)          | Situar el corpus de especificaciones; hoy `language-spec.md` es el nivel 4                                                    |
| Skill `package-docs`                  | Admitir que la sección 6 («decisiones de producto que condicionan el código») cite identificadores; aclarar que el historial de versiones vive en el corpus, no en el `README.md` |
| Skill `language-spec-authoring`       | Escribir construcciones como especificaciones del corpus; nuevo criterio de desempate ([04](04-filosofia-y-modelo-del-lenguaje.md) §1.2) |
| Skill nueva `spec-authoring`          | Cómo escribir, clasificar y estabilizar una especificación                                                                   |
| Skill `phase-gate`                    | Añadir «matriz de conformidad sin regresiones» a la comprobación de cierre                                                    |
| `language-spec.md`                    | Migración por secciones con tabla de correspondencia; durante la transición, cada sección migrada se sustituye por un enlace |

### 13.4 Transición propuesta

1. **Convivencia:** se especifican en el corpus solo construcciones nuevas y las secciones que se
   migren; `language-spec.md` sigue siendo normativo para lo no migrado.
2. **Tabla de correspondencia** sección → identificadores, verificada mecánicamente.
3. **Criterio de fin:** toda sección de `language-spec.md` migrada, con casos verdes en el núcleo; la
   persona responsable declara el cambio de reglas en un mensaje explícito (`PHASE-STOP`).

Ninguno de estos pasos se ha dado; dependen de [D-09](17-riesgos-preguntas-y-decisiones.md#d-09).

---

## 14. Producto mínimo del sistema

Para que el sistema se gane su lugar, la primera versión debe demostrar valor con poco:

| Capacidad                                                  | En el mínimo |
|------------------------------------------------------------|--------------|
| Formato, esquema y validación (§4)                         | Sí           |
| Identidad, estados y versión (§2, §5, §6.1)                | Sí           |
| Ejecutor de conformidad N2 con adaptador del núcleo         | Sí           |
| Archivo de conformidad y matriz de cobertura (§9)          | Sí           |
| Hash de contenido y clasificación preliminar (§6.2, §6.3)  | Sí           |
| Grafo de dependencias e informe de impacto (§7, §8)        | Sí           |
| Propiedades N3                                             | Segunda iteración |
| Diferencial entre sujetos (N4)                             | Cuando exista la VM |
| Generación de artefactos (gramáticas, plantillas, base de conocimiento) | Segunda iteración |
| Migración completa de `language-spec.md`                   | Progresiva   |

Criterios de aceptación concretos en [15](15-evolucion-y-hoja-de-ruta.md) (fase F1) y experimento de
validación en [E-15](16-experimentos-y-benchmarks.md#e-15): migrar tres secciones y medir si el sistema
detecta los hallazgos H-02, H-05, H-06, H-18 y H-37 sin buscarlos.

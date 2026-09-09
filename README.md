# pseudolearn

Fuente de verdad técnica de la raíz del monorepo. Aquí vive el *por qué* de las decisiones transversales
—estructura de paquetes, tooling compartido, gestión de dependencias entre proyectos—, para que ningún
archivo de configuración necesite comentarios que lo expliquen. Un cambio de arquitectura o de decisión
de diseño a nivel de monorepo se documenta aquí en el mismo cambio que lo introduce (`DOC-README-TRUTH`).

Las reglas transversales de calidad, documentación y capas están en `AGENTS.md` (symlink `CLAUDE.md`),
en la misma carpeta que este archivo. Este documento no repite esas reglas: describe el mapa del
repositorio y las decisiones de organización que las hacen posibles. La arquitectura de cada paquete vive
en su propio `README.md`: `packages/pseudolearn_core/README.md` para el motor del lenguaje,
`packages/pseudolearn_brand/README.md` para el motor de la identidad visual y
`apps/pseudolearn_app/README.md` para el cliente Flutter.

El sitio público (landing, descargas) vive en su propio repositorio de git, fuera de este monorepo, y no
tiene entrada en el catálogo de carpetas de §3.3. Para que el motor de marca y el script de capturas de
producto puedan escribirle directo, se lo clona localmente como `apps/fe-pseudolearn/` —una carpeta que
este repositorio ignora (`.gitignore`) y no versiona— y ese es el único motivo por el que aparece como
destino de ruta en `packages/pseudolearn_brand/brand.json` y en `apps/pseudolearn_app/README.md` §2.8.

**Estado:** Monorepo de tres miembros activos —dos paquetes bajo `packages/` y una aplicación bajo
`apps/`— con una única arista de dependencia en tiempo de compilación, de la app hacia el núcleo por ruta
relativa, y una relación de generación de `pseudolearn_brand` hacia sus consumidores; sin tooling de
orquestación multi-proyecto (`melos` u otro) instalado.

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

`pseudolearn` es el monorepo raíz del ecosistema PseudoLearn: agrupa el motor de lenguaje puro en Dart y
la aplicación cliente en Flutter que lo consume, bajo un único árbol de control de versiones. Resuelve la
coherencia entre ambos proyectos —un cambio de contrato en el núcleo y su adaptación en la app se
revisan y versionan juntos— sin forzar a que compartan arquitectura, límites de tamaño ni criterios de
capas, porque un motor de lenguaje puro y un cliente de interfaz gráfica no tienen las mismas
responsabilidades ni las mismas tentaciones de acoplamiento.

Lo consume, en primer lugar, quien desarrolla sobre el repositorio: da el punto de entrada para ubicar
cualquier archivo, decidir en qué paquete trabajar y encontrar el comando de verificación correcto sin
tener que descubrirlo por ensayo y error.

### 1.2 Responsabilidades primarias

1. **Mapa del repositorio:** Ubicación de cada paquete y aplicación bajo `packages/` y `apps/`, y la
   regla de qué va en cada carpeta (§3.1).
2. **Reglas transversales del monorepo (`AGENTS.md`):** Contrato de reglas con ID estable, orden de
   precedencia ante conflictos entre fuentes, y catálogo de skills disponibles para quien trabaje en
   cualquier paquete.
3. **Gestión de dependencias entre proyectos:** La única arista de dependencia en tiempo de
   compilación del grafo interno —`apps/pseudolearn_app` hacia `packages/pseudolearn_core` por `path:`
   en `pubspec.yaml`— y su dirección obligatoria, más la relación de generación de
   `packages/pseudolearn_brand` hacia los artefactos que sus consumidores versionan (§3.2).
4. **Tooling compartido de dos puntos de entrada:** El symlink `CLAUDE.md` → `AGENTS.md` y el symlink
   `.claude/skills` → `.agents/skills`, que exponen la misma fuente de verdad a distintos agentes sin
   duplicarla.

### 1.3 Fuera de alcance a propósito (`SCOPE-YAGNI`)

#### De producto

- **Documentación de arquitectura de paquete:** Ninguna capa, decisión de diseño visual, algoritmo de
  layout, medida de marca o regla de negocio de un miembro concreto se describe aquí. Vive
  exclusivamente en el `README.md` de cada paquete (`DOC-README-TRUTH`); duplicarla aquí crearía una
  segunda fuente que diverge con el primer cambio no sincronizado.

#### De implementación técnica

- **Orquestador de monorepo (`melos`, `nx`, workspaces de npm u otro):** No existe herramienta de
  orquestación multi-paquete instalada. Cada paquete se prepara, compila y prueba con sus propios
  comandos nativos de su propia cadena de herramientas desde su propio directorio; el número de
  miembros del monorepo no justifica la complejidad operativa de un orquestador dedicado, que además
  tendría que abarcar dos cadenas de herramientas distintas.
- **CI/CD centralizado que ejecute los verificadores de cada paquete:** No hay integración continua que
  corra `flutter test`, `dart analyze` ni los scripts de `tool/` en cada cambio. La verificación mecánica
  de cada miembro se ejecuta localmente con los comandos declarados en su propio `README.md` y reunidos
  en §2.5. `.github/workflows/release-macos.yml` es la única automatización presente, y es de
  publicación —construye, firma, empaqueta y sube el `.pkg` a App Store Connect al crear un tag `v*.*.*`—, no de verificación
  continua (`apps/pseudolearn_app/README.md` §2.6).
- **`pubspec.yaml` de raíz:** La raíz no es un paquete Dart ni Flutter y no declara dependencias propias.
  Cada miembro del monorepo resuelve las suyas de forma independiente.

### 1.4 Casos de uso principales

1. **Incorporación de una persona o agente nuevo al repositorio:** Lee este documento, identifica el
   paquete relevante para su tarea y continúa por el `README.md` de ese paquete siguiendo el orden de
   lectura obligatorio de `AGENTS.md` §1.
2. **Cambio que cruza el límite entre el núcleo y la app:** Quien modifica un contrato público de
   `pseudolearn_core` (un tipo expuesto, un evento, una firma) ubica aquí la dirección de la dependencia
   para saber que la adaptación corresponde a la capa `engine/` de `pseudolearn_app`, nunca al revés.
3. **Resolución de conflicto entre fuentes de reglas:** Ante una contradicción entre `AGENTS.md` y el
   `README.md` de un paquete, se aplica el orden de precedencia de `AGENTS.md` §3 y se reporta en vez de
   resolverse en silencio (`CONFLICT-REPORT`).

### 1.5 Pendientes técnicos declarados

| Pendiente                             | De quién depende                                                                                                                                   | Estado actual |
|:--------------------------------------|:---------------------------------------------------------------------------------------------------------------------------------------------------|:--------------|
| Orquestador de comandos multi-paquete | Decisión de adoptar `melos` u otra herramienta si el número de miembros del monorepo crece                                                         | Abierto       |
| Integración continua (CI)             | Elección de proveedor y definición de pipeline que ejecute los verificadores de cada paquete en cada cambio                                        | Abierto       |
| Verificador del par `(app, núcleo)`   | Implementación del script que rechaza una versión sin entrada de publicación y un núcleo anclado que no coincide con el `pubspec.yaml` real (§4.4) | Abierto       |

---

## 2. Guía operativa y ciclo de vida

### 2.1 Requisitos previos y plataformas objetivo

- **Entorno de ejecución y SDKs:** Dart SDK `^3.5.0` (ambos paquetes Dart); Flutter SDK `>=3.24.0`
  (requerido únicamente por `apps/pseudolearn_app`); Python `>=3.9` con `fonttools` (requerido
  únicamente por `packages/pseudolearn_brand`).
- **Plataformas soportadas:** Las declaradas por cada miembro en su propio `README.md`; la raíz no
  impone restricción de plataforma adicional.
- **Variables de entorno y flags requeridos:** Ninguna a nivel de raíz.

### 2.2 Preparación e instalación

La raíz no resuelve dependencias propias. Cada paquete se prepara desde su propio directorio:

```bash
# Núcleo del lenguaje
(cd packages/pseudolearn_core && dart pub get)

# Aplicación cliente
(cd apps/pseudolearn_app && flutter pub get)

# Motor de marca
python3 -m pip install fonttools
```

### 2.3 Ejecución en desarrollo

No aplica a la raíz. Ver `apps/pseudolearn_app/README.md` §2.3 para ejecutar el cliente, y
`packages/pseudolearn_core/README.md` §2.3 para ejecutar el script de integración del motor.

### 2.4 Compilación y build

No aplica a la raíz. Los comandos de compilación de cada miembro están en su propio `README.md` §2.4.

### 2.5 Pruebas y verificación inmediata

Verificación mecánica completa del monorepo, paquete por paquete:

```bash
# Núcleo del lenguaje: tests, análisis estático y verificadores de arquitectura
(cd packages/pseudolearn_core && dart test && dart analyze --fatal-infos --fatal-warnings && dart run tool/check_limits.dart)

# Aplicación cliente: tests, análisis estático y verificadores de arquitectura y contenido
(cd apps/pseudolearn_app && flutter test && flutter analyze --fatal-infos --fatal-warnings && dart run tool/check_limits.dart && dart run tool/check_content.dart && dart run tool/check_design_system.dart)

# Motor de marca: artefactos de consumidor, capas, límites y tests
(cd packages/pseudolearn_brand && python3 -m pseudolearn_brand check && python3 tool/check_limits.py && python3 -m unittest discover -s test -t .)
```

La lista exhaustiva de verificadores, con qué detecta cada uno y dónde vive su regla, está en la sección
7 del `README.md` de cada paquete.

### 2.6 Despliegue y distribución

No aplica a la raíz. El canal de distribución de la aplicación cliente está en
`apps/pseudolearn_app/README.md` §2.6. El núcleo no se publica: es un paquete de monorepo interno
consumido por ruta relativa (`packages/pseudolearn_core/README.md` §2.6).

---

## 3. Arquitectura y modelo del sistema

### 3.1 Paradigma arquitectónico

Monorepo estructurado de dos categorías de miembro, y la regla de qué va en cada carpeta es esta:

- **`packages/` — todo lo reutilizable que no es una aplicación.** Librerías y utilidades, en el lenguaje
  que a cada una le corresponda. Un miembro de `packages/` no tiene interfaz de usuario, no se despliega
  y no depende de ninguna aplicación.
- **`apps/` — lo que se despliega a una persona.** El cliente Flutter. El sitio público vive en un
  repositorio separado y no es miembro de este monorepo.

Un único árbol git gobierna ambas categorías; cada miembro es, puertas adentro, arquitectónicamente
independiente y define su propio paradigma en su propio `README.md`.

**`packages/` no es exclusivo de Dart, y la regla dice «reutilizable», no «librería de un lenguaje
concreto».** El porqué de esa redacción está en §4.5.

### 3.2 Diagrama de capas y dirección de dependencias

La única arista de dependencia entre miembros del monorepo es unidireccional: la aplicación depende del
núcleo, nunca al revés (`LAYER-DIRECTION`).

Hay dos relaciones, y son de naturaleza distinta. Una es de compilación: la app no compila sin el
núcleo. La otra es de generación: el motor de marca escribe artefactos que su consumidor versiona, y no
lo necesita para compilar.

```
┌──────────────────────────┐
│ apps/pseudolearn_app     │
│ (cliente Flutter)        │
└─────────┬────────────────┘
          │ depende de (path relativo)
          ▼
┌─────────────────────────────┐
│ packages/pseudolearn_core   │
│ (motor de lenguaje, Dart)   │
└─────────────────────────────┘

          ▲ genera y verifica
          │
┌─────────┴─────────────────────┐
│ packages/pseudolearn_brand     │
│ (motor de la identidad visual, │
│ Python)                        │
└─────────────────────────────────┘
```

El sitio público, en su propio repositorio, recibe los artefactos que `pseudolearn_brand` escribe
directo en su árbol de trabajo local (clonado como `apps/fe-pseudolearn/`, ignorado por git en este
repositorio) y consume las entradas de versión publicadas por `apps/pseudolearn_app` (§4.4). Esa
relación cruza el límite del monorepo y no participa del grafo de dependencias interno ni de
`LAYER-DIRECTION`.

`packages/pseudolearn_core` no importa, referencia ni conoce nada de `apps/pseudolearn_app`. Es un
paquete de Dart puro sin dependencia de Flutter (`packages/pseudolearn_core/README.md` §1.3).

`packages/pseudolearn_brand` tampoco importa nada de `apps/`: escribe en rutas que su propio catálogo
declara como destino, y verifica que lo que hay ahí siga siendo lo que él produce. La flecha apunta desde
la marca hacia sus consumidores, nunca al revés; que las fuentes tipográficas vivan dentro del paquete en
vez de leerse de la app es exactamente lo que sostiene esa dirección (`packages/pseudolearn_brand/README.md` §4.2).

### 3.3 Catálogo de carpetas, responsabilidades e invariantes

| Directorio                    | Responsabilidad única                                                                                                  | Puede importar (`may_import`)                                                                                                        | Prohibido importar (`forbidden_imports`)                                    |
|:------------------------------|:-----------------------------------------------------------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------|:----------------------------------------------------------------------------|
| `packages/pseudolearn_core/`  | Motor de lenguaje: lexer, parser, AST, chequeo de tipos, evaluación, diagnósticos                                      | Dart SDK puro; capas internas según su propio `architecture.yaml`                                                                    | `package:flutter/`, `dart:io`, `dart:isolate`, cualquier símbolo de `apps/` |
| `apps/pseudolearn_app/`       | Cliente Flutter: interfaz, orquestación de estado, persistencia local, adaptación al núcleo                            | `packages/pseudolearn_core` por ruta relativa; paquetes de `pubspec.yaml` propio; capas internas según su propio `architecture.yaml` | Símbolos internos de `pseudolearn_core` no exportados en su API pública     |
| `packages/pseudolearn_brand/` | Motor de la identidad visual: geometría paramétrica de la marca y emisión de cada artefacto que un consumidor necesita | Librería estándar de Python y `fontTools`; capas internas según su propio `architecture.json`                                        | Cualquier símbolo de `packages/` o `apps/`; no participa en ningún build    |
| `.agents/skills/`             | Skills operativas del monorepo, fuente única enlazada también desde `.claude/skills`                                   | — (contenido Markdown, sin código ejecutable)                                                                                        | —                                                                           |
| `AGENTS.md` (raíz)            | Reglas transversales de todos los paquetes: contrato de reglas, precedencia, skills                                    | — (documento)                                                                                                                        | Arquitectura específica de un paquete concreto                              |

Cada paquete declara su propio catálogo de carpetas internas, con sus propios `may_import` y
`forbidden_imports`, en la sección 3.3 de su `README.md` y en su `architecture.yaml`. Este catálogo cubre
únicamente la frontera entre miembros del monorepo, no el interior de cada uno.

### 3.4 Flujo de datos y ciclo de vida

Un cambio de contrato público en `packages/pseudolearn_core` (un tipo expuesto, un evento del
intérprete, una firma de diagnóstico) se propaga en una sola dirección: la capa `engine/` de
`apps/pseudolearn_app` lo traduce a los tipos propios del dominio de la aplicación (`apps/pseudolearn_app/README.md`
§1.2, punto 3). Ningún cambio en la aplicación se propaga hacia el
núcleo: el núcleo no tiene conocimiento de que existe un consumidor Flutter.

### 3.5 Concurrencia, asincronía y modelo de threading

No aplica a nivel de raíz. El modelo de concurrencia de cada miembro —síncrono y determinista en el
núcleo, micro-lotes en el hilo de interfaz en la aplicación— está descrito en la sección 3.5 de su
propio `README.md`.

---

## 4. Decisiones de diseño y fundamentos técnicos

### 4.1 Monorepo de git puro sin orquestador multi-paquete

- **Problema:** Con tres miembros escritos en dos cadenas de herramientas y una única arista de
  dependencia en tiempo de compilación entre ellos, cualquier herramienta de orquestación multi-paquete (`melos`, `nx`,
  workspaces) añade una capa de configuración, un archivo de reglas propio y una curva de
  aprendizaje sin resolver un problema que hoy existe; y ninguna de ellas abarca las dos cadenas.
- **Elección:** Git puro como mecanismo de agrupación. Cada paquete se prepara, compila, prueba y
  despliega desde su propio directorio con los comandos nativos de `pub`/`flutter`. La única
  coordinación entre miembros es la dependencia por ruta relativa declarada en
  `apps/pseudolearn_app/pubspec.yaml`.
- **Alternativas descartadas y por qué:**
    - *`melos`:* Aporta ejecución de comandos en paralelo sobre N paquetes y versionado sincronizado.
      Solo entiende paquetes de Dart, con lo que dejaría fuera al motor de marca (Python); y sobre los
      dos miembros que sí cubre, el paralelismo no ahorra tiempo apreciable con una dependencia
      unidireccional, y el versionado sincronizado no aplica porque el núcleo no se publica.
    - *Workspaces de un gestor de paquetes ajeno al ecosistema Dart/Flutter (npm, yarn):* Fuera del
      ecosistema del lenguaje de los miembros de este monorepo; introduciría una cadena de herramientas
      nueva sin beneficio.

### 4.2 Dos puntos de entrada, una fuente de verdad (symlinks de tooling)

- **Problema:** Distintos agentes y herramientas (Claude Code, otros lectores de convenciones) esperan
  encontrar las reglas del proyecto y las skills bajo nombres de archivo y carpeta específicos y
  distintos entre sí (`CLAUDE.md` vs. `AGENTS.md`; `.claude/skills` vs. `.agents/skills`). Mantener el
  contenido duplicado en ambas ubicaciones garantiza que diverjan en el primer cambio aplicado a una
  sola copia.
- **Elección:** `AGENTS.md` y `.agents/skills/` son la fuente de verdad única. `CLAUDE.md` es un symlink
  a `AGENTS.md`; `.claude/skills` es un symlink a `.agents/skills`. Un cambio a cualquiera de los dos
  edita el mismo contenido en disco, sin importar por qué nombre se lo abra.
- **Alternativas descartadas y por qué:**
    - *Dos archivos independientes sincronizados a mano:* Descartado porque delega en la disciplina
      humana lo que el sistema de archivos resuelve de forma estructural.
    - *Un script de sincronización que copie el contenido en cada cambio:* Añade un paso manual o un
      hook adicional para resolver un problema que un symlink resuelve en tiempo de lectura, sin estado
      que pueda quedar desactualizado.

### 4.3 Dependencia del núcleo por ruta relativa, no por publicación

- **Problema:** `apps/pseudolearn_app` necesita el motor de lenguaje en cada build, y ambos miembros
  evolucionan juntos dentro del mismo repositorio y del mismo ciclo de revisión.
- **Elección:** `pseudolearn_core` se declara en `apps/pseudolearn_app/pubspec.yaml` con
  `path: ../../packages/pseudolearn_core`. No se publica a `pub.dev` ni a un registro privado (`publish_to: 'none'` en
  ambos `pubspec.yaml`).
- **Alternativas descartadas y por qué:**
    - *Publicación a un registro de paquetes (público o privado):* Introduce un paso de versionado y
      publicación por cada cambio del núcleo antes de que la aplicación pueda consumirlo, cuando ambos
      viven en el mismo commit y se revisan juntos.

### 4.4 Versión de producto con núcleo anclado

- **Problema:** `pseudolearn_core` y `apps/pseudolearn_app` cambian por razones distintas, pero el
  público necesita un solo número con el que hablar del producto, y el repositorio necesita que ninguna
  publicación del núcleo se quede sin llegar a nadie. Una versión compartida por ambos obliga a subir el
  núcleo cada vez que cambia solo la interfaz de la app y miente sobre lo que cambió; dos versiones
  sueltas sin regla no obligan a nada y dejan que un núcleo nuevo se quede sin app que lo lleve.
- **Elección:** dos números con dueños distintos y una regla que ata uno al otro.
    - `pseudolearn_core` lleva versionado semántico de su **contrato**: los tipos y firmas que expone,
      y la gramática que acepta. Es interno; nadie fuera del repositorio lo consume.
    - `apps/pseudolearn_app` lleva la **versión de producto**: la de la tienda, la que publica el sitio
      público (en su propio repositorio) y la que se pide al reportar un fallo.
      La regla de propagación va en una sola dirección, la misma que la única arista del grafo interno:

  | Cambio en el núcleo | Obliga en la app                                              |
      |:--------------------|:--------------------------------------------------------------|
  | MAYOR               | MENOR como mínimo; MAYOR si cambia lo que el estudiante escribe |
  | MENOR               | MENOR como mínimo                                             |
  | PARCHE              | PARCHE como mínimo                                            |

  Al revés no existe: un cambio de interfaz, de texto o de atajo en la app no toca el núcleo. El
  argumento es que un motor que ninguna app lleva dentro no le ha llegado a nadie, así que la versión
  de la app es el acuse de recibo de que ese núcleo se probó en producto.
- **Unidad de publicación:** el par `(app, núcleo)`. Toda publicación se declara como una entrada con
  la versión de producto, la del núcleo anclado, la fecha y los identificadores de lo que trae. Esa
  entrada es lo que el sitio público, en su propio repositorio, consume para mostrar el historial de
  versiones, de modo que no hay una segunda lista que pueda divergir.
- **Alternativas descartadas y por qué:**
    - *Versión única compartida por ambos miembros:* cada cambio de interfaz o de copia obligaría a
      subir la versión del núcleo, que es un contrato: el número dejaría de significar nada.
    - *Dos versiones completamente independientes, sin regla que las ate:* no obliga a nada, y la
      pregunta que el proyecto necesita poder contestar —«¿con qué motor se probó esta app?»— se queda
      sin respuesta declarada.
- **Pendiente declarado:** el verificador que rechaza una versión que cambia sin su entrada, y una
  entrada cuyo núcleo anclado no coincide con el `pubspec.yaml` real, está en la tabla de §1.5.

### 4.5 `packages/` aloja utilidades, no solo librerías de Dart

- **Problema:** este documento definía `packages/` como «paquetes de librería pura» de Dart, siguiendo la
  convención del ecosistema. El motor de la identidad visual es una utilidad reutilizable escrita en
  Python: no es una aplicación, no se despliega, no tiene interfaz, y varios miembros del monorepo
  consumen lo que produce. Bajo la redacción anterior no cabía en ninguna carpeta, y vivía en una tercera
  carpeta de raíz (`brand/`) que era una categoría de un solo miembro.
- **Elección:** `packages/` pasa a definirse por **qué es** un miembro —reutilizable, sin interfaz, sin
  despliegue— y no por **en qué lenguaje está escrito**. `apps/` sigue siendo lo que se despliega a una
  persona. Ninguna carpeta nueva en la raíz: una raíz con una carpeta por excepción deja de ser un mapa.
- **Consecuencia:** el criterio para ubicar un archivo se vuelve una pregunta sobre su papel, que es
  estable, en vez de una sobre su lenguaje, que no lo es —el monorepo ya sostiene Dart y Python—. A
  cambio, `packages/` deja de tener una cadena de herramientas única: no hay un comando que prepare o
  pruebe todos sus miembros a la vez, y cada uno declara los suyos en su `README.md` §2.
- **Alternativas descartadas y por qué:**
    - *Dejar el motor de marca en una carpeta `brand/` de raíz:* Es lo que había. Una carpeta de raíz por
      cada cosa que no encaja convierte el primer nivel del repositorio en una lista de excepciones, y
      obliga a documentar en este README la arquitectura de un miembro que debería documentarse en el
      suyo.
    - *Una carpeta `tools/` de raíz para utilidades no-Dart:* Resuelve la ubicación pero crea la misma
      lista de excepciones un nivel más abajo, y obliga a decidir en cada caso si algo es «paquete» o
      «utilidad», que es una frontera que nadie sabe dibujar dos veces igual.
    - *Reescribir el motor de marca en Dart para que `packages/` siga siendo de un solo lenguaje:* El
      motor extrae contornos reales de archivos `.ttf`; en Dart eso exige un analizador de fuentes de
      terceros sin equivalente maduro a `fontTools`, o congelar los contornos como dato y perder
      justamente la propiedad —geometría paramétrica de extremo a extremo— que da valor al motor. Cambiar
      una regla de organización sale más barato que degradar el artefacto que la regla debía alojar.

---

## 5. Reglas de legibilidad, estilo y estructura de código

### 5.1 Filosofía de código auto-explicativo

No aplica directamente a la raíz: no contiene código fuente propio, solo documentación y configuración
de tooling. Las reglas de código auto-explicativo, límites métricos, política de comentarios y gestión
tipada de errores —idénticas en su fundamento para todo el monorepo— están definidas en `AGENTS.md` §4 y
se aplican y verifican dentro de cada paquete según su propio `architecture.yaml`.

### 5.2 Límites métricos obligatorios

No hay archivo de reglas de raíz. Cada miembro declara los suyos, en el formato que su propio
intérprete lee sin dependencias añadidas: `packages/pseudolearn_core/architecture.yaml`,
`apps/pseudolearn_app/architecture.yaml` en YAML;
`packages/pseudolearn_brand/architecture.json` en JSON, por la razón registrada en el §4.3 de ese
paquete.

### 5.3 Política estricta de comentarios

Ver `AGENTS.md` §4, aplicable sin excepción a todo el código del monorepo (`LANG-EN-CODE`,
`QUALITY-NO-NOISE-COMMENTS`, `QUALITY-NO-DOC-REFS`, `QUALITY-WHY-ONLY`).

### 5.4 Convenciones técnicas y anti-patrones prohibidos

No aplica a la raíz. Ver la sección 5.4 del `README.md` de cada paquete.

### 5.5 Gestión tipada de errores

No aplica a la raíz. Ver la sección 5.5 del `README.md` de cada paquete.

---

## 6. Decisiones de producto que condicionan el código

### 6.1 El núcleo y la app no comparten arquitectura por decisión, no por omisión

Un motor de lenguaje puro en Dart y un cliente de interfaz gráfica en Flutter tienen responsabilidades,
tentaciones de acoplamiento y criterios de capas distintos entre sí. Forzar un mismo patrón
arquitectónico (por ejemplo, arquitectura hexagonal también dentro del núcleo, o un pipeline concéntrico
también dentro de la app) produciría capas artificiales sin correspondencia con el problema real de cada
miembro. Cada paquete elige y documenta su propio paradigma en la sección 3.1 de su `README.md`.

### 6.2 El código cierra código cerrado, la documentación no lleva adornos de marketing

PseudoLearn es un proyecto de código cerrado con rigor de ingeniería. Ningún `README.md` del monorepo —
incluida la raíz— lleva insignias, logotipos decorativos ni prosa promocional. Toda la documentación
técnica prioriza densidad y precisión sobre estilo editorial (`AGENTS.md`, skill `package-docs`).

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

| Verificador                  | Comando                                                                       | Qué detecta                                                                                                                                       | Dónde vive la regla                               |
|:-----------------------------|:------------------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------|
| Tests del núcleo             | `cd packages/pseudolearn_core && dart test`                                   | Regresiones funcionales del motor de lenguaje                                                                                                     | `packages/pseudolearn_core/test/`                 |
| Análisis estático del núcleo | `cd packages/pseudolearn_core && dart analyze --fatal-infos --fatal-warnings` | Tipado, null safety, buenas prácticas de Dart                                                                                                     | `packages/pseudolearn_core/analysis_options.yaml` |
| Límites y capas del núcleo   | `cd packages/pseudolearn_core && dart run tool/check_limits.dart`             | Violación de `may_import`, tamaño de archivo/función, parámetros, comentarios                                                                     | `packages/pseudolearn_core/architecture.yaml`     |
| Tests de la app              | `cd apps/pseudolearn_app && flutter test`                                     | Regresiones funcionales, de arquitectura y de widgets                                                                                             | `apps/pseudolearn_app/test/`                      |
| Análisis estático de la app  | `cd apps/pseudolearn_app && flutter analyze --fatal-infos --fatal-warnings`   | Tipado, null safety, lints de Flutter                                                                                                             | `apps/pseudolearn_app/analysis_options.yaml`      |
| Límites y capas de la app    | `cd apps/pseudolearn_app && dart run tool/check_limits.dart`                  | Violación de `may_import`, tamaño de archivo/función, reglas de widgets, comentarios                                                              | `apps/pseudolearn_app/architecture.yaml`          |
| Contenido pedagógico         | `cd apps/pseudolearn_app && dart run tool/check_content.dart`                 | Invariantes de la base de conocimiento versionada                                                                                                 | `apps/pseudolearn_app/tool/content/`              |
| Sistema de diseño            | `cd apps/pseudolearn_app && dart run tool/check_design_system.dart`           | Integridad de tokens y fuentes tipográficas empaquetadas                                                                                          | `apps/pseudolearn_app/architecture.yaml`          |
| Artefactos de marca          | `cd packages/pseudolearn_brand && python3 -m pseudolearn_brand check`         | Copia de marca que el motor ya no produce, medida redibujada que dejó de coincidir, cara tipográfica divergente, geometría a mano en la plantilla | `packages/pseudolearn_brand/brand.json`           |
| Capas y límites de la marca  | `cd packages/pseudolearn_brand && python3 tool/check_limits.py`               | Violación de `may_import`, tamaño de archivo/función, parámetros, anidamiento, comentarios                                                        | `packages/pseudolearn_brand/architecture.json`    |
| Tests de la marca            | `cd packages/pseudolearn_brand && python3 -m unittest discover -s test -t .`  | Regresiones de geometría, tipografía, composición, emisión y verificación                                                                         | `packages/pseudolearn_brand/test/`                |

Esta tabla enumera los verificadores por su punto de entrada desde la raíz. El detalle de qué código
ejecuta cada uno y su caso de prueba negativo está en la sección 7.1 del `README.md` de cada paquete.

### 7.2 Estrategia y pirámide de pruebas

La raíz no define estrategia de pruebas propia. `TEST-MIRROR` y `TEST-BOTH-PATHS` (`AGENTS.md` §2) se
aplican dentro de cada paquete; ver la sección 7.2 de cada `README.md` para su implementación concreta.

### 7.3 Señales de alerta al revisar (Code Review Checklist)

A nivel de monorepo, un cambio se rechaza si:

- Introduce una dependencia de `packages/pseudolearn_core` hacia `apps/pseudolearn_app`, en cualquier
  dirección o forma (import directo, `dart:mirrors`, reflexión, o acoplamiento por convención de
  nombres).
- Documenta una decisión de arquitectura de un paquete específico en este `README.md` de raíz en vez de
  en el `README.md` de ese paquete.
- Añade tooling de orquestación multi-paquete, CI o un `pubspec.yaml` de raíz sin que este documento se
  actualice en el mismo cambio (`DOC-README-TRUTH`).
- Rompe el symlink `CLAUDE.md` → `AGENTS.md` o `.claude/skills` → `.agents/skills`, o duplica su
  contenido como archivo regular en lugar de symlink.
- Añade una carpeta de primer nivel para alojar algo que es reutilizable y no se despliega, en vez de
  ponerlo bajo `packages/` (§4.5).
- Introduce una dependencia de `packages/pseudolearn_brand` hacia cualquier miembro de `apps/` que no sea
  una ruta de destino declarada en su catálogo.
- Versiona un artefacto que el motor de marca genera sin que sea un destino de consumidor declarado
  (`packages/pseudolearn_brand/README.md` §4.5).

---

## 8. Fuentes consultadas y genealogía conceptual

La estructura de monorepo con separación entre `packages/` (librerías puras) y `apps/` (aplicaciones
clientes) sigue la convención habitual del ecosistema Dart/Flutter para proyectos multi-paquete, sin
adoptar ninguna herramienta de orquestación asociada a esa convención (`melos`) por las razones
registradas en la sección 4.1.

- **Qué se tomó:** La convención de nombres de carpeta `packages/` y `apps/`, y la práctica de declarar
  dependencias internas por `path:` relativo en `pubspec.yaml` en vez de publicarlas.
- **Dónde se dejó de seguir a propósito:** Esa convención da por hecho que todo lo que hay bajo
  `packages/` es un paquete de Dart. Aquí `packages/` se define por el papel del miembro y no por su
  lenguaje, y aloja también utilidades en otras cadenas de herramientas; el razonamiento completo está en
  la sección 4.5.
- **Qué se rechazó deliberadamente y por qué:** El tooling de orquestación multi-paquete que
  habitualmente acompaña esa convención (`melos` y equivalentes), por las razones técnicas registradas
  en la sección 4.1: no abarca las dos cadenas de herramientas del monorepo, y sobre la parte que sí
  abarca no resuelve un problema que hoy exista.

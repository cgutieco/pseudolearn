# Plantilla Estándar: README.md de Paquete, Aplicación o Raíz

> Esta plantilla es el recurso operativo oficial definido por la skill `package-docs`.
> Todo `README.md` del monorepo debe reproducir esta estructura exacta de 8 secciones numeradas.
>
> **Directrices esenciales de redacción:**
> 1. **100 % Autosustentable:** Prohibido referenciar carpetas externas como `docs/decisions/`. Todo vive aquí.
> 2. **Presente Normativo Atemporal (Sin arqueología de versiones):** Prohibido relatar la historia o evolución del
     código (nada de «debido a tal situación se tomó la decisión», «en la fase X se cambió de A a B», «anteriormente
     era...»). Toda decisión se enuncia como la ley vigente actual, como si hubiera sido concebida así desde su origen.
> 3. **Máxima Densidad Técnica para IA e Ingenieros:** Redacción directa al grano, sin adornos gramaticales, metáforas
     ni relleno retórico. No omitir ningún detalle técnico, contrato o caso límite.

---

```markdown
# <nombre_del_paquete_o_app>

Fuente de verdad técnica de este paquete. Aquí vive el *por qué* de cada decisión, para que el código
no necesite comentarios que lo expliquen. Un cambio de arquitectura o de decisión de diseño se
documenta aquí en el mismo cambio que lo introduce (`DOC-README-TRUTH`).

Las reglas transversales del monorepo están en el `AGENTS.md` de la raíz. Las reglas que los
verificadores ejecutan están en `architecture.yaml`, junto a este archivo.

**Estado:
** [Fase o bloque actual completado, hitos arquitectónicos alcanzados, estado de tests y verificadores al 100 % en verde].

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

[Descripción técnica exacta de qué resuelve este paquete o aplicación, a quién sirve y quién lo consume dentro del ecosistema de PseudoLearn.]

### 1.2 Responsabilidades primarias

[Lista concreta de las capacidades que pertenecen exclusivamente a este paquete.]

### 1.3 Fuera de alcance a propósito

[Delimitación estricta, atemporal y consciente para evitar sobre-ingeniería (SCOPE-YAGNI). Formulado en presente indicativo sin narrar fases anteriores ni evoluciones.]

#### De producto

- **[Capacidad excluida 1]:** [Razón técnica/producto por la cual no existe en el sistema].
- **[Capacidad excluida 2]:** [Razón técnica/producto por la cual no existe en el sistema].

#### De implementación técnica

- **[Patrón o tecnología excluida 1]:
  ** [Justificación técnica de la exclusión, p. ej. no concurrencia real, no isolates].
- **[Patrón o tecnología excluida 2]:** [Justificación técnica de la exclusión].

### 1.4 Casos de uso principales

[Enumeración precisa de los flujos de trabajo clave soportados por el paquete o app.]

1. **[Caso de uso 1]:** [Flujo concreto y contratos involucrados].
2. **[Caso de uso 2]:** [Flujo concreto y contratos involucrados].

### 1.5 Pendientes técnicos declarados

No son alcance recortado: son cosas que esta arquitectura necesita y que hoy no existen.

| Pendiente | De quién depende | Estado actual |
|:---|:---|:---|
| [Nombre del pendiente] | [Componente o contrato del que depende] | [Abierto / En progreso / Planificado] |

---

## 2. Guía operativa y ciclo de vida

### 2.1 Requisitos previos y plataformas objetivo

- **Entorno de ejecución y SDKs:** [Dart SDK versión X.Y.Z / Flutter SDK versión X.Y.Z].
- **Plataformas soportadas:** [p. ej. macOS 13+, iOS 16+, Web WASM/JS, CLI Linux/macOS].
- **Variables de entorno y flags requeridos:** [Variables como SUPABASE_URL, flags de compilación
  `--dart-define`, etc. Indicar explícitamente si no requiere ninguna].

### 2.2 Preparación e instalación

Comandos para resolver dependencias y preparar el entorno local:

```bash
# Instalación de dependencias
[dart pub get / flutter pub get]

# Generación de código o sincronización de recursos (si aplica)
[dart run build_runner build --delete-conflicting-outputs]
```

### 2.3 Ejecución en desarrollo

Comandos exactos para ejecutar en local en modo desarrollo:

```bash
# Ejecución en plataforma principal
[flutter run -d macos / dart run bin/main.dart]

# Ejecución con perfil específico o flags de depuración
[flutter run -d macos --flavor dev / dart --observe bin/main.dart]
```

### 2.4 Compilación y build

Comandos para generar binarios y artefactos optimizados de producción:

```bash
# Compilación para producción
[flutter build macos --release / dart compile exe bin/main.dart -o build/app]

# Compilación para otras plataformas soportadas
[flutter build ipa --no-codesign / dart compile js lib/main.dart -o build/web/main.js]
```

- **Rutas de salida de artefactos:** [p. ej. `build/macos/Build/Products/Release/<App>.app`, `build/bin/`].

### 2.5 Pruebas y verificación inmediata

Comandos rápidos para validar la salud técnica sin dependencias de entorno:

```bash
# Ejecución de tests unitarios y de integración
[dart test / flutter test]

# Análisis estático y linter
[dart analyze / flutter analyze]

# Verificadores mecánicos propios
[dart test test/architecture/architecture_test.dart]
[dart run tool/check_limits.dart]
```

### 2.6 Despliegue y distribución

- **Estrategia de entrega:** [Canal de distribución: TestFlight, DMG directo, CDN web, paquete pub privado].
- **Proceso de empaquetado y firmado:** [Comandos o pasos de codesign, notarización o bundle].
- **Checklist de release:**
    - [ ] Tests y verificadores al 100 % en verde.
    - [ ] Versión y build number sincronizados en `pubspec.yaml`.
    - [ ] Documentación actualizada en el mismo commit (`DOC-README-TRUTH`).

---

## 3. Arquitectura y modelo del sistema

### 3.1 Paradigma arquitectónico

[Descripción técnica directa del patrón adoptado: Arquitectura Hexagonal / Puertos y Adaptadores para app, Pipeline concéntrico para motor, Monorepo estructurado para la raíz.]

### 3.2 Diagrama de capas y dirección de dependencias

Las capas internas nunca conocen a las externas (`LAYER-DIRECTION`).

```
[Diagrama ASCII o Mermaid de capas concéntricas o flujo unidireccional]
```

### 3.3 Catálogo de carpetas, responsabilidades e invariantes

Toda carpeta bajo el código fuente tiene una única responsabilidad y límites explícitos declarados:

| Capa / Directorio | Responsabilidad única | Puede importar (`may_import`) | Prohibido importar (`forbidden_imports`) |
|:------------------|:----------------------|:------------------------------|:-----------------------------------------|
| `[nombre_capa]`   | [Qué resuelve]        | `[capas permitidas]`          | `[paquetes o capas prohibidas]`          |

### 3.4 Flujo de datos y ciclo de vida

[Trazabilidad paso a paso de datos y eventos a través de las capas. Entrada de evento -> validación/procesamiento en dominio -> persistencia/emisión.]

### 3.5 Concurrencia, asincronía y modelo de threading

- **Hilo de ejecución:
  ** [p. ej. Todo el motor es síncrono y determinista; la interfaz ejecuta en lotes sobre el hilo principal].
- **Política sobre hilos secundarios (`Isolate`):
  ** [p. ej. Prohibido el uso de Isolate; la ejecución se divide en micro-lotes sin bloquear UI].

---

## 4. Decisiones de diseño y fundamentos técnicos

> Cada decisión técnica o de diseño vive en este documento, es 100 % autosustentable y se enuncia en presente
> normativo (la ley vigente desde el origen).
> Prohibido relatar la historia («debido a tal situación se decidió», «se cambió de X a Y»).
> Toda decisión sigue esta terna obligatoria:
> 1. **Problema:** La tensión, requerimiento o limitación técnica concreta.
> 2. **Elección:** La solución implementada y su mecánica detallada.
> 3. **Alternativas descartadas y por qué:** Las opciones que se consideraron y la justificación técnica de su rechazo.

### 4.1 [Nombre de la decisión 1]

- **Problema:** [Descripción del problema técnico].
- **Elección:** [Solución adoptada, contratos, estructuras y funcionamiento].
- **Alternativas descartadas y por qué:**
    - *[Alternativa descartada A]:* [Razón técnica de rechazo].
    - *[Alternativa descartada B]:* [Razón técnica de rechazo].

### 4.2 Fundamentos visuales y sistema de diseño [Si aplica a la app]

*(En aplicaciones UI, las decisiones de tokens, paleta semántica, tipografía, espacios y lienzo viven aquí, sin archivos
externos).*

- **Tokens y Escalas:** [Valores de escala y prohibición de valores arbitrarios].
- **Temas:** [Mecánica de temas claro y oscuro mediante tokens semánticos].

### 4.3 Especificación de pantallas y navegación [Si aplica a la app]

- [Estructura del armazón de pantalla, navegación adaptativa por clase de ventana].

### 4.4 Catálogo de componentes y reglas de interfaz [Si aplica a la app]

- [Reglas de widgets, estados visuales, interactividad].

### 4.5 Algoritmos y motor de notaciones / visualizaciones [Si aplica]

- [Algoritmos de layout, direccionamiento de conectores, sincronización por NodeId].

---

## 5. Reglas de legibilidad, estilo y estructura de código

### 5.1 Filosofía de código auto-explicativo

- **Una sola responsabilidad por archivo:** Todo archivo se debe poder describir en una sola frase sin conjunciones
  copulativas ("y").
- **Idioma del código (`LANG-EN-CODE`):** Todos los identificadores, variables, nombres de archivos, tests y mensajes de
  commit se escriben en inglés. La documentación y explicaciones se escriben en español (`LANG-ES-DOCS`).

### 5.2 Límites métricos obligatorios (`architecture.yaml`)

Valores enforceados mecánicamente en este paquete:

- **Líneas por archivo:** Máximo [250 / 300] líneas (salvo rutas exentas en tests/tool).
- **Líneas por función / método:** Máximo [40] líneas.
- **Líneas por método build (widgets):** Máximo [30] líneas.
- **Parámetros posicionales:** Máximo [3 / 4]. Preferir parámetros nombrados con nombre claro.
- **Profundidad de anidación:** Máximo [3] niveles de control (`if`, `for`, `while`, `switch`, `try`).
- **Métodos públicos por clase:** Máximo [5 / 7].

### 5.3 Política estricta de comentarios

- **Prohibido (`QUALITY-NO-NOISE-COMMENTS`):**
    - Comentarios que repiten lo que el código ya expresa.
    - Comentarios que traducen identificadores al español.
    - Citar documentos o secciones (`QUALITY-NO-DOC-REFS`): Prohibido `// ver README`, `// según AGENTS.md`. Se describe
      la restricción técnica, nunca dónde está escrita.
    - Código comentado o TODOs sin responsable y condición de cierre.
- **Admisible (`QUALITY-WHY-ONLY`):**
    - Únicamente un *por qué* local, no evidente y contraintuitivo.
    - Las justificaciones arquitectónicas pertenecen a este README, no al código.

### 5.4 Convenciones técnicas y anti-patrones prohibidos

- [Listado de patrones prohibidos según architecture.yaml: p. ej. prohibidos constructores adaptativos como
  `Switch.adaptive`, prohibido
  `await` en capa de presentación, prohibido filtrar o derivar datos en el árbol de widgets].

### 5.5 Gestión tipada de errores

- Ninguna excepción no controlada cruza la frontera pública de un paquete o capa.
- Los fallos esperables se representan como tipos de retorno explícitos (resultados estructurados, estados de error o
  sellados), no lanzando excepciones.

---

## 6. Decisiones de producto que condicionan el código

[Decisiones pedagógicas, contractuales o de producto que justifican implementaciones técnicas que de otro modo parecerían subóptimas o contraintuitivas. Se enuncian en presente normativo como leyes del producto para blindarlas ante refactorizaciones involuntarias.]

- **[Decisión de producto 1]:** [Explicación del comportamiento observable y por qué debe mantenerse].
- **[Decisión de producto 2]:** [Explicación del comportamiento observable y por qué debe mantenerse].

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

Los verificadores garantizan que las reglas arquitectónicas y de calidad se cumplan de forma automatizada:

| Verificador              | Archivo / Comando                  | Qué detecta                                     | Dónde vive la regla     |
|:-------------------------|:-----------------------------------|:------------------------------------------------|:------------------------|
| Linter de Dart           | `dart analyze`                     | Tipado, null safety, buenas prácticas           | `analysis_options.yaml` |
| Test de capas            | `dart test test/architecture/...`  | Violación de `may_import` o capas cruzadas      | `architecture.yaml`     |
| Límites métricos         | `dart run tool/check_limits.dart`  | Archivos largos, funciones extensas, parámetros | `architecture.yaml`     |
| Test de cadenas visibles | `dart run tool/check_strings.dart` | Literales fuera de capas autorizadas            | `architecture.yaml`     |

### 7.2 Estrategia y pirámide de pruebas

- **Estructura espejo (`TEST-MIRROR`):** La carpeta `test/` replica exactamente la estructura interna de `lib/`.
- **Doble camino (`TEST-BOTH-PATHS`):** Toda funcionalidad se prueba en su camino feliz y en su camino infeliz, con
  casos límite explícitos (colecciones vacías, bordes numéricos, nulos).
- **Pruebas de verificadores:** Cada script de verificación mecánica cuenta con tests negativos que aseguran que falla
  ante una violación deliberada.

### 7.3 Señales de alerta al revisar (Code Review Checklist)

Si un cambio presenta cualquiera de estos síntomas, debe ser rechazado:

- [ ] Importa desde una capa prohibida por `architecture.yaml`.
- [ ] Un archivo o método excede los límites métricos fijados.
- [ ] Contiene comentarios que explican *qué* hace el código o citan documentos externos.
- [ ] Hay un `switch` repetido sobre el mismo tipo en más de un lugar (indica falta de polimorfismo o sellado).
- [ ] Cambia una regla de arquitectura o diseño sin actualizar este `README.md` en el mismo commit (`DOC-README-TRUTH`).
- [ ] Contiene justificaciones narrativas de evolución histórica en lugar de enunciados normativos en presente.

---

## 8. Fuentes consultadas y genealogía conceptual

Documentación de las fuentes externas analizadas durante el diseño del componente. Acredita la autoría propia y
fundamenta las decisiones tomadas:

| Fuente consultada                                 | Qué se tomó                   | Qué se rechazó deliberadamente y por qué                    |
|:--------------------------------------------------|:------------------------------|:------------------------------------------------------------|
| [Nombre de la fuente / estándar / especificación] | [Conceptos o ideas adaptadas] | [Partes rechazadas y motivo técnico/pedagógico del rechazo] |

```

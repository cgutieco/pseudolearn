# pseudolearn_core

Fuente de verdad técnica de este paquete. Aquí vive el *por qué* de cada decisión, para que el código
no necesite comentarios que lo expliquen. Un cambio de arquitectura o de decisión de diseño se
documenta aquí en el mismo cambio que lo introduce (`DOC-README-TRUTH`).

Las reglas transversales del monorepo están en el `AGENTS.md` de la raíz. Las reglas que los
verificadores ejecutan están en `architecture.yaml`, junto a este archivo. La gramática normativa del
lenguaje está en `docs/language-spec.md`.

**Estado:** Motor de lenguaje puro implementado y verificado; pipeline concéntrico por etapas (`domain` → `syntax` →
`semantic` → `evaluation` → `diagnostics`); soporte de orientación a objetos (clases, herencia simple, visibilidad
pública/privada, polimorfismo, `Este`, `Super`, copia superficial), subprogramas y paso de parámetros por valor y por
referencia; determinismo aritmético de 64 bits con `BigInt`; compilación verificada a nativo, JavaScript y WebAssembly;
suite de 748 tests y verificadores mecánicos al 100 % en verde.

---

## 1. Qué es y qué no es

### 1.1 Propósito y problema que resuelve

`pseudolearn_core` es el motor de ejecución, análisis sintáctico y verificación semántica del lenguaje didáctico
PseudoLearn. Resuelve de forma centralizada la tokenización, el análisis gramatical por descenso recursivo, el modelado
del árbol de sintaxis abstracta (AST), la resolución de identificadores en múltiples pasadas, el chequeo estático de
tipos y la evaluación interpretada paso a paso con emisión de eventos e instantáneas de memoria.

Es un paquete de **Dart puro**, agnóstico de interfaz de usuario y sin dependencias de Flutter ni llamadas al sistema
operativo (`dart:io` prohibido en biblioteca). Compila a código nativo de máquina, JavaScript (`dart compile js`) y
WebAssembly (`dart compile wasm`), garantizando paridad matemática y semántica idéntica en clientes de escritorio,
móviles y navegadores web.

Lo consumen `apps/pseudolearn_app` (cliente interactivo en Flutter para macOS e iOS) y, en extensiones planificadas, el
visor web autónomo y validadores de consola. Ningún consumidor aporta lógica de lenguaje: las reglas léxicas,
gramaticales, de tipado y de evaluación residen exclusivamente aquí.

### 1.2 Responsabilidades primarias

1. **Tokenización léxica desacoplada (`syntax/lexer/`):** Conversión de texto fuente en flujo de tokens tipados y
   reporte de diagnósticos léxicos gobernados por el perfil activo (`LanguageProfile`).
2. **Construcción y recuperación sintáctica (`syntax/parser/`):** Construcción modular del AST inmutable (
   `SourceUnitNode`) mediante descenso recursivo con sincronización ante fallas y cuota de diagnósticos.
3. **Modelado inmutable del AST (`syntax/ast/`):** Definición de nodos sellados libres de métodos de cómputo, con
   identificadores estables (`NodeId`), tramos de código (`Span`) y recorrido estructural único.
4. **Resolución de símbolos y jerarquías (`semantic/symbols/`):** Resolución de ámbitos, detección de ciclos de
   herencia, validación de miembros y análisis de símbolos no usados en cuatro pasadas secuenciales.
5. **Verificación estática de tipos (`semantic/types/`):** Chequeo tipado en perfiles estricto y flexible, inferencia en
   primera asignación, ampliación única (`Entero` a `Real`), comprobación de asignabilidad y reglas de operadores.
6. **Evaluación determinista paso a paso (`evaluation/interpreter/`):** Máquina de tareas explícita no recursiva sobre
   la pila del host (`ExecutionTask`), avance atómico con soporte para lectura interactiva suspendida y emisión de
   eventos.
7. **Aritmética y entorno en ejecución (`evaluation/values/`, `evaluation/environment/`):** Enteros deterministas de 64
   bits con detección de desbordamiento sobre `BigInt` (`PseudoInteger`), fuente pseudoaleatoria sembrada, celdas de
   variables e instancias con identidad de objeto.
8. **Diagnósticos independientes de idioma (`diagnostics/`, `domain/`):** Estructuración abstracta de diagnósticos
   tipados con argumentos sellados y renderizado desacoplado hacia el idioma de interfaz.
9. **Definición y validación de perfiles de lenguaje (`domain/profile/`):** Separación formal entre vocabulario y reglas
   de rigor con normalización canónica de programas.

### 1.3 Fuera de alcance a propósito (`SCOPE-YAGNI`)

#### De producto

- **Herencia múltiple, interfaces y clases abstractas:** El lenguaje modela únicamente herencia simple y despacho
  dinámico directo para preservar la claridad conceptual de la programación orientada a objetos sin complejidades
  combinatorias de resolución.
- **Métodos estáticos y sobrecarga de métodos:** Descartados para asegurar que cada firma de método sea unívoca y que la
  resolución de llamadas no dependa de reglas ad-hoc de despacho estático.
- **Genéricos y sobrecarga de operadores:** Excluidos para evitar la explosión combinatoria del sistema de tipos en un
  lenguaje enfocado en fundamentos algorítmicos.
- **Excepciones de usuario y bloques de captura (`try`/`catch`):** El lenguaje enseña precondiciones y control
  estructurado; las fallas esperables de ejecución devuelven estados tipados.
- **Tercer nivel de visibilidad (protegido):** Solo existen miembros públicos o privados a la clase (`Privado`). Para
  acceder al estado de la superclase se requiere pasar por métodos públicos o constructores, reforzando la encapsulación
  canónica.
- **Constantes con nombre:** Las expresiones constantes en arreglos y dimensiones operan exclusivamente sobre literales
  numéricos evaluados sintácticamente, sin resolución de identificadores de constantes.
- **Tipos de usuario complejos:** Sin apuntadores explícitos, enumerados, tuplas, subrangos ni tipos de archivo.
- **Instrucciones de salto arbitrario (`Interrumpir`, `Continuar`, `Ir A`):** Excluidas para preservar estrictamente los
  principios de la programación estructurada. La sentencia `Retornar` se admite exclusivamente como terminación natural
  de subprogramas.
- **Perfiles de sintaxis personalizados o programables por el usuario:** Excluidos formalmente por complejidad técnica y
  falta de viabilidad. Permitir que el usuario o el entorno definan libremente nuevos perfiles léxicos introduce
  colisiones impredecibles entre palabras clave y nombres de variables/identificadores, fragmentación en la experiencia
  didáctica y severas fricciones en componentes periféricos (autocompletado en editor, resaltado de sintaxis, teclados
  contextuales). El soporte de sintaxis está cerrado y garantizado exclusivamente sobre dos perfiles oficiales, maduros
  y documentados: `ClassicSpanishProfile` y `EnglishProfile`.

#### De implementación técnica

- **Acceso a recursos de sistema operativo:** Prohibido `dart:io` en `lib/`; el paquete carece de acceso a sistema de
  archivos, red, portapapeles o reloj del host. La E/S se modela mediante eventos abstractos y llamadas a
  `Interpreter.provideInput()`.
- **Dependencias de interfaz de usuario:** Prohibido `package:flutter/` y `dart:ui`.
- **Concurrencia real o hilos secundarios:** Prohibido `dart:isolate`. La ejecución del núcleo es puramente síncrona y
  determinista; la asincronía hacia la UI se provee únicamente como adaptador periférico (
  `ExecutionEventStreamAdapter`).
- **Reflexión dinámica e interoperabilidad web acoplada:** Prohibido `dart:mirrors`, `dart:html`, `dart:js` y
  `dart:js_interop`.
- **Dependencias externas en runtime:** Cero librerías de terceros en la sección `dependencies` de `pubspec.yaml` (Dart
  SDK puro).

### 1.4 Casos de uso principales

1. **Tokenización y análisis léxico:** Conversión de código fuente en secuencia de tokens tipados y reporte de
   diagnósticos léxicos con tramos de código (`Lexer.tokenize()`).
2. **Construcción y validación del AST:** Generación del árbol sintáctico estructurado (`Parser.parse()`) con
   recuperación ante errores en sentencias simples y límite de 100 diagnósticos.
3. **Resolución de símbolos y jerarquías:** Validación de identificadores, ámbitos y clases en 4 pasadas (
   `NameResolver.resolve()`).
4. **Chequeo estático de tipos:** Comprobación estricta o flexible de tipos en asignaciones, operadores, llamadas y
   retornos (`TypeChecker.check()`).
5. **Ejecución guiada paso a paso:** Avance instrucción a instrucción (`Interpreter.step()`) con notificación síncrona a
   observadores (`ExecutionObserver`) y soporte para pausar ante lecturas interactivas (`Leer`).
6. **Ejecución completa continua:** Evaluación continua de un programa analizado de principio a fin (
   `ProgramRunner.run()`).
7. **Normalización y traducción de programas:** Reformateo canónico y traducción entre perfiles léxicos mediante
   `ProfileNormalizer.normalize()`.
8. **Renderizado localizado de diagnósticos:** Traducción y formateo de diagnósticos independientes del idioma hacia el
   idioma de interfaz configurado (`DiagnosticRenderer.render()`).

### 1.5 Pendientes técnicos declarados

| Pendiente                                                         | De quién depende                                                                                                                           | Estado actual |
|:------------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------|:--------------|
| Tramos y tokens de comentarios en el lexer                        | Extensión del lexer para emitir comentarios como canal secundario (trivia) sin descartarlos para soporte del editor                        | Abierto       |
| Ámbitos con copia al escribir (`copy-on-write` en frames)         | Optimización interna del almacenamiento de entornos en bucles extensos sin alterar firmas públicas                                         | Planificado   |
| Verificación de bit exacto en funciones trascendentes             | Evaluación de polyfill numérico para funciones trigonométricas si JS/WASM divergen de nativo                                               | Abierto       |
| Diagnóstico de nombre reservado en las demás posiciones de nombre | Extensión de `reservedLexemeUsedAsName` al nombre de algoritmo, de subprograma, de clase, de miembro, de parámetro y al destino de lectura | Abierto       |

---

## 2. Guía operativa y ciclo de vida

### 2.1 Requisitos previos y plataformas objetivo

- **Entorno de ejecución y SDKs:** Dart SDK ^3.5.0.
- **Plataformas soportadas:** macOS (x64, arm64), Linux (x64, arm64), Windows (x64), Web (JavaScript / WebAssembly).
- **Variables de entorno y flags requeridos:** Ninguna variable requerida. El paquete opera de forma autónoma en
  memoria.

### 2.2 Preparación e instalación

Comandos para resolver dependencias y preparar el entorno local:

```bash
# Instalación de dependencias de desarrollo
dart pub get
```

### 2.3 Ejecución en desarrollo

Comando para ejecutar el script de integración de ejemplo que ejercita el pipeline completo:

```bash
# Ejecución nativa del objetivo de pipeline
dart run example/pipeline_compilation_target.dart
```

### 2.4 Compilación y build

Comandos para validar la compilación a los tres objetivos oficiales:

```bash
# Compilación a JavaScript optimizado
dart compile js -O1 -o build/target.js example/pipeline_compilation_target.dart

# Compilación a WebAssembly
dart compile wasm -o build/target.wasm example/pipeline_compilation_target.dart

# Compilación a binario ejecutable nativo
dart compile exe example/pipeline_compilation_target.dart -o build/target_exe
```

- **Rutas de salida de artefactos:** Directorio `build/` en la raíz del paquete.

### 2.5 Pruebas y verificación inmediata

Comandos directos para validar la salud técnica sin dependencias de entorno:

```bash
# Ejecución de la suite completa de tests unitarios y de integración
dart test

# Análisis estático y linter estricto
dart analyze --fatal-infos --fatal-warnings

# Verificador de límites métricos estructurales
dart run tool/check_limits.dart

# Verificación de arquitectura y capas permitidas
dart test test/architecture/layering_test.dart

# Verificación de pureza arquitectónica (cadenas de usuario fuera de diagnostics)
dart test test/architecture/no_user_facing_strings_test.dart

# Verificación de objetivos de compilación a JS y WASM
dart test test/compilation/compilation_targets_test.dart
```

### 2.6 Despliegue y distribución

- **Estrategia de entrega:** Paquete de monorepo interno privado (`publish_to: 'none'`). Consumido por
  `apps/pseudolearn_app` y paquetes hermanos mediante dependencias por ruta relativa (
  `path: ../packages/pseudolearn_core`).
- **Checklist de release:**
    - [ ] Suite de pruebas al 100 % en verde (`dart test`).
    - [ ] Análisis estático sin incidencias (`dart analyze --fatal-infos --fatal-warnings`).
    - [ ] Script de límites métricos en verde (`dart run tool/check_limits.dart`).
    - [ ] Compilación a JS y WASM verificada (`dart test test/compilation/compilation_targets_test.dart`).
    - [ ] Versión sincronizada en `pubspec.yaml`.
    - [ ] Documentación técnica actualizada en el mismo commit (`DOC-README-TRUTH`).

---

## 3. Arquitectura y modelo del sistema

### 3.1 Paradigma arquitectónico

Pipeline concéntrico por etapas de compilador e intérprete. La dirección de dependencias es estrictamente unidireccional
y concéntrica: las capas internas nunca conocen a las externas (`LAYER-DIRECTION`).

```
┌──────────────────────────────────────────────┐
│ 4. diagnostics   presentación de diagnósticos │ ← estructuras, no cadenas de texto
├──────────────────────────────────────────────┤
│ 3. evaluation    intérprete y eventos         │
├──────────────────────────────────────────────┤
│ 2. semantic      resolución y tipos           │
├──────────────────────────────────────────────┤
│ 1. syntax        lexer, AST, parser           │
├──────────────────────────────────────────────┤
│ 0. domain        tokens, spans, diagnósticos  │ ← el centro, no depende de nada
└──────────────────────────────────────────────┘
```

### 3.2 Diagrama de capas y dirección de dependencias

Matriz de dependencias enforceada mecánicamente por `architecture.yaml`:

| Capa          | Identificador | Importa de (`may_import`)      | Prohibido importar (`forbidden_imports`)          |
|:--------------|:--------------|:-------------------------------|:--------------------------------------------------|
| `domain`      | 0             | nada del paquete (`[]`)        | `syntax`, `semantic`, `evaluation`, `diagnostics` |
| `syntax`      | 1             | `domain`                       | `semantic`, `evaluation`, `diagnostics`           |
| `semantic`    | 2             | `domain`, `syntax`             | `evaluation`, `diagnostics`                       |
| `evaluation`  | 3             | `domain`, `syntax`, `semantic` | `diagnostics`                                     |
| `diagnostics` | 4             | `domain`                       | `syntax`, `semantic`, `evaluation`                |

**Por qué la capa 4 solo depende de la 0:** Convertir un diagnóstico en estructura presentable es una función pura
`(código, argumentos) → estructura presentable`. Si necesitara importar del parser o del evaluador, cargaría lógica que
pertenece al análisis.

### 3.3 Catálogo de carpetas, responsabilidades e invariantes

| Capa / Directorio           | Responsabilidad única                                                                                                           | Puede importar (`may_import`)                           | Prohibido importar o contener (`forbidden_imports`)                 |
|:----------------------------|:--------------------------------------------------------------------------------------------------------------------------------|:--------------------------------------------------------|:--------------------------------------------------------------------|
| `lib/pseudolearn_core.dart` | Único punto de exportación de la API pública del paquete                                                                        | Todas las capas internas de `src/`                      | Dependencias externas no declaradas                                 |
| `domain/`                   | Define datos puros e inmutables (`Token`, `Span`, `NodeId`, `PrimitiveType`, `DiagnosticCode`, `Diagnostic`, `LanguageProfile`) | Ninguna capa interna                                    | Prohibido importar capas 1-4 y decidir comportamiento complejo      |
| `syntax/lexer/`             | Convierte texto plano en flujo de tokens con vocabulario del perfil activo                                                      | `domain`                                                | Prohibido conocer sentencias, expresiones o nodos del AST           |
| `syntax/ast/`               | Define clases selladas del AST y el recorrido puramente estructural                                                             | `domain`                                                | Prohibido métodos de evaluación, tipado, impresión o mutación       |
| `syntax/parser/`            | Construye el AST mediante descenso recursivo modular                                                                            | `domain`, `syntax/ast`, `syntax/lexer`                  | Prohibido evaluar, resolver símbolos o recibir vocabulario directo  |
| `semantic/symbols/`         | Resuelve identificadores, ámbitos y jerarquías en 4 pasadas                                                                     | `domain`, `syntax`                                      | Prohibido evaluar expresiones o ejecutar código                     |
| `semantic/types/`           | Chequea estáticamente tipos, inferencia y compatibilidad                                                                        | `domain`, `syntax`, `semantic/symbols`                  | Prohibido mutar o reescribir el AST recibido                        |
| `evaluation/values/`        | Modelo de valores en runtime y aritmética determinista de 64 bits                                                               | `domain`                                                | Prohibido conocer ámbitos, llamadas o eventos                       |
| `evaluation/environment/`   | Almacenamiento en ejecución (`VariableCell`, `ObjectInstance`, scopes)                                                          | `domain`, `evaluation/values`                           | Prohibido decidir lógica de evaluación sobre valores                |
| `evaluation/events/`        | Modelos de eventos de ejecución, instantáneas y canales de observación                                                          | `domain`, `evaluation/values`, `evaluation/environment` | Prohibido contener lógica de cálculo del intérprete                 |
| `evaluation/builtins/`      | Ejecución de funciones matemáticas y de cadena incorporadas                                                                     | `domain`, `evaluation/values`                           | Prohibido conocer perfiles más allá del formateador inyectado       |
| `evaluation/interpreter/`   | Máquina de tareas no recursiva y avance síncrono paso a paso                                                                    | `domain`, `syntax`, `semantic`, `evaluation/*`          | Prohibido recursión del host en llamadas de usuario y parsear texto |
| `diagnostics/`              | Traducción pura de diagnósticos a representaciones estructuradas                                                                | `domain`                                                | Prohibido literales de texto para el usuario fuera de esta capa     |

### 3.4 Flujo de datos y ciclo de vida

El procesamiento de un programa en `pseudolearn_core` sigue un ciclo estrictamente secuencial y desacoplado:

1. **Entrada y configuración:** El consumidor suministra el código fuente como cadena y una instancia inmutable de
   `LanguageProfile`.
2. **Análisis léxico:** `Lexer.tokenize()` procesa los caracteres según las reglas alfabéticas y el vocabulario del
   perfil, produciendo `List<Token>` y diagnósticos léxicos.
3. **Análisis sintáctico:** `Parser.parse()` procesa los tokens, maneja la precedencia de operadores, coordina la
   recuperación ante sentencias simples mediante `StatementSynchronizer` y construye
   `ParseResult(SourceUnitNode?, List<Diagnostic>)`.
4. **Resolución de nombres:** Si el programa sintáctico es válido, `NameResolver.resolve()` ejecuta cuatro pasadas sobre
   el AST generando la tabla de símbolos `Scope` y diagnósticos semánticos.
5. **Verificación de tipos:** `TypeChecker.check()` recorre el AST con la información de símbolos, infiere tipos de
   primera asignación en perfil flexible y valida asignabilidad, operadores y retornos, produciendo `TypeCheckResult`.
6. **Inicialización de la ejecución:** `Interpreter.start()` valida que no existan diagnósticos con severidad de error.
   Inicializa la pila de marcos `Interpreter.frames` con el marco raíz y apila la primera `ExecutionTask`.
7. **Ciclo paso a paso:** Cada invocación a `Interpreter.step()` desapila y ejecuta una micro-tarea atómica, actualiza
   `VariableCell`, emite eventos (`ExecutionEvent`, `DecisionEvaluatedEvent`) a través de `ExecutionObserver` y captura
   `EnvironmentSnapshot` si hay observadores suscritos.
8. **Suspensión por entrada:** Si la sentencia actual es de lectura (`Leer`), el intérprete suspende su ejecución
   devolviendo `StepOutcome.waitingForInput`. La ejecución se reanuda síncronamente al invocar
   `Interpreter.provideInput()`.
9. **Proyección de diagnósticos:** Todo diagnóstico acumulado es transformado por `DiagnosticRenderer` en estructuras
   estructuradas localizadas según el idioma de interfaz y el perfil léxico activo.

### 3.5 Concurrencia, asincronía y modelo de threading

- **Sincronismo absoluto:** El núcleo es 100 % síncrono y determinista. No contiene primitivas de espera, ni eventos
  dependientes de temporizadores, ni uso de `Future` en sus interfaces internas de análisis y evaluación.
- **Política sobre hilos secundarios (`Isolate`):** Prohibido el uso de `dart:isolate` dentro de `lib/`.
- **Adaptación asíncrona reactiva:** Para aplicaciones de interfaz gráfica que requieren consumir eventos mediante
  flujos reactivos, el paquete exporta `ExecutionEventStreamAdapter` como un adaptador periférico que envuelve la
  ejecución síncrona sin comprometer la pureza del núcleo.

---

## 4. Decisiones de diseño y fundamentos técnicos

### 4.1 Verificación de capas: test propio sobre el analizador de Dart

- **Problema:** La regla de dirección de dependencias es fundamental para la mantenibilidad del motor; una regla
  puramente documental se incumple con facilidad si los verificadores no la evalúan mecánicamente en cada cambio.
- **Elección:** Un test automatizado en `test/architecture/layering_test.dart` que parsea las directivas de importación,
  exportación y partición de cada archivo en `lib/src/` utilizando el analizador sintáctico de Dart en modo estricto.
  Resuelve rutas relativas contra el directorio del archivo emisor, valida la matriz de `architecture.yaml` e intercepta
  importaciones prohibidas de plataforma (`dart:io`, `package:flutter/`, etc.).
- **Alternativas descartadas y por qué:**
    - *Plugins de `custom_lint`:* Descartados por requerir configuración dependiente del editor, presentar opacidad en
      la depuración y sufrir roturas frecuentes ante actualizaciones del SDK de Dart.
    - *Paquetes de análisis de arquitectura de terceros:* Descartados para evitar introducir dependencias de
      mantenedores individuales o licencias comerciales en la regla no negociable del monorepo.
    - *Análisis mediante expresiones regulares (`RegExp`):* Descartado por generar falsos positivos en comentarios,
      cadenas literales o fragmentos de código documentados.

### 4.2 Recorrido del AST: clases selladas y coincidencia de patrones exhaustiva

- **Problema:** Múltiples consumidores independientes (chequeador de tipos, evaluador, futuros exportadores a lenguajes
  reales y layout de diagramas) requieren recorrer el árbol de sintaxis abstracta. Los nodos no deben contener lógica de
  comportamiento ni mutar su estructura.
- **Elección:** Nodos modelados como clases inmutables selladas (`sealed class`) que exponen exclusivamente constructor,
  campos finales, `Span` y `NodeId`. Las operaciones específicas se implementan mediante coincidencia de patrones
  exhaustiva (`switch` sobre tipos de nodo), apoyadas en una única función puramente estructural (
  `structural_traversal.dart`) para operaciones que no diferencian semántica de nodos.
- **Alternativas descartadas y por qué:**
    - *Patrón Visitor clásico (`accept(visitor)`):* Descartado porque inyecta métodos de comportamiento en las clases de
      nodo y su clase base abstracta con implementaciones por omisión silencia la adición de nuevos nodos en tiempo de
      compilación. Las clases selladas convierten al compilador en un validador exhaustivo que impide omitir nodos
      nuevos.
    - *Recorridos estructurales ad-hoc en cada consumidor:* Descartado para evitar dispersar la inspección de hijos; la
      función de recorrido estructural único garantiza orden de aparición idéntico en todos los consumidores.

### 4.3 Diagnósticos independientes del idioma

- **Problema:** El núcleo no puede acoplar sus mensajes al idioma de la interfaz ni a un perfil léxico específico, ya
  que un estudiante puede utilizar una interfaz en español con palabras clave en inglés o viceversa.
- **Elección:** Cada diagnóstico es una tupla estructurada `Diagnostic(code, severity, span, relatedSpans, arguments)`.
  Los argumentos pertenecen a una jerarquía sellada (`DiagnosticArgument`: token, tipo primitivo, término del dominio,
  lexema de usuario, número). La renderización se realiza en la capa `diagnostics/` resolviendo tokens contra el perfil
  activo y términos contra el catálogo de localización. La severidad se inyecta mediante tablas de rigor desacopladas
  del código de error.
- **Alternativas descartadas y por qué:**
    - *Generación de cadenas de texto dentro del lexer, parser o evaluador:* Descartado porque introduce literales de
      idioma en capas internas e impide la traducción limpia de mensajes.
    - *Severidad fijada directamente en la enumeración de diagnósticos:* Descartado porque impide que perfiles estrictos
      y flexibles asignen diferente severidad al mismo conflicto sintáctico o tipado sin ramificar el código.
    - *Omitir tramos relacionados (`relatedSpans`):* Descartado porque impide señalar visualmente el punto de apertura
      de un bloque sin cerrar o el sitio de declaración original de una variable en conflicto.

### 4.4 Ejecución paso a paso: intérprete gobernado desde fuera

- **Problema:** La depuración didáctica exige avanzar paso a paso, suspender la ejecución para lecturas del usuario (
  `Leer`) y permitir que múltiples observadores (resaltado de código, diagramas y tablas de traza) inspeccionen el
  estado sin acoplar el evaluador a sus implementaciones.
- **Elección:** El intérprete avanza mediante invocaciones atómicas a `Interpreter.step()`, donde no solicitar el paso
  siguiente equivale a la pausa. La ejecución se modela como una máquina de tareas explícita (`ExecutionTask`) con pilas
  independientes de tareas y operandos en cada `InterpreterFrame`, eliminando la recursión sobre la pila de llamadas de
  Dart. Cuando se encuentra una lectura interactiva, se emite `StepOutcome.waitingForInput` y el motor suspende
  síncronamente hasta que el llamador proporciona el dato con `Interpreter.provideInput()`. Los eventos se emiten a
  través de la interfaz `ExecutionObserver`.
- **Alternativas descartadas y por qué:**
    - *Evaluador recursivo clásico:* Descartado porque confunde la pila de llamadas de Dart con la de PseudoLearn,
      impidiendo pausar la evaluación en medio de expresiones compuestas con llamadas a subprogramas.
    - *Intérprete asíncrono con `async`/`await` o `Stream`:* Descartado porque contamina de asincronía todo el motor,
      perjudica la compilación a JS/WASM y destruye el determinismo estricto de las pruebas unitarias.
    - *Retorno de subprogramas implementado con excepciones de Dart:* Descartado porque el flujo normal de control no
      debe utilizar mecanismos de falla del lenguaje anfitrión.

### 4.5 Modelo de perfil: dos ejes ortogonales con invariante de no mutación semántica

- **Problema:** Distintas instituciones educativas utilizan vocabularios disímiles (castellano clásico, variantes
  regionales) y diferentes niveles de exigencia sintáctica y tipada, sin que ello deba alterar el significado de los
  algoritmos.
- **Elección:** Separación formal en dos ejes independientes dentro de `LanguageProfile`: el eje de vocabulario (mapeo
  biunívoco de tokens reservados a lexemas) y el eje de rigor (banderas booleanas de exigencia). Rige el invariante
  fundamental de portabilidad: **una bandera de rigor solo puede invalidar un programa, nunca alterar lo que calcula.**
  El parser opera sobre tipos abstractos de token sin conocer palabras clave concretas.
- **Alternativas descartadas y por qué:**
    - *Un solo eje combinando vocabulario y rigor:* Descartado porque confunde la traducción léxica con la semántica del
      programa y produce fallos silenciosos al migrar código entre perfiles.
    - *Hacer configurables la base de índices de arreglos o la sensibilidad a mayúsculas:* Descartado porque ambas
      opciones alteran el valor resultante del cálculo en lugar de su validez; se fijan normativamente en el lenguaje
      (base 0 y mayúsculas/minúsculas canónicas).
    - *Normalización léxica por token individual:* Descartado porque hace no decidible la detección de colisiones entre
      identificadores y palabras reservadas.
- **Superficie de extensión y su alcance actual:** El paquete incluye y soporta exclusivamente dos perfiles oficiales
  completos y simétricos: `ClassicSpanishProfile` («Español clásico») y `EnglishProfile` («English»), ambos con paridad
  total y constructores `.strict()` y `.flexible()`. La creación de perfiles personalizados o programables por el
  usuario
  queda excluida deliberadamente por complejidad técnica (colisiones léxicas con identificadores, inconsistencias en el
  autocompletado del editor y fragmentación del dialecto didáctico) y por no resultar viable frente a dos perfiles
  maduros y formalmente documentados. El catálogo de perfiles es cerrado; toda la maquinaria del analizador léxico,
  sintáctico, semántico y evaluador opera sobre las interfaces del dominio (`LanguageProfile`, `LexerProfile`,
  `ParserProfile`, `SemanticProfile`) desacopladas de las palabras clave concretas, garantizando portabilidad sin abrir
  la
  puerta a la proliferación de sintaxis arbitrarias. El eje de rigor expone los constructores `.strict()` y
  `.flexible()`
  en cada perfil incluido; la aplicación cliente utiliza `.flexible()` por defecto y reserva `.strict()` para escenarios
  académicos de máxima exigencia.

### 4.6 Parser modular: un archivo por construcción con sincronizador compartido

- **Problema:** Un parser de descenso recursivo monolítico sobrepasa ampliamente los límites de tamaño de archivo y
  acopla la gramática de sentencias dispares.
- **Elección:** Modularización de cada construcción sintáctica en un sub-parser independiente coordinado por
  `StatementParser` (despachador central de sentencias) y `StatementSynchronizer` (mecanismo que avanza hasta
  delimitadores seguros ante errores). Se aplica un límite estricto de 100 diagnósticos por análisis para evitar
  cascadas infinitas de error en programas malformados, retornando siempre `ParseResult` tipado sin lanzar excepciones.
- **Alternativas descartadas y por qué:**
    - *Parser monolítico en un único archivo:* Descartado por violar los límites métricos y concentrar múltiples razones
      de cambio en un solo componente.
    - *Sincronización indiscriminada en sentencias compuestas:* Descartado porque provocaría que el sincronizador
      saltara por encima de bloques anidados completos (`Si`, `Mientras`), ocultando errores didácticos internos.
    - *Lanzar excepciones de parseo:* Descartado para preservar la frontera pública tipada libre de excepciones.

### 4.7 Procedural y unidad de compilación: `SourceUnitNode`, subprogramas y parámetros

- **Problema:** Un archivo fuente puede contener un algoritmo principal y múltiples subprogramas (procedimientos y
  funciones) en cualquier orden de nivel superior, con parámetros escalares y matriciales multidimensionales pasados por
  valor o por referencia.
- **Elección:** El nodo raíz del AST es `SourceUnitNode`, que preserva tanto las colecciones tipadas (`algorithm`,
  `subroutines`) como la secuencia textual ordenada (`declarations`). Los parámetros se modelan unificados en
  `ParameterNode` con dimensionalidad (`dimensionCount`), tipo primitivo opcional y modo de paso (`passingMode`).
  `ReturnStatementNode` y `CallStatementNode` encapsulan la semántica procedimental en sub-parsers desacoplados.
- **Alternativas descartadas y por qué:**
    - *Separar procedimientos y funciones en tipos de nodo disjuntos:* Descartado porque duplica innecesariamente la
      estructura de cabecera y cuerpo; se unifican en `SubroutineDeclarationNode` diferenciados por la presencia
      opcional de tipo de retorno.
    - *Exigir declaraciones adelantadas de subprogramas:* Descartado por introducir burocracia sintáctica ajena a la
      didáctica algorítmica.

### 4.8 Tabla de símbolos y resolución de nombres en cuatro pasadas

- **Problema:** La resolución de identificadores debe admitir el uso de subprogramas y clases antes de su punto textual
  de declaración, respetar la ausencia de ámbitos de bloque (las variables declaradas dentro de `Si` o `Mientras`
  pertenecen al subprograma envolvente y persisten tras él), exigir el prefijo `Este.` para miembros propios, detectar
  ciclos en herencia simple y auditar variables no usadas.
- **Elección:** `NameResolver` ejecuta cuatro pasadas secuenciales desacopladas: (1) `TopLevelDeclarationCollector` para
  declaraciones de nivel superior y colisiones; (2) `ClassHierarchyValidator` para resolución de herencia, ciclos en
  grafos y firmas de sobrescritura; (3) `BodySymbolResolver` para resolución secuencial de cuerpos sin ámbitos de
  bloque; y (4) `UnusedSymbolAnalyzer` para reportar advertencias pedagógicas de símbolos no leídos o no usados.
- **Alternativas descartadas y por qué:**
    - *Resolución en una sola pasada:* Descartado porque imposibilita la invocación mutua entre subprogramas o el uso de
      tipos de clase antes de su definición textual.
    - *Creación de ámbitos locales por cada bloque de control (`if`, `while`):* Descartado porque viola la semántica
      canónica del lenguaje donde las variables declaradas dentro de estructuras persisten en el entorno del algoritmo.

### 4.9 Sistema de tipos y verificación semántica

- **Problema:** La verificación de tipos debe conciliar el modo estricto con el modo flexible (inferencia en primera
  asignación y ampliación única de `Entero` a `Real`), soportar subtipado en clases, verificar paso de parámetros por
  referencia (que exige coincidencia exacta de tipo) y validar operadores aritméticos y relacionales sin truncamientos
  implícitos.
- **Elección:** Jerarquía sellada `SemanticType` en `lib/src/semantic/types/`, con `TypeRelations` gobernando identidad,
  convertibilidad, compatibilidad y comparabilidad. Los operadores aplican las reglas canónicas mediante
  `OperatorTypeTable`. `TypeEnvironment` gestiona la inferencia y ampliación controlada, y verificadores modulares
  recorren el AST validando expresiones, sentencias y llamadas sin modificar los nodos.
- **Alternativas descartadas y por qué:**
    - *Truncamiento implícito en asignaciones de real a entero:* Descartado porque convierte un error de pérdida de
      precisión en un valor silenciosamente corrompido; se exige conversión explícita mediante funciones como `Trunc`.
    - *Inferencia dinámica permisiva con múltiples ampliaciones:* Descartado porque degenera el pseudocódigo en tipado
      dinámico caótico; se restringe a una única ampliación de entero a real en perfil flexible.
    - *Conversión implícita en parámetros por referencia:* Descartado porque en el paso por referencia el parámetro
      accede a la celda de memoria original; una conversión de tipo rompería la representación y la semántica de la
      variable llamadora.

### 4.10 Representación determinista de los valores en ejecución

- **Problema:** El motor compila a plataformas nativas (enteros de 64 bits), JavaScript (números IEEE 754 con enteros
  seguros de 53 bits) y WebAssembly. Los tipos primitivos nativos de Dart rompen el determinismo numérico entre
  plataformas.
- **Elección:** `PseudoInteger` en `domain/` encapsula un `BigInt` y valida rigurosamente los límites de 64 bits con
  signo en cada operación. La aritmética entera y las divisiones truncadas se calculan mediante `BigInt` componiendo
  operaciones exactas. La generación pseudoaleatoria (`azar`) utiliza un generador lineal congruente propio con
  aritmética de 16/32 bits sembrado de forma determinista, prescindiendo de `dart:math.Random`.
- **Alternativas descartadas y por qué:**
    - *Uso del tipo nativo `int` de Dart:* Descartado porque produce divergencias críticas en desbordamientos y
      truncamientos al compilar a JavaScript frente a plataformas nativas.
    - *Uso directo de `dart:math.Random`:* Descartado porque su implementación varía según la plataforma subyacente y no
      permite reproducibilidad idéntica de semillas entre clientes.

### 4.11 Evaluación orientada a objetos: instancias, despacho y referencias

- **Problema:** Modelar objetos en tiempo de ejecución con identidad unívoca, soporte de paso de parámetros por
  referencia vs valor de referencia, despacho dinámico polimórfico, invocaciones a `Super` y copia de instancias,
  manteniendo la transparencia en la prueba de escritorio y sin recursión en el host.
- **Elección:** `ObjectInstance` con identificador entero único y mapa mutable de celdas de atributos (`VariableCell`),
  representado como `ObjectValue`. Las asignaciones y pasos de parámetros copian la referencia al objeto. El despacho
  dinámico resuelve métodos según la clase concreta de la instancia; las llamadas a `Super` resuelven estáticamente
  desde la superclase del llamador. La primitiva `Copiar` realiza copia superficial (duplica la instancia pero preserva
  referencias compartidas en atributos anidados).
- **Alternativas descartadas y por qué:**
    - *Copia profunda automática por omisión:* Descartado porque enmascara el fenómeno del aliasing e introduce costos
      de clonación impredecibles en el intérprete.
    - *Instanciación implícita de objetos al declarar variables:* Descartado porque oculta la distinción esencial entre
      la referencia nula y la instancia creada en memoria.

### 4.12 Superficie de palabras reservadas y colisión con nombres de variable

- **Problema:** El léxico reservado de un perfil es insensible a mayúsculas y a tildes, y esa insensibilidad es la misma
  búsqueda que decide si una palabra escrita es una palabra clave o un nombre. Cada forma reservada —canónica o alias—
  retira del vocabulario disponible el nombre correspondiente en todas sus grafías: declarar `Numero` como alias de un
  tipo le quita a quien programa la variable `numero`. Una forma que nunca se imprime paga ese precio sin devolver nada
  a la lectura del programa, y la colisión resultante se manifiesta lejos de su causa, como una cascada de errores de
  sintaxis sobre una declaración correcta a ojos de quien la escribió.
- **Elección:** Doble regla. **Primera:** un perfil declara un alias solo cuando la forma aporta una entrada habitual
  que no compite con un nombre frecuente; los tipos del perfil de referencia se escriben únicamente con su lexema
  canónico. **Segunda:** el parser reporta la colisión con un diagnóstico propio (`reservedLexemeUsedAsName`) que lleva
  la palabra tal como se escribió y el token reservado con el que choca, solo en las posiciones donde la gramática
  exige un nombre y ninguna otra cosa —lista de declaración, destino de asignación y variable de control del bucle
  contado—, consumiendo el token y continuando el análisis para que la sentencia produzca un diagnóstico y no una
  cascada. El predicado que distingue un lexema de palabra de uno de símbolo es único (`LexemeShape`) y lo comparten el
  lexer, al construir su tabla, y el parser, al clasificar lo que encontró.
- **Alternativas descartadas y por qué:**
    - *Comparar el nombre contra el léxico reservado carácter a carácter:* Descartado porque exige renunciar a la
      insensibilidad a mayúsculas y a tildes del propio léxico reservado; reconocer `mientras` como palabra clave y
      admitir `mientras` como nombre son resultados contradictorios de la misma búsqueda en la misma tabla.
    - *Palabras clave blandas admitidas como nombre según la posición:* Descartado porque los operadores lógicos `Y`,
      `O` y `NO` son genuinamente ambiguos en posición de expresión, de modo que la técnica no cubre el caso que más
      duele y obliga a ampliar el modelo de perfil, el validador y el flujo entre lexer y parser para resolver solo los
      tokens de tipo.
    - *Reportar la colisión desde el lexer:* Descartado porque el lexer no conoce la posición gramatical y no puede
      distinguir el uso legítimo de una palabra clave del nombre mal elegido.
    - *Reportar en cualquier posición donde aparezca un lexema reservado:* Descartado porque confunde el nombre mal
      elegido con la expresión incompleta y sustituye un diagnóstico correcto por uno que induce al error contrario.

---

## 5. Reglas de legibilidad, estilo y estructura de código

### 5.1 Filosofía de código auto-explicativo

- **Una sola responsabilidad por archivo:** Todo archivo debe describirse en una única frase sin conjunciones
  copulativas ("y").
- **Idioma del código (`LANG-EN-CODE`):** Todos los identificadores, variables, nombres de archivos, tests y mensajes de
  commit se escriben en inglés. La documentación técnica y especificaciones se escriben en español (`LANG-ES-DOCS`).

### 5.2 Límites métricos obligatorios (`architecture.yaml`)

Valores enforceados mecánicamente por `tool/check_limits.dart`:

- **Líneas por archivo:** Máximo 300 líneas (rutas exentas: `test/` y `tool/`).
- **Líneas por función o método:** Máximo 40 líneas.
- **Parámetros posicionales:** Máximo 4 parámetros. Para listas mayores se utilizan parámetros nombrados o clases de
  configuración.
- **Profundidad de anidación:** Máximo 3 niveles de control (`if`, `for`, `while`, `switch`, `try`).
- **Métodos públicos por clase:** Máximo 7 métodos públicos.

### 5.3 Política estricta de comentarios (`QUALITY-NO-COMMENTS`)

- **Prohibición absoluta en código Dart (`code_rules.forbid_comments: true`):**
    - Todo comentario de cualquier tipo (`//`, `/* */`, `///`) está estrictamente prohibido en los archivos `.dart`.
    - Los nombres de variables, funciones y clases junto con tipos explícitos expresan el *qué*.
    - Las razones y decisiones arquitectónicas residen en este `README.md`, nunca en comentarios dentro del código.
    - Esta regla es enforceada de forma mecánica por `tool/check_limits.dart` y validada por
      `test/tool/check_limits_test.dart`.

### 5.4 Convenciones técnicas y anti-patrones prohibidos

- **Imports relativos obligatorios (`forbid_self_package_imports`):** Dentro de `lib/src/` está prohibido importar
  archivos propios mediante `package:pseudolearn_core/`. Todos los imports internos son relativos para garantizar la
  verificación estricta de capas.
- **Prohibición de plataformas externas:** Prohibido importar `dart:io`, `dart:ui`, `dart:html`, `dart:js`,
  `dart:js_interop`, `dart:mirrors`, `dart:isolate` o `package:flutter/` en `lib/`.
- **AST puramente pasivo:** Prohibido que las clases de nodo en `syntax/ast/` contengan métodos de evaluación, impresión
  o tipado.
- **Pureza de cadenas de usuario:** Prohibido que existan cadenas de texto destinadas a personas en `syntax`, `semantic`
  o `evaluation`. Todos los literales de usuario residen en `diagnostics/` (`no_user_facing_strings_test.dart`).

### 5.5 Gestión tipada de errores

- Ninguna excepción no controlada cruza la frontera pública del paquete.
- Los fallos sintácticos, semánticos y de evaluación se representan mediante resultados tipados estructurados:
    - `ParseResult(program, diagnostics)`
    - `ResolutionResult(scope, diagnostics)`
    - `TypeCheckResult(typeEnvironment, diagnostics)`
    - `ExecutionResult` (`ExecutionSuccess`, `ExecutionStepLimitReached`, `ExecutionNotExecutable`,
      `ExecutionHaltedOnExit`)
    - `StepOutcome` (`stepped`, `waitingForInput`, `completed`, `error`)

---

## 6. Decisiones de producto que condicionan el código

Leyes vigentes del producto que justifican decisiones técnicas para preservarlas ante refactorizaciones:

### 6.1 El núcleo no produce texto legible en capas internas

Los tests unitarios y de integración se escriben contra códigos de diagnóstico (`DiagnosticCode`), no contra frases
literales. Esto permite evolucionar las traducciones y adaptaciones regionales sin romper la suite de verificación
técnica.

### 6.2 La semántica está desacoplada de la sintaxis superficial

El AST y el evaluador referencian tipos de token y enumeraciones semánticas, nunca los lexemas textuales utilizados en
el código fuente. Los perfiles institucionales e idiomas son datos inyectados, no bifurcaciones condicionales de código.

### 6.3 Extensibilidad mecánica y verificable

La incorporación de un nuevo perfil de sintaxis o idioma de diagnósticos es un proceso estrictamente mecánico: consiste
en completar tablas de datos y ejecutar verificadores automatizados, sin modificar la lógica interna del compilador o
intérprete.

### 6.4 El aliasing de objetos se enseña explícitamente

Los objetos se asignan y se pasan por referencia, exponiendo su identidad (`ObjectInstance.id`). La primitiva `Copiar`
realiza copia superficial (duplica la instancia pero preserva referencias compartidas en atributos anidados), reflejando
con fidelidad el comportamiento de lenguajes industriales como Java o Python.

### 6.5 Determinismo absoluto en el camino crítico

La ejecución de algoritmos es completamente determinista y verificable. Ninguna pieza del núcleo consulta servicios
externos, ni depende del reloj del sistema, ni emplea generadores aleatorios no sembrados.

### 6.6 El error como herramienta pedagógica

Los diagnósticos proveen tramos exactos (`Span`) y ubicaciones relacionadas (`relatedSpans`), señalando pedagógicamente
el origen del conflicto (ej. punto de apertura de un bloque sin cerrar o ubicación de declaración original de una
variable en conflicto) en lugar de reportar fallas opacas.

### 6.7 Ausencia de valores por omisión en variables no inicializadas

Tanto en perfil estricto como flexible, las variables no inicializadas carecen de valores por omisión implícitos.
Acceder a una variable antes de inicializarla produce un diagnóstico de error (`variableUsedUninitialized`), evitando
que un olvido de inicialización se confunda con un resultado de cómputo válido.

---

## 7. Verificación, testing y aseguramiento de calidad

### 7.1 Matriz de verificadores mecánicos

| Verificador                      | Archivo / Comando                                              | Qué detecta                                                                                                                                            | Dónde vive la regla     |
|:---------------------------------|:---------------------------------------------------------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------|
| Linter de Dart                   | `dart analyze --fatal-infos --fatal-warnings`                  | Tipado estricto, null safety, buenas prácticas y dead code                                                                                             | `analysis_options.yaml` |
| Test de capas                    | `dart test test/architecture/layering_test.dart`               | Violaciones de `may_import`, `forbidden_imports`, capas no declaradas e imports no relativos                                                           | `architecture.yaml`     |
| Test de cadenas visibles         | `dart test test/architecture/no_user_facing_strings_test.dart` | Literales de texto de interfaz o mensajes de error fuera de `diagnostics/`                                                                             | `architecture.yaml`     |
| Límites métricos y comentarios   | `dart run tool/check_limits.dart`                              | Archivos >300 líneas, funciones >40 líneas, >4 parámetros posicionales, >3 niveles de anidación, >7 métodos públicos, y cualquier comentario en código | `architecture.yaml`     |
| Objetivos de compilación JS/WASM | `dart test test/compilation/compilation_targets_test.dart`     | Valida que el pipeline compila con éxito a JavaScript (`dart compile js`) y WebAssembly (`dart compile wasm`)                                          | `architecture.yaml`     |
| Fixture negativo de límites      | `dart test test/tool/check_limits_test.dart`                   | Verifica mecánicamente que el evaluador de límites reporta fallos ante violaciones deliberadas                                                         | `architecture.yaml`     |

### 7.2 Estrategia y pirámide de pruebas

- **Estructura espejo (`TEST-MIRROR`):** El directorio `test/` reproduce con exactitud la jerarquía de carpetas de
  `lib/` (`domain`, `syntax`, `semantic`, `evaluation`, `diagnostics`), complementada con `architecture`, `compilation`,
  `public_api` y `tool`.
- **Doble camino (`TEST-BOTH-PATHS`):** Toda funcionalidad se prueba en su camino exitoso, en sus caminos de error
  controlados y ante casos límite explícitos (programas vacíos, colecciones vacías, recursión profunda, identificadores
  de un carácter, desbordamiento aritmético de 64 bits y división por cero).
- **Pruebas negativas de verificadores:** Los scripts de verificación arquitectónica y límites cuentan con fixtures de
  prueba negativos que introducen violaciones deliberadas para constatar que los verificadores fallan efectivamente ante
  infracciones.

### 7.3 Señales de alerta al revisar (Code Review Checklist)

Un cambio debe ser rechazado si presenta cualquiera de los siguientes síntomas:

- [ ] Importa desde una capa prohibida por `architecture.yaml`.
- [ ] Utiliza `package:pseudolearn_core/` en lugar de imports relativos dentro de `lib/src/`.
- [ ] Importa librerías prohibidas de plataforma (`dart:io`, `dart:ui`, `package:flutter/`).
- [ ] Añade métodos de comportamiento, tipado o evaluación a clases de nodo en `syntax/ast/`.
- [ ] Introduce literales de texto para el usuario fuera de `diagnostics/`.
- [ ] Un archivo o método excede los límites métricos fijados en `architecture.yaml`.
- [ ] Contiene comentarios que explican *qué* hace el código o citan documentos externos.
- [ ] Modifica reglas de arquitectura o diseño sin actualizar este `README.md` (`DOC-README-TRUTH`).
- [ ] Incluye justificaciones narrativas de evolución histórica en lugar de enunciados normativos en presente.

---

## 8. Fuentes consultadas y genealogía conceptual

Documentación de las fuentes externas analizadas durante el diseño del motor. PseudoLearn es dueño de su motor y de su
gramática; la especificación normativa del lenguaje es `docs/language-spec.md`.

| Fuente consultada                                                      | Qué se tomó                                                                                                                                                                                                                                                                                                                                                                                                                                                      | Qué se rechazó deliberadamente y por qué                                                                                                                                                                                                                                      |
|:-----------------------------------------------------------------------|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| PSeInt: sitio oficial y manuales de uso                                | La familiaridad del vocabulario del perfil «Español clásico» como decisión pedagógica para estudiantes hispanohablantes.                                                                                                                                                                                                                                                                                                                                         | Su motor en C++, su modelo de ejecución no determinista, su tratamiento de errores permisivo, la declaración de arreglos en dos sentencias separadas y la sintaxis de retorno en cabecera.                                                                                    |
| Libro de algoritmos y ordinogramas de abrirllave                       | Criterio de precedencia y asociatividad de operadores; notación de ordinogramas estandarizada; semántica paso a paso de bucles; tipos admisibles en etiquetas de selección múltiple; y catálogo de tipos resultantes en expresiones con operadores.                                                                                                                                                                                                              | Vocabulario en minúsculas, instrucciones de salto (`Interrumpir`), bucle posterior con condición de permanencia en lugar de terminación, truncamiento implícito en asignación de real a entero, y orden relacional entre valores lógicos.                                     |
| Alpha, notación algorítmica basada en pseudocódigo                     | Semántica de orientación a objetos: herencia simple, acceso a miembros con punto, visibilidad por miembro y acceso a la superclase.                                                                                                                                                                                                                                                                                                                              | Sintaxis en inglés, punteros, plantillas, destructores, visibilidad protegida y el constructor `super.atributo` que rompe el encapsulamiento privado de la superclase.                                                                                                        |
| MultiPseudo                                                            | Confirmación del modelo de vocabulario como dato desacoplado capaz de traducir entre múltiples sintaxis.                                                                                                                                                                                                                                                                                                                                                         | Sintaxis orientada a Python, traducción automática por diccionario simple y ausencia de gramática formal publicada para orientación a objetos.                                                                                                                                |
| Guía de pseudocódigo de Cambridge International 9618                   | Estructura de subprogramas: sentencia de retorno de ejecución inmediata admisible múltiples veces, marcas explícitas de paso por valor y referencia (con paso por valor por omisión), paréntesis obligatorios y llamadas a funciones restringidas a expresiones. Convenciones de orientación a objetos (`CLASS`/`ENDCLASS`, `INHERITS`, `PUBLIC`/`PRIVATE`, constructor `NEW`, `SUPER.`, instanciación `NEW`). Regla de división real obligatoria entre enteros. | Separación de procedimientos y funciones en construcciones disjuntas; arrastre implícito de la marca de paso a parámetros siguientes; sintaxis en inglés; operador de concatenación separado de la suma; y silencios en semántica de visibilidad privada y ligadura dinámica. |
| Notación de pseudocódigo de OCR A Level Computer Science H046/H446     | Convergencia independiente en notación de objetos con Cambridge: palabras clave idénticas, visibilidad pública por omisión, constructor `NEW` y acceso a superclase mediante `SUPER.`.                                                                                                                                                                                                                                                                           | Los mismos vacíos de especificación semántica que Cambridge respecto a ligadura dinámica y encapsulamiento estricto.                                                                                                                                                          |
| NASPI y NASPOO, notaciones algorítmicas estándar                       | Selección múltiple sin caída (`fallthrough`) entre ramas; ligadura dinámica siempre en métodos; obligatoriedad de referencia explícita al objeto actual (`Este`); y estructura formal de relaciones de tipo (identidad, compatibilidad, asignabilidad y comparabilidad).                                                                                                                                                                                         | Tipos elementales divergentes, operadores de salto, acceso matricial encadenado, punteros, tuplas, miembros estáticos, compatibilidad simétrica que permite truncar en silencio, visibilidad por bloques y copia implícita de objetos al pasar por valor.                     |
| UPSAM 2.0, notación de Joyanes Aguilar (*Fundamentos de programación*) | Visibilidad por miembro y constructor explícito en el formato general de clases en castellano.                                                                                                                                                                                                                                                                                                                                                                   | Tipo de retorno antepuesto al nombre del método, secciones `const` y `var` dentro de clases, operador de alcance `::` y contradicción interna entre visibilidad por bloques y por miembro.                                                                                    |

### Contradicciones entre fuentes resueltas y registradas

| Punto                            | Qué dicen las fuentes consultadas                                                                                 | Qué se decidió normativamente                                                                                                                                                                   |
|:---------------------------------|:------------------------------------------------------------------------------------------------------------------|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Semántica del bucle contado      | PSeInt sitúa el cuerpo antes de la prueba (itera al menos una vez); abrirllave evalúa la prueba antes del cuerpo. | **Prueba antes.** Cero o más iteraciones, consistente con el comportamiento de los lenguajes industriales estructurados.                                                                        |
| Paso omitido en el bucle contado | PSeInt fija paso 1; abrirllave infiere 1 o −1 según la relación inicial/final.                                    | **Siempre 1.** Inferir la dirección haría que el sentido del recorrido dependiera de valores dinámicos en tiempo de ejecución.                                                                  |
| Delimitador de dimensión         | Referencia de PSeInt usa paréntesis; manuales docentes usan corchetes.                                            | **Corchetes (`[]`).** Coherente con el inventario léxico estándar de arreglos.                                                                                                                  |
| Acceso multidimensional          | NASPI declara con comas y accede con corchetes encadenados (`m[1][2]`).                                           | **Un solo par de corchetes con comas (`m[1, 2]`).** Coherente entre la declaración y el acceso.                                                                                                 |
| Bucle posterior                  | PSeInt sale cuando la condición es verdadera; abrirllave y NASPI continúan mientras es verdadera.                 | **Condición de salida (`Repetir ... Hasta Que`).** La condición evalúa cuándo terminar el bucle.                                                                                                |
| Declaración de arreglos          | PSeInt utiliza dos sentencias separadas (dimensión y tipo).                                                       | **Una sola sentencia.** Evita inconsistencias de emparejamiento entre tamaño y tipo.                                                                                                            |
| Procedimiento y función          | abrirllave, NASPI y Cambridge separan en dos construcciones disjuntas; PSeInt unifica con retorno opcional.       | **Una sola construcción (`Subproceso` / `Subprograma`) con cláusula de retorno opcional.** Refleja los lenguajes reales donde las funciones tienen tipo de retorno posiblemente vacío (`void`). |
| Forma de retorno                 | PSeInt declara variable receptora en cabecera; abrirllave, NASPI y Cambridge usan sentencia de retorno.           | **Sentencia de retorno (`Retornar`).** Salida única y natural en cualquier punto del subprograma.                                                                                               |
| Variables globales               | abrirllave y NASPI permiten variables globales visibles en subprogramas; PSeInt las prohíbe.                      | **No hay variables globales.** Un subprograma debe recibir explícitamente sus datos para garantizar reutilización y transparencia en la traza paso a paso.                                      |
| Marca de paso de parámetros      | Cambridge arrastra la marca al resto de la lista; PSeInt la define por parámetro individual.                      | **Por parámetro y sin arrastre.** Previene que un parámetro no marcado se pase por referencia inadvertidamente.                                                                                 |
| Creación de objetos              | NASPOO instancia implícitamente al declarar; Cambridge, OCR y Joyanes exigen palabra clave explícita.             | **Instanciación explícita (`Nuevo`).** Enseña con nitidez la diferencia entre declarar una variable de referencia y asignar una instancia en memoria.                                           |
| Referencia al objeto actual      | Cambridge y OCR no disponen de autorreferencia; NASPOO la requiere.                                               | **Obligatoria (`Este.`).** Desambigua campos de parámetros en constructores y métodos.                                                                                                          |
| Visibilidad privada y herencia   | NASPOO y Joyanes no definen el acceso de la subclase a privados de la superclase.                                 | **Privado estricto a la clase.** La subclase no accede a miembros privados de su superclase; interactúa mediante métodos públicos o constructor.                                                |
| Marca de sobrescritura           | NASPOO exige `virtual` y `sobrescribe`; Cambridge y OCR omiten marcas.                                            | **Sin marcas léxicas adicionales.** Despacho dinámico polimórfico siempre en métodos de clase.                                                                                                  |
| División entre enteros           | Cambridge y abrirllave fijan resultado real; PSeInt no posee operador de división entera sin truncar.             | **Real siempre (`/`), y división entera explícita (`div`).** Previene pérdida de decimales inadvertida.                                                                                         |
| Asignación de real a entero      | abrirllave y NASPI truncan en silencio; PSeInt rechaza la asignación.                                             | **Se rechaza con error tipado.** Exige funciones explícitas de truncamiento o redondeo (`Trunc`, `Redon`).                                                                                      |
| Orden entre lógicos              | abrirllave admite orden entre booleanos; Cambridge y NASPI lo rechazan.                                           | **Sin relación de orden entre booleanos.** Comparar lógicos con `<` o `>` carece de fundamento algorítmico y denota confusión conceptual.                                                       |
| Concatenación de número y texto  | Lenguajes permisivos convierten implícitamente; Python lo rechaza.                                                | **Error semántico tipado.** La suma de número y texto no concatena; la salida estructurada admite listas de expresiones.                                                                        |
| Variables no inicializadas       | Indefinido en el material consultado.                                                                             | **Sin valores por omisión.** Acceder a variables no inicializadas genera diagnóstico de error pedagógico.                                                                                       |

### Negativos comprobados y advertencias registradas

- **Inexistencia de normas ISO/IEEE/ANSI de sintaxis de pseudocódigo:** No existe normativa formal que defina palabras
  clave o gramática para pseudocódigo. ANSI normalizó únicamente simbología gráfica de diagramas de flujo (ANSI X3.5 /
  ISO 5807), e IEEE 1016 normaliza descripciones de diseño de software sin fijar lenguajes formales.
- **Desactualización de la referencia web de PSeInt:** La documentación de referencia de sintaxis de su sitio oficial
  carece de especificaciones de tipado, subprogramas, tablas de precedencia y orientación a objetos. Se utiliza como
  referencia histórica del vocabulario, no como especificación normativa.
- **Ausencia de orientación a objetos en estándares de bachillerato internacional (IB/AQA):** Aunque IB y AQA poseen
  pseudocódigo normalizado para estructuras imperativas, no lo extienden a objetos (evalúan orientación a objetos
  directamente en Java). PseudoLearn establece su modelo de objetos didáctico propio convergente con Cambridge y OCR.
- **Omisión de tipos de resultado en operadores en fuentes analizadas:** NASPOO, Alpha y UPSAM 2.0 listan operadores
  admisibles pero omiten definir el tipo formal resultante de expresiones combinadas (ej. enteros en división real),
  requiriendo especificación formal propia en `docs/language-spec.md`.

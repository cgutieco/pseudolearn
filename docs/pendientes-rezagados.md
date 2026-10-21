# Pendientes rezagados y hoja de ruta futura de PseudoLearn

Este documento recopila todos los pendientes técnicos, deudas técnicas aceptadas, criterios de aceptación aún no
certificados y las fases de evolución futura del lenguaje tras la culminación de la reescritura del núcleo en Rust. Es
un documento transitorio y autosustentable; ninguna tarea ni archivo externo debe citarlo como dependencia.

---

## 1. Pendientes y deuda técnica de las fases del núcleo Rust (R0–R9)

### 1.1 Backend nativo Cranelift (fase R6)

Fase R6 cerrada: el nivel Cranelift cumple `PERF.AOT.LEVEL#R1` a `#R3` en la campaña formal pareada (arreglos 1,639×,
numérica 1,467×, objetos 1,488×, recursiva 1,316× frente a V1F; emisión máxima 9,749 ms), el aislamiento del backend nativo
en iOS, macOS, Windows y Wasm se verifica con `rust-checks isolation`, y el manifiesto `aot` no deja reglas pendientes de R6.
Lo que sigue abierto:

- **Nivel optimizado (`PERF.AOT.LEVEL#R4`):** alcanzar una razón geométrica por familia ≤ 1,30× frente a V1F-S (variante
  que incorpora rastreo de indefinidos y recolección forzada con límite de celdas vivas). Cranelift no se compromete a
  alcanzarlo; requiere evaluar alternativas según costes residuales medidos. Vínculo `pendiente` en `conformance-aot.yaml`
  con `resuelve_en: nivel-optimizado-posterior`.
- **Causa de la anomalía histórica de `Permute`:** la diferencia entre políticas de raíces (`AllLive` 1,61× frente a `Borrowed`
  2,18×) dejó de observarse tras eliminar comprobaciones dominadas (1,302× y 1,314×), pero la causa microarquitectónica
  nunca se demostró con contadores de hardware de fallos de caché de instrucciones, ramas y alineación.
- **Reserva sobre el margen certificado:** la familia de arreglos cumple con 1,639× frente a un límite de 1,70×; el margen
  (0,061) es del orden del ruido entre campañas (la misma configuración midió 1,681× y 1,722× antes del cambio), de modo
  que una repetición podría quedar cerca del límite. Por carga, Queens (1,784×), NBody (1,846×), Richards (1,854×) y Storage
  (3,097×) superan 1,70×; el contrato mide la media geométrica por familia y no cada carga.
- **Evidencia no conservada:** los datos crudos de la campaña formal viven en un directorio temporal local y no están en el
  repositorio. Las cifras quedan transcritas en el README de `pseudolearn_codegen` y la campaña se reproduce con
  `cargo run --release -p pseudolearn_bench_worker -- paired <directorio-nuevo>`.

Correcciones a este punto respecto de su redacción anterior: el manifiesto `aot` es `conformance-aot.yaml` (no existe
`matriz-aot.json`); `ENG.INPUT`, `IR.OBSERVATION-POINTS` y `RT.HOST.INTERFACE` ya figuraban como `cumple` o `exento` con
justificación y solo `ENG.LIMITS#R8` estaba pendiente (ahora `exento`, por ser de revisión humana); y el aislamiento móvil
cubre los destinos reales de la app (iOS, macOS y Windows) más Wasm, porque la app no tiene destino Android.

### 1.2 Servicio de lenguaje y herramientas (fase R7)

- **Extensión mínima para Visual Studio Code:**
    - La fase R7 dejó la extensión de VS Code como opcional al estar plenamente operativo el servidor LSP (`pseudo lsp`)
      en `apps/pseudolearn_cli`.
    - Queda pendiente empaquetar y publicar una extensión liviana de VS Code que active el ejecutable `pseudo lsp`
      mediante stdio para archivos `.pseudo` y `.psc`.
- **Reutilización semántica por unidad en el servicio incremental:**
    - Actualmente, la sesión incremental (`LspServerSession`) detecta huellas de cambio por unidad y reanaliza el
      documento completo con latencias p95 muy por debajo del umbral de 16 ms (1,0 ms en 1.000 líneas; 9,2 ms en 10.000
      líneas).
    - La reutilización de resultados semánticos parciales entre ediciones sin reanálisis total quedó pendiente y sólo se
      retomará si un proyecto excede de forma demostrable dicho presupuesto de latencia.

### 1.3 Puentes con la aplicación y la web (fase R8)

- **Campaña de rendimiento físico E-NR2:**
    - El ejecutor reproducible de E-NR2 está implementado en `packages/pseudolearn_benchmarks`
      (`tool/create_bridge_campaign.dart`, `tool/collect_bridge.dart` y `tool/summarize_bridge.dart`).
    - Permanece pendiente ejecutar la campaña formal completa (10 procesos × 30 iteraciones) en hardware físico
      certificado (macOS arm64 e iOS real en modo Release).
- **Validación de latencia de paso (`PERF.VM.STEP-LATENCY`):**
    - Medir la latencia física por micro-paso observado a través del puente FFI en un dispositivo móvil modesto para
      certificar el cumplimiento del límite contractual (p95 ≤ 1 ms).
- **Ejecución no acotada de `Fib(20)` en la interfaz:**
    - El smoke test actual de la app reduce temporalmente `Fib(20)` a `Fib(4)` para pruebas rápidas de integración.
      Queda pendiente verificar la ejecución completa y fluida del cálculo de `Fib(20)` en la UI de Flutter con la barra
      de progreso y ritmos activos.
- **Empaquetado y distribución multiplataforma sin dependencias de desarrollo:**
    - Automatizar el empaquetado final de instaladores para macOS, iOS, Windows x64 (DLL, instalador portable y MSIX) y
      Wasm, comprobando que funcionen en máquinas de usuario sin requerir el toolchain de Rust ni un checkout de
      desarrollo.
- **Integración de diagramas y resaltado enriquecido en la app:**
    - Conectar el resaltado sintáctico fino y la identificación de nodos de foco (`unitId`) para los diagramas
      pedagógicos consumiendo directamente la vista pública `API.PROGRAM.VIEW` y el servicio Rust.

### 1.4 Paridad, conformidad y retiro final (fase R9)

- **Conformidad final y suite de `apps/pseudolearn_app`:**
    - Resolver la limitación operativa de ejecución de pruebas en entornos con sockets restringidos para correr la suite
      completa de 2.152 tests de la app y la conformidad automática de SEE (`see conform --subject app`).
- **Promoción de contratos experimentales a estables:**
    - Promover formalmente en el corpus de especificaciones los contratos restantes de `app`, los contratos de
      rendimiento (`PERF.*`) y los contratos de `aot` que aún permanecen en estado `experimental`, una vez dispongan de
      la evidencia final requerida.
- **Verificación en checkout limpio y publicación:**
    - Ejecutar una verificación integral en un clon limpio e independiente del repositorio y publicar los resultados
      actualizados en la rama principal.

---

## 2. Hoja de ruta para la evolución del lenguaje (post-R9)

Una vez completada la paridad con el núcleo original, la evolución de PseudoLearn hacia un lenguaje de propósito general
se estructura en las siguientes fases normativas. Toda nueva característica debe seguir el flujo: **especificación →
casos de prueba → tests → código**.

### 2.1 Fase F4 · Edición A: Fundamentos de propósito general (compatibles)

Fase centrada en ampliar el lenguaje manteniendo total compatibilidad hacia atrás con los programas existentes.

- **Mecanismo de ediciones:** Implementar el campo de edición en el manifiesto de proyecto (`LANG.EDITION.MODEL`),
  permitiendo fijar la edición por módulo o paquete.
- **Módulos e importación:** Sintaxis y semántica para importar archivos y bibliotecas con visibilidad controlada
  (pública / privada a nivel de módulo).
- **Constantes y enumerados:** Declaración de valores inmutables en tiempo de compilación y tipos enumerados finitos con
  comprobación estática.
- **Tipos de datos ampliados:**
    - Tipo `Opcional<T>` para representar ausencia sin referencias nulas descontroladas.
    - Tipo `Resultado<T, E>` para tratamiento determinista y explícito de errores (resolución de decisión D-15).
    - Tipos registro por valor (`Registro`), almacenados de forma contigua en memoria sin sobrecoste de asignación en
      montón (decisión D-04).
- **Estructuras de control avanzadas:** Bloque `Segun` exhaustivo con coincidencia de patrones básica sobre literales,
  enumerados y variantes.
- **Interfaces y polimorfismo:** Definición de interfaces/rasgos para tipado polimórfico sin herencia múltiple de
  implementación (decisión D-16).
- **Normalización Unicode:** Soporte normativo de Unicode NFC en fuentes y admisión del carácter `ñ` en identificadores
  bajo el perfil estricto (decisión D-14).
- **Biblioteca estándar básica:** E/S de archivos, utilidades avanzadas de texto y operaciones matemáticas ampliadas con
  redondeo riguroso (decisión D-03).

### 2.2 Fase F7 · Edición B: Cambios incompatibles y abstracción

Fase que introduce cambios sintácticos o semánticos que pueden romper compatibilidad con el pseudocódigo tradicional,
aislados bajo la nueva edición.

- **Ámbitos de bloque léxicos:** Las variables declaradas dentro de un bloque condicional o de bucle dejan de ser
  visibles fuera de dicho bloque (decisión D-12).
- **Funciones como valores y clausuras (*closures*):** Subprogramas anónimos que capturan variables de su entorno
  léxico, representadas con paso de contexto seguro.
- **Tipado genérico:** Funciones y estructuras de datos parametrizadas por tipos (`Vector<T>`, `Diccionario<K, V>`).
- **Colecciones en biblioteca estándar:** Implementación nativa en Rust de estructuras de datos genéricas dinámicas de
  alto rendimiento.
- **Iteración moderna:** Bucle `Para Cada` sobre secuencias e iteradores.
- **Salida anticipada:** Sentencias `Retornar [valor]` y `Salir` con garantía de ejecución de limpieza y consistencia en
  la traza observable.
- **Herramienta de migración automática:** Suborden `pseudo migrar` que reescribe código de la Edición A a la Edición B
  preservando semántica y comentarios.

### 2.3 Fase F8 · Paquetes, espacios de trabajo y ecosistema

- **Manifiesto de paquete:** Esquema y analizador para archivos de configuración del proyecto (ej. `pseudolearn.toml`,
  decisión D-19).
- **Espacios de trabajo (*workspaces*):** Soporte para monorepos con múltiples paquetes interdependientes y resolución
  coordinada.
- **Archivo de bloqueo (*lockfile*):** Registro determinista de versiones y hashes criptográficos de dependencias.
- **Resolutor determinista:** Algoritmo de resolución de versiones mínimas con soporte para aliases de dependencias.
- **Eliminación de código muerto (*tree shaking* con garantías):** Optimización en compilación AOT que descarta
  funciones y tipos inalcanzables garantizando idéntico comportamiento observable (decisión D-08 / TS-3).
- **Registro de paquetes:** Infraestructura básica y cliente para publicación y descarga de dependencias externas
  (decisión D-01).

### 2.4 Fase F9 · Gobernanza y comunidad

- **Licencia formal:** Selección e implantación de la licencia definitiva del proyecto (decisión D-01).
- **Gobernanza y RFCs:** Proceso público de propuestas de cambio (RFC) para el lenguaje, permitiendo contribuciones
  guiadas por especificaciones ejecutables.
- **Guía de contribución bilingüe:** Documentación de normas de diseño, arquitectura y calidad para contribuidores
  externos.

### 2.5 Fase F10 · Horizonte a largo plazo

- **Concurrencia estructurada:** Modelo pedagógico y seguro de tareas asíncronas sin condiciones de carrera observables.
- **Interoperabilidad con C (*C FFI*):** Interfaz para llamar bibliotecas nativas de C y exponer funciones de
  PseudoLearn con ABI C.
- **Autoalojamiento (*self-hosting*):** Reescritura del compilador y front-end de PseudoLearn en el propio lenguaje
  PseudoLearn.
- **Compilador JIT de escritorio:** Evaluación de un backend JIT si experimentos demuestran ventajas sobre AOT en ciclos
  de desarrollo interactivo.
- **Semántica formal en DSL ejecutable:** Modelado de la semántica central en un lenguaje formal verificable de manera
  independiente.

---

## 3. Decisiones de diseño y arquitectura pendientes de resolución formal

| Identificador | Asunto                                | Descripción y opciones a decidir                                                                                                                                             |
|---------------|---------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **D-01**      | Licencia del ecosistema               | Determinar la licencia abierta final (e.g., MIT/Apache-2.0 o dual) para publicación de crates en crates.io y modelos de gobernanza comunitaria.                              |
| **D-08**      | Eliminación de código no utilizado    | Definir si la eliminación (*tree shaking*) opera puramente a nivel de enlazador o exige análisis de alcanzabilidad con garantías formales de equivalencia semántica (TS-3).  |
| **D-12**      | Ámbito de variables en bloques        | Fijar la transición de visibilidad a nivel de subprograma (herencia pedagógica actual) hacia visibilidad léxica estricta por bloque en la Edición B.                         |
| **D-14**      | Unicode e identificadores             | Definir la política definitiva de normalización NFC y admisión de grafías como `ñ`, acentos y signos de puntuación en nombres de identificadores según el perfil de rigidez. |
| **D-15**      | Modelo de gestión de errores          | Formalizar si el lenguaje de propósito general adopta tipos suma `Resultado<T, E>` o excepciones tradicionales, priorizando la predictibilidad pedagógica.                   |
| **D-16**      | Contrato de abstracción e interfaces  | Definir si el polimorfismo se basa en contratos nominales explícitos (interfaces) o en coincidencia estructural (rasgos/traits).                                             |
| **D-19**      | Formato del manifiesto de proyecto    | Seleccionar entre formato TOML o YAML para `pseudolearn.toml` y estandarizar sus secciones (`[paquete]`, `[dependencias]`, `[edicion]`).                                     |
| **D-24**      | Revisión de restricciones pedagógicas | Evaluar qué restricciones didácticas actuales (prohibición de ciertas coerciones implícitas, límites de anidación) se relajan o configuran para uso profesional.             |

---

## 4. Mejoras de herramientas e infraestructura secundaria

- **Soporte DAP (Debug Adapter Protocol):**
    - Implementar un adaptador DAP en `apps/pseudolearn_cli` (`pseudo dap`) que traduzca peticiones de depuración
      estándar (pausa, puntos de interrupción, inspección de pila y variables) a comandos sobre `pseudolearn_timeline` y
      `pseudolearn_vm`.
- **Integración con JetBrains / IntelliJ:**
    - Configurar y validar la integración del servidor LSP con plugins de editores de la familia IntelliJ Platform.
- **Infraestructura de CI/CD para compilación remota y firma de código:**
    - Automatizar flujos de integración continua en GitHub Actions con runners dedicados de macOS e infraestructura de
      firma de binarios para instaladores de Windows y macOS.

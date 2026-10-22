# Hoja de ruta futura de PseudoLearn

Este documento registra la fase 2 de evolución de PseudoLearn después de completar la reescritura del núcleo en Rust. Es transitorio y autosustentable; ninguna tarea ni archivo externo debe citarlo como dependencia.

## Fase 2 · Hoja de ruta para la evolución del lenguaje (post-R9)

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

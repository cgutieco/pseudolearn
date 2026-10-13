# 07 · Herramientas de desarrollo y autocompletado

> **Estado:** investigación, no normativo. Las arquitecturas y comportamientos descritos son
> **propuestas**. El autocompletado vigente es el de `apps/pseudolearn_app/lib/engine/completion/`.

Responde a V-30 a V-34.

---

## 1. Punto de partida

**[COMPROBADO]** (detalle en el [diagnóstico](02-diagnostico-del-sistema-actual.md) §4.4 y H-17 a H-21):

- El autocompletado es una lista fija de diez plantillas por perfil, sin contexto, con marcadores en
  español también en inglés; la plantilla de selección múltiple es inválida y nadie lo detecta.
- El lexer descarta comentarios; no hay árbol sin pérdida.
- `NodeId` cambia en cada análisis; no hay identidad estable entre ediciones.
- Cada pulsación reanaliza todo (≈12,7 ms a 1 000 líneas, ≈50 ms a 5 000).
- No hay gramática formal ni servidor de lenguaje; ningún editor externo entiende PseudoLearn.

A favor: el parser devuelve árbol ante código incompleto, los diagnósticos son estructurados y
bilingües, y el léxico de cada perfil es un dato consultable. Son exactamente los cimientos que un
servicio de lenguaje necesita.

---

## 2. Quién es responsable de qué

| Capa                          | Responsabilidad                                                                                                                                         | Ejemplos concretos                                                                                         |
|-------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------|
| **Lenguaje**                  | Una gramática que haga **predecible** la siguiente palabra: aperturas y cierres únicos (EST-01), palabras intermedias obligatorias (EST-02), sin significado por indentación, vocabulario como dato por perfil | Tras `Si … Entonces` solo caben sentencias, `SiNo` o `FinSi`; eso es deducible de la gramática, no una heurística |
| **Servicio de lenguaje** (motor de análisis) | Árbol sin pérdida, análisis resiliente e incremental, modelo semántico consultable por posición, motor de autocompletado, formateo, renombrado, acciones de corrección | «¿Qué nombres son visibles aquí y de qué tipo?»; «¿qué bloques están abiertos en esta posición?»             |
| **Protocolos**                | Transportar capacidades entre el servicio y cualquier editor sin acoplarlos                                                                               | LSP para edición; DAP para depuración y ejecución paso a paso                                              |
| **Editores e integraciones**  | Presentación, atajos, configuración, empaquetado del servidor                                                                                            | Extensión de VS Code, plugin de IntelliJ, gramática de tree-sitter para resaltado                          |
| **App de PseudoLearn**        | Experiencia pedagógica propia (barra de teclas, vistas sincronizadas, niveles) sobre el **mismo** servicio de lenguaje                                   | La app consume el servicio en proceso, sin protocolo intermedio                                            |

**Principio:** ninguna capa reimplementa lo de la de abajo. La app no tiene lógica de lenguaje
(regla vigente, `README.md` de la app §1.1) y tampoco la tendrá una extensión de editor.

---

## 3. El servicio de lenguaje

### 3.1 Árbol sin pérdida y análisis resiliente

| Técnica                                       | Referencia                                                       | Para qué                                                                                      |
|-----------------------------------------------|------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
| Árbol concreto sin pérdida con trivia         | Árboles rojo-verde de Roslyn; rowan (rust-analyzer)              | Conservar comentarios y espacios: formateo, traducción entre perfiles y migración sin perder nada (H-19) |
| Análisis resiliente que «nunca falla»         | rust-analyzer (el parser devuelve árbol y errores); tutorial de *resilient LL parsing* de A. Kladov | Código a medio escribir: nodos de error y tokens faltantes, árbol siempre utilizable         |
| Análisis incremental por consultas            | salsa (rust-analyzer)                                            | Recalcular solo lo afectado por una edición                                                  |
| Reanálisis incremental del texto              | Wagner y Graham (TOPLAS 1998); tree-sitter                        | Reutilizar subárboles intactos                                                                |
| Identidad estable de nodos                    | Punteros sintácticos (tipo, rango, ruta) de rust-analyzer        | Sustituir el `NodeId` secuencial donde hace falta identidad entre ediciones (H-20)            |

**Relación con la especificación vigente.** Las siete reglas de recuperación de §1.3 de
`language-spec.md` (un diagnóstico por sentencia, bloque sin cerrar con un único diagnóstico, tope de
cien, árbol siempre) son **compatibles** con un análisis resiliente y se convierten en casos
ejecutables ([11](11-especificaciones-ejecutables-diseno.md)); hoy dos de ellas se incumplen (H-05,
H-06).

### 3.2 Modelo semántico consultable

Consultas que el autocompletado y las demás herramientas necesitan, todas por posición en el texto:

- Bloques abiertos y su pila (para cierres).
- Construcciones admisibles según la gramática (para palabras clave).
- Nombres visibles con su tipo y su clase (variable, subprograma, clase, módulo, función incorporada).
- Tipo esperado en la posición (para ordenar candidatos).
- Miembros visibles de un tipo (para `.`), respetando visibilidad y tipo **estático** (§11.7 de la
  especificación).
- Firma activa en una llamada (ayuda de firma).

### 3.3 Capacidades por encima del autocompletado

| Capacidad                                     | Valor pedagógico o productivo                                                                      |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------|
| Acciones de corrección asociadas a diagnósticos | «Falta `Entonces`» → insertarlo; «falta `Este.`» → añadirlo. Cada código de diagnóstico puede declarar su corrección |
| Pistas en línea (*inlay hints*)               | Mostrar el tipo inferido en el perfil flexible (hoy es un diagnóstico informativo, §12.5)          |
| Formateo canónico                             | Una sola forma impresa por perfil; base de la traducción entre perfiles                            |
| Traducción entre perfiles                     | Imprimir el árbol sin pérdida con el otro léxico                                                   |
| Renombrado y búsqueda de referencias          | Esenciales en propósito general                                                                    |
| Explicación de diagnósticos                   | Ficha por código, en ambos idiomas, desde la especificación ([03](03-identidad-bilingue-y-gramatica.md) §7.3) |

---

## 4. Autocompletado determinista y bilingüe

### 4.1 Fuentes de candidatos

| Fuente                                | Cómo se obtiene                                                                                      | Ejemplo (perfil español)                                           |
|---------------------------------------|------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
| Palabras clave admisibles             | Conjunto de tokens que la gramática admite en la posición × léxico del perfil                        | Al inicio de sentencia: `Si`, `Mientras`, `Para`, `Escribir`…      |
| **Cierres**                           | Pila de bloques abiertos en la posición                                                              | Dentro de `Mientras … Hacer` sin cerrar: `FinMientras` primero     |
| Palabras intermedias                  | Producción en curso                                                                                  | Tras `Si edad >= 18`: `Entonces`                                    |
| Plantillas de construcción            | **Generadas** desde la gramática formal y **validadas** analizándolas (corrige H-18)                  | `Segun <selector> Hacer` … `FinSegun`                              |
| Nombres en ámbito                     | Modelo semántico                                                                                     | Variables y subprogramas visibles, con tipo                        |
| Miembros                              | Tipo estático del receptor                                                                           | Tras `mascota.`: `Nombre()`, `Hablar()`                             |
| Tipos                                 | Tras `Como`                                                                                          | `Entero`, `Real`, clases declaradas                                |
| Funciones incorporadas y biblioteca   | Catálogo con firmas bilingües                                                                        | `Longitud(texto Como Cadena) Como Entero`                          |
| Rutas de importación                  | Resolutor de módulos y aliases ([08](08-modulos-paquetes-y-monorepos.md))                            | `Importar @comun/…`                                                |

### 4.2 Detección de cierres

La gramática de PseudoLearn hace la detección de cierres **determinista**: cada apertura tiene un
único cierre (EST-01). El servicio mantiene la pila de bloques abiertos en cada posición y:

1. Ofrece el cierre del bloque más interno como primer candidato.
2. Al pulsar «Intro» tras una apertura completa, puede insertar el cierre (configurable; la app ya
   calcula sangrías desde el léxico).
3. Ante un cierre que no corresponde, el diagnóstico vigente (con tramo relacionado en la apertura) se
   acompaña de una acción de corrección.
4. Usa la **indentación como pista** (no como significado) para adivinar a qué bloque pertenece una
   línea cuando faltan cierres, solo para ordenar sugerencias, nunca para analizar.

### 4.3 Particularidades del bilingüismo

- **Candidatos en el perfil del archivo.** Nunca se mezclan idiomas en una lista.
- **Coincidencia insensible a tildes y mayúsculas** para el léxico reservado, coherente con la
  política del perfil: escribir `segun` encuentra `Segun`.
- **Autocompletado translingüe (propuesta original).** Como el pivote es el tipo de token, si en un
  archivo en español se escribe `while`, el servicio puede ofrecer `Mientras` con la explicación
  «`while` en inglés». Es barato (consulta inversa en el otro perfil) y ayuda a quien llega de otro
  lenguaje o alterna idiomas. Se mide su utilidad con [E-14](16-experimentos-y-benchmarks.md#e-14).
- **Marcadores de plantilla localizados**, desde el catálogo de términos de `diagnostics/`, nunca
  literales en el código (corrige el defecto de los marcadores en español del perfil inglés).

### 4.4 Ordenación determinista

La misma entrada produce la misma lista, siempre: criterios explícitos y explicables (cierre del bloque
abierto primero; compatibilidad con el tipo esperado; cercanía de ámbito; orden alfabético como último
desempate). Nada de modelos estadísticos en este canal (§6).

### 4.5 Cómo saber si el autocompletado es bueno

| Métrica                                    | Definición                                                                                         | Objetivo propuesto          |
|--------------------------------------------|----------------------------------------------------------------------------------------------------|-----------------------------|
| Validez de plantillas                      | Fracción de plantillas que analizan sin errores en su contexto                                     | 100 % por construcción      |
| Precisión @1 / @5                          | En un corpus de programas truncados en cada token, ¿está el token real entre los primeros k?        | A fijar con E-09            |
| Ahorro de pulsaciones                      | Pulsaciones necesarias con autocompletado frente a escribir todo                                    | Mide HIP-02                 |
| Latencia p95                               | Desde la pulsación hasta la lista                                                                   | ≤ 50 ms                     |

El corpus sale gratis de la base de conocimiento (ejemplos y soluciones de ejercicios en los dos
perfiles). Ver [E-09](16-experimentos-y-benchmarks.md#e-09).

---

## 5. Integración con entornos

### 5.1 Arquitectura propuesta

```
                  ┌──────────────────────────────────────────────┐
                  │ Servicio de lenguaje (biblioteca Dart)        │
                  │ árbol sin pérdida · semántica · autocompletado │
                  │ formateo · diagnósticos · acciones             │
                  └───────┬───────────────┬──────────────┬────────┘
                          │ en proceso    │ LSP (stdio)  │ DAP
                 ┌────────▼──────┐  ┌─────▼────────┐  ┌──▼────────────────┐
                 │ App Flutter   │  │ `pseudo lsp`  │  │ `pseudo dap`      │
                 │ (y web, Wasm) │  │ binario AOT   │  │ VM observable     │
                 └───────────────┘  └─────┬────────┘  └──┬────────────────┘
                                          │              │
                ┌──────────────┬──────────┴───┬──────────┴──────┐
                │ VS Code      │ IntelliJ     │ Neovim, Helix,  │
                │ (cliente LSP)│ (API LSP)    │ Zed, Emacs      │
                └──────────────┴──────────────┴─────────────────┘
       Resaltado sin servidor: gramáticas de tree-sitter generadas por perfil
```

**[HECHO EXTERNO]** LSP 3.17 es estable y 3.18 figura como versión actual en el sitio oficial,
marcada aún «en desarrollo». Las capacidades se negocian por banderas, de modo que un servidor puede
empezar por diagnósticos y autocompletado. La API LSP de la plataforma IntelliJ estuvo reservada a
productos de pago hasta 2025; desde la distribución unificada (2025.3) está disponible para todas las
personas usuarias (anuncio de JetBrains, septiembre de 2025). Una entrada posterior del blog de la
plataforma (junio de 2026) se titula «Open-Sourcing the LSP Client API in IntelliJ IDEA 2026.2»; solo
se verificó el título, no el alcance. Para versiones anteriores existe el plugin LSP4IJ.

### 5.2 Qué se estandariza y qué es específico

| Capacidad                                         | Estandarizable (LSP/DAP)                         | Específica                                                     |
|---------------------------------------------------|--------------------------------------------------|----------------------------------------------------------------|
| Diagnósticos, autocompletado, ayuda de firma, ir a definición, renombrado, formateo, acciones, pistas en línea, tokens semánticos | Sí (LSP) | —                                                              |
| Ejecución paso a paso con los ritmos de la app    | Parcial: DAP tiene *step in/over/out*, que se corresponden con «entrar», «saltar bloque» y «salir de bloque» definidos sobre eventos observables | La tabla de prueba de escritorio y los diagramas sincronizados |
| Inspección de variables y objetos                 | Sí (DAP: *scopes*, *variables*)                  | Grafo de objetos dibujado                                      |
| Resaltado sin servidor                            | Gramática de tree-sitter / TextMate              | Una por perfil (generadas)                                     |
| Barra de teclas contextual, niveles, ejercicios   | No                                               | App                                                            |
| Vista de traza y diagramas en VS Code             | No                                               | Extensión con panel web alimentado por eventos DAP propios     |

### 5.3 Resaltado bilingüe

Las gramáticas de tree-sitter son estáticas: una gramática que acepte los dos léxicos reservaría las
palabras de ambos idiomas a la vez. **Propuesta:** generar dos gramáticas (`pseudolearn-es`,
`pseudolearn-en`) desde la gramática formal y los perfiles (`GEN-NO-HAND-COPY`), elegidas por el perfil
del archivo (manifiesto o cabecera). Se verifica comparando sus árboles con el parser de referencia
([E-18](16-experimentos-y-benchmarks.md#e-18)).

---

## 6. Determinista frente a IA

**Separación propuesta, por contrato:**

| Aspecto                     | Autocompletado del lenguaje                                    | Sugerencias de IA                                                         |
|-----------------------------|----------------------------------------------------------------|---------------------------------------------------------------------------|
| Origen                      | Gramática, perfiles, modelo semántico                          | Modelo estadístico externo                                                |
| Reproducibilidad            | Misma entrada, misma lista                                     | No garantizada                                                            |
| Corrección                  | Toda sugerencia es válida en su posición (comprobable)         | Puede ser inválida                                                        |
| Especificación              | Comportamiento especificado y probado                          | Fuera del lenguaje                                                        |
| Canal LSP                   | `textDocument/completion`                                      | Canales propios de cada herramienta (p. ej., `inlineCompletion` en 3.18)  |
| En la app                   | Sí                                                             | Fuera de alcance vigente (`README.md` de la app §1.3)                     |

Las dos cosas pueden convivir en un editor, pero el servicio de lenguaje no mezcla resultados de IA en
su lista ni depende de ellos. Lo que sí puede ofrecer a herramientas de IA, sin comprometer nada, es
información estructurada (especificaciones, diagnósticos con explicación, firmas bilingües).

---

## 7. Herramientas de línea de órdenes

Propuesta de una sola orden con subórdenes, con nombres canónicos en un idioma y alias en el otro
(idioma canónico por decidir, [D-21](17-riesgos-preguntas-y-decisiones.md#d-21)):

| Subórden                  | Función                                                                 |
|---------------------------|-------------------------------------------------------------------------|
| `pseudo nuevo`            | Crear paquete o espacio de trabajo                                      |
| `pseudo analizar`         | Diagnósticos (también en formato máquina)                              |
| `pseudo ejecutar`         | Ejecutar en la VM o, si existe, compilar y ejecutar                    |
| `pseudo compilar`         | Producir un ejecutable nativo                                           |
| `pseudo probar`           | Ejecutar bloques `Prueba` y casos de especificación                    |
| `pseudo formatear`        | Formateo canónico                                                       |
| `pseudo traducir`         | Cambiar el perfil de un archivo sin pérdida                             |
| `pseudo migrar`           | Migración entre ediciones                                               |
| `pseudo lsp` / `pseudo dap` | Servidores para editores                                              |
| `pseudo explicar <código>` | Ficha de un diagnóstico                                                |

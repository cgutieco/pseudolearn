# 03 · Identidad bilingüe, vocabulario y evolución de la gramática

> **Estado:** investigación, no normativo. Las formas sintácticas de §8 son **propuestas
> ilustrativas** para evaluar el estilo; ninguna está aprobada ni especificada. La gramática vigente
> es la de `packages/pseudolearn_core/docs/language-spec.md`.

Responde a V-08 a V-13 ([trazabilidad](01-vision-y-trazabilidad.md#4-matriz-de-trazabilidad)).

---

## 1. No hay un pseudocódigo estándar: qué es convención y qué es decisión propia

**[HECHO EXTERNO]** No existe norma ISO, IEEE ni ANSI que defina palabras clave o gramática de
pseudocódigo. ANSI X3.5 / ISO 5807 normalizan símbolos de diagramas de flujo, no texto. Lo que existe
son notaciones de organismos de examen (Cambridge International 9618, OCR H446, IB, AQA), de libros
(Joyanes / UPSAM 2.0, NASPI y NASPOO, abrirllave) y de herramientas (PSeInt). El `README.md` del núcleo
(§8) ya registra qué tomó y qué rechazó PseudoLearn de cada una; este documento no lo repite.

**Consecuencia para la evolución.** A partir de la sección 11 de `language-spec.md` (objetos), las
fuentes externas dejan de cubrir el terreno: no hay convención de pseudocódigo para módulos,
genéricos, closures, errores tipados, concurrencia ni paquetes. Todo lo que venga después es
**decisión normativa propia** de PseudoLearn. Conviene declararlo así en cada especificación nueva,
porque el criterio de desempate vigente («la forma que prepara mejor para el lenguaje real») deja de
tener referente si PseudoLearn es el destino ([C-01](17-riesgos-preguntas-y-decisiones.md#c-01)).

| Clase de afirmación         | Ejemplo                                                     | Autoridad                                   |
|-----------------------------|-------------------------------------------------------------|---------------------------------------------|
| Convención externa adoptada | Bucle `Repetir … Hasta Que` con condición de salida         | Convergencia de fuentes, registrada en §8 del `README.md` del núcleo |
| Convención externa rechazada | Base uno en arreglos, globales visibles en subprogramas    | Decisión registrada con su motivo           |
| Decisión propia sin fuente   | `Este` obligatorio, sin valor nulo, división siempre real  | `language-spec.md`                          |
| Decisión propia futura       | Todo lo de §8 de este documento                             | Requiere especificación y aprobación        |

---

## 2. Bilingüismo: precedentes y evidencia

### 2.1 Qué dice la evidencia

| Fuente                                                              | Hecho                                                                                                                        | Límite de aplicabilidad                                                       |
|---------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------|
| ALGOL 68, *Revised Report* (1975–76)                                | Separa lenguaje estricto, lenguaje extendido y **lenguaje de representación**; el Boletín ALGOL anunció traducciones del informe al ruso y al alemán, y el diseño admite representaciones con palabras clave en otros idiomas; hubo además una representación de hardware estándar | Histórico; no hay datos de adopción por idioma                                |
| 1C:Enterprise (documentación de la plataforma 8.3)                  | Todos los operadores tienen forma rusa e inglesa, **mezclables en un mismo texto**; existe una herramienta de traducción de código y metadatos (1C:Language Tool, 2019) | Plataforma propietaria de dominio empresarial; comunidad grande en la CEI     |
| AppleScript (Cook, HOPL III, 2007; guías de Apple 1996–1999)        | Tuvo dialectos francés y japonés; se abandonaron (Mac OS 8.5). El motivo reportado: los diccionarios de las aplicaciones casi nunca se tradujeron y los scripts quedaban en una mezcla confusa de idiomas | Lenguaje de scripting sobre APIs de terceros                                   |
| Hedy (Hermans; ICPEC 2024; *J. Computer Languages* 2022)            | Palabras clave en decenas de idiomas desde 2022; el estudio de usuarios señala la localización de palabras clave como mejora deseada | Lenguaje gradual para niños; no de propósito general                          |
| Dasgupta y Hill, L@S 2017                                           | En Scratch, quienes usaban el entorno localizado aprendieron conceptos nuevos más rápido que quienes usaban el inglés en los mismos países | Lenguaje de bloques; aprendizaje, no producción                               |
| Guo, CHI 2018 (840 respuestas, 86 países)                           | Barreras de quien no es nativo en inglés: leer material, comunicar, leer y escribir código, aprender inglés y programación a la vez | Encuesta; no compara lenguajes localizados                                    |
| Lenguaje Latino (desde 2015)                                        | Lenguaje con sintaxis en español orientado a aprender antes de pasar a otros                                                 | Monolingüe; sin datos públicos de adopción verificados                        |

### 2.2 Lecciones

1. **[INFERENCIA]** Las palabras clave son la parte fácil. Un lenguaje tiene decenas de palabras clave
   y decenas de miles de nombres de API. AppleScript fracasó en lo segundo, no en lo primero. 1C lo
   resolvió dando **nombre bilingüe a toda la API de la plataforma**. Para PseudoLearn el problema
   decisivo es la biblioteca estándar y la de terceros (§7.2).
2. **[INFERENCIA]** La mezcla de idiomas **dentro de un mismo texto** degrada la lectura. 1C la admite
   y su propia comunidad pide mecanismos para aislar configuraciones; AppleScript la sufrió. Esto
   apoya la regla vigente de un perfil por archivo.
3. **[HECHO, comprobado en el repositorio]** PseudoLearn ya tiene el mecanismo de ALGOL 68: un plano
   abstracto único y un plano de representación por perfil, con pivote no lingüístico. Es un activo
   diferencial que conviene conservar intacto.
4. **[INFERENCIA, evidencia parcial]** La evidencia favorece la localización para **aprender**. No hay
   evidencia sobre la productividad profesional en lenguajes de texto localizados. La hipótesis HIP-03
   queda abierta para el uso profesional y se propone medirla ([E-14](16-experimentos-y-benchmarks.md#e-14)).

---

## 3. El estilo vigente, convertido en reglas verificables

La visión pide que las construcciones futuras sigan el estilo existente (V-11). Para que «estilo» no
sea una opinión, se extraen de `language-spec.md` las regularidades que hoy se cumplen sin excepción y
se proponen como **reglas de estilo gramatical** que toda construcción nueva debería superar antes de
especificarse. Cada una puede comprobarse sobre la gramática formal (§5).

| ID       | Regla de estilo (propuesta)                                                                                             | De dónde sale (vigente)                                    | Cómo se comprobaría                                     |
|----------|------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------|---------------------------------------------------------|
| EST-01   | Todo bloque abre con una palabra y cierra con su palabra de cierre propia (`Si`/`FinSi`)                               | §8, §10, §11                                               | Cada producción de bloque tiene un token de cierre único |
| EST-02   | Las palabras intermedias que separan cabecera y cuerpo son obligatorias (`Entonces`, `Hacer`)                          | §8.1 («obligatoria siempre»)                                | Ningún opcional entre cabecera y cuerpo                 |
| EST-03   | Los modificadores van en sufijo (`Por Referencia`, `Sin Saltar`, `Con Paso`)                                           | §7.1, §8.5, §10.3                                           | Posición del modificador en la producción              |
| EST-04   | El tipo se escribe al final, introducido por el conector de tipo (`Como`)                                              | §6.3, §10.2                                                 | Una sola forma de anotar tipos                          |
| EST-05   | Una construcción por concepto; las variantes son cláusulas opcionales, no palabras clave nuevas                        | §8.4 (un solo bucle posterior), §10 (una sola construcción de subprograma) | Revisión: lista de conceptos ↔ producciones     |
| EST-06   | Las llamadas llevan paréntesis siempre                                                                                 | §10.2, §11.5                                                | Producción de llamada                                   |
| EST-07   | Sin significado por indentación; fin de línea termina sentencia; `;` opcional salvo rigor                             | §3, §6.2                                                     | Lexer                                                   |
| EST-08   | Ningún símbolo nuevo con significado no aritmético; los conceptos se escriben con palabras                             | Inventario de §2.4                                          | Inventario de tokens                                    |
| EST-09   | Toda palabra nueva existe en los dos perfiles, con forma canónica natural en cada idioma, y no compite con un nombre frecuente | §2.3, decisión 4.12 del `README.md` del núcleo      | Tabla de perfiles + corpus de nombres ([E-10](16-experimentos-y-benchmarks.md#e-10)) |
| EST-10   | La construcción tiene un caso mínimo inválido con diagnóstico propio y pedagógico                                      | Skill `language-spec-authoring`                             | Existencia del caso en la especificación                |

**[INFERENCIA]** EST-08 es la regla que más va a tensionarse: closures, genéricos y acceso opcional
tienden a símbolos (`=>`, `<T>`, `?.`). Las propuestas de §8 la respetan a costa de verbosidad, que es
lo que la visión acepta (V-09).

---

<a id="presupuesto-reservado"></a>

## 4. El presupuesto de palabras reservadas

### 4.1 El problema, medido

**[COMPROBADO]** En el perfil español, `y`, `o` y `no` no pueden ser identificadores (son `Y`, `O`,
`NO`, insensibles a mayúsculas); `Definir x, y Como Entero` es inválido. En inglés, `step`, `to`, `do`,
`as`, `new`, `this`, `function`, `default`, `print` y `char` tampoco (hallazgo H-22). Cada construcción
nueva añade palabras. Proyección **[INFERENCIA]** con las propuestas de §8, solo en español:
`Interfaz`, `Implementa`, `Constante`, `Enumeracion`, `Registro`, `Importar`, `Modulo`, `Cada`, `En`,
`Resultado`, `Opcional`, `Funcion` (hoy alias de subprograma), `Tarea`, `Esperar`. Varias (`en`,
`modulo`, `resultado`, `registro`, `tarea`) son nombres de variable frecuentes en español. El coste no
es lineal: lo que se retira es un nombre **en todas sus grafías**, porque el léxico reservado es
insensible a mayúsculas y tildes.

### 4.2 Alternativas

| Alternativa                                                   | Precedente                                                    | Ventaja                                                         | Coste                                                                                       |
|---------------------------------------------------------------|---------------------------------------------------------------|-----------------------------------------------------------------|---------------------------------------------------------------------------------------------|
| **A. Reservar todo** (vigente)                                | Pascal, Java                                                  | Lexer simple; resaltado trivial                                 | El vocabulario disponible se encoge con cada versión; las ediciones nuevas rompen programas |
| **B. Palabras clave contextuales** para lo nuevo              | C# (`var`, `async`, `yield`), Kotlin (palabras blandas y modificadoras), Python 3.10 (`match`, `case`), JavaScript (`let`, `async`) | Lo nuevo no retira nombres; compatibilidad hacia atrás         | Parser y resaltado dependen de la posición; diagnósticos más difíciles; requiere gramática formal para comprobar que no hay ambigüedad |
| **C. Escape de identificador**                                | Rust (`r#match`, RFC 2151), C# (`@class`), Kotlin (`` `fun` ``) | Interoperabilidad y migración entre ediciones                   | Un símbolo nuevo (contra EST-08); feo para quien aprende                                     |
| **D. Stropping** (marcar palabras clave tipográficamente)    | ALGOL 68 (negrita, `.PUNTO`, MAYÚSCULAS)                     | Separa espacios por completo                                    | Incompatible con la insensibilidad a mayúsculas vigente y con la escritura en teclado táctil |
| **E. Reservar solo frases multipalabra**                      | `Hasta Que`, `De Otro Modo` ya lo hacen                       | `hasta` sola queda libre si el token es la frase                 | No sirve para conceptos de una palabra; complica el reconocimiento por coincidencia más larga |

**Antecedente vigente.** El `README.md` del núcleo (§4.12) rechazó B para `Y`, `O` y `NO` porque «son
genuinamente ambiguos en posición de expresión». **[INFERENCIA]** El argumento es exacto para `NO`
(prefijo: en posición de operando, `NO x` y una variable `no` chocan) y no lo es para `Y` y `O`, que son
**solo binarios**: en un analizador por precedencia, en posición de operando nunca son operadores, y en
posición de operador nunca son nombres. Reabrirlo es un cambio de una decisión vigente y se registra
como [D-13](17-riesgos-preguntas-y-decisiones.md#d-13), no como recomendación aplicada.

### 4.3 Propuesta

1. **Núcleo reservado congelado:** las palabras de bloque y de tipo primitivo ya existentes siguen
   reservadas.
2. **Todo vocabulario nuevo es contextual** siempre que la gramática formal (§5) demuestre que la
   posición lo desambigua. Si no puede demostrarse, la palabra se reserva y su coste se mide antes con
   el corpus ([E-10](16-experimentos-y-benchmarks.md#e-10)).
3. **Escape de identificador** reservado para interoperabilidad y migración entre ediciones, no para
   el uso cotidiano. Forma por decidir; debe ser la misma en ambos perfiles.
4. **Métrica de presupuesto:** porcentaje de identificadores de un corpus de referencia que colisionan
   con el vocabulario reservado de cada perfil. Toda especificación que añada vocabulario declara su
   impacto en esa métrica.

**Qué haría cambiar esta propuesta:** que E-10 muestre colisiones despreciables con las palabras
nuevas (entonces A basta), o que las palabras contextuales degraden de forma medible los diagnósticos
para quien empieza (E-14).

---

## 5. Gramática formal como artefacto ejecutable

**[COMPROBADO]** La sección 14 de `language-spec.md` (gramática formal) está pendiente; la sintaxis
existe en prosa y en el parser escrito a mano (H-32). Sin gramática formal no se puede **demostrar**
que una palabra contextual no es ambigua, ni generar resaltado para editores, ni comprobar que una
plantilla de autocompletado es válida (el defecto H-18 lo muestra).

| Formato candidato                              | Uso conocido                                  | A favor                                                              | En contra                                                    |
|------------------------------------------------|-----------------------------------------------|----------------------------------------------------------------------|--------------------------------------------------------------|
| EBNF (ISO/IEC 14977) o variante W3C            | Especificaciones de lenguajes                 | Legible, independiente de herramienta                                | No ejecutable por sí mismo                                   |
| ungrammar                                      | rust-analyzer (genera tipos del árbol)        | Describe el árbol sin pérdida, pensado para herramientas             | Poco conocido                                                |
| Gramática de tree-sitter (`grammar.js`)        | Neovim, Helix, Zed, GitHub                    | Ejecutable, incremental, resiliente, consumida por editores          | JavaScript; mezcla gramática y resolución de conflictos      |
| PEG / ANTLR                                    | Python 3.9+ (PEG), muchos lenguajes           | Generadores maduros                                                  | ANTLR añade dependencia de Java; PEG oculta ambigüedades por orden |

**Propuesta.** Una gramática **sobre tipos de token** (plano abstracto) en un formato propio mínimo o
en EBNF estricta, versionada como especificación ([11](11-especificaciones-ejecutables-diseno.md)), a
partir de la cual se **generan** (`GEN-NO-HAND-COPY`): las gramáticas de tree-sitter de cada perfil
(sustituyendo lexemas), las plantillas de autocompletado, la referencia sintáctica de la base de
conocimiento, y un parser de referencia generado que se compara diferencialmente con el parser
escrito a mano sobre un corpus ([E-18](16-experimentos-y-benchmarks.md#e-18)). El parser de producción
puede seguir escrito a mano por la calidad de sus diagnósticos; lo que cambia es que deja de ser la
única definición de la sintaxis.

---

## 6. Identificadores, Unicode y normalización

**[COMPROBADO]** Los identificadores se comparan carácter a carácter, sin normalización Unicode; el
alfabeto lo fija el perfil y el perfil estricto excluye `ñ` y tildes. Un `ñ` en forma descompuesta
(NFD, frecuente al copiar desde ciertos sistemas de archivos y editores) produce un error léxico
opaco con cascada (H-23).

| Referencia                                    | Qué establece                                                                                            |
|-----------------------------------------------|----------------------------------------------------------------------------------------------------------|
| Unicode UAX #31, rev. 43 (Unicode 17.0, 2025)  | Sintaxis de identificadores por defecto (`XID_Start`, `XID_Continue`) y perfiles                        |
| Unicode UTS #39 (17.0)                        | Mecanismos de seguridad: confundibles, mezcla de escrituras                                             |
| Python, PEP 3131 (2007)                       | Identificadores no ASCII, normalizados a NFKC                                                            |
| Rust, RFC 2457                                | Identificadores no ASCII normalizados a NFC, con avisos de confundibles y mezcla de escrituras           |

**Propuesta.**

1. Normalizar el texto fuente de identificadores a **NFC** en el lexer, antes de clasificar. Elimina H-23
   sin cambiar ningún programa válido hoy (todo identificador válido hoy ya está en NFC).
2. Definir el alfabeto extendido como el subconjunto latino de UAX #31, y avisar (no rechazar) mezclas
   de escrituras y confundibles según UTS #39.
3. Reabrir con datos la exclusión de `ñ` en el perfil estricto ([D-14](17-riesgos-preguntas-y-decisiones.md#d-14)):
   en un lenguaje cuya identidad nace en español, un modo «estricto» que no deja escribir `año` es una
   señal contradictoria; el argumento vigente (portabilidad a sistemas sin `ñ`) pierde fuerza con
   UAX #31.
4. Mantener la comparación exacta de mayúsculas y tildes entre identificadores (§2.2 de la
   especificación): es lo que hacen todos los lenguajes de destino y la prueba del eje la justifica.

---

## 7. Coherencia entre idiomas más allá de las palabras clave

### 7.1 Un perfil por archivo, mezcla entre módulos

**[COMPROBADO]** La especificación (§2) establece que un archivo guarda su perfil. Con módulos
([08](08-modulos-paquetes-y-monorepos.md)), un programa en inglés podrá importar un módulo en español
porque ambos se encuentran en el plano abstracto. **Propuesta:** el perfil se declara por archivo (en el
manifiesto del paquete por defecto, con anulación por archivo), y la mezcla **dentro** de un archivo
sigue prohibida, por la lección de §2.2.

### 7.2 Nombres de API: el problema decisivo

Las palabras clave se traducen solas; los nombres de clases, funciones y miembros no. Opciones:

| Opción                                                                              | Precedente                         | Coste                                                                                               |
|-------------------------------------------------------------------------------------|------------------------------------|-----------------------------------------------------------------------------------------------------|
| **I. Nombres monolingües**: cada biblioteca en el idioma de quien la escribe        | Todo lenguaje no localizado        | Un programa en español que usa bibliotecas inglesas mezcla idiomas en cada línea                    |
| **II. Biblioteca estándar bilingüe por construcción** (identidad abstracta + nombre por perfil, como `BuiltinFunction`) | 1C:Enterprise; funciones incorporadas vigentes | Duplica la superficie a documentar; exige comprobar ausencia de colisiones por perfil           |
| **III. Nombres bilingües declarados por el autor** de cualquier biblioteca publicada | Ninguno conocido a escala          | Doble trabajo para cada autor; riesgo de traducciones malas; resolución de nombres más compleja     |
| **IV. Traducción automática** de nombres                                            | Ninguno fiable                     | Viola la regla de no inventar alias que nadie decidió (§2.3 de la especificación)                   |

**Propuesta:** II para la biblioteca estándar, I por defecto para terceros, y III como **opción** para
bibliotecas que la declaren, verificada mecánicamente (sin colisiones, paridad de superficie). IV se
rechaza. Decisión en [D-21](17-riesgos-preguntas-y-decisiones.md#d-21).

**Consecuencia técnica [INFERENCIA]:** el modelo de símbolo del lenguaje necesita distinguir
**identidad** de **nombre visible** también para declaraciones de usuario cuando una biblioteca
declara nombres bilingües. Hoy esa distinción solo existe para funciones incorporadas.

### 7.3 Diagnósticos, documentación y formato

- Los diagnósticos ya son independientes del idioma (§3.6 del diagnóstico). Para propósito general,
  cada código de diagnóstico debería ser una entrada de especificación con identificador estable,
  ejemplo mínimo y explicación en ambos idiomas, consultable desde el editor (como `rustc --explain`).
- La documentación de la biblioteca estándar se genera desde la especificación en ambos idiomas.
- El formateador canónico imprime en el perfil del archivo. Traducir un archivo de perfil es imprimir
  su árbol con otro perfil; para que no pierda nada hace falta un árbol **sin pérdida** que conserve
  comentarios (H-19; [07](07-herramientas-y-autocompletado.md)).
- **Nombres de identificadores de usuario nunca se traducen** al cambiar de perfil; la herramienta de
  traducción debe decirlo explícitamente en su salida.

---

## 8. Propuestas de forma para construcciones futuras

**Todo lo de esta sección es PROPUESTA ilustrativa.** Sirve para evaluar si el estilo de §3 escala; no
fija semántica (que está en [04](04-filosofia-y-modelo-del-lenguaje.md)) ni vocabulario definitivo
(que depende de E-10). Se marcan las palabras nuevas y si podrían ser contextuales.

### 8.1 Interfaces

```
Interfaz Figura
    Metodo Area() Como Real
    Metodo Nombre() Como Cadena
FinInterfaz

Clase Circulo Implementa Figura
    Privado Definir radio Como Real
    Metodo Constructor(r Como Real)
        Este.radio <- r
    FinMetodo
    Metodo Area() Como Real
        Retornar 3.14159 * Este.radio ^ 2
    FinMetodo
    Metodo Nombre() Como Cadena
        Retornar "círculo"
    FinMetodo
FinClase
```

```
interface Shape
    method Area() as real
    method Name() as string
endInterface

class Circle implements Shape
    ...
endClass
```

Palabras nuevas: `Interfaz`/`interface`, `FinInterfaz`/`endInterface`, `Implementa`/`implements`.
`Implementa` solo aparece tras una cabecera de clase: candidata a contextual. Una clase que hereda e
implementa: `Clase Gato Hereda De Mascota Implementa Figura, Comparable`.

### 8.2 Constantes, enumerados y registros

```
Constante LIMITE Como Entero <- 100

Enumeracion Color
    Rojo, Verde, Azul
FinEnumeracion

Registro Punto
    Definir x, y Como Real
FinRegistro
```

`Registro` introduce un **tipo valor** (copia al asignar), distinto de `Clase` (referencia). La
distinción se analiza en [04](04-filosofia-y-modelo-del-lenguaje.md) y [09](09-gestion-de-memoria.md).
Nótese que el ejemplo usa `y` como nombre: solo es válido si [D-13](17-riesgos-preguntas-y-decisiones.md#d-13)
se resuelve a favor de `Y`/`O` contextuales.

### 8.3 Funciones como valores y closures

Forma de **declaración local con nombre** (preferida por EST-01 y EST-05):

```
SubProceso ContadorDesde(inicio Como Entero) Como Funcion() Como Entero
    Definir actual Como Entero
    actual <- inicio
    Funcion Siguiente() Como Entero
        actual <- actual + 1
        Retornar actual
    FinFuncion
    Retornar Siguiente
FinSubProceso
```

Forma de **expresión** para argumentos cortos (alternativa a evaluar con E-14):

```
ordenados <- Ordenar(personas, Funcion(a Como Persona, b Como Persona) Como Logico
    Retornar a.Edad() < b.Edad()
FinFuncion)
```

El tipo de una función se escribe con la misma forma de cabecera: `Funcion(Entero, Entero) Como Logico`.
Hoy `Funcion` es **alias** de `SubProceso` en el perfil español; reutilizarla como tipo y como literal
exige decidir si el alias se conserva (EST-05 sugiere que sí: una función local es un subprograma
anidado). Requiere levantar la exclusión de subprogramas anidados (§10.1 de la especificación) y
**ámbitos de bloque** ([D-12](17-riesgos-preguntas-y-decisiones.md#d-12)).

### 8.4 Genéricos

```
Clase Pila De T
    Privado Definir elementos Como Lista De T
    Metodo Apilar(x Como T)
        Este.elementos.Agregar(x)
    FinMetodo
FinClase

Definir numeros Como Pila De Entero
numeros <- Nueva Pila De Entero()
```

`De` como conector de parámetro de tipo se lee de forma natural en español («pila de enteros») y en
inglés usaría `of` (`Stack of integer`). Varios parámetros: `Mapa De Cadena, Entero`. `De` y `of` son
palabras muy frecuentes: deben ser **contextuales** (solo tras un nombre de tipo). La concordancia de
género (`Nuevo`/`Nueva`) es un problema real del español: o se admiten ambas formas como alias del
mismo token (coste: retira `nueva` como nombre), o se acepta `Nuevo` invariable. La especificación
vigente rechaza derivar alias automáticamente; aquí haría falta una decisión explícita.

### 8.5 Módulos e importación

```
Importar geometria.figuras
Importar geometria.figuras.Circulo
Importar "@comun/texto" Como texto
```

Detalle en [08](08-modulos-paquetes-y-monorepos.md). `Importar`/`import` es candidata a reservada
(aparece al inicio de archivo); `Como` ya existe.

### 8.6 Errores y valores opcionales

```
SubProceso LeerEdad(texto Como Cadena) Como Resultado De Entero
    Si NO EsNumero(texto) Entonces
        Retornar Error("no es un número")
    FinSi
    Retornar Exito(AEntero(texto))
FinSubProceso

Definir r Como Resultado De Entero
r <- LeerEdad(entrada)
Segun r Hacer
    Exito(edad): Escribir "Edad: ", edad
    Error(motivo): Escribir "Inválido: ", motivo
FinSegun
```

Opcional: `Definir siguiente Como Opcional De Nodo`, con `Nada`/`nothing` como único valor vacío y
obligación de comprobarlo antes de usarlo. Sustituiría el patrón de banderas `tieneSiguiente` (H-34).

### 8.7 Recorrido de colecciones

```
Para Cada nota En notas Hacer
    total <- total + nota
FinPara
```

Reutiliza `Para`/`FinPara`; añade `Cada` y `En` (contextuales tras `Para`).

### 8.8 Concurrencia estructurada (horizonte)

```
Concurrente
    Tarea descargar1 <- Descargar(url1)
    Tarea descargar2 <- Descargar(url2)
FinConcurrente
```

Solo ilustra que el estilo de bloque cerrado encaja con concurrencia estructurada (todas las tareas
terminan al cerrar el bloque). Ver [04](04-filosofia-y-modelo-del-lenguaje.md) §4.

### 8.9 Evaluación del estilo

| Construcción     | Palabras nuevas (ES)                          | ¿Contextuales?           | Cumple EST-01…10 | Riesgo principal                                   |
|------------------|-----------------------------------------------|--------------------------|------------------|----------------------------------------------------|
| Interfaces       | `Interfaz`, `FinInterfaz`, `Implementa`        | `Implementa` sí          | Sí               | Ninguno relevante                                  |
| Constantes       | `Constante`                                   | No (inicio de sentencia) | Sí               | Valor inicial en declaración contradice §6.3 vigente |
| Enumerados       | `Enumeracion`, `FinEnumeracion`                | No                       | Sí               | Ninguno relevante                                  |
| Registros        | `Registro`, `FinRegistro`                      | No                       | Sí               | `registro` es nombre frecuente                     |
| Closures         | (`Funcion` reutilizada)                        | —                        | Sí               | Ámbitos de bloque; alias vigente                   |
| Genéricos        | `De`                                          | Sí (tras tipo)           | Sí               | Concordancia de género (`Nuevo`/`Nueva`)           |
| Módulos          | `Importar`                                    | No                       | Sí               | Ninguno relevante                                  |
| Errores          | `Resultado`, `Exito`, `Error`, `Opcional`, `Nada` | Tipos y constructores de biblioteca, no palabras clave | Sí | Si son biblioteca, no consumen presupuesto |
| Colecciones      | `Cada`, `En`                                   | Sí (tras `Para`)         | Sí               | `en` es preposición omnipresente                   |

**[INFERENCIA]** El estilo escala si se acepta que varios conceptos (resultados, opcionales,
colecciones) sean **tipos de la biblioteca estándar** y no palabras clave. Es la vía de Rust
(`Result`, `Option`) y reduce el presupuesto reservado.

---

## 9. Cómo evolucionar la gramática sin perder la identidad

Procedimiento propuesto, compatible con la skill `language-spec-authoring` vigente y que la extiende:

1. La construcción se especifica antes de su parser (vigente), **en ambos perfiles a la vez** y con su
   forma en la gramática formal.
2. Supera las reglas EST-01 a EST-10 o justifica la excepción en la propia especificación.
3. Declara su impacto en el presupuesto reservado (§4.3) medido con el corpus.
4. Declara su clase de cambio ([11](11-especificaciones-ejecutables-diseno.md) §6): una palabra nueva
   reservada es un cambio **incompatible** para programas existentes y solo entra con una edición nueva
   ([04](04-filosofia-y-modelo-del-lenguaje.md) §5).
5. Añade casos de paridad bilingüe y su herramienta de migración si es incompatible.

# Especificación del lenguaje PseudoLearn

Especificación normativa del lenguaje. Es la fuente de verdad de la gramática: ante una discrepancia
con cualquier documentación de terceros, manda este documento.

Crece por fases. Cada sección declara su estado, y **una construcción se especifica aquí antes de que
exista su parser**, nunca después. Una sección en estado pendiente significa que la construcción no
está decidida, no que esté decidida y sin escribir.

## Estado por sección

La columna **Proyectada en** declara en qué documento de la especificación publicada de la base de
conocimiento —ESP-I, ESP-O, o ninguno— se proyecta cada sección normativa —nombrando entre acentos
graves el identificador de esa sección publicada—. El cumplimiento se valida mediante el test de
cobertura uno a uno de invariantes de contenido. Una sección marcada «No se proyecta» es prosa
dirigida a quien implementa el motor, no material publicable.

| Sección                                    | Estado                                              | Proyectada en                                        |
|--------------------------------------------|-----------------------------------------------------|------------------------------------------------------|
| 1. Convenciones de la especificación       | Especificado                                        | No se proyecta — metanotación interna                |
| 2. Modelo de perfil                        | Especificado                                        | No se proyecta — dato de perfil, no de contenido     |
| 3. Estructura léxica                       | Especificado                                        | `esp-i-lexico` · publicada (CON-F18)                 |
| 4. Tipos primitivos                        | Especificado                                        | `esp-i-tipos-primitivos` · publicada (CON-F6)        |
| 5. Operadores, precedencia y asociatividad | Especificado                                        | `esp-i-operadores` · publicada (CON-F6)              |
| 6. Declaración y asignación                | Especificado                                        | `esp-i-declaracion` · publicada (CON-F6)             |
| 7. Entrada y salida                        | Especificado                                        | `esp-i-entrada-salida` · publicada (CON-F18)         |
| 8. Estructuras de control                  | Especificado                                        | `esp-i-control` · publicada (CON-F18)                |
| 9. Arreglos                                | Especificado                                        | `esp-i-arreglos` · publicada (CON-F18)               |
| 10. Subprocesos y funciones                | Especificado                                        | `esp-i-subprogramas` · publicada (CON-F18)           |
| 11. Orientación a objetos                  | Especificado                                        | `esp-o-clases` · publicada (CON-F19)                 |
| 12. Sistema de tipos y política de rigor   | Especificado                                        | `esp-i-sistema-de-tipos` · publicada (CON-F18)       |
| 13. Funciones incorporadas                 | Parcial                                             | `esp-i-funciones-incorporadas` · publicada (CON-F18) |
| 14. Gramática formal                       | Pendiente · se consolida cuando 6–12 estén cerradas | No se proyecta — gramática interna, no se publica    |

---

## 1. Convenciones de la especificación

El lenguaje se define en dos planos que no hay que confundir:

- **El plano abstracto** — tipos de token y construcciones. Es lo que el AST, el chequeador de tipos y
  el evaluador conocen. Es único y no depende del idioma.
- **El plano superficial** — los lexemas concretos con los que se escribe cada token. Es un dato del
  perfil de lenguaje, y hay uno por idioma y por perfil institucional.

Esta especificación define el plano abstracto de forma normativa. Los lexemas que aparecen en los
ejemplos corresponden al perfil de referencia «Español clásico» y son ilustrativos: cambiar de perfil
cambia los lexemas, nunca la gramática.

### 1.1 Metanotación de las formas

Las formas de las construcciones se escriben con esta metanotación, que **no es parte del lenguaje**:

| Símbolo             | Significado                              |
|---------------------|------------------------------------------|
| `<nombre de token>` | Un tipo de token del inventario de 2.4   |
| `<construcción>`    | Otra construcción de esta especificación |
| `[ ... ]`           | Opcional                                 |
| `{ ... }`           | Cero o más repeticiones                  |
| `\|`                | Alternativa                              |

Los nombres entre paréntesis angulares son **tipos de token**, no lexemas. Un ejemplo escrito con
lexemas del perfil de referencia acompaña a cada forma y es ilustrativo: cambiar de perfil cambia el
ejemplo, nunca la forma.

### 1.2 Clases de error

Toda forma de estar mal escrito un programa pertenece a **una** de estas cuatro clases, y a cuál
pertenece es una decisión de diseño que cada construcción declara explícitamente, nunca una
consecuencia de dónde acabó detectándose:

| Clase        | La detecta              | Sobre qué trabaja                                 |
|--------------|-------------------------|---------------------------------------------------|
| Léxico       | El lexer                | Caracteres que no llegan a formar un token        |
| Sintáctico   | El parser               | Tokens que no llegan a formar una construcción    |
| Semántico    | Resolvedor y chequeador | Un árbol bien formado que no tiene sentido        |
| De ejecución | El evaluador            | Un programa con sentido cuyo valor concreto falla |

**Las fases semánticas no se ejecutan si el análisis sintáctico produjo algún diagnóstico de
severidad error.** Un árbol con sentencias erróneas produciría diagnósticos semánticos sobre código
que el parser no llegó a entender, y esos diagnósticos son ruido que compite con el error real. Un
programa con errores de varias clases a la vez se corrige por fases, y cada fase informa cuando la
anterior está limpia.

### 1.3 Estrategia de recuperación de errores de sintaxis

El parser **no se detiene en el primer error**: se recupera y reporta varios. Un estudiante que
escribe treinta líneas de una vez merece verlas todas evaluadas. Pero recuperarse mal es peor que no
recuperarse: la cascada de errores derivados de uno solo es la queja mejor documentada sobre los
mensajes de error dirigidos a principiantes. Las reglas que la evitan son parte de la
especificación, no del parser:

1. **Puntos de sincronización de sentencia:** el fin de línea y el terminador explícito de sentencia.
2. **Puntos de sincronización de bloque:** los tokens de apertura y de cierre de bloque.
3. **Como máximo un diagnóstico sintáctico por sentencia.** Emitido el primero, el parser descarta
   tokens hasta el siguiente punto de sincronización antes de volver a informar de nada.
4. **Se suprime todo diagnóstico cuyo span empiece en un token descartado** durante una recuperación.
5. **Un bloque sin cerrar produce un solo diagnóstico**, con un span relacionado que señala su
   apertura. Nunca uno por cada construcción que quedó abierta debajo.
6. **Tope de cien diagnósticos sintácticos.** Superado, se informa cuántos quedan sin detallar. Un
   archivo binario abierto por error no puede producir un muro de mensajes.
7. **El parser siempre devuelve un árbol.** Una sentencia irrecuperable se representa con un nodo de
   sentencia errónea, de modo que el editor conserve una estructura sobre la que consultar posiciones
   y el resto del programa siga siendo un árbol válido.

## 2. Modelo de perfil

Un perfil declara todo lo que puede cambiar entre una institución y otra sin que cambie el lenguaje.
Tiene **dos ejes independientes**, y la distinción entre ellos no es organizativa: decide qué se puede
traducir automáticamente y qué no.

- **Eje de vocabulario.** Asigna lexemas a un inventario fijo de tipos de token. Dos perfiles se
  corresponden término a término a través de ese inventario, así que todo programa escrito en uno tiene
  un equivalente exacto en el otro.
- **Eje de rigor.** Enciende y apaga exigencias. No hay reescritura de superficie que convierta un
  programa flexible en un programa estricto válido.

Un perfil se identifica por un nombre estable, porque un archivo guarda con qué perfil fue escrito.

### 2.1 La prueba del eje

Ante un punto de variación nuevo, la pregunta que decide a qué eje pertenece —o si no pertenece a
ninguno— es esta:

> Al reimprimir el programa con el vocabulario canónico del otro perfil, ¿se obtiene un programa
> válido y con el mismo significado?

- **Sí siempre** → eje de vocabulario.
- **No siempre, pero cuando es válido significa lo mismo** → eje de rigor.
- **Es válido y significa otra cosa** → **no es configurable**. Es una decisión del lenguaje.

La tercera rama es la que protege el modelo. Una variación que cambia el resultado en vez de la
validez rompe la promesa de que abrir un archivo ajeno lo muestra tal como lo pensó quien lo escribió,
y lo rompe en silencio, que es la peor forma de romperlo.

**Invariante del eje de rigor:** todo programa válido bajo dos perfiles significa lo mismo bajo los
dos. Una bandera de rigor solo puede invalidar un programa; nunca puede cambiar lo que calcula.

### 2.2 Lo que nunca es configurable

El catálogo de lo fijo es tan normativo como el de lo variable, y se declara por adelantado para que
ninguna de estas cosas acabe pareciendo negociable:

| Punto fijo                             | Por qué no puede ser un dato del perfil                                                                                                                                              |
|----------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| El inventario de tipos de token        | Un perfil asigna lexemas a los tokens que existen; no inventa tokens. Si pudiera, el AST dejaría de ser único                                                                        |
| Precedencia y asociatividad            | Las notaciones consultadas discrepan —hay quien pone la conjunción al nivel del producto y la disyunción al de la suma. Bajo dos precedencias, la misma expresión da dos resultados  |
| El conjunto de tipos primitivos        | Cambiarlo cambia qué programas tienen sentido, no cómo se escriben                                                                                                                   |
| La conversión implícita admitida       | Misma razón                                                                                                                                                                          |
| La semántica de cada construcción      | Un bucle que itera distinto no es el mismo bucle escrito de otro modo                                                                                                                |
| El separador decimal                   | Con la coma como separador decimal, una lista de argumentos de dos elementos y un número real se escriben igual                                                                      |
| La base del índice de un arreglo       | Un mismo recorrido leería elementos distintos. Es una decisión del lenguaje, fijada en la sección de arreglos: **base cero**                                                         |
| La sensibilidad de los identificadores | Bajo comparación laxa, `Total` y `total` son la misma variable; bajo comparación exacta, dos. Un programa que usa ambas grafías es válido en los dos casos y calcula cosas distintas |

Las tres últimas filas son candidatas que la prueba del eje descartó. La comparación de
identificadores queda fijada así: **los identificadores se comparan exactamente**, carácter a carácter,
con tildes y mayúsculas incluidas. Es además lo que el estudiante encontrará en cualquier lenguaje
real.

### 2.3 Eje de vocabulario

El inventario de tipos de token se parte en dos, y la partición es lo que hace verificable el modelo:

- **Tokens reservados** — tienen lexema fijo: palabras clave, operadores y delimitadores. El perfil les
  asigna su forma escrita.
- **Tokens abiertos** — su contenido lo escribe la persona: identificador, los cuatro literales, fin de
  línea y fin de archivo. El perfil no les asigna nada.

El perfil declara una **entrada de lexema** por cada token reservado, y solo por ellos:

| Campo            | Contenido                                                           |
|------------------|---------------------------------------------------------------------|
| Lexema canónico  | La forma que se emite al imprimir. Obligatorio, exactamente uno     |
| Alias de entrada | Formas adicionales que se aceptan al escribir. Posiblemente ninguna |

La función de tipo de token reservado a entrada de lexema es **total**: un token sin entrada es un
perfil mal formado, no un token sin nombre. La relación inversa —de forma escrita a token— es **inyectiva**: dos tokens
no pueden compartir una forma, sea canónica o alias.

**Política de tildes y política de mayúsculas.** Ambas son **del perfil y valen para todo su léxico
reservado**, no por token. La razón no es de comodidad: la detección de colisiones necesita una única
función de normalización por perfil. Si cada token normalizara a su manera, «¿colisionan estas dos
formas?» no tendría una sola respuesta —dependería de por cuál de los dos tokens se pregunte— y el
validador dejaría de ser decidible. Ninguna de las dos políticas alcanza a los identificadores.

**Tokens de varias palabras.** Un lexema puede contener espacios, y se declara con un espacio simple
entre palabras. Al reconocerlo, cualquier sucesión de espacios y tabulaciones cuenta como un separador. **Un salto de
línea nunca cae dentro de un token**: el salto de línea termina una sentencia, y dejar
que un token lo cruzase convertiría un bloque sin cerrar en un error que aparece páginas más abajo.

La forma pegada no se deriva: si un perfil acepta la variante sin espacios, la declara como alias. La
derivación automática produciría alias que nadie decidió y colisiones imposibles de prever.

**Reconocimiento por coincidencia más larga.** Entre dos formas en las que una es prefijo de la otra
gana la más larga. Es lo que permite que convivan un token de una palabra y otro que empieza por esa
misma palabra.

**Operadores y delimitadores.** Sus lexemas son datos del perfil, incluido el de asignación —las
notaciones consultadas usan al menos tres símbolos distintos para él. Lo que el perfil **no** puede
tocar de un operador es su nivel de precedencia, su asociatividad ni su aridad.

**Marcador de comentario.** Es del perfil.

**Delimitador de literal entre comillas.** Un único token reservado, compartido por el literal de
cadena y el de carácter: el perfil de referencia acepta comilla doble y comilla simple para los dos,
de forma intercambiable, tal como ya fijaba la sección de estructura léxica. El delimitador **no**
decide si el literal resultante es cadena o carácter — decidirlo por delimitador exigiría dos tokens
reservados que nunca podrían compartir forma, y las fuentes consultadas usan las mismas comillas para
ambos. Qué convierte un literal entre comillas en carácter y qué lo convierte en cadena es una regla
del lexer, y se cierra en el sprint que lo construye, no aquí: aquí solo se fija que la elección no
puede recaer sobre qué comilla se usó, porque el perfil no tiene forma de declarar dos comillas
distintas para dos tokens que se escriben igual.

**Nombres de las funciones incorporadas.** Cada función incorporada tiene una identidad abstracta y un
nombre por perfil, con sus alias, igual que un token reservado. **No son lexemas reservados:** una
declaración con ese nombre la oculta dentro de su ámbito, como en cualquier lenguaje real.

**Reglas de identificador.** La *forma* es del lenguaje: un identificador empieza por letra o guion
bajo y sigue con letras, dígitos o guiones bajos. El *alfabeto* —qué caracteres cuentan como letra— es
un dato del perfil, y por la prueba del eje pertenece al eje de rigor, porque un identificador nunca se
traduce: una variable llamada `año` no tiene equivalente bajo un alfabeto que no admite `ñ`.

Se rechaza admitir el guion en los identificadores, que alguna notación consultada permite: haría
ambigua toda resta escrita sin espacios.

**Invariantes de integridad léxica que los perfiles oficiales cumplen.** Un perfil oficial es válido y admisible en el
catálogo cuando cumple todas:

1. Cada token reservado tiene exactamente un lexema canónico.
2. Ninguna forma escrita —canónica o alias— pertenece a dos tokens tras normalizarla.
3. Todo lexema reservado formado por palabras es escribible con el alfabeto de identificador del
   propio perfil. Un perfil que excluye las tildes no puede declarar `Según`, porque su lexer nunca
   llegaría a formar esa palabra.
4. Ningún lexema de operador tiene el marcador de comentario como prefijo propio: sería inalcanzable.
5. Ningún delimitador de literal coincide con un lexema de operador o de delimitador.
6. Toda bandera de rigor tiene valor. No hay valor por omisión implícito.

### 2.4 Inventario de tipos de token

Cubre el alcance completo del lenguaje. La columna de lexema es **ilustrativa** del perfil de
referencia.

Los grupos marcados con «·» son **provisionales**: la sección que fija su gramática está pendiente, y
al cerrarla puede cambiar la forma de una entrada o añadir alguna. El grupo de subprogramas sigue
provisional mientras la sección 10 esté a la espera de aprobación: esa sección propone **una sola
entrada nueva**, el token de retorno, y ninguna otra —procedimiento y función resultan ser una única
construcción, y el tipo de retorno y el de los parámetros reutilizan el conector de tipo y los tokens
de tipo primitivo. El grupo de objetos sigue provisional por la misma razón, mientras la sección 11
esté a la espera de aprobación: la investigación del sprint 10 confirma que **ninguna entrada cambia
ni se añade**, así que la marca solo señala que el estado de su gramática es «propuesto», no que su
forma esté en duda. Los demás grupos están cerrados.

**Tokens abiertos**, sin lexema:

identificador, literal entero, literal real, literal de cadena, literal de carácter, fin de línea y
fin de archivo.

**Tokens reservados:**

| Grupo                   | Token                    | Lexema del perfil de referencia |
|-------------------------|--------------------------|---------------------------------|
| Programa                | inicio de algoritmo      | `Proceso`                       |
|                         | fin de algoritmo         | `FinProceso`                    |
| Declaración             | declaración              | `Definir`                       |
|                         | conector de tipo         | `Como`                          |
|                         | declaración de dimensión | `Dimension`                     |
| Tipos                   | tipo entero              | `Entero`                        |
|                         | tipo real                | `Real`                          |
|                         | tipo lógico              | `Logico`                        |
|                         | tipo carácter            | `Caracter`                      |
|                         | tipo cadena              | `Cadena`                        |
| Literales lógicos       | verdadero                | `Verdadero`                     |
|                         | falso                    | `Falso`                         |
| Entrada y salida        | lectura                  | `Leer`                          |
|                         | escritura                | `Escribir`                      |
|                         | modificador sin salto    | `Sin Saltar`                    |
| Asignación              | asignación               | `<-`                            |
| Condicional             | si                       | `Si`                            |
|                         | entonces                 | `Entonces`                      |
|                         | si no                    | `SiNo`                          |
|                         | fin de condicional       | `FinSi`                         |
| Selección múltiple      | según                    | `Segun`                         |
|                         | rama por defecto         | `De Otro Modo`                  |
|                         | fin de selección         | `FinSegun`                      |
| Bucles                  | mientras                 | `Mientras`                      |
|                         | hacer                    | `Hacer`                         |
|                         | fin de mientras          | `FinMientras`                   |
|                         | repetir                  | `Repetir`                       |
|                         | hasta que                | `Hasta Que`                     |
|                         | para                     | `Para`                          |
|                         | hasta                    | `Hasta`                         |
|                         | con paso                 | `Con Paso`                      |
|                         | fin de para              | `FinPara`                       |
| Subprogramas ·          | inicio de subproceso     | `SubProceso`                    |
|                         | fin de subproceso        | `FinSubProceso`                 |
|                         | paso por referencia      | `Por Referencia`                |
|                         | paso por valor           | `Por Valor`                     |
|                         | retorno ·                | `Retornar`                      |
| Objetos ·               | clase                    | `Clase`                         |
|                         | fin de clase             | `FinClase`                      |
|                         | herencia                 | `Hereda De`                     |
|                         | método                   | `Metodo`                        |
|                         | fin de método            | `FinMetodo`                     |
|                         | constructor              | `Constructor`                   |
|                         | visibilidad pública      | `Publico`                       |
|                         | visibilidad privada      | `Privado`                       |
|                         | instanciación            | `Nuevo`                         |
|                         | objeto actual            | `Este`                          |
|                         | superclase               | `Super`                         |
| Operadores aritméticos  | suma                     | `+`                             |
|                         | resta                    | `-`                             |
|                         | producto                 | `*`                             |
|                         | división                 | `/`                             |
|                         | división entera          | `div`                           |
|                         | módulo                   | `mod`                           |
|                         | potencia                 | `^`                             |
| Operadores relacionales | menor                    | `<`                             |
|                         | menor o igual            | `<=`                            |
|                         | mayor                    | `>`                             |
|                         | mayor o igual            | `>=`                            |
|                         | igual                    | `=`                             |
|                         | distinto                 | `<>`                            |
| Operadores lógicos      | conjunción               | `Y`                             |
|                         | disyunción               | `O`                             |
|                         | negación                 | `NO`                            |
| Acceso                  | acceso a miembro ·       | `.`                             |
| Delimitadores           | abre paréntesis          | `(`                             |
|                         | cierra paréntesis        | `)`                             |
|                         | abre índice              | `[`                             |
|                         | cierra índice            | `]`                             |
|                         | separador de lista       | `,`                             |
|                         | terminador de sentencia  | `;`                             |
|                         | separador de rama        | `:`                             |
|                         | delimitador de literal   | `"` · alias `'`                 |

**El separador de rama lo añadió la sección de estructuras de control.** No estaba en el
inventario cuando esta sección se cerró: la forma de la selección múltiple lo destapó, y las tres
fuentes consultadas lo usan sin excepción. Es la única entrada añadida al inventario después de
darlo por cerrado.

**El delimitador de literal es un único token**, compartido por el literal de cadena y el de carácter;
no hay dos entradas porque no hay dos delimitadores que distinguir. Ver 2.3.

**No hay token de concatenación.** Comparte lexema con la suma, el parser produce el mismo nodo y la
operación la decide el chequeo de tipos. Un token propio obligaría al parser a conocer los tipos.

**Consecuencia para la presentación de diagnósticos.** Un mensaje que nombra un token reservado lo
resuelve contra el vocabulario activo; uno que nombra un token abierto no puede —no hay lexema— y usa
un término de prosa en el idioma de la interfaz. La partición decide cuál de las dos vías se toma, y
por eso es un dato del lenguaje y no una preferencia de presentación.

### 2.5 Eje de rigor

Una bandera de rigor es un valor de dos estados que **exige o deja de exigir** algo. La columna de
consumidor es la parte que importa: una bandera que consume el parser cambia qué programas son
sintácticamente válidos.

| Bandera                                      | Qué exige cuando está activa                           | Consumidor | Estricto | Flexible |
|----------------------------------------------|--------------------------------------------------------|------------|----------|----------|
| Alfabeto de identificador extendido          | Admite `ñ` y vocales acentuadas como letra             | Lexer      | No       | Sí       |
| Terminador de sentencia obligatorio          | Cada sentencia cierra con el terminador explícito      | Parser     | Sí       | No       |
| Paso explícito en el bucle contado           | El paso se escribe siempre, aunque sea el habitual     | Parser     | Sí       | No       |
| Declaración obligatoria                      | Toda variable se declara antes de su primer uso        | Resolvedor | Sí       | No       |
| Inicialización obligatoria                   | Leer una variable antes de asignarle valor es un error | Chequeador | Sí       | No       |
| Etiquetas numéricas en la selección múltiple | Las etiquetas de rama son de tipo entero               | Chequeador | Sí       | No       |
| Dimensión constante de arreglo               | El tamaño de un arreglo es una expresión constante     | Chequeador | Sí       | No       |

Las siete cumplen el invariante: apagar una amplía el conjunto de programas válidos y no cambia lo que
calcula ninguno de los que ya lo eran.

**Una candidata descartada, y por qué.** «Permitir formas alternativas de cierre de bloque» no es una
bandera: aceptar `Fin Mientras` junto a `FinMientras` es declarar un alias, que es eje de vocabulario.
La versión que sí sería una bandera —admitir un cierre genérico que valga para cualquier bloque—
necesita un token que hoy no existe, y crearlo es una decisión de la sección de estructuras de control,
no de esta.

**La política de severidad** es la segunda mitad de este eje: una tabla de código de diagnóstico a
severidad, inyectada junto con las banderas. Su contenido se cierra en la sección 12.
Aquí queda fijado que pertenece al perfil y que los dos modos son dos conjuntos de datos, nunca dos
ramas de código.

### 2.6 Segregación por consumidor

Ningún componente recibe el perfil entero. Recibe la parte que consume, y nada más:

| Consumidor                   | Recibe                                       | No conoce                                    |
|------------------------------|----------------------------------------------|----------------------------------------------|
| Lexer                        | Vocabulario y reglas de identificador        | Toda bandera de rigor sintáctico o semántico |
| Parser                       | Solo las banderas de rigor sintáctico        | El vocabulario, por completo                 |
| Resolvedor y chequeador      | Solo las banderas de rigor semántico         | El vocabulario                               |
| Presentación de diagnósticos | Vocabulario, para resolver tokens reservados | Toda bandera de rigor                        |

La fila del parser es la menos evidente y la que confirma que el modelo está bien cortado: **el parser
no necesita ni una sola entrada de vocabulario.** Trabaja sobre tipos de token, que el lexer ya
resolvió, y sobre una precedencia que es del lenguaje. Si algún día el parser necesitara un lexema,
sería la señal de que una decisión de vocabulario se coló en la gramática.

### 2.7 Independencia de ejes y traducción entre perfiles

El idioma de la interfaz y el perfil de sintaxis son dos ajustes separados. La combinación
«interfaz en un idioma, palabras clave en otro» es legítima y tiene que producir mensajes coherentes.

Traducir un programa de un perfil a otro es analizarlo con el vocabulario de origen e imprimirlo con el
de destino. **En el eje de vocabulario la traducción no pierde nada**, porque ambos perfiles cubren el
mismo inventario de tokens. En el eje de rigor puede no haber traducción: si el programa usa algo que
el perfil de destino exige de otro modo, no hay reimpresión que lo arregle, y decirlo es la respuesta
correcta.

**El pivote de la traducción es el tipo de token, y el tipo de token no es de ningún idioma.** Ni el
perfil de referencia en español ni un perfil en inglés hacen de intermediario: cada perfil declara su
propia entrada `tipo de token → lexema`, y traducir es leer con el mapa de origen y escribir con el
mapa de destino, sin pasar por un tercero. Esto es lo que permite que una institución declare un
perfil con vocabulario propio —incluidas palabras que no traducen literalmente ninguna de las otras
dos— sin que ese perfil quede aislado: en cuanto sus lexemas están anclados al inventario de tokens,
se traduce hacia y desde cualquier otro perfil exactamente igual que el de referencia, porque lo
único que la traducción consulta es esa ancla, nunca el idioma del que salió cada palabra. Si el
pivote fuera un perfil concreto en vez del tipo de token, cambiar ese perfil de referencia algún día
invalidaría todos los perfiles construidos «contra» él; con un pivote no lingüístico eso no puede
pasar.

### 2.8 Casos límite y errores

| Situación                                                        | Clase de error                                         |
|------------------------------------------------------------------|--------------------------------------------------------|
| Perfil sin entrada para un token reservado                       | Perfil inválido (inadmisible en catálogo oficial)      |
| Dos tokens con la misma forma normalizada                        | Perfil inválido (inadmisible en catálogo oficial)      |
| Lexema reservado no escribible con el alfabeto del propio perfil | Perfil inválido (inadmisible en catálogo oficial)      |
| Bandera de rigor sin valor                                       | Perfil inválido (inadmisible en catálogo oficial)      |
| Perfil sin ningún alias                                          | Válido. Los alias son opcionales                       |
| Identificador que coincide con un lexema reservado               | Error sintáctico, en el programa                       |
| Salto de línea dentro de un token de varias palabras             | No se reconoce el token. El error lo reporta el parser |

Ejemplo mínimo de perfil válido: uno que asigna a cada token reservado un lexema distinto, sin alias,
con las dos políticas de normalización apagadas y las siete banderas con valor.

Ejemplo mínimo de perfil inválido: el mismo, con el token de igualdad y el de asignación compartiendo
el lexema `=`. Es el caso que explica por qué el perfil de referencia usa una flecha para asignar.

## 3. Estructura léxica

**Identificadores.** Empiezan por letra o guion bajo, y siguen con letras, dígitos o guiones bajos.
Qué caracteres cuentan como letra lo fija el alfabeto del perfil. **Entre sí, dos identificadores se
comparan exactamente:** ni las tildes ni las mayúsculas se ignoran nunca en un nombre, de modo que
`total` y `Total` son dos variables distintas.

**Un identificador no puede coincidir con un lexema reservado del perfil activo, y esa coincidencia se
decide con la normalización del perfil, no carácter a carácter.** Es la única comparación en la que las
políticas de tildes y mayúsculas alcanzan a un nombre, y no puede ser de otro modo: reconocer la
palabra clave y descartar el nombre son la misma búsqueda en la misma tabla. Un perfil que acepta
`Segun`, `segun` y `SEGÚN` como la misma palabra clave no tiene forma de admitir `segun` como nombre de
variable. La consecuencia gobierna el diseño de todo vocabulario: **la superficie de formas reservadas
de un perfil es exactamente el conjunto de nombres que le retira a quien programa**, en todas sus
grafías, y un alias que nunca se imprime cobra ese precio sin devolver nada a la lectura del programa.

**Clase del error y quién lo reporta.** Usar un lexema reservado donde la gramática exige un nombre es
un **error sintáctico**. El lexer no puede clasificarlo: reconoce la palabra clave la escriba quien la
escriba, y no sabe si el sitio en que apareció admitía un nombre. Quien lo sabe es el parser, y es
quien emite el diagnóstico, con la palabra tal como se escribió y el token reservado con el que choca.

**Dónde se reporta.** Solo donde la gramática exige un nombre y ninguna otra cosa: la lista de una
declaración de variables, el destino de una asignación y la variable de control del bucle contado. En
posición de expresión un lexema reservado es ambiguo entre un nombre mal elegido y una expresión
incompleta —`Si x > Entonces` es lo segundo—, y resolver esa ambigüedad por conjetura enseña lo
contrario de lo que hace falta: allí el diagnóstico es el de elemento inesperado en la expresión.

**Sensibilidad a mayúsculas y tildes del léxico reservado.** Ambas son políticas del perfil y solo
alcanzan a las palabras clave, los operadores y los delimitadores. En el perfil de referencia el léxico
reservado es insensible a mayúsculas y a tildes, de modo que `Segun` y `Según` son el mismo token: en
un teclado táctil nadie escribe tildes, y castigarlo no enseña nada.

**Tokens multipalabra.** El léxico admite lexemas de varias palabras, de modo que un perfil puede
definir un token como una sola palabra o como dos separadas por espacios. Ningún token cruza un salto
de línea.

**Números.** Enteros como secuencia de dígitos; reales con un punto como separador decimal y al menos
un dígito a cada lado. El signo no forma parte del literal: es un operador unario.

**Cadenas y caracteres.** Delimitados por comilla doble o simple; la forma canónica de salida es la
comilla doble. Se aceptan ambas porque el material educativo usa las dos de forma intercambiable. Las
secuencias de escape admitidas se cierran en la fase del lexer.

**Comentarios.** Desde un marcador de comentario hasta el fin de línea. El marcador es un dato del
perfil.

**Fin de sentencia.** Una sentencia termina al final de la línea. El terminador explícito de sentencia
se acepta siempre como separador, lo que permite escribir varias sentencias en una línea; que además
sea obligatorio es una bandera de rigor.

**Espacios en blanco.** Espacios, tabulaciones y saltos de línea separan tokens y no son
significativos, salvo el salto de línea como fin de sentencia. La indentación no es significativa.

## 4. Tipos primitivos

Cinco tipos, sin conversiones implícitas salvo la indicada:

| Tipo     | Valores                                         |
|----------|-------------------------------------------------|
| entero   | números enteros                                 |
| real     | números con parte decimal                       |
| lógico   | los dos valores de verdad                       |
| carácter | un único carácter                               |
| cadena   | secuencia de caracteres, de longitud no acotada |

**Cadena y carácter son tipos distintos.** No se replica el tratamiento de algunas herramientas que los
confunden ni el que usa la declaración de arreglo para acotar la longitud de una cadena: una cadena no
es un arreglo de caracteres, y confundirlos enseña un modelo equivocado.

**Un carácter es un punto de código Unicode.** Cerrado en el Sprint 15, porque `Longitud`, `carácter en
posición`, `código de carácter` y `carácter desde código` (12.11) no tienen semántica sin decidir qué
se cuenta. Con unidades de código UTF-16 del lenguaje anfitrión, un carácter fuera del plano básico
—poco frecuente, pero no exótico en español— daría resultados distintos a los que el estudiante ve en
pantalla. Contar puntos de código es lo que coincide con lo que se ve, aunque el acceso a una posición
dentro de una cadena deje de ser una operación de coste constante: irrelevante a la escala de estos
programas. `Longitud("año")` vale 3.

**La única conversión implícita es de entero a real**, en la dirección que no pierde información. La
contraria requiere una función incorporada explícita. La tabla completa de conversiones, con las que
se rechazan y por qué, está en 12.1.

**Rango de los tipos numéricos.** `entero` es de **64 bits con signo**; `real` es de **doble
precisión, IEEE 754 binario de 64 bits**. Los dos rangos son idénticos en los tres objetivos de
compilación, y salirse de ellos es un diagnóstico de ejecución y nunca un giro silencioso: ver 12.2.

## 5. Operadores, precedencia y asociatividad

De mayor a menor prioridad. Los operadores de una misma fila comparten prioridad. La tabla es del
lenguaje: ningún perfil la altera.

| Nivel | Operadores                                        | Descripción              | Asociatividad |
|-------|---------------------------------------------------|--------------------------|---------------|
| 1     | signo positivo, signo negativo, negación lógica   | unarios                  | derecha       |
| 2     | potencia                                          | exponenciación           | **derecha**   |
| 3     | multiplicación, división, división entera, módulo |                          | izquierda     |
| 4     | suma, resta, concatenación                        |                          | izquierda     |
| 5     | menor, menor o igual, mayor, mayor o igual        | relacionales de orden    | izquierda     |
| 6     | igual, distinto                                   | relacionales de igualdad | izquierda     |
| 7     | conjunción lógica                                 |                          | izquierda     |
| 8     | disyunción lógica                                 |                          | izquierda     |

Los paréntesis alteran la prioridad y se pueden anidar.

**Dos puntos que ninguna fuente consultada resolvía y que aquí quedan fijados**, porque son
exactamente el tipo de detalle que un test de precedencia consolida para siempre:

1. **La potencia asocia a la derecha.** Es la convención matemática y la de la mayoría de lenguajes.
2. **La negación lógica liga más fuerte que los relacionales.** Es coherente con el nivel 1 de la
   tabla y con el comportamiento de los lenguajes de la familia C.

La concatenación comparte nivel con la suma porque comparte lexema: qué operación es se decide por los
tipos de los operandos, en el chequeo de tipos, no en el parser.

**Esta tabla ordena, no tipa.** Qué combinaciones de tipos admite cada operador y qué tipo devuelve
está en 12.3, y no se repite aquí.

**Los operadores lógicos evalúan en cortocircuito**, y esto sí es de esta sección porque es
observable: evaluado el primer operando, si ya determina el resultado, **el segundo no se evalúa**. Es
lo que hacen todos los lenguajes a los que el estudiante saltará después, y es lo que permite
comprobar un índice y usarlo en la misma condición sin salirse del arreglo.

## 6. Declaración y asignación

### 6.1 Estructura del programa

```
<inicio de algoritmo> <identificador>
    <cuerpo>
<fin de algoritmo>
```

El **nombre del algoritmo es obligatorio** y sigue las reglas de identificador de la sección 3. No
ocupa el espacio de nombres del programa: una variable puede llamarse igual, porque el nombre del
algoritmo no aparece en ninguna expresión. Se usa al informar diagnósticos y como nombre por omisión
al exportar.

**No hay sección de declaraciones.** El cuerpo es una lista de sentencias, y declarar es una
sentencia más, que puede aparecer en cualquier punto. Se rechazan las secciones propias de las
notaciones consultadas por una razón concreta: exigirían tokens de sección y de delimitación de
cuerpo que el inventario no tiene, y la disciplina de declarar antes de usar ya la impone la bandera
de rigor «Declaración obligatoria» sin gramática adicional.

**Consecuencia normativa:** hay un solo ámbito por programa, y —cuando existan— uno por subprograma. **No hay ámbitos de
bloque**: una variable declarada dentro de un condicional o de un bucle es
visible en todo el programa a partir de esa declaración.

Un texto de origen contiene **exactamente un** algoritmo. Con el alcance estructurado cerrado aquí,
nada puede aparecer antes de la cabecera ni después del cierre salvo espacios en blanco y
comentarios. La sección 10 propone levantar esa restricción para admitir declaraciones de subprograma
hermanas del algoritmo, antes o después de él; mientras esa sección esté a la espera de aprobación,
esta regla se lee con esa reserva.

| Situación                            | Clase de error                                           |
|--------------------------------------|----------------------------------------------------------|
| Texto de origen vacío                | Sintáctico: se esperaba el inicio del algoritmo          |
| Cabecera sin nombre                  | Sintáctico                                               |
| Falta el cierre al final del archivo | Sintáctico, con span relacionado en la cabecera          |
| Sentencias después del cierre        | Sintáctico                                               |
| Cuerpo vacío                         | **No es error.** Un algoritmo que no hace nada es válido |

Ejemplo mínimo válido — `Proceso Vacio` / `FinProceso`.
Ejemplo mínimo inválido — `Proceso` / `FinProceso`: falta el nombre.

### 6.2 Sentencias y su terminación

Una sentencia termina al final de la línea. El terminador explícito se acepta **siempre** como
separador, lo que permite escribir varias sentencias en una línea.

Bajo la bandera «Terminador de sentencia obligatorio» lo llevan **solo las sentencias simples** —
declaración, dimensionamiento, asignación, entrada y salida—, incluida la última de un bloque. **Nunca lo llevan las
palabras de apertura ni de cierre de bloque.** Exigirlo también en los cierres
sería más uniforme de enunciar y se apartaría de todas las fuentes consultadas y de todo lenguaje
real, que es el criterio de desempate.

Una línea en blanco no es una sentencia vacía: no produce nodo ni diagnóstico.

### 6.3 Declaración de variables

```
<declaración> <identificador> {<separador de lista> <identificador>} <conector de tipo> <tipo>
```

Donde `<tipo>` es uno de los cinco tokens de tipo primitivo, o un identificador de clase (11.8).

- **Varias variables en una sentencia: sí.** Todas reciben el mismo tipo.
- **Valor inicial: no.** Se rechaza el que admite una de las fuentes consultadas por una razón de
  esta gramática y no de gusto: el tipo va al final, así que un inicializador por variable tendría
  que colarse antes del conector de tipo y sería indistinguible de una asignación. La asignación ya
  es una sentencia de primera clase, y escribirla aparte enseña exactamente lo mismo.
- Declarar no da valor. Qué valor tiene una variable declarada y no asignada lo decide la sección
  12, según la política de rigor: **no hay valor por omisión**, y leerla es un fallo en las dos
  políticas.

| Situación                              | Clase de error                                     |
|----------------------------------------|----------------------------------------------------|
| Lista de identificadores vacía         | Sintáctico                                         |
| Falta el conector de tipo o el tipo    | Sintáctico                                         |
| Se escribe una asignación tras el tipo | Sintáctico: la declaración no admite valor inicial |
| El mismo nombre declarado dos veces    | Semántico, lo detecta el resolvedor                |
| Uso antes de la declaración            | Semántico, solo bajo «Declaración obligatoria»     |
| Un identificador de un solo carácter   | **No es error**                                    |

Ejemplo válido — `Definir base, altura Como Real`.
Ejemplo inválido — `Definir Como Entero`: no hay nada que declarar.

### 6.4 Designadores

Un **designador** es una expresión que denota un sitio donde guardar un valor. Es la única forma
admisible como destino de una asignación, como destino de una entrada, y como variable de control de
un bucle contado.

```
<designador> ::= <identificador>
               | <designador> <abre índice> <lista de expresiones> <cierra índice>
               | <designador> <acceso a miembro> <identificador>      (11.7)
```

No son designadores: los literales, una expresión entre paréntesis, el resultado de un operador y
la llamada a una función.

**El parser analiza una expresión completa y después comprueba que es un designador.** No intenta
reconocer un designador desde el primer token. La diferencia es el diagnóstico: reconociendo la
expresión entera se puede decir «esto no es algo a lo que se pueda asignar» subrayando la expresión
completa, mientras que fallar en el primer token produce un error de sintaxis genérico en el sitio
equivocado. El destino no designador es, por tanto, un error **sintáctico** con código propio.

### 6.5 Asignación

```
<designador> <asignación> <expresión>
```

**Orden de evaluación**, normativo porque es observable: primero las expresiones de índice del
designador, en orden de aparición; después la expresión de la derecha; después se guarda el valor.
Es el orden de lectura del texto, que es el único que un estudiante puede predecir.

| Situación                        | Clase de error        |
|----------------------------------|-----------------------|
| El destino no es un designador   | Sintáctico            |
| Falta la expresión de la derecha | Sintáctico            |
| Tipos incompatibles              | Semántico, sección 12 |
| Índice fuera de rango            | De ejecución          |
| Asignar un arreglo completo      | Semántico, ver 9.1    |

Ejemplo válido — `notas[i] <- notas[i] + 1`.
Ejemplo inválido — `3 <- x`: el destino no es un designador.

## 7. Entrada y salida

### 7.1 Salida

```
<escritura> [<lista de expresiones>] [<modificador sin salto>]
```

- La lista admite **cero o más** expresiones, separadas por el separador de lista, evaluadas de
  izquierda a derecha y una sola vez cada una.
- Los valores se emiten **concatenados, sin ningún separador automático**. El espacio que se quiera
  ver se escribe en el programa.
- El modificador va **en sufijo**, después de la lista, y es opcional. Ausente, se emite un salto de
  línea tras los valores; presente, no se emite.

La variante sin salto es un **modificador de la sentencia de salida, no una segunda instrucción ni
una palabra clave distinta**. Produce un único nodo de árbol con una bandera, y de ahí salen tres
consecuencias que justifican la elección: un solo símbolo de salida en el ordinograma, un solo camino
en el evaluador, y ningún par de nodos hermanos que puedan divergir al mantenerlos.

| Situación                         | Resultado o clase de error        |
|-----------------------------------|-----------------------------------|
| Cero expresiones, sin modificador | Válido: emite una línea en blanco |
| Cero expresiones, con modificador | Válido: no emite nada             |
| Modificador antes de la lista     | Sintáctico                        |
| Modificador repetido              | Sintáctico                        |
| Separador de lista sobrante       | Sintáctico                        |

Ejemplo válido — `Escribir "Total: ", total Sin Saltar`.
Ejemplo inválido — `Escribir Sin Saltar "Total"`: el modificador va al final.

**Representación textual de cada valor.** Cerrado en el Sprint 15, porque sin esta regla no hay un
solo caso de salida verificable ni semántica posible para `ConvertirACadena` (12.11). No puede quedar
en manos del lenguaje anfitrión: `double.toString()` de Dart no está garantizado idéntico entre los
tres objetivos de compilación, y el determinismo en el camino crítico es una decisión de producto
declarada.

| Tipo       | Texto emitido                                                                                                     |
|------------|-------------------------------------------------------------------------------------------------------------------|
| `entero`   | Dígitos decimales, con signo menos si es negativo. Nunca separador de millares                                    |
| `real`     | Notación posicional, sin exponente; al menos un dígito decimal, incluso para un valor entero (`2` se emite `2.0`) |
| `lógico`   | El lexema del perfil activo para verdadero o falso                                                                |
| `carácter` | El carácter, sin comillas                                                                                         |
| `cadena`   | El contenido, sin comillas                                                                                        |

**El texto que emite la salida y el que devuelve `ConvertirACadena` son el mismo**, producidos por la
misma pieza. Que difieran es la incoherencia que ningún ejercicio detectaría hasta cruzarla. Emitir el
lexema lógico del perfil activo no infringe la prohibición de texto para personas fuera de
`diagnostics/`: no es un literal en el código, es el mismo dato de la tabla de vocabulario que el
lexer ya usó para reconocer el programa.

### 7.2 Entrada

```
<lectura> <designador> {<separador de lista> <designador>}
```

- **Al menos un** designador. A diferencia de la salida, la lectura vacía no tiene significado
  posible: escribir nada es una línea en blanco, leer nada no es nada.
- Los valores se piden **de uno en uno y en orden**, no todos a la vez.
- El tipo esperado de cada valor es el tipo del designador.

**Valor que no corresponde al tipo esperado: diagnóstico de ejecución, y se vuelve a pedir el mismo
valor.** El paso del evaluador señala que espera un valor y con qué tipo; si el que recibe no
convierte, emite el diagnóstico y **permanece en el mismo estado**, volviendo a pedirlo. No se
interrumpe la ejecución y no se lanza ninguna excepción. Esta decisión fija el protocolo del motor
paso a paso, y por eso se cierra aquí y no en la fase que lo construye.

| Situación                           | Clase de error                    |
|-------------------------------------|-----------------------------------|
| Ningún designador                   | Sintáctico                        |
| Un elemento que no es designador    | Sintáctico                        |
| Valor de tipo incorrecto            | De ejecución, y se vuelve a pedir |
| Índice fuera de rango en el destino | De ejecución                      |

Ejemplo válido — `Leer notas[i], nombre`.
Ejemplo inválido — `Leer 3`: no es un designador.

## 8. Estructuras de control

Reglas comunes a las cinco construcciones de bloque:

- **El cuerpo de un bloque es una lista de sentencias que puede estar vacía.** Un bloque vacío es
  válido en todas ellas y no produce diagnóstico.
- Cualquier construcción puede anidarse dentro de cualquier otra, sin límite declarado de
  profundidad.
- La condición de un condicional o de un bucle debe ser de tipo lógico; que no lo sea es un error **semántico**, no
  sintáctico.
- Un bloque sin cerrar al final del archivo produce **un** diagnóstico sintáctico con span
  relacionado en su apertura, según 1.3.

### 8.1 Condicional

```
<si> <expresión> <entonces>
    <cuerpo>
[<si no>
    <cuerpo>]
<fin de condicional>
```

La palabra intermedia es **obligatoria siempre**, sin bandera de rigor que la relaje: da un punto de
sincronización limpio al parser y permite un diagnóstico concreto —«falta la palabra intermedia»— en
lugar de un error genérico.

La rama contraria es opcional; ausente, equivale a un cuerpo vacío.

**No existe una construcción propia para el caso contrario encadenado.** Escribir varias condiciones
en cascada es anidar un condicional dentro de la rama contraria, cada uno con su propio cierre. Las
tres fuentes consultadas coinciden, y el inventario no tiene ningún token para ello.

**El árbol no tiene nodo de cadena.** La rama contraria es una lista de sentencias; que su única
sentencia sea otro condicional es un patrón que el impresor y el ordinograma pueden reconocer para
dibujarlo como cadena, pero no es una construcción distinta y el chequeador y el evaluador no la
distinguen.

| Situación                   | Clase de error                                  |
|-----------------------------|-------------------------------------------------|
| Falta la palabra intermedia | Sintáctico, con código propio                   |
| Dos ramas contrarias        | Sintáctico                                      |
| Falta el cierre             | Sintáctico, con span relacionado en la apertura |
| Cierre que no corresponde   | Sintáctico, con span relacionado en la apertura |
| Condición no lógica         | Semántico                                       |
| Los dos cuerpos vacíos      | **No es error**                                 |

Ejemplo válido — `Si nota >= 5 Entonces` / `Escribir "Aprobado"` / `FinSi`.
Ejemplo inválido — `Si nota >= 5` / `Escribir "Aprobado"` / `FinSi`: falta `Entonces`.

### 8.2 Selección múltiple

```
<según> <expresión> <hacer>
    <lista de etiquetas> <separador de rama>
        <cuerpo>
    {<lista de etiquetas> <separador de rama>
        <cuerpo>}
    [<rama por defecto> <separador de rama>
        <cuerpo>]
<fin de selección>
```

**El selector es una expresión completa, evaluada exactamente una vez** antes de comparar con
ninguna etiqueta.

**Las etiquetas son literales**, no expresiones y no identificadores. Un literal entero puede llevar
signo. Esta restricción es la que permite que el **parser** detecte etiquetas repetidas comparando
literales, sin conocer tipos ni valores; con expresiones como etiqueta la detección exigiría evaluar,
y una rama muerta pasaría inadvertida hasta la ejecución.

**No hay caída de una rama a la siguiente.** Ejecutada la rama que coincide, la ejecución continúa
después del cierre. Es lo que dice explícitamente la única fuente que se pronuncia, ninguna describe
lo contrario, y el inventario no tiene ningún token de salto con el que se pudiera escribir la
interrupción que la caída exigiría.

**Rangos como etiqueta: no.** Ninguna fuente los tiene y ninguna fase aprobada los pide.

**Tipos admisibles de las etiquetas:**

| Tipo     | Estricto | Flexible | Motivo                                                                                                    |
|----------|----------|----------|-----------------------------------------------------------------------------------------------------------|
| entero   | Sí       | Sí       |                                                                                                           |
| carácter | No       | Sí       | Bandera «Etiquetas numéricas en la selección múltiple»                                                    |
| cadena   | No       | Sí       | Ídem                                                                                                      |
| lógico   | No       | Sí       | Ídem                                                                                                      |
| real     | **No**   | **No**   | Decisión del lenguaje, no bandera: comparar reales por igualdad es una trampa, no una exigencia relajable |

| Situación                                   | Clase de error                                           |
|---------------------------------------------|----------------------------------------------------------|
| Etiqueta repetida en dos ramas              | Sintáctico, con span relacionado en la primera aparición |
| Una etiqueta que no es literal              | Sintáctico                                               |
| Rama por defecto repetida o no última       | Sintáctico                                               |
| Falta el separador de rama                  | Sintáctico                                               |
| Etiqueta de tipo real                       | Semántico, en las dos políticas                          |
| Etiqueta no entera bajo perfil estricto     | Semántico                                                |
| Tipo del selector distinto del de etiquetas | Semántico                                                |
| Ninguna rama, con o sin rama por defecto    | **No es error**                                          |
| Ninguna rama coincide y no hay defecto      | **No es error.** No se ejecuta nada                      |

Ejemplo válido — `Segun dia Hacer` / `1, 7: Escribir "Fin de semana"` / `De Otro Modo: Escribir "Laborable"` /
`FinSegun`.
Ejemplo inválido — la misma selección con `1, 7:` en una rama y `7:` en otra: etiqueta repetida.

> **Adición al inventario de tokens.** El separador de rama —dos puntos en el perfil de referencia—
> **no estaba en el inventario cerrado en la sección 2.4**, que no tiene ningún token de dos puntos.
> Las tres fuentes consultadas lo usan sin excepción, así que la adición es forzada y unánime.
> Es la única entrada que esta sección añade al inventario.

### 8.3 Bucle condicional anterior

```
<mientras> <expresión> <hacer>
    <cuerpo>
<fin de mientras>
```

La condición se evalúa **antes** de cada iteración, incluida la primera. El cuerpo se ejecuta **cero
o más veces**. Un bucle cuya condición es falsa desde el principio no ejecuta nada y no es error.

Ejemplo válido — `Mientras i < 10 Hacer` / `i <- i + 1` / `FinMientras`.
Ejemplo inválido — el mismo sin `Hacer`: falta la palabra intermedia (sintáctico).

### 8.4 Bucle condicional posterior

```
<repetir>
    <cuerpo>
<hasta que> <expresión>
```

La condición se evalúa **después** de cada iteración. El cuerpo se ejecuta **una o más veces**. El
bucle **termina cuando la condición se hace verdadera**: es una condición de salida, no de
permanencia.

**No lleva token de cierre propio.** La palabra que introduce la condición cierra el bloque, y eso es
coherente con el inventario, que no tiene ninguna de fin de repetición.

**Equivalencia normativa:** `<repetir> S <hasta que> C` equivale a `S` seguido de
`<mientras> <negación> C <hacer> S <fin de mientras>`.

**Solo hay una construcción posterior.** Se rechaza añadir una segunda con condición de permanencia
—la forma que usan dos de las tres fuentes consultadas— porque sería la misma construcción con la
condición negada, duplicando nodo de árbol, parser, evaluador y tests sin enseñar nada nuevo. Los
programas de referencia escritos con la otra forma se traducen negando la condición.

| Situación                              | Resultado o clase de error                      |
|----------------------------------------|-------------------------------------------------|
| Cuerpo vacío                           | Válido: la condición se evalúa una vez          |
| Falta la palabra de condición al final | Sintáctico, con span relacionado en la apertura |
| Condición verdadera desde la primera   | Válido: exactamente una iteración               |

Ejemplo válido — `Repetir` / `Leer opcion` / `Hasta Que opcion = 0`.
Ejemplo inválido — `Repetir` / `Leer opcion` / `FinProceso`: el bucle nunca se cierra.

### 8.5 Bucle contado

```
<para> <identificador> <asignación> <expresión> <hasta> <expresión>
       [<con paso> <expresión>] <hacer>
    <cuerpo>
<fin de para>
```

La variable de control es un **identificador**, no un designador cualquiera: un elemento de arreglo
como variable de control no tiene lectura pedagógica y complica el diagnóstico sin comprar nada.

**Semántica, paso a paso.** Cada punto es observable y ninguno estaba resuelto en las fuentes:

1. Se evalúan, **exactamente una vez y en este orden**, el valor inicial, el valor final y el paso.
   Omitido el paso, vale **uno**.
2. Si el paso es **cero**, se emite un diagnóstico **de ejecución** y el bucle no se ejecuta.
3. Se asigna el valor inicial a la variable de control.
4. **La prueba va antes del cuerpo.** Con paso positivo se itera mientras la variable sea menor o
   igual que el valor final; con paso negativo, mientras sea mayor o igual. **La dirección la decide
   el signo del paso**, nunca la relación entre el valor inicial y el final.
5. Se ejecuta el cuerpo.
6. Se suma el paso a la variable de control y se vuelve al punto 4.
7. Al salir, **la variable de control conserva el primer valor que falló la prueba**.

De esas siete, tres son decisiones que hay que poder defender:

**Los tres valores se congelan.** Modificar dentro del cuerpo la variable que se usó como valor final
no cambia el bucle. Es el modelo de Pascal y Ada, y el único que una tabla de prueba de escritorio
puede explicar sin trampas.

**El paso omitido vale uno, siempre.** Se rechaza inferir la dirección de la relación entre el valor
inicial y el final, que es lo que hace una de las fuentes consultadas y lo que ofrece como opción la
herramienta de referencia. Con inferencia, un bucle escrito con variables recorre hacia delante o
hacia atrás **según los valores de ejecución**: el mismo texto calcula cosas distintas según la
entrada. Es exactamente el fallo silencioso que la prueba del eje de 2.1 existe para impedir.

**La variable de control conserva un valor definido al salir.** Se rechaza dejarlo indefinido, que es
justo lo que la tabla de prueba de escritorio no puede mostrar; y no puede «dejar de existir», porque
sin ámbitos de bloque es una variable normal del programa.

| Situación                                       | Resultado o clase de error                                         |
|-------------------------------------------------|--------------------------------------------------------------------|
| Falta la cláusula de paso bajo «Paso explícito» | Sintáctico                                                         |
| Paso cero                                       | De ejecución                                                       |
| Valor inicial mayor que el final, paso positivo | **No es error**: cero iteraciones, la variable queda en el inicial |
| Se modifica la variable de control en el cuerpo | **Advertencia** semántica, en las dos políticas                    |
| Variable de control no entera                   | Semántico                                                          |
| Variable de control no declarada                | Semántico, solo bajo «Declaración obligatoria»                     |

Prohibir la modificación de la variable de control exigiría demostrar que no ocurre, y con el paso
por referencia de la fase procedimental eso es indecidible en general. Una advertencia es honesta;
un error que a veces no se detecta, no.

Ejemplo válido — `Para i <- 10 Hasta 0 Con Paso -2 Hacer` / `Escribir i` / `FinPara`.
Ejemplo inválido — `Para i <- 10 Hasta 0 Hacer` / `Escribir i` / `FinPara` bajo perfil estricto:
falta el paso explícito. Bajo perfil flexible es válido y **no itera ninguna vez**, porque el paso
omitido vale uno.

## 9. Arreglos

### 9.1 Dimensionamiento

```
<declaración de dimensión> <dimensionado> {<separador de lista> <dimensionado>}
                           <conector de tipo> <tipo>

<dimensionado> ::= <identificador> <abre índice> <lista de expresiones> <cierra índice>
```

**Una sola sentencia declara el arreglo entero**: su nombre, sus dimensiones y el tipo de sus
elementos. Se rechaza el par de sentencias separadas de la herramienta de referencia —una para
dimensionar y otra para tipar— y se registra por qué: crea cuatro clases de error de emparejamiento
que con una sola sentencia no existen —dimensionado sin tipar, tipado sin dimensionar, dimensionado
dos veces, y las dos sentencias en orden invertido— a cambio de ninguna ventaja. La forma elegida no
añade ningún token al inventario: reutiliza los de dimensión y de conector de tipo.

`<tipo>` admite un identificador de clase (11.8): los elementos de un arreglo de clase empiezan **sin
instanciar**, con la misma semántica que una variable de clase declarada y no asignada.

Varios arreglos en una sentencia comparten el tipo de elemento, igual que varias variables en una
declaración.

**Base del índice: cero.** Un arreglo declarado con N elementos admite los índices de 0 a N−1. Es una
decisión del lenguaje y no un dato del perfil, tal como fija 2.2. El criterio que la decide es el de
desempate declarado del proyecto —la forma que prepara mejor para el lenguaje real—: los lenguajes a
los que el estudiante saltará después indexan desde cero. Se rechaza la base uno de la notación
académica consultada.

**Expresión de tamaño.** Sintácticamente es siempre una expresión. Bajo la bandera «Dimensión
constante de arreglo» tiene que ser una **expresión constante**, y lo comprueba el chequeador.

> **Expresión constante**, definida aquí porque ninguna otra sección la necesitaba: un literal, o un
> operador aplicado a expresiones constantes. **No incluye identificadores**, porque el lenguaje no
> tiene construcción de constantes con nombre —exclusión deliberada, ver la sección de alcance del
> paquete.

**Un arreglo no es un valor.** No se puede asignar entero, ni comparar, ni pasar a la salida, ni
devolver. Solo se accede a sus elementos. Declararlo aquí impide que el parser lo acepte por
accidente y permite un diagnóstico específico en vez de uno de tipos confuso.

| Situación                                | Resultado o clase de error                                                    |
|------------------------------------------|-------------------------------------------------------------------------------|
| Cero dimensiones (`a[]`)                 | Sintáctico                                                                    |
| Tamaño cero                              | **Válido.** No admite ningún índice; recorrerlo con un bucle contado no itera |
| Tamaño negativo                          | De ejecución                                                                  |
| Tamaño no entero                         | Semántico                                                                     |
| Tamaño no constante bajo perfil estricto | Semántico                                                                     |
| Dimensionar dos veces el mismo nombre    | Semántico, es una declaración duplicada                                       |
| Usar como valor un arreglo completo      | Semántico, con código propio                                                  |

Ejemplo válido — `Dimension notas[10], nombres[3, 4] Como Real`.
Ejemplo inválido — `Dimension notas[] Como Real`: no declara ninguna dimensión.

### 9.2 Acceso a un elemento

```
<designador> <abre índice> <lista de expresiones> <cierra índice>
```

**Un solo par de corchetes con separador de lista** para cualquier número de dimensiones: `a[i, j]`,
nunca `a[i][j]`. Es coherente con la forma del dimensionamiento y convierte «el número de índices
coincide con las dimensiones declaradas» en una regla única y comprobable en un solo sitio. La forma
encadenada tiene diagnóstico propio, porque es lo que un estudiante que viene de otro lenguaje va a
escribir.

Los índices se evalúan de izquierda a derecha, una sola vez cada uno.

| Situación                                     | Clase de error                                     |
|-----------------------------------------------|----------------------------------------------------|
| Lista de índices vacía                        | Sintáctico                                         |
| Forma encadenada `a[i][j]`                    | Sintáctico, con código propio y pedagógico         |
| Número de índices distinto de las dimensiones | Semántico                                          |
| Índice no entero                              | Semántico, sección 12                              |
| Índice fuera de rango, por arriba o por abajo | De ejecución, con el span del índice culpable      |
| Acceso a un arreglo de tamaño cero            | De ejecución: cualquier índice está fuera de rango |

Ejemplo válido — `notas[0] <- notas[n - 1]`.
Ejemplo inválido — `notas[0][1] <- 5`: la forma encadenada no existe.

## 10. Subprocesos y funciones

**Una sola construcción, dos papeles.** Un subprograma que declara tipo de retorno devuelve un valor
y se llama dentro de una expresión; uno que no lo declara no devuelve nada y se llama como sentencia.
No hay dos palabras clave ni dos gramáticas: hay una cláusula opcional.

De las cuatro fuentes consultadas, tres separan procedimiento y función en dos construcciones
—cabecera distinta, palabra de cierre distinta— y una las trata como sinónimos con retorno opcional.
Se adopta la minoritaria por el criterio de desempate del proyecto: los lenguajes a los que el
estudiante saltará después —C, Java, Python, Dart, JavaScript— tienen **una** construcción cuyo tipo
de retorno puede ser vacío. La separación en dos existe en Pascal y Ada, que no son el destino
probable. Además, la distinción que de verdad importa —si una llamada es una sentencia o una
expresión— **no es sintáctica en ningún lenguaje real**: depende de si hay valor devuelto, y por eso
aquí se comprueba en la fase semántica y no en el parser.

**Consecuencia para el inventario de tokens:** esta forma añade **un** token, el de retorno. Los
cuatro tokens del grupo de subprogramas ya inventariados bastan para todo lo demás: el tipo de
retorno y el tipo de un parámetro reutilizan el conector de tipo y los tokens de tipo primitivo, y la
lista de parámetros reutiliza los delimitadores que ya existen.

### 10.1 Estructura del texto de origen

La sección 6.1 dejó esta pregunta abierta explícitamente. Queda cerrada así:

Un texto de origen contiene **exactamente un algoritmo y cero o más subprogramas y clases**, en
cualquier orden, todos al nivel superior. Un subprograma o una clase **no puede declararse dentro de
otro ni dentro del cuerpo del algoritmo**: los subprogramas, las clases y el algoritmo son hermanos
entre sí (11.1).

- **Cualquier orden**, porque la resolución de nombres recoge los subprogramas en una pasada previa (ver 10.7). Exigir
  que la declaración preceda al uso obligaría a reordenar el texto para escribir
  dos subprogramas que se llaman entre sí, que es justo el caso de la recursión mutua.
- **Sin anidamiento**, porque un subprograma dentro de otro solo tiene sentido con ámbitos anidados,
  y el lenguaje no los tiene: la sección 6.1 fijó que no hay ámbitos de bloque. Una de las fuentes
  consultadas admite la declaración local de subprogramas y señala en la misma página que el lenguaje
  real más cercano no la admite; esa es la razón de rechazarla.

Fuera del algoritmo y de los subprogramas no puede aparecer nada salvo espacios en blanco y
comentarios. Esto sustituye a la reserva que la sección 6.1 dejó anotada.

| Situación                                             | Clase de error                                   |
|-------------------------------------------------------|--------------------------------------------------|
| Ningún algoritmo, solo subprogramas                   | Sintáctico: se esperaba el inicio del algoritmo  |
| Dos algoritmos                                        | Sintáctico                                       |
| Subprograma declarado dentro del cuerpo de otro       | Sintáctico, con código propio                    |
| Subprograma declarado dentro del cuerpo del algoritmo | Sintáctico, con código propio                    |
| Subprograma antes del algoritmo                       | **No es error**                                  |
| Un texto con un algoritmo y ningún subprograma        | **No es error.** Es todo el alcance de la fase 7 |

### 10.2 Declaración

```
<inicio de subproceso> <identificador>
        <abre paréntesis> [<lista de parámetros>] <cierra paréntesis>
        [<conector de tipo> <tipo>]
    <cuerpo>
<fin de subproceso>
```

- **Los paréntesis son obligatorios**, también sin parámetros, y también en la llamada. No son
  decoración: son lo que permite distinguir una llamada de una referencia a variable sin mirar la
  tabla de símbolos, y por tanto lo que permite que los nombres de subprograma vivan en su propio
  espacio de nombres (ver 10.6). La herramienta de referencia los hace opcionales; se rechaza esa
  variante, porque con ella `asteriscos` es indistinguible de leer una variable llamada `asteriscos`
  hasta que la fase semántica lo resuelve, y el diagnóstico de un nombre mal escrito deja de poder
  decir si sobra o falta algo.
- **La cláusula de tipo de retorno es opcional.** Presente, el subprograma devuelve un valor de ese
  tipo. Ausente, no devuelve nada. Se escribe con el conector de tipo, exactamente igual que en una
  declaración de variable, para que la misma palabra signifique siempre lo mismo.
- **El tipo de retorno es uno de los cinco tipos primitivos, o una clase (11.8).** No se puede
  devolver un arreglo, porque la sección 9.1 fija que un arreglo no es un valor; un objeto sí lo es.
- El cuerpo es una lista de sentencias que puede estar vacía, como el de cualquier bloque.
- El nombre sigue las reglas de identificador de la sección 3.

| Situación                                   | Clase de error                                          |
|---------------------------------------------|---------------------------------------------------------|
| Falta el nombre                             | Sintáctico                                              |
| Faltan los paréntesis                       | Sintáctico, con código propio: los paréntesis no sobran |
| Falta el tipo tras el conector de tipo      | Sintáctico                                              |
| Tipo de retorno que nombra un arreglo       | Sintáctico                                              |
| Subprograma sin cerrar al final del archivo | Sintáctico, con span relacionado en su apertura         |
| Cuerpo vacío                                | **No es error**                                         |
| Dos subprogramas con el mismo nombre        | Semántico, es una declaración duplicada                 |
| Nombre de un solo carácter                  | **No es error**                                         |

Ejemplo válido — `SubProceso Saludar()` / `Escribir "Hola"` / `FinSubProceso`.
Ejemplo inválido — `SubProceso Saludar` / `FinSubProceso`: faltan los paréntesis.

### 10.3 Parámetros

```
<lista de parámetros> ::= <parámetro> {<separador de lista> <parámetro>}

<parámetro> ::= <identificador> [<abre índice> {<separador de lista>} <cierra índice>]
                [<conector de tipo> <tipo>]
                [<paso por valor> | <paso por referencia>]
```

- **El tipo de un parámetro es opcional en la gramática**, y la bandera de rigor «Declaración
  obligatoria» lo hace exigible. No se crea una bandera nueva: un parámetro es la variable de entrada
  del subprograma, y la bandera que ya obliga a declarar toda variable antes de su primer uso lo
  alcanza sin ampliar el catálogo. Bajo perfil flexible, el tipo se infiere como el de cualquier otra
  variable, según lo que fija la sección 12.
- **Los corchetes marcan un parámetro de arreglo**, y el número de dimensiones es el número de
  separadores más uno: `notas[]` es de una dimensión, `matriz[,]` de dos, `cubo[,,]` de tres. Los
  tamaños no aparecen: el arreglo ya existe cuando llega, y el subprograma no lo dimensiona.

  **Esta forma no es una invención sin respaldo: es la única compatible con una decisión ya
  tomada.** Ninguna de las cuatro fuentes declara el número de dimensiones de un parámetro de arreglo
  sin declarar también sus tamaños, así que no hay una forma que adoptar tal cual — pero sí hay una
  forma que rechazar, y eso basta para fijar esta. La sección 9.2 ya decidió **un solo par de
  corchetes con separador de lista** para cualquier número de dimensiones, y rechazó explícitamente
  el corchete encadenado `a[i][j]` con diagnóstico propio, precisamente para que «el número de
  índices coincide con las dimensiones declaradas» fuera una regla única y comprobable en un solo
  sitio. Declarar un parámetro multidimensional con corchetes encadenados —`matriz[][]`, la forma de
  Java y de C— reintroduciría exactamente la ambigüedad que 9.2 cerró, y en el único lugar del
  lenguaje que además necesita la cuenta de dimensiones sin conocer los tamaños. Un solo par de
  corchetes con tantos separadores como dimensiones haya menos una es, por tanto, la única extensión
  de la sintaxis ya elegida que no contradice una decisión previa. No se declara el número de
  dimensiones deduciéndolo del argumento en la llamada, porque la regla de
  9.2 —«el número de índices coincide con las dimensiones declaradas»— tiene que ser comprobable **dentro** del cuerpo
  del subprograma, sin mirar quién lo llama.
- **La marca de paso va en sufijo**, después del tipo, igual que el modificador sin salto de la
  sección 7.1 va después de la lista. Ausente, el paso es **por valor**. Las cuatro fuentes coinciden
  en ese valor por omisión.
- **La marca es por parámetro y no se arrastra.** Una de las fuentes admite escribirla una vez y
  aplicarla a todos los parámetros siguientes del mismo grupo; se rechaza expresamente. Bajo esa
  regla, en una lista de dos parámetros donde solo el primero lleva la marca, el segundo se pasa por
  referencia mientras que quien lo lee ve un parámetro sin marcar y supone lo contrario. Es un fallo
  silencioso del tipo que la prueba del eje de 2.1 existe para impedir.
- **La marca por valor es admisible y redundante.** Escribirla no cambia nada; permite ser explícito.

**Los arreglos se pasan siempre por referencia.** No es una excepción caprichosa: se deduce de 9.1.
Pasar por valor es copiar un valor, y un arreglo no es un valor en este lenguaje. Por tanto, marcar
un parámetro de arreglo como por valor es un **error semántico con código propio** —no se ignora en
silencio— y marcarlo por referencia es admisible y redundante. La herramienta de referencia toma la
misma decisión, y también los lenguajes reales a los que el estudiante saltará, donde un arreglo es
siempre una referencia.

| Situación                                          | Clase de error                          |
|----------------------------------------------------|-----------------------------------------|
| Separador de lista sobrante o parámetro sin nombre | Sintáctico                              |
| Marca de paso antes del nombre                     | Sintáctico                              |
| Las dos marcas de paso en el mismo parámetro       | Sintáctico                              |
| Dos parámetros con el mismo nombre                 | Semántico, es una declaración duplicada |
| Parámetro de arreglo marcado por valor             | Semántico, con código propio            |
| Cero parámetros                                    | **No es error**                         |
| Parámetro sin tipo bajo «Declaración obligatoria»  | Semántico                               |

Ejemplo válido — `SubProceso Promediar(notas[] Como Real, cuantas Como Entero) Como Real`.
Ejemplo inválido — `SubProceso Ordenar(datos[] Como Entero Por Valor)`: un arreglo no se copia.

### 10.4 Paso por referencia: qué es un argumento válido

**Un argumento que corresponde a un parámetro por referencia tiene que ser un designador**, en el
sentido exacto de la sección 6.4. No hace falta un concepto nuevo: un parámetro por referencia
necesita un sitio donde guardar un valor, y designador es precisamente el nombre de eso. Cualquier
otra cosa —un literal, una expresión, la llamada a otro subprograma, un paréntesis— es un **error
semántico con código propio**, no un error de sintaxis: la llamada está bien formada y lo que falla
es a qué se aplica.

**Un elemento de arreglo sí es un argumento válido por referencia**, y su índice **se evalúa una sola
vez, en el momento de la llamada**. La posición queda fijada ahí para toda la ejecución del
subprograma. Modificar dentro del subprograma la variable que se usó como índice no cambia sobre qué
elemento se escribe. Es la misma decisión que la sección 8.5 tomó para los tres valores del bucle
contado y por la misma razón: es el único comportamiento que una tabla de prueba de escritorio puede
mostrar sin trampas.

**Un arreglo completo como argumento** solo es válido donde el parámetro es de arreglo, y solo se
escribe su nombre, sin corchetes. Es la única posición del lenguaje donde el nombre de un arreglo
aparece sin índices; en cualquier otra sigue valiendo la prohibición de 9.1.

**Pasar la misma variable a dos parámetros por referencia está permitido** y produce lo que produce:
los dos parámetros nombran la misma casilla. No se diagnostica. El proyecto enseña el aliasing en vez
de ocultarlo, y este es el caso más simple en el que aparece.

| Situación                                                   | Clase de error                          |
|-------------------------------------------------------------|-----------------------------------------|
| Literal o expresión como argumento por referencia           | Semántico, con código propio            |
| Llamada a subprograma como argumento por referencia         | Semántico, con código propio            |
| Elemento de arreglo como argumento por referencia           | **No es error**                         |
| Índice fuera de rango en un argumento por referencia        | De ejecución, antes de entrar al cuerpo |
| Nombre de arreglo donde el parámetro no es de arreglo       | Semántico                               |
| Arreglo con distinto número de dimensiones que el parámetro | Semántico                               |

Ejemplo válido — `Intercambiar(notas[i], notas[j])`.
Ejemplo inválido — `Intercambiar(3, notas[j])`: un literal no tiene dónde guardar nada.

### 10.5 Retorno

```
<retorno> [<expresión>]
```

**El retorno es una sentencia, no una variable declarada en la cabecera.** La herramienta de
referencia usa la segunda forma —un nombre a la izquierda de una flecha en la cabecera, que el cuerpo
asigna—, y se rechaza por el criterio de desempate: ningún lenguaje al que el estudiante vaya a
saltar la tiene, y la que sí tienen todos es la sentencia de retorno. Las otras tres fuentes
consultadas también usan la sentencia.

El coste se asume y se registra: la forma de la cabecera no necesitaba salto de control y esta sí. El
evaluador lo paga con un estado explícito de «retornando» en su máquina, no con una excepción del
lenguaje anfitrión. Esa restricción es normativa: **el retorno nunca se implementa como una excepción
que atraviese el intérprete.**

- **Puede aparecer varias veces**, en cualquier punto del cuerpo, incluidos el interior de un
  condicional, de una selección múltiple y de cualquiera de los tres bucles. Se rechaza la regla de
  salida única: es una convención de estilo, no del lenguaje, y ningún lenguaje real la impone.
- **Al ejecutarse, el subprograma termina inmediatamente.** Lo que quede de cuerpo no se ejecuta, y
  los bucles y bloques abiertos se abandonan.
- **Con expresión** en un subprograma con tipo de retorno declarado; **sin expresión** en uno sin
  tipo, donde sirve de salida anticipada. Las combinaciones cruzadas son errores semánticos con
  código propio cada una.
- **La expresión no puede ser un arreglo** (9.1).

**Quién comprueba que todos los caminos retornan.** En dos niveles, y la partición es deliberada:

1. Un subprograma con tipo de retorno declarado **cuyo cuerpo no contiene ninguna sentencia de
   retorno** es un **error semántico**. Comprobarlo es un recorrido del cuerpo y no necesita análisis
   de flujo, así que se hace y se hace pronto.
2. Cualquier otro caso —hay retornos, pero un camino de ejecución llega al final sin pasar por
   ninguno— es un **diagnóstico de ejecución**, emitido cuando el control alcanza el cierre del
   subprograma, con el span del token de cierre y un span relacionado en la cabecera.

Se rechaza el análisis conservador de caminos que hacen Java o Dart. Exigiría un grafo de flujo de
control que ninguna fase aprobada construye, y **rechazaría programas correctos**: un bucle cuya
condición es siempre verdadera y que retorna desde dentro es válido y ese análisis no lo ve sin
razonar además sobre constantes. Un diagnóstico de ejecución preciso, sin falsos positivos y con
span exacto enseña más que un error estático que a veces se equivoca.

**Un retorno fuera de un subprograma —en el cuerpo del algoritmo— es un error sintáctico con código
propio.** Es la misma decisión, y por la misma razón, que la sección 6.4 tomó con el destino no
designador: la sentencia está bien formada, pero reconocerla y rechazarla en el parser permite
subrayar exactamente la palabra sobrante y decir qué le falta al programa, mientras que dejarla pasar
a la fase semántica produce un mensaje más lejos del sitio.

| Situación                                                | Clase de error                                    |
|----------------------------------------------------------|---------------------------------------------------|
| Retorno en el cuerpo del algoritmo                       | Sintáctico, con código propio                     |
| Retorno con expresión sin tipo de retorno declarado      | Semántico, con código propio                      |
| Retorno sin expresión con tipo de retorno declarado      | Semántico, con código propio                      |
| Tipo de la expresión distinto del declarado              | Semántico, sección 12                             |
| Ningún retorno en un subprograma con tipo declarado      | Semántico, con código propio                      |
| Un camino llega al cierre sin retornar                   | De ejecución, con span relacionado en la cabecera |
| Varios retornos, o retorno dentro de un bucle            | **No es error**                                   |
| Retorno como última sentencia de un subprograma sin tipo | **No es error**, es redundante y válido           |

Ejemplo válido — `SubProceso Maximo(a Como Entero, b Como Entero) Como Entero` /
`Si a > b Entonces` / `Retornar a` / `SiNo` / `Retornar b` / `FinSi` / `FinSubProceso`.
Ejemplo inválido — `Retornar 3` en el cuerpo del algoritmo: no hay nada de lo que retornar.

### 10.6 Llamada

```
<llamada> ::= <identificador> <abre paréntesis> [<lista de expresiones>] <cierra paréntesis>
```

Una misma forma, dos posiciones: **como sentencia** y **como expresión**. Cuál es válida la decide si
el subprograma llamado declara tipo de retorno, y por tanto es una comprobación **semántica**, no
sintáctica. El parser produce el mismo nodo en los dos sitios.

- **Llamar como expresión a un subprograma sin tipo de retorno** es un **error semántico con código
  propio**. No hay valor que colocar en la expresión.
- **Llamar como sentencia a un subprograma con tipo de retorno** es válido y produce una **advertencia** con código
  propio: el valor se descarta. Es legal en todo lenguaje de la familia C
  y es un error real de principiante, así que se avisa sin invalidar. Su severidad la fija la tabla
  de política de la sección 12, donde es de clase «higiene»: advertencia en las dos políticas.
- **No hay palabra clave de llamada.** Una de las fuentes exige escribirla delante de toda llamada a
  procedimiento; se rechaza porque haría falta un token nuevo para desambiguar algo que los
  paréntesis obligatorios ya desambiguan, y porque ningún lenguaje real la tiene.
- **Los argumentos se evalúan de izquierda a derecha, una sola vez cada uno, antes de entrar en el
  cuerpo.** Para un argumento por valor se evalúa su valor; para uno por referencia se evalúa su
  designador —es decir, sus índices— y se fija la posición.
- **El número de argumentos coincide con el de parámetros.** No hay parámetros opcionales ni valores
  por omisión. Una discrepancia es un error **semántico** con código propio, que nombra cuántos se
  esperaban y cuántos hay.
- **Olvidar los paréntesis tiene diagnóstico propio**, y puede tenerlo porque 10.7 impide que una
  variable y un subprograma compartan nombre: un identificador suelto que resulta ser el nombre de un
  subprograma solo puede ser una llamada mal escrita, nunca la lectura de una variable. Es el caso
  que un estudiante que viene de la herramienta de referencia, donde los paréntesis son opcionales, va
  a escribir.

| Situación                                           | Clase de error                                                                       |
|-----------------------------------------------------|--------------------------------------------------------------------------------------|
| Paréntesis sin cerrar en la llamada                 | Sintáctico                                                                           |
| Separador de lista sobrante                         | Sintáctico                                                                           |
| Llamada sin paréntesis, como sentencia              | Sintáctico: un identificador solo no es una sentencia                                |
| Llamada sin paréntesis, dentro de una expresión     | Semántico, con código propio: el nombre es de un subprograma y faltan los paréntesis |
| Nombre que no corresponde a ningún subprograma      | Semántico                                                                            |
| Número de argumentos distinto del de parámetros     | Semántico, con código propio                                                         |
| Llamada como expresión a un subprograma sin retorno | Semántico, con código propio                                                         |
| Llamada como sentencia a un subprograma con retorno | **Advertencia** semántica                                                            |
| Cero argumentos con paréntesis vacíos               | **No es error**                                                                      |

Ejemplo válido — `Escribir "Máximo: ", Maximo(a, b)`.
Ejemplo inválido — `total <- Saludar()`: un subprograma sin tipo de retorno no vale como expresión.

### 10.7 Ámbito y espacios de nombres

**No hay variables globales.** Cada subprograma tiene su propio ámbito, y las variables del algoritmo **no son
visibles** dentro de ningún subprograma. Toda comunicación pasa por los parámetros y el
valor de retorno.

Es el punto donde las fuentes se contradicen más y donde la decisión más cambia lo que se enseña. Dos
de las notaciones consultadas hacen globales las declaraciones del algoritmo y visibles desde
cualquier subprograma; la herramienta de referencia no admite variables globales en absoluto; la
cuarta fuente no se pronuncia. Se adopta la ausencia de globales, y las razones son tres:

1. **Un subprograma que lee una variable que no recibió no es reutilizable**, y su corrección depende
   de que quien lo llame haya dejado un valor en un sitio que el subprograma no nombra. Una de las
   fuentes que sí las admite advierte en la misma página de que conviene declarar lo más localmente
   posible: la propia fuente desaconseja lo que su notación permite.
2. **La ejecución paso a paso tiene que poder mostrarse.** Sin globales, el estado visible en cada
   paso es el marco actual, y lo que entra y sale de un subprograma está escrito en la llamada.
3. **Es lo que el estudiante encontrará después.** Ningún lenguaje real hace globales por defecto las
   variables del programa principal.

**Consecuencias normativas:**

- Un nombre declarado en el algoritmo y usado en un subprograma **no** es el mismo nombre. Bajo
  «Declaración obligatoria» es un error semántico de variable no declarada; sin la bandera, es una
  variable local nueva del subprograma. La bandera solo invalida, nunca cambia el resultado de un
  programa que ya era válido, así que se cumple el invariante de 2.5.
- Los parámetros son variables locales del subprograma como cualquier otra, con la única diferencia
  de que reciben valor en la llamada.
- Sigue sin haber ámbitos de bloque (6.1). Hay exactamente un ámbito por algoritmo y uno por
  subprograma.

**Espacio de nombres de subprogramas.** Los nombres de subprograma forman un espacio propio, único
para todo el texto de origen. Como los paréntesis son obligatorios en la llamada, no hay ambigüedad
posible entre una llamada y una lectura de variable, y ese es exactamente el motivo de exigirlos.
Aun así:

- **Un subprograma y una variable no pueden llamarse igual dentro del mismo ámbito.** Es un error
  semántico con código propio. No se prohíbe por necesidad técnica sino porque el programa que lo
  hace no se puede leer, y la herramienta de referencia toma la misma decisión.
- **Un subprograma puede llamarse como el algoritmo.** El nombre del algoritmo no ocupa el espacio de
  nombres del programa, tal como fija 6.1, y esta sección no lo cambia.
- **Un subprograma con el nombre de una función incorporada la oculta** en todo el texto de origen,
  igual que una declaración oculta una función incorporada dentro de su ámbito según 2.3. No se
  diagnostica: es el comportamiento de cualquier lenguaje real.

**Orden de declaración: no lo hay.** Un subprograma puede llamar a otro declarado después, y al
algoritmo le da igual dónde estén. La resolución de nombres hace por tanto **una pasada previa de
recolección** de todas las cabeceras antes de resolver ningún cuerpo, y eso es un requisito de la
sección de tabla de símbolos, no un detalle de implementación.

Se rechaza la sección de declaración adelantada de una de las fuentes —una lista de cabeceras al
principio del algoritmo—, y se rechaza con el mismo argumento con el que 9.1 rechazó partir en dos la
declaración de arreglo: crea clases de error de emparejamiento que sin ella no existen —declarado y
no definido, definido y no declarado, declarado dos veces, firma declarada distinta de la definida— a
cambio de ninguna ventaja, porque la pasada de recolección cuesta lo mismo con o sin ella.

### 10.8 Recursión

**Un subprograma puede llamarse a sí mismo**, directa o indirectamente. La recursión mutua funciona
sin ninguna declaración adicional, porque no hay orden de declaración (10.7).

**Hay un límite de profundidad de llamada, es del lenguaje y vale mil.** Alcanzarlo produce un **diagnóstico de
ejecución** con el span de la llamada que excede el límite y un span relacionado en
la cabecera del subprograma; la ejecución se detiene ahí.

- **No es un dato del perfil.** Por la prueba del eje de 2.1: un programa que recurre novecientas
  veces terminaría bajo un límite y fallaría bajo otro, y eso cambia lo que el programa hace, no si es
  válido. La tercera rama de esa prueba dice que entonces es una decisión del lenguaje.
- **Mil, y no otro número, porque es el que el estudiante encontrará después.** Es el límite por
  omisión del intérprete de Python, que es el lenguaje real más probable como siguiente paso. Ningún
  ejercicio de un curso introductorio —factorial, Fibonacci, torres de Hanói, búsqueda binaria— se
  acerca a esa profundidad, y una recursión sin caso base la alcanza en un instante.
- **La pila de llamadas es una estructura de datos del evaluador, no la pila del lenguaje
  anfitrión.** Esto es normativo y no una nota de implementación: el límite se comprueba contando
  marcos antes de crear el siguiente, de modo que **es imposible que una recursión infinita se
  manifieste como un desbordamiento de la pila de la máquina virtual**. Un fallo esperable es un
  diagnóstico, nunca una excepción que escape.

| Situación                                            | Resultado o clase de error                         |
|------------------------------------------------------|----------------------------------------------------|
| Subprograma que se llama a sí mismo                  | **No es error**                                    |
| Dos subprogramas que se llaman mutuamente            | **No es error**                                    |
| Recursión sin caso base                              | De ejecución, al alcanzar el límite de profundidad |
| Recursión de profundidad novecientos noventa y nueve | **No es error**                                    |

Ejemplo válido — `SubProceso Factorial(n Como Entero) Como Entero` / `Si n <= 1 Entonces` /
`Retornar 1` / `SiNo` / `Retornar n * Factorial(n - 1)` / `FinSi` / `FinSubProceso`.
Ejemplo inválido — el mismo sin el condicional: se agota el límite de profundidad y se diagnostica.

### 10.9 Interacción con lo ya especificado

Puntos que no son decisiones nuevas sino consecuencias de aplicar las secciones anteriores, escritos
porque cada uno es una pregunta que aparecería al implementar:

- **Terminador de sentencia.** Bajo la bandera correspondiente, la llamada como sentencia y el
  retorno lo llevan, porque son sentencias simples; la cabecera y el cierre del subprograma no, porque
  son apertura y cierre de bloque (6.2).
- **Entrada y salida dentro de un subprograma.** Válidas sin restricción. Una lectura dentro de un
  subprograma a cualquier profundidad suspende la máquina paso a paso igual que en el cuerpo del
  algoritmo, con el mismo protocolo de reintento de 7.2.
- **Declaraciones dentro de un subprograma.** Una declaración de variable o de dimensión es una
  sentencia más y puede aparecer en cualquier punto del cuerpo, como en el algoritmo (6.1). Lo
  declarado es local y deja de existir al terminar la llamada.
- **Advertencia de la variable de control.** La sección 8.5 anticipó que el paso por referencia hace
  indecidible en general demostrar que la variable de control de un bucle contado no se modifica.
  Esta sección lo confirma: pasar la variable de control por referencia a un subprograma que la
  modifica es exactamente ese caso, y por eso aquella advertencia es advertencia y no error.
- **Un arreglo sigue sin ser un valor.** No se devuelve, no se asigna, no se compara y no se escribe.
  La única posición nueva que esta sección le da es la de argumento de un parámetro de arreglo.

## 11. Orientación a objetos

**No existe ninguna notación de pseudocódigo orientado a objetos con adopción real y en castellano
adoptable tal cual** —comprobado en la investigación del sprint 10, no supuesto—, pero **sí existe una
convergencia verificable entre dos organismos de certificación independientes**, Cambridge
International 9618 y OCR H446, cuyas notaciones de objetos coinciden en casi todo. Lo que sigue es la
forma castellana de esa convergencia, completada donde ambas fuentes callan y ajustada donde chocan
con secciones ya cerradas de esta especificación. **No añade ningún token al inventario de 2.4**: los
once lexemas de objetos que el sprint 2 dejó como provisionales bastan exactamente.

### 11.1 Declaración de clase

```
<clase> <identificador> [<herencia> <identificador>]
    {<miembro>}
<fin de clase>
```

- **Las clases son hermanas del algoritmo y de los subprogramas**, al nivel superior del texto de
  origen (10.1). No hay clases anidadas, ni una clase dentro de un subprograma o del cuerpo del
  algoritmo, por la misma razón que 10.1 excluyó los subprogramas anidados: solo tendrían sentido con
  ámbitos anidados, y el lenguaje no los tiene. Un subprograma tampoco puede declararse dentro de una
  clase: lo que vive ahí son miembros.
- **El orden de declaración no importa.** La resolución de nombres ya hace una pasada previa de
  recolección de cabeceras (10.7); ahora recoge también las de clase.
- **Herencia simple únicamente.** Varias superclases separadas por coma tienen diagnóstico propio.
- La convención de inicial mayúscula en el nombre de clase **no se exige**: es estilo, no gramática.

| Situación                                                     | Clase de error                                                            |
|---------------------------------------------------------------|---------------------------------------------------------------------------|
| Falta el nombre de la clase                                   | Sintáctico                                                                |
| Clase sin cerrar al final del archivo                         | Sintáctico, con span relacionado en su apertura                           |
| Clase dentro de otra clase, de un subprograma o del algoritmo | Sintáctico, con código propio                                             |
| Subprograma declarado dentro de una clase                     | Sintáctico, con código propio y pedagógico                                |
| Varias superclases separadas por coma                         | Sintáctico, con código propio: la herencia múltiple está fuera de alcance |
| Dos clases con el mismo nombre                                | Semántico, declaración duplicada                                          |
| Clase que hereda de sí misma, o ciclo de herencia             | Semántico, con código propio                                              |
| Herencia de una clase no declarada                            | Semántico                                                                 |
| Clase vacía                                                   | **No es error**                                                           |
| Nombre de un solo carácter                                    | **No es error**                                                           |

Ejemplo válido — `Clase Mascota` / `FinClase`.
Ejemplo inválido — `Clase Gato Hereda De Mascota, Animal`: solo hay herencia simple.

### 11.2 Atributos y visibilidad

```
<miembro> ::= [<visibilidad>] <declaración de atributo>
            | [<visibilidad>] <declaración de método>
            | <declaración de constructor>

<visibilidad> ::= <visibilidad pública> | <visibilidad privada>
```

**Un atributo se declara con la misma sentencia con la que se declara cualquier variable o dimensión**
(6.3, 9.1), no con una sentencia propia. Es una consecuencia, no una elección: escribir una segunda
forma de declarar obligaría a decidir dos veces valor inicial, varios nombres por sentencia y
arreglos, que 6.3 y 9.1 ya decidieron una vez.

```
[<visibilidad>] <declaración> <identificador> {<separador de lista> <identificador>}
                <conector de tipo> <tipo>

[<visibilidad>] <declaración de dimensión> <dimensionado>
                {<separador de lista> <dimensionado>} <conector de tipo> <tipo>
```

- **La visibilidad es un prefijo por miembro y no se arrastra.** Coincide con Cambridge, con OCR y con
  el formato general de Joyanes. Se rechaza la visibilidad por bloques de NASPOO por la misma razón
  que 10.3 rechazó la marca de paso arrastrada: quien lee un miembro sin buscar hacia arriba no puede
  saber su visibilidad.
- **Por omisión, público**, en atributos y en métodos.
- **Privado significa privado a la clase, no a la instancia, y la subclase no lo ve.** No hay un tercer
  nivel de visibilidad. Un método de `Persona` puede leer `otra.edad` siendo `otra` otra `Persona`; un
  método de `Empleado` no puede leer un atributo privado que declaró `Persona`.
- **Quién comprueba el acceso, en dos niveles:** si el tipo estático del receptor se conoce, el acceso
  indebido es un error semántico; si no se conoce (perfil flexible con tipo inferido), es un
  diagnóstico de ejecución en el momento del acceso.

| Situación                                                                      | Clase de error                                            |
|--------------------------------------------------------------------------------|-----------------------------------------------------------|
| Dos modificadores de visibilidad en el mismo miembro                           | Sintáctico                                                |
| Dos miembros con el mismo nombre en la misma clase                             | Semántico, declaración duplicada                          |
| Atributo que redeclara el nombre de un atributo heredado                       | Semántico, con código propio, sea cual sea su visibilidad |
| Acceso a un miembro privado desde fuera de su clase, tipo estático conocido    | Semántico                                                 |
| Acceso a un miembro privado desde fuera de su clase, tipo estático desconocido | De ejecución                                              |
| Clase solo con atributos, o solo con métodos                                   | **No es error**                                           |
| Miembro sin modificador de visibilidad                                         | **No es error.** Es público                               |

### 11.3 Métodos

```
[<visibilidad>] <método> <identificador>
        <abre paréntesis> [<lista de parámetros>] <cierra paréntesis>
        [<conector de tipo> <tipo>]
    <cuerpo>
<fin de método>
```

**Un método es un subprograma con receptor: misma forma que 10.2, con otra palabra de apertura y de
cierre.** Se hereda sin repetirlo todo lo que 10.2, 10.3 y 10.5 ya deciden: paréntesis obligatorios
también sin parámetros; lista de parámetros con dimensiones y marcas de paso; retorno como sentencia,
admisible varias veces, con terminación inmediata; llamarlo como sentencia teniendo retorno produce
advertencia. El tipo de retorno es uno de los cinco primitivos **o una clase** (11.8).

Todos los métodos son de instancia: no hay métodos estáticos, fuera de alcance del paquete.

| Situación                                             | Clase de error                                  |
|-------------------------------------------------------|-------------------------------------------------|
| Método sin cerrar                                     | Sintáctico, con span relacionado en su apertura |
| Método declarado fuera de una clase                   | Sintáctico, con código propio                   |
| Método con el nombre de un atributo de la misma clase | Semántico, declaración duplicada                |
| Método sin parámetros                                 | **No es error**                                 |
| Cuerpo vacío                                          | **No es error**                                 |

### 11.4 Constructor

```
<método> <constructor> <abre paréntesis> [<lista de parámetros>] <cierra paréntesis>
    <cuerpo>
<fin de método>
```

- **Es un método cuyo nombre es un token reservado.** No admite visibilidad ni tipo de retorno: es
  siempre público y nunca devuelve valor. Escribir cualquiera de las dos cosas es un error sintáctico
  con código propio.
- **Opcional, y como máximo uno.** Sin declarar ninguno, la clase tiene un constructor implícito sin
  parámetros que no asigna nada.
- **Se rechaza nombrar el constructor como la clase** (la forma de Java, C++, C# y de las tres
  notaciones académicas consultadas): obligaría al parser a comparar el nombre del método con el de la
  clase para saber qué está leyendo. Un método declarado con el nombre exacto de su clase produce un **diagnóstico
  pedagógico propio** que explica cómo se declara aquí un constructor.
- **Cadena de construcción.** Antes del cuerpo del constructor de una clase se ejecuta el de su
  superclase. Si la superclase tiene constructor con parámetros, la subclase **debe** invocarlo con
  `Super.Constructor(<argumentos>)` como primera sentencia de su propio constructor; si no lo tiene, o
  lo tiene sin parámetros, la invocación es opcional.

| Situación                                                                | Clase de error                                  |
|--------------------------------------------------------------------------|-------------------------------------------------|
| Constructor con visibilidad, o con tipo de retorno                       | Sintáctico, con código propio cada uno          |
| Dos constructores en la misma clase                                      | Semántico, con código propio: no hay sobrecarga |
| Constructor fuera de una clase                                           | Sintáctico                                      |
| Método con el nombre exacto de su clase                                  | Sintáctico, con código propio y pedagógico      |
| Falta la invocación obligatoria al constructor de la superclase          | Semántico, con código propio                    |
| La invocación al constructor de la superclase no es la primera sentencia | Semántico, con código propio                    |
| Invocar al constructor de la superclase fuera de un constructor          | Sintáctico                                      |
| Clase sin constructor                                                    | **No es error**                                 |
| Retorno sin expresión dentro de un constructor                           | **No es error.** Es salida anticipada           |
| Retorno con expresión dentro de un constructor                           | Semántico, con código propio                    |

### 11.5 Instanciación

```
<instanciación> ::= <instanciación> <identificador>
                    <abre paréntesis> [<lista de expresiones>] <cierra paréntesis>
```

Es una **expresión primaria**, no una sentencia. Coinciden Cambridge, OCR y Joyanes; se rechaza la
creación implícita al declarar, que era la única fuente discrepante.

- **Declarar y crear son dos sentencias porque son dos cosas:** `Definir p Como Persona` declara una
  referencia sin objeto; `p <- Nuevo Persona("Ana", 30)` crea el objeto y hace que la referencia lo
  apunte.
- **El número de argumentos coincide con el del constructor**, con la misma regla de 10.6.
- **No hay valor nulo escribible.** Una variable de clase declarada y no asignada está **sin
  instanciar**; acceder a un miembro suyo es un diagnóstico de ejecución con código propio.

| Situación                                                             | Clase de error                                   |
|-----------------------------------------------------------------------|--------------------------------------------------|
| Instanciación de un nombre que no es una clase                        | Semántico, con código propio                     |
| Número de argumentos distinto del del constructor                     | Semántico                                        |
| Falta el nombre de la clase tras la palabra de instanciación          | Sintáctico                                       |
| Faltan los paréntesis                                                 | Sintáctico, con código propio: no son opcionales |
| Acceso a un miembro de una variable sin instanciar                    | De ejecución, con código propio                  |
| Instanciar una clase declarada después en el texto                    | **No es error**                                  |
| Encadenar acceso sobre el resultado, `Nuevo Persona("Ana").Saludar()` | **No es error**                                  |

### 11.6 Objeto actual y superclase

**`Este` es obligatorio para acceder a cualquier miembro del objeto actual.** Dentro de un método o de
un constructor, un identificador suelto nunca designa un atributo: designa un parámetro o una variable
local. Los atributos se alcanzan exclusivamente con `Este.<miembro>`, y los métodos propios con
`Este.<método>(...)`.

Ni Cambridge ni OCR tienen esta referencia, y sus ejemplos leen los atributos a pelo — funciona solo
mientras ningún parámetro se llama como un atributo. Con `Este` obligatorio no hay regla de sombra que
escribir: los atributos no están en el ámbito del método, están detrás de un acceso a miembro. Gana
además por el criterio de desempate: Python la exige.

**`Super` da acceso a la implementación de la superclase, y solo a eso:**

```
<superclase> <acceso a miembro> <identificador> <abre paréntesis> [<lista de expresiones>] <cierra paréntesis>
<superclase> <acceso a miembro> <constructor> <abre paréntesis> [<lista de expresiones>] <cierra paréntesis>
```

- **Solo puede ser el receptor de una llamada a método o al constructor.** No es una expresión por sí
  solo, no se puede asignar, y **no da acceso a atributos** — se rechaza el `super.atributo` de Alpha
  porque contradice 11.2: si la subclase no ve los privados de su superclase, `Super` no puede ser el
  resquicio por el que los vea.
- **La llamada por `Super` no es dinámica.** Invoca la implementación de la superclase aunque el
  objeto sea de una subclase que la sobrescribe; sin esa garantía, una sobrescritura que llama a
  `Super` sería recursión infinita.

| Situación                                                      | Clase de error                                          |
|----------------------------------------------------------------|---------------------------------------------------------|
| `Este` fuera de un método o de un constructor                  | Sintáctico, con código propio                           |
| `Este` sin miembro detrás                                      | Sintáctico                                              |
| `Super` en una clase sin superclase                            | Semántico, con código propio                            |
| `Super` seguido de algo que no es una llamada                  | Sintáctico, con código propio                           |
| `Super` fuera de un método o de un constructor                 | Sintáctico                                              |
| Identificador suelto en un método que coincide con un atributo | Semántico, con código propio y pedagógico: falta `Este` |

### 11.7 Acceso a miembro, llamada a método y sobrescritura

```
<acceso a miembro> ::= <expresión> <acceso a miembro> <identificador>
<llamada a método> ::= <expresión> <acceso a miembro> <identificador>
                       <abre paréntesis> [<lista de expresiones>] <cierra paréntesis>
```

- **El acceso a miembro es un designador** (6.4): sirve como destino de asignación y de entrada. Una
  llamada a método no es un designador, igual que una llamada a función.
- **Se encadena**, también sobre el resultado de una llamada. El acceso a miembro es un operador
  postfijo del mismo nivel que el índice de arreglo. Esto no reabre 9.2: aquella prohíbe encadenar
  corchetes porque el número de índices debe coincidir con las dimensiones declaradas; encadenar
  puntos no tiene ese problema, porque cada punto se resuelve contra el tipo del resultado del
  anterior.
- **Toda llamada a método es de despacho dinámico**, sobre la clase real del objeto, nunca sobre el
  tipo con el que se declaró la variable.
- **La sobrescritura no lleva marca.** Un método de subclase con el mismo nombre que uno de su
  superclase lo sobrescribe. Sin sobrecarga en el alcance, un método con el mismo nombre y **distinta
  firma** es un error semántico con código propio: no es una segunda versión, es una sobrescritura mal
  escrita. Misma firma significa mismo número de parámetros, mismos tipos, mismas marcas de paso y
  mismo tipo de retorno.
- **Qué métodos existen se comprueba contra el tipo estático cuando se conoce.** Una variable
  declarada `Como Mascota` que apunta a un `Gato` no admite `p.Ronronear()` aunque en ejecución fuese a
  funcionar: es la distinción entre tipo declarado y tipo real, la lección central del polimorfismo.

| Situación                                                     | Clase de error                             |
|---------------------------------------------------------------|--------------------------------------------|
| Acceso a miembro sin nombre de miembro detrás del punto       | Sintáctico                                 |
| Asignar a una llamada a método                                | Sintáctico: el destino no es un designador |
| Miembro inexistente en el tipo estático                       | Semántico, con código propio               |
| Llamada a un método inexistente con tipo estático desconocido | De ejecución, con código propio            |
| Sobrescritura con firma incompatible                          | Semántico, con código propio               |
| Llamar como expresión a un método sin tipo de retorno         | Semántico, el código de 10.6               |
| Sobrescribir un método sin marca alguna                       | **No es error**                            |
| Acceder a un miembro del resultado de una llamada             | **No es error**                            |

### 11.8 Las clases como tipos

Un objeto tiene que poder declararse, pasarse y devolverse. Esta sección extiende cuatro formas ya
cerradas:

```
<tipo> ::= <tipo primitivo> | <identificador de clase>
```

Alcanza a 6.3 (declaración de variables), 9.1 (dimensionamiento: los elementos de un arreglo de clase
empiezan sin instanciar), 10.2 y 11.3 (tipo de retorno) y 10.3 (tipo de parámetro). Un identificador en
posición de tipo que no nombra ninguna clase declarada es un **error semántico**, no sintáctico: el
parser no tiene tabla de símbolos.

**Un objeto es un valor; un arreglo no lo es (9.1).** El valor es la referencia:

| Operación               | Con arreglo            | Con objeto                                                                           |
|-------------------------|------------------------|--------------------------------------------------------------------------------------|
| Asignar completo        | Error semántico        | **Válido.** Se copia la referencia; los dos nombres pasan a designar el mismo objeto |
| Pasar como argumento    | Siempre por referencia | Se copia la referencia (ver más abajo)                                               |
| Devolver                | Error semántico        | **Válido**                                                                           |
| Escribir en la salida   | Error semántico        | Error semántico con código propio: no hay conversión automática a cadena             |
| Comparar con `=` o `<>` | Error semántico        | **Válido: compara identidad**, no contenido                                          |
| Cualquier otro operador | Error semántico        | Error semántico                                                                      |

**Paso de un objeto a un subprograma o método.** Un parámetro de tipo clase **por valor** —la omisión—
copia la referencia: el subprograma puede modificar el objeto a través de ella, pero no puede hacer
que la variable de quien llamó apunte a otro objeto. Un parámetro **por referencia** permite además
reasignarla. Es la semántica de Java, C#, Dart y Python.

### 11.9 Copia

La operación de copia explícita es **copia superficial**: crea un objeto nuevo con los mismos valores
de atributo, y los atributos que son objetos se siguen compartiendo. Es la semántica que el estudiante
encontrará al pasar a un lenguaje real, y deja visible el aliasing anidado en vez de ocultarlo. Se
materializa como **función incorporada** (13), no como token: su nombre se traduce como el de
cualquier otra función incorporada y no consume ningún token del inventario.

### 11.10 Diagnósticos pedagógicos de construcciones fuera de alcance

Fuera de alcance del paquete: herencia múltiple, interfaces, clases abstractas, métodos estáticos,
sobrecarga, genéricos, excepciones, destructores, y el tercer nivel de visibilidad (protegido). Un
subconjunto es detectable con la gramática ya definida —herencia múltiple por el separador de lista
tras la superclase, sobrecarga por declaración duplicada, constructor al estilo de Java por el nombre
de método igual al de la clase, métodos definidos fuera de una clase—.

El resto —`Interfaz`, `Abstracta`, `Estatico`, genéricos, excepciones— no son lexemas reservados y el
lexer los ve como identificadores cualesquiera. Se propone una **tabla del perfil** que asocie formas
escritas de otros lenguajes fuera de alcance con su diagnóstico, consultada solo al construir el
mensaje de un identificador inesperado, nunca en el lexer, para que esas palabras sigan siendo
identificadores válidos para una variable. Es deuda declarada del sprint 11.2, con el precedente del
token de retorno del sprint 8.

### 11.11 Ejemplo

```
Clase Mascota
    Privado Definir nombre Como Cadena

    Metodo Constructor(unNombre Como Cadena)
        Este.nombre <- unNombre
    FinMetodo

    Publico Metodo Nombre() Como Cadena
        Retornar Este.nombre
    FinMetodo

    Publico Metodo Hablar() Como Cadena
        Retornar "..."
    FinMetodo
FinClase

Clase Gato Hereda De Mascota
    Privado Definir raza Como Cadena

    Metodo Constructor(unNombre Como Cadena, unaRaza Como Cadena)
        Super.Constructor(unNombre)
        Este.raza <- unaRaza
    FinMetodo

    Publico Metodo Hablar() Como Cadena
        Retornar Este.Nombre() + " dice miau"
    FinMetodo
FinClase

Proceso Refugio
    Definir mascota Como Mascota
    mascota <- Nuevo Gato("Kitty", "Siames")
    Escribir mascota.Hablar()
FinProceso
```

## 12. Sistema de tipos y política de rigor

Esta sección cierra las remisiones de tipos de las secciones anteriores y define **qué
es exactamente un error de tipos** y **qué cambia entre el perfil estricto y el flexible**.

### 12.1 Las tres relaciones entre tipos

Toda regla de esta sección se apoya en tres relaciones, nombradas para no tener que redescribirlas:

| Relación            | Definición                                                          | Dónde se usa                                       |
|---------------------|---------------------------------------------------------------------|----------------------------------------------------|
| **Identidad**       | Son el mismo tipo primitivo, o la misma clase                       | Comparación de firmas al sobrescribir (11.7)       |
| **Convertibilidad** | Idénticos; o de entero a real; o de una clase a una superclase suya | Asignación, argumento de llamada, valor de retorno |
| **Comparabilidad**  | Uno es convertible al otro                                          | Operadores relacionales                            |

**La convertibilidad es dirigida**, y ahí está toda la decisión. Dos de las fuentes consultadas la
definen simétrica entre entero y real, es decir, admiten asignar un real a un entero truncando en
silencio. Se rechazan las dos: la sección 4 ya fijó que la conversión implícita es solo la que no
pierde información, y la herramienta de referencia coincide con esa decisión al obligar a escribir el
truncamiento a mano.

**Tabla completa de conversiones implícitas.** Tiene una sola fila entre primitivos, y esa es la
afirmación normativa de esta subsección:

| De         | A          | ¿Implícita? | Motivo                                                                                  |
|------------|------------|-------------|-----------------------------------------------------------------------------------------|
| entero     | real       | **Sí**      | No pierde información. Única entre primitivos en todo el lenguaje                       |
| real       | entero     | No          | Pierde la parte decimal. Hay función incorporada de truncamiento y de redondeo          |
| carácter   | cadena     | No          | La sección 4 fijó que son tipos distintos; ningún lenguaje de destino la hace implícita |
| cadena     | carácter   | No          | No está definida: una cadena de longitud distinta de uno no tiene carácter equivalente  |
| lógico     | numérico   | No          | No hay valor de verdad numérico                                                         |
| numérico   | lógico     | No          | Es la regla que hace que un condicional sobre un entero sea un error y no una costumbre |
| cualquiera | cadena     | No          | Es la conversión automática al concatenar de Java y JavaScript. Ver 12.3                |
| subclase   | superclase | **Sí**      | Es lo que hace posible el polimorfismo (12.9)                                           |
| superclase | subclase   | No          | No hay operador de conversión descendente, y añadirlo exigiría un token                 |

**El lenguaje es fuertemente tipado y no abre ninguna excepción.** Las tres que las fuentes ofrecían
—truncamiento en la asignación, verdad de un número y conversión automática a texto— se rechazan con
el mismo argumento: cada una convierte un error del estudiante en un programa que se ejecuta y da un
resultado equivocado.

### 12.2 Rango de los tipos numéricos y desbordamiento

La sección 4 describe los cinco tipos pero no acota los dos numéricos. Queda fijado aquí, porque sin
rango no hay ni evaluador ni test de bordes:

- **`entero` es de 64 bits con signo**, de −9 223 372 036 854 775 808 a 9 223 372 036 854 775 807.
- **`real` es de doble precisión, IEEE 754 binario de 64 bits.**
- **El desbordamiento de `entero` es un diagnóstico de ejecución con código propio**, nunca un giro
  silencioso al negativo. Se rechaza el desbordamiento por envolvente de C y de Java: convertir un
  número grande en uno negativo sin avisar es el error más difícil de explicar que un lenguaje puede
  producir, y la máquina paso a paso puede señalar la operación culpable. Se rechaza también la
  precisión arbitraria de Python, que ocultaría un límite que el estudiante va a encontrar.
- **Producir un valor no finito con `real`** —infinito o no numérico— es igualmente un **diagnóstico de
  ejecución con código propio**. Un infinito propagándose por una tabla de prueba de escritorio no
  enseña nada.

> **Restricción normativa sobre la representación.** El rango de `entero` es **el mismo en los tres
> objetivos de compilación**. El evaluador no puede representarlo con el entero nativo del lenguaje
> anfitrión si ese entero cambia de rango entre objetivos. No es una nota de implementación: un mismo
> programa que diera resultados distintos en el visor web y en la aplicación de escritorio rompería el
> determinismo que el producto declara en el camino crítico.

### 12.3 El tipo de cada operador

`E` es entero, `R` real, `L` lógico, `C` carácter, `S` cadena.

| Operador                      | Operandos admitidos               | Tipo del resultado                       |
|-------------------------------|-----------------------------------|------------------------------------------|
| `+` `-` unarios               | numérico                          | el del operando                          |
| `+` `-` `*` binarios          | `E`,`E`                           | `E`                                      |
|                               | par numérico con al menos un `R`  | `R`                                      |
| `+` como concatenación        | al menos un `S`; o `C`,`C`        | `S`                                      |
| `/`                           | cualquier par numérico            | **`R` siempre**, aunque los dos sean `E` |
| `div` `mod`                   | `E`,`E` **únicamente**            | `E`                                      |
| `^`                           | `E`,`E`                           | `E`                                      |
|                               | par numérico con al menos un `R`  | `R`                                      |
| `<` `<=` `>` `>=`             | dos numéricos; `C`,`C`; o `S`,`S` | `L`                                      |
| `=` `<>`                      | dos tipos comparables (12.1)      | `L`                                      |
| `NO` unario, `Y` `O` binarios | `L` únicamente                    | `L`                                      |

**Cinco reglas de esta tabla llevan decisión y se justifican:**

**La división de dos enteros da un real.** `5 / 2` vale `2.5`. Es la única regla de toda la sección en
que dos fuentes se pronuncian explícitamente y coinciden, y los dos lenguajes de destino más probables
hacen lo mismo teniendo, como nosotros, un operador aparte para la división entera. Se rechaza la
alternativa de C y Java —división entera con la misma barra— porque convierte el promedio
`media <- suma / n` en un truncamiento invisible y porque dejaría a `div` sin ninguna función.

**`div` y `mod` solo aceptan enteros.** No se admite dividir enteramente dos reales. Truncar los
operandos y seguir reintroduciría por la puerta de atrás la conversión que 12.1 rechaza. El
diagnóstico nombra la función de truncamiento, para que la corrección esté en el mensaje.

**`div` y `mod` truncan hacia cero, y `mod` toma el signo del dividendo.** Con enteros negativos,
dividir −7 entre 2 da −3 y su resto es −1. Ninguna fuente consultada tiene un solo ejemplo con
operandos negativos, así que decide el criterio de desempate: seis de los lenguajes de destino truncan
hacia cero y solo uno redondea hacia abajo. Además así se cumple la identidad
`(a div b) * b + (a mod b) = a`, que es la que permite explicar los dos operadores como uno solo.

**La potencia conserva el entero, y el exponente negativo es un error de ejecución.** Elevar un entero
a un exponente entero da entero. Un exponente negativo produciría un valor no entero, pero **el tipo
de una expresión no puede depender del valor de un operando en ejecución** —es el mismo argumento con
el que 8.5 rechazó inferir la dirección de un bucle—, así que el tipo se mantiene y el caso se resuelve
con un **diagnóstico de ejecución con código propio**, de la misma familia que la división por cero.

**Concatenar un número con un texto es un error semántico con código propio.** No hay conversión
automática a cadena. El diagnóstico tiene dos salidas que nombrar: la función incorporada de
conversión, y el hecho de que **la salida ya admite una lista de expresiones** (7.1), de modo que
escribir el rótulo y el número como dos elementos de la lista es la forma natural y no necesita
conversión ninguna.

**Dos reglas más, que no son de tipos pero son observables y por tanto normativas:**

- **Los operadores lógicos evalúan en cortocircuito.** Evaluado el primer operando, si ya determina el
  resultado, el segundo no se evalúa. Es lo que hacen todos los lenguajes de destino y lo que permite
  comprobar un índice antes de usarlo en la misma condición.
- **Comparar dos reales por igualdad es válido y produce advertencia.** La sección 8.2 ya prohibió el
  literal real como etiqueta de selección múltiple por ser «una trampa, no una exigencia relajable»; en
  una expresión no se puede prohibir sin rechazar programas correctos, así que se avisa. **No hay orden
  entre lógicos:** comparar dos valores de verdad con menor o mayor es un error semántico, aunque una
  de las fuentes lo admita.

### 12.4 Quién comprueba qué: la regla de los dos niveles

> Una comprobación se hace **estáticamente** si es decidible sin ejecutar y sin construir un grafo de
> flujo de control; en cualquier otro caso se hace **en ejecución**, con span exacto. **Nunca se
> rechaza un programa correcto por no poder demostrar que lo es.**

No es una regla nueva: es la que 10.5 usó para «¿todos los caminos retornan?» y la que 11.2 usó para la
visibilidad. Aquí gobierna la inicialización (12.7), el conflicto de tipos con un operando
indeterminado (12.6) y la existencia de un miembro (11.7).

### 12.5 Inferencia de tipos en perfil flexible

**El tipo de una variable no declarada queda fijado por la primera acción que le da un valor**, y esas
acciones son exactamente dos: **la asignación y la lectura**. No es la primera aparición en el texto:
una variable que aparece por primera vez dentro de una expresión sin haber recibido valor es un uso
sin inicializar (12.7), no una inferencia.

| Primera acción | Tipo que se fija                                    | Cuándo           |
|----------------|-----------------------------------------------------|------------------|
| Asignación     | El tipo estático de la expresión de la derecha      | En el chequeo    |
| Lectura        | El que corresponda a la forma del texto introducido | **En ejecución** |

**Inferencia por lectura, con orden determinista.** Es el único punto en que el lenguaje es
genuinamente dinámico, y por eso su regla es cerrada y no una heurística. El texto introducido se
clasifica en este orden y gana el primero que encaja:

1. Literal entero válido → **entero**.
2. Literal real válido → **real**.
3. Coincide exactamente con uno de los dos lexemas lógicos del perfil activo → **lógico**.
4. En cualquier otro caso → **cadena**.

**Carácter nunca se infiere.** Un texto de un solo carácter se clasifica como cadena de longitud uno:
desde el texto introducido las dos lecturas son indistinguibles y cadena es la que no pierde
información. Quien necesite un carácter lo declara.

**Una variable cuyo tipo viene de una lectura tiene tipo indeterminado para el chequeador**, y toda
comprobación que la involucre se difiere a ejecución por la regla de 12.4. **El tipo de una expresión
con al menos un operando indeterminado es indeterminado.**

**Cada inferencia emite un diagnóstico de severidad informativa** que nombra la variable y el tipo
inferido. Es la nota que el documento de producto exige, y le da a la interfaz el ancla para mostrarla
junto a la línea.

**En perfil estricto no hay inferencia**, porque la bandera «Declaración obligatoria» no deja ninguna
variable sin tipo. La inferencia no es una bandera nueva: es lo que ocurre cuando esa bandera está
apagada.

### 12.6 Ampliación aceptable y conflicto real de tipos

**Ampliación aceptable: una y solo una.** Si el tipo inferido es **entero** y más adelante se asigna un **real**, el
tipo de la variable pasa a **real**. Es aceptable porque todo valor entero anterior es
representable como real, así que ninguna línea ya comprobada deja de ser correcta.

**Conflicto real: todo lo demás.** Cualquier asignación cuyo tipo no sea convertible al tipo ya fijado,
y que no sea esa ampliación, produce **un error en esa línea** —no en la declaración ni al final del
programa—.

**Tres propiedades que hacen la regla implementable, y que son normativas:**

1. **La ampliación ocurre como máximo una vez por variable.** La red de conversión implícita entre
   primitivos tiene una sola arista, así que el tipo cambia a lo sumo una vez y el análisis termina en
   una pasada. No hace falta punto fijo.
2. **La ampliación no retropropaga.** Las líneas anteriores, ya comprobadas contra entero, siguen
   siendo correctas y no se vuelven a comprobar. Es justo la propiedad que hace segura la ampliación.
3. **No hay ampliación entre clases.** Si el tipo inferido es una clase y luego se asigna una instancia
   de otra clase hermana, es **conflicto**, aunque compartan superclase. Ampliar al ancestro común
   exigiría calcular el supremo de la jerarquía y cambiaría retroactivamente el tipo de la variable,
   invalidando llamadas de líneas anteriores que eran correctas.

**Quién lo detecta:** estáticamente cuando los dos tipos se conocen; en ejecución cuando alguno es
indeterminado (12.4). Coincide con el comportamiento observable de la herramienta de referencia, cuya
documentación dice que si el tipo de una variable cambia, el proceso se interrumpe.

| Situación                                                   | Resultado o clase de error                                     |
|-------------------------------------------------------------|----------------------------------------------------------------|
| Se infiere entero y luego se asigna un real                 | **No es error.** Ampliación, con diagnóstico informativo       |
| Se infiere real y luego se asigna un entero                 | **No es error.** El entero es convertible a real               |
| Se infiere entero y luego se asigna una cadena              | Semántico, con código propio, en esa línea                     |
| Se infiere una clase y luego se asigna una clase hermana    | Semántico, con código propio                                   |
| El tipo vino de una lectura y luego hay conflicto           | De ejecución, con span de la asignación culpable               |
| Asignar a una variable **declarada** un tipo no convertible | Semántico. La declaración manda; no hay inferencia que ampliar |

### 12.7 Variable usada sin inicializar

**Leer el valor de una variable a la que nunca se le asignó ninguno es un fallo en las dos políticas.**
Lo que la bandera «Inicialización obligatoria» decide es **cuándo se detecta**, no si lo es:

| Política                  | Comportamiento                                                                                                                                                                        |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Estricta, bandera activa  | **Error semántico** cuando es decidible sin grafo de flujo: no hay ninguna asignación a esa variable antes en el texto de su ámbito. En cualquier otro caso, diagnóstico de ejecución |
| Flexible, bandera apagada | **Diagnóstico de ejecución** en el momento de la lectura, siempre                                                                                                                     |

**Dos códigos, no uno, cerrado en el Sprint 15.** Esta subsección, tal como quedó escrita en el Sprint
12, es contradictoria con 12.10 tomada literalmente: la detección estática es de **clase B**
—advertencia bajo perfil flexible—, y una advertencia no detiene la ejecución; pero sin ella el motor
tendría que seguir con algún valor en la mano, y no hay ninguno que pueda tomar sin reintroducir el
valor por omisión que este mismo apartado rechaza tres párrafos más arriba. La regla de oro de 12.10
—«si dos políticas necesitaran que el mismo código quisiera decir dos cosas, harían falta dos
códigos»— resuelve la contradicción sin tocar ninguna de las dos reglas que la causan:

| Código                      | Cuándo se detecta                               | Clase | Efecto               |
|-----------------------------|-------------------------------------------------|-------|----------------------|
| `variableUsedUninitialized` | **Estáticamente**, decidible sin grafo de flujo | B     | No ejecuta nada      |
| `uninitializedVariableRead` | **En ejecución**, en el instante de la lectura  | A     | Detiene la ejecución |

Bajo perfil flexible un programa que el chequeador solo advirtió puede aun así detenerse en ejecución.
No es una incoherencia nueva: es lo que ya significa que «la bandera decide cuándo se detecta, no si lo
es». Una alternativa —continuar con un valor centinela— queda rechazada por reintroducir el fallo
silencioso por la puerta de atrás.

**No hay valores por omisión.** Una variable declarada y no asignada **existe pero no tiene valor**, y
el entorno del evaluador distingue los dos estados de modo que la instantánea lo muestre. Las razones:

- Un valor por omisión convierte un olvido en un programa que se ejecuta y da un resultado equivocado.
  Es el mismo fallo silencioso que el lenguaje ya rechazó al fijar el paso del bucle contado, la marca
  de paso de parámetros y la visibilidad por miembro.
- La máquina paso a paso puede señalar la lectura culpable con span exacto; un cero por omisión no
  tiene nada que subrayar.
- **Es lo que la sección 11.5 ya decidió** para las variables de tipo clase, que arrancan sin
  instanciar. Con valores por omisión, primitivos y clases se comportarían de dos maneras distintas
  ante el mismo olvido.

### 12.8 Variable no usada

**Uso es leer el valor.** Asignar no es usar. De ahí dos diagnósticos distintos:

| Diagnóstico                | Severidad                        | Por qué                                                                                                                                    |
|----------------------------|----------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| Declarada y nunca usada    | Advertencia en las dos políticas | Código muerto. Solo existe bajo «Declaración obligatoria»                                                                                  |
| **Asignada y nunca leída** | Advertencia en las dos políticas | Es el que caza el error de escritura de un nombre. Bajo perfil flexible es la única red que queda, porque no hay declaración que lo delate |

Advertencia y no error, porque hay programas correctos que lo hacen. Y **no es una bandera de rigor**:
por la prueba del eje de 2.1 no cambia qué programas son válidos.

**Tres casos que cuentan como uso**, escritos porque cada uno produciría un falso positivo: una
variable pasada como argumento **por referencia**; la **variable de control** de un bucle contado, que
la prueba del bucle lee en cada iteración; y un **atributo** leído desde cualquier método de su clase,
aunque ese método no se llame nunca.

### 12.9 Tipado de arreglos y de objetos

**Arreglos.** El índice es de tipo **entero**; un índice real es un **error semántico**, no un
truncamiento —truncarlo sería la conversión que 12.1 rechaza, en el sitio donde menos se nota—.

**El tamaño no forma parte del tipo, y es una consecuencia y no una elección.** El tipo de un arreglo
es el par *(tipo de elemento, número de dimensiones)*. La sección 10.3 ya decidió que un parámetro de
arreglo declara sus dimensiones sin sus tamaños, así que el tipo con el que se comprueba una llamada no
puede contenerlos; y la bandera «Dimensión constante de arreglo» solo está activa en perfil estricto,
de modo que en flexible el tamaño puede no conocerse antes de ejecutar. Cualquiera de las dos razones
basta.

- Compatibilidad con un parámetro: **mismo tipo de elemento y mismo número de dimensiones**. El tamaño
  no se comprueba nunca en el chequeo; el índice fuera de rango sigue siendo de ejecución (9.2).
- **Un arreglo sigue sin ser un valor** (9.1) y por tanto no aparece en las relaciones de 12.1: tiene
  tipo para declararse y para emparejar parámetros, no para participar en expresiones.

**Objetos.** Cerrado en su mayor parte por 11.8. Lo que esta sección añade es la regla de subtipo:

- **Una variable de tipo `C` puede referenciar una instancia de `C` o de cualquier subclase suya.** Es
  la fila «subclase → superclase» de 12.1 y es lo que hace posible el polimorfismo.
- **La contraria no**, y no hay conversión descendente: añadirla exigiría un operador nuevo y por tanto
  un token nuevo.
- **La consecuencia se enseña, no se tapa.** Sobre una variable declarada del tipo de la superclase, la
  llamada a un método que solo existe en la subclase es un error semántico aunque en ejecución fuese a
  funcionar, y **el diagnóstico dice exactamente eso**: es la distinción entre tipo declarado y tipo
  real, y el mensaje es donde se enseña.
- **Igualdad entre objetos: identidad**, y solo entre tipos comparables. Comparar instancias de dos
  clases sin relación de herencia es un error semántico, porque el resultado sería siempre falso.

### 12.10 La política de severidad

**Regla de oro, y es la que hace que los dos modos sean datos y no ramas:** un código de diagnóstico **nunca cambia de
significado** entre políticas. Cambia de severidad, o no cambia nada. Si dos
políticas necesitaran que el mismo código quisiera decir dos cosas, harían falta dos códigos.

Cada código pertenece a **una clase**, que es un dato del lenguaje y se declara al crearlo. La
severidad es un dato del perfil, y solo puede moverse dentro de lo que su clase permite:

| Clase                         | Estricta    | Flexible    | Ejemplos                                                                                                                                                                                                       |
|-------------------------------|-------------|-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **A · Estructural**           | error       | error       | Todo lo sintáctico. Conflicto real de tipos, número de argumentos, índice no entero, herencia circular, miembro privado desde fuera, desbordamiento, división por cero, etiqueta real en la selección múltiple |
| **B · Gobernada por bandera** | error       | advertencia | Variable no declarada, uso sin inicializar, etiqueta no entera y no real en la selección múltiple, dimensión de arreglo no constante                                                                           |
| **C · Higiene**               | advertencia | advertencia | Declarada y no usada, asignada y no leída, parámetro no usado, valor devuelto descartado, modificación de la variable de control, atributo público, comparación de reales por igualdad                         |
| **D · Informativa**           | información | información | Cada inferencia de tipo del perfil flexible                                                                                                                                                                    |
| **E · Ejecución recuperable** | advertencia | advertencia | El único miembro es `readValueTypeMismatch` (7.2): el valor leído no corresponde al tipo esperado, y el motor **no se detiene**, vuelve a pedir el mismo valor                                                 |

**La clase E, añadida en el Sprint 15.** Las cuatro clases originales se escribieron cuando todo
diagnóstico era estático. Un diagnóstico de ejecución tiene una propiedad que ninguna de las cuatro
expresa: **si detiene la ejecución o no**, y 7.2 ya especifica un caso, con severidad de advertencia en
las dos políticas, que explícitamente no la detiene. Todos los demás diagnósticos de ejecución nuevos
—desbordamiento, división por cero, índice fuera de rango, profundidad de recursión, lectura sin
inicializar en ejecución, y el resto que el Sprint 15 introduce— son **clase A**: la misma razón que
12.10 da para la clase A —«un fallo estructural rebajado a advertencia significaría seguir ejecutando
sin valor que producir»— describe un diagnóstico de ejecución mejor todavía que uno estático. El test
de invariantes de la política de severidad se amplía con el invariante correspondiente: ningún código
de clase E es error en ninguna política, y todo diagnóstico de ejecución que no sea
`readValueTypeMismatch` es de clase A.

**Dos invariantes mecánicos, cada uno con test propio**, porque una tabla de datos que nadie comprueba
se desincroniza:

1. **La política flexible es siempre igual o más permisiva que la estricta.** Ninguna entrada puede ser
   `error` en flexible y menos que `error` en estricta. Es la traducción a esta tabla del invariante
   que 2.5 exige de las banderas.
2. **Ningún código de clase A baja de `error` en ninguna política.** Un fallo estructural rebajado a
   advertencia significaría seguir ejecutando sin valor que producir.

**Un matiz de la selección múltiple que no hay que unificar por simetría:** la etiqueta de tipo real
está prohibida en las dos políticas y es de **clase A**, mientras que carácter, cadena y lógico son de **clase B**. La
misma construcción tiene dos clases según el tipo de la etiqueta, tal como 8.2 ya
tabulaba.

### 12.11 Funciones incorporadas que este sistema de tipos obliga a tener

Cada conversión implícita rechazada en 12.1 obliga a que exista una explícita, o el lenguaje se queda
sin forma de hacer algo legítimo. Ninguna consume un token: la sección 13 fija que el nombre de una
función incorporada no es un lexema reservado.

| Función               | Firma                        | Por qué es obligatoria                                                                                             |
|-----------------------|------------------------------|--------------------------------------------------------------------------------------------------------------------|
| truncamiento          | real → entero                | Ya existe. Salida de la conversión real→entero rechazada                                                           |
| redondeo              | real → entero                | Ya existe. La otra salida de la misma                                                                              |
| conversión a cadena   | cualquier primitivo → cadena | Salida del rechazo a concatenar número con texto                                                                   |
| conversión a entero   | cadena → entero              | Sin ella, un dato leído como cadena no se puede usar en aritmética. Falla en ejecución si el texto no es un número |
| conversión a real     | cadena → real                | Ídem                                                                                                               |
| longitud              | cadena → entero              | Sin ella no hay forma de recorrer una cadena                                                                       |
| carácter en posición  | cadena, entero → carácter    | La única vía de cadena a carácter, que 12.1 declara no convertible                                                 |
| código de carácter    | carácter → entero            | La única vía de carácter a número                                                                                  |
| carácter desde código | entero → carácter            | La inversa                                                                                                         |
| copia superficial     | objeto → objeto              | Comprometida por 11.9                                                                                              |

Las cinco de texto y conversión numérica **no estaban en el catálogo de partida de la sección 13**, que
solo enumera funciones matemáticas. Es una ampliación forzada por este sistema de tipos, y se declara
como tal.

### 12.12 Casos límite

| Situación                                                  | Resultado o clase de error                          |
|------------------------------------------------------------|-----------------------------------------------------|
| Dividir por cero con `/`, `div` o `mod`                    | De ejecución, con código propio                     |
| Desbordamiento de entero                                   | De ejecución, con código propio                     |
| Real que resulta infinito o no numérico                    | De ejecución, con código propio                     |
| Exponente entero negativo sobre base entera                | De ejecución, con código propio                     |
| Convertir a entero una cadena que no es un número          | De ejecución, con código propio                     |
| Condición de un condicional o de un bucle que no es lógica | Semántico                                           |
| Expresión de un solo literal                               | **No es error.** Su tipo es el del literal          |
| Comparar una variable consigo misma                        | **No es error.** Advertencia solo si son dos reales |
| Operación entre los bordes del tipo entero                 | **No es error** mientras no desborde                |
| Arreglo de tamaño cero                                     | **No es error** (9.1)                               |
| Programa sin ninguna expresión                             | **No es error**                                     |

## 13. Funciones incorporadas

Las funciones son un dato del perfil, no código: su nombre visible cambia con el idioma, su semántica
no. Su nombre no es un lexema reservado. Cerrado por completo en el Sprint 15: cada función tiene ya su
entrada en `BuiltinFunction`, su firma y su lexema en los dos perfiles de referencia.

**Las diez matemáticas**, registradas desde el catálogo de partida: raíz cuadrada, valor absoluto,
logaritmo natural, exponencial, seno, coseno, arcotangente, truncamiento, redondeo y aleatorio.

**Las ocho que 12.11 obliga a añadir**, cerradas en el Sprint 15: conversión a cadena, conversión de
cadena a entero, conversión de cadena a real, longitud, carácter en posición, código de carácter,
carácter desde código, y copia superficial.

**Sobre `aleatorio`, y el determinismo declarado.** El motor no consulta el reloj ni ningún generador
del lenguaje anfitrión no determinista: recibe inyectada una fuente pseudoaleatoria con semilla
explícita, propia del paquete, para que una ejecución sea reproducible por construcción. Quien gobierne
el motor decide la semilla; el núcleo nunca la deduce del entorno.

**Sobre `Copiar`, y el límite del Sprint 15.** Su firma y su chequeo de tipos están completos desde
este sprint, porque el chequeador de tipos ya resuelve clases desde el Sprint 14. Su **ejecución**
no: el Sprint 15 construye el evaluador de la parte estructurada y procedimental del lenguaje
únicamente, y la orientación a objetos —instanciación, atributos, despacho— es el Sprint 16. Por eso el
motor de este sprint **se niega a ejecutar cualquier programa que declare una clase**, con un resultado
propio y sin diagnóstico de idioma, en vez de intentarlo y fallar a medias: es la misma disciplina de
«un fallo esperable es un valor de retorno, no una excepción que escapa» aplicada a un límite de
alcance en vez de a un error del programa. Ningún programa que declare una clase puede tener cero
errores de tipos sin usarla —una variable de tipo clase no instanciada, un `Este` fuera de método, una
llamada a un miembro que no existe—, así que la frontera es detectable sin ambigüedad y se documenta en
el README de este paquete.

## 14. Gramática formal

Pendiente. Se consolida cuando las secciones de construcciones, de orientación a objetos y de
sistema de tipos estén
cerradas, y sustituirá a las descripciones en prosa como definición normativa de la sintaxis. Escribirla
antes sería consolidar decisiones que aún no están tomadas.

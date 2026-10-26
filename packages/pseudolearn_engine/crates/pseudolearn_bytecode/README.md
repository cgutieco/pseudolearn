# pseudolearn_bytecode

## 1. Qué es y qué no es

Traduce una RI verificada a bytecode gemelo con asignación de registros por clase, depósitos de constantes,
verificación estructural y selección perfilada de superinstrucciones.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno | — | — |

## 2. Guía operativa y ciclo de vida

Usa la versión exacta de rust-toolchain.toml del miembro. El crate está activo en el workspace.
Comprobación: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

El módulo conserva vocabulario, jerarquía de clases, disposiciones heredadas y metadatos de origen por función. Cada variante
lleva mapas de raíces en instrucciones que asignan memoria o llaman: ranuras de variables en ámbito más
temporales vivos de la evaluación actual. La información de variables sobrevive aunque no tengan usos
futuros; la liveness de registros por sí sola no representa el conteo nocional. Las continuaciones
suspendidas consultan el mapa de su llamada. Los mapas son datos verificados antes de cargar la VM.

Nivel 5. Importa ir y source; serde_json solo para generación. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

El catálogo de opcodes y sus identidades se generan desde la exportación de `IR.INSTRUCTIONS`. Cada función
conserva descriptores de bloque, tablas de constantes, tipos de registro y spans laterales con su ID de fuente.
El ID no se copia a cada valor ni cambia su representación. Las ranuras se
asignan en orden estable y se separan por clase de valor. La salida SSA transporta argumentos de bloque
como copias paralelas; los gemelos rápido y sondeado comparten registros, constantes, descriptores y puntos
de retorno.

Los metadatos de clase incluyen superclase, campos aplanados en orden heredado, mapas de referencias y
objetivos de métodos. El verificador valida nombres únicos, jerarquías acíclicas, prefijos de campos
heredados y receptores compatibles con cada método. También comprueba las clases de destino y operandos
de arreglos, celdas, objetos, comparación de referencias y azar antes de cargar la VM.

Cada variante termina acolchada con `unreachable` hasta la siguiente potencia de dos y registra en
`used_length` cuántas instrucciones son código real. El consumidor indexa con `pc & (longitud − 1)`: un pc
que se saliera del código cae en una instrucción que atrapa, nunca fuera del vector.

Invariantes: Los gemelos comparten el mapa de registros, depósitos de constantes y descriptores de bloque. Cada operando cabe en su ventana; cada salto pertenece a su función; cada superinstrucción contiene un par compatible del mismo bloque; cada punto de retorno existe en ambos gemelos con PC propio. La longitud de cada variante es potencia de dos, la cola solo contiene `unreachable` sin operandos y ningún bloque, salto, continuación ni superinstrucción apunta a la cola.

## 4. Decisiones de diseño y fundamentos técnicos

Una única generación parametrizada produce Fast y Probed. El rápido omite observación y registro de escrituras. Descriptores de bloque contienen masas de sentencia y evento; los cargos se fusionan en saltos. Los puntos de retorno tienen identidad independiente del gemelo y PC propio para cada variante. El verificador rechaza registros fuera de ventana, saltos inválidos, clases incompatibles, continuaciones sin identidad, jerarquías o disposiciones de objeto incoherentes y fusiones de opcode incompatibles. Las aristas de bloque y las escrituras a celdas aceptan un objeto derivado cuando el destino espera una superclase. El compilador recibe las superinstrucciones elegidas a partir de perfiles de entrenamiento; la fusión de comparación y salto se valida con una carga reservada. Una expresión pura fusionada reejecuta sus componentes en orden ante una marca de fallo para atribuir la primera trampa.
Los literales escalares usados por operaciones aritméticas, comparaciones y escritura pasan como
operandos constantes directos; se mantienen registros solo cuando una transferencia de bloque,
llamada o instrucción sin forma inmediata necesita el valor.
Fast elimina marcadores de observación antes del despacho; Probed los conserva.
El acolchado se descartó como relleno con copias del código o con saltos al inicio: una instrucción que
atrapa conserva la semántica ante un defecto y el verificador la reconoce sin análisis de flujo. Las tablas de retorno
comparten identidad y mantienen sus contadores de programa por gemelo.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

`BytecodeModule` conserva la tabla de perfiles por fuente del módulo RI (`profiles`) y reexporta `SourceProfile`; el
bytecode no la interpreta, la entrega al cargador de la VM.

El switch de RI conserva sus destinos como operandos verificados y se carga como tabla de aristas en cada gemelo. La verificación exige selector entero, ordinales crecientes dentro de 16 bits y tipos válidos para reinterpretación y transporte de celdas. Reinterpretar conserva el banco: los opcodes no permiten convertir una palabra escalar en raíz ni una celda en objeto.

Los valores de una misma variable de origen comparten registro solo si tienen exactamente el mismo tipo de RI. Una variable de tipo clase base que recibe instancias de subclases hermanas conserva un registro por clase concreta; el salto al bloque de unión copia cada valor al parámetro, cuyo tipo es el declarado, y el verificador acepta la copia porque la subclase es asignable a la base. Compartir el registro del primer valor fijaba su clase como tipo del registro y rechazaba el segundo valor con `ValueClass`.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

No introduce observables; conserva los de la RI y habilita ENG.EXEC y ENG.TRACE. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

Negativos del verificador (incluidos longitud no potencia de dos, cola con otra instrucción, longitud
usada vacía o mayor que el código y bloque que empieza en la cola), ciclos de copias paralelas, diferencial entre gemelos, cambio arbitrario de gemelo y validación de superinstrucciones fuera de muestra. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

Lua inspira registros, JVM verificación y Self cambio de código. Ertl y Gregg inspiran superinstrucciones por perfil; se rechaza elegirlas por intuición o solo por entrenamiento.


### Funciones como valores y ámbitos de ejecución

Cada función conserva el tipo de retorno y los intervalos léxicos de sus registros nombrados. La firma de una llamada indirecta incluye tipos de parámetros y retorno; el registro de identidad ocupa el banco escalar. La generación de raíces elimina vínculos cerrados que tampoco siguen vivos por flujo. Ambos gemelos conservan las mismas disposiciones, puntos de retorno y tamaño fijo de instrucción.

# pseudolearn_lowering

## 1. Qué es y qué no es

Traduce el HIR tipado a representación intermedia observable SSA.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Ninguno | B2 completado | R5 B2 |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. Crate de librería incorporado al workspace Cargo del motor.
Comprobación: `cargo xtask verify` y `rust-checks all .` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Los argumentos por referencia se traducen como celdas de local, campo o elemento y se validan antes
de entrar al cuerpo. Los constructores conservan argumentos y receptor; los métodos tienen identidad
calificada por su clase. Los orígenes laterales quedan calificados por función.

Nivel 4. Importa semantic, ir, diagnostics y source; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Traducción procedural de expresiones, asignación, controles, entrada y salida; después llamadas y objetos. CFG SSA con análisis de asignación definida, celdas para referencias, masas y orígenes. Se marca la arista de retroceso de componentes cíclicos sin masa para sondeo.

Invariantes: Cada bloque tiene una masa igual a su cantidad de stmt.enter. Las conversiones están explícitas en Widen; no se vuelven a resolver nombres ni a interpretar fuente.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: representar parámetros arreglo como celdas introduce una indirección que no permite ninguna operación adicional del lenguaje. Elección: LANG.TYPES.ARRAY y LANG.STMT.ASSIGNMENT prohíben asignar o retornar el arreglo completo; los parámetros arreglo conservan el asa y comparten los elementos. La declaración y todas las llamadas usan el mismo tipo RI array; los orígenes conservan esa asa observable. Las referencias escalares y las celdas de elemento o campo conservan su representación. Se descarta especializar solo AOT y mantener dos interpretaciones de cell<array>.

Los locales respaldados por celdas conservan su asa estable a través de un bucle y no reciben parámetros SSA escalares. Se descarta acarrear como entero una referencia de celda: las escrituras indirectas ya conservan el valor y el alias.

Los límites y el paso de Para se congelan en temporales sin origen de variable para que una escritura del cuerpo no altere los controles ya evaluados. Mientras tiene una entrada a sentencia para el bucle completo y una decisión por prueba, incluida la final. La escritura sin valores usa un texto vacío, manteniendo el evento de salida y su salto opcional. Se descartan ranuras de origen mutables como caché de límites, entradas repetidas al bucle y RI inválida para salida vacía.

Escribir evalúa todos sus operandos antes del único out.write. Para evalúa inicial, final y paso una vez, comprueba paso, prueba inclusive por signo e incrementa con comprobación aun tras la última iteración. Los índices de celdas por referencia se evalúan y comprueban antes de llamar. La desvirtualización usa la jerarquía cerrada. Se omite value.require solo para lecturas demostradas asignadas; los enteros restantes reciben definición SSA.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.
El conjunto de variables acarreadas por un bucle incluye escrituras anidadas en condicionales,
selecciones y bucles internos; así cada iteración recibe el valor SSA que dejó la anterior.

La detección de llamada inicial al constructor padre se consulta a semantic. La traducción no redefine esa decisión ni acepta una llamada ordinaria a método como inicialización de superclase.

Problema: las funciones de un proyecto proceden de varias fuentes. Elección: `lower_project` recibe una fuente por
unidad y cada función se baja con la de su unidad, sin tocar el resto del bajado; las funciones llevan el
calificador de módulo en su nombre de RI y solo la entrada seleccionada se llama `@main`. Las demás
unidades con algoritmo se nombran `@calificador.main`. Se rechaza una tabla global de fuentes dentro de cada
expresión, porque ninguna instrucción cruza unidades.

`lower_project` emite el módulo sin tabla de perfiles; quien conoce el perfil de cada archivo (la API) completa
`profiles` y el vocabulario de entrada antes de verificar. El bajado no decide perfiles.

### Registros aplanados, retorno por celdas y nombre de enumerado

Un registro nunca es un valor de la RI: `record_values::lower_range` entrega los valores de sus hojas y cada consumidor
(asignación, argumento, retorno, igualdad) trabaja sobre esa lista. Leer `p.x` solo lee (y exige definida) la hoja
tocada, no el registro entero. Las variables de tipo registro se declaran, acarrean en bucles y se unen en ramas como
sus hojas, porque semantic ya las expuso como locales. Los argumentos se expanden a un argumento por hoja y el
resultado de una función registro se devuelve por celdas: la función recibe, tras sus parámetros, una `cell<hoja>`
por hoja (`FunctionBuilder.result_cells`), escribe con `cell.store` y retorna sin operando; el llamador crea un
`cell.local` por hoja, pasa las celdas y las lee con `cell.load` después de `call`. Esto no añade instrucciones ni
toca bytecode, VM, runtime ni Cranelift, pero cuesta una celda por hoja en cada llamada; es el coste medible que un
retorno multivalor de la RI eliminaría (decisión reversible: se revisa si una medición con cargas de registros muestra que la celda domina el coste). La igualdad compara hoja a
hoja con la instrucción de su tipo y combina los resultados con una cadena de ramas que termina en el primer falso;
las comparaciones previas son puras. `<>` niega el resultado. `Escribir` de un valor enumerado selecciona el nombre del
miembro con una cadena de comparaciones de ordinal y bloques que unen un texto (`enum_output`), sin instrucción nueva;
la tabla de saltos del terminador `switch` llega con la exhaustividad de `Segun`. Un enumerado es un entero de RI, por lo que
`class_density` lo trata como entero para no omitir la máscara de definidos de un campo sin asignar.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Datos con índices tipados,
funciones pequeñas y fallos como Result. Límites y dependencias en architecture.yaml del miembro.
Las salidas generadas se producen en OUT_DIR y no se copian a consumidores.

## 6. Decisiones de producto que condicionan el código

IR.LOWERING, IR.OBSERVATION-POINTS, IR.SOURCE-MAP y orden de efectos de LANG. Ejecutar y observar conservan la misma semántica. Los identificadores, el contenido de
literales y los efectos del programa se preservan; idioma de interfaz y vocabulario son independientes.

## 7. Verificación, testing y aseguramiento de calidad

P1 y P3 sobre corpus y generados; cada traducción y primera trampa en distintas posiciones de evaluación. El resultado pasa el verificador. Tests espejo, caminos felices, infelices y límites explícitos. Cada verificador tiene un negativo
con violación deliberada. No se cierran pendientes hasta tener cargo xtask verify y conformidad en verde.

## 8. Fuentes consultadas y genealogía conceptual

La RI tipada conserva el orden normativo; se rechaza optimizar antes de conservar efectos, tramos y variables observables.

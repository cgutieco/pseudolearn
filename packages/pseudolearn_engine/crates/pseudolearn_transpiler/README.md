# pseudolearn_transpiler

## 1. Qué es y qué no es

Traduce un programa ya analizado (el HIR tipado de `pseudolearn_semantic`) a código equivalente en Rust
y en Python. El código emitido solo usa la biblioteca estándar de cada destino y, cuando hace falta
reproducir una semántica del motor, incluye al final (Rust) o al principio (Python) las funciones de
apoyo que esa traducción usa, visibles y legibles para quien estudia el programa.

No compila ni ejecuta el código traducido, no añade dependencias externas al resultado, no analiza
fuentes por su cuenta ni decide nada a partir de lexemas del perfil: recibe identidades canónicas
(tipos, operadores, incorporadas, variantes, canales) y las palabras lógicas del perfil activo.

Pendientes declarados:

- Operaciones de capacidad y de biblioteca de efectos (`HirExpression::Effect`: consola, archivos,
  directorio, reloj, temporizador, argumentos, entorno, red, bytes y JSON) se informan como
  construcción `capability`. Red HTTPS y JSON no tienen equivalente en la biblioteca estándar de
  Rust; el resto queda por traducir.
- Capacidades: su comportamiento lo media el anfitrión (permisos, archivos simulados, cinta de efectos, reloj
  real), por lo que el barrido diferencial no puede contrastarlas con la salida del motor; se traducirán con su
  propio arnés de anfitrión.
- En Rust, una tarea cancelada por el fallo de una hermana se descarta sin ejecutar sus limpiezas de `Diferir`;
  en Python `asyncio` las ejecuta como el motor.
- En Rust, `Instantanea` copia en profundidad primitivos, cadenas, vectores y diccionarios; sobre objetos y
  registros no compila todavía. `Copiar` de un objeto de una jerarquía de clases en Rust se informa como
  `builtin:shallowCopy`.
- Métodos suspendibles dentro de una jerarquía de clases en Rust (`suspendible_method`): un `trait`
  con `async fn` no admite despacho dinámico.
- Los resultados de las funciones trascendentes usan `f64` de Rust y `math` de Python; el motor
  garantiza redondeo correcto y estos destinos pueden diferir en el último bit.
- Python usa enteros de precisión arbitraria: un desbordamiento de 64 bits que el motor atrapa
  continúa en Python.
- En Rust, volver a entrar en un objeto que ya está ejecutando un método (por ejemplo `a.m(a)` cuando
  `m` modifica el objeto) produce un fallo de préstamo de `RefCell` donde el motor continúa.

## 2. Guía operativa y ciclo de vida

Versión exacta de `rust-toolchain.toml` del miembro. Crate del workspace de `pseudolearn_engine`; no
se despliega por separado. Comprobación local: `cargo test -p pseudolearn_transpiler` y el barrido
diferencial de `pseudolearn_api` (sección 7).

## 3. Arquitectura y modelo del sistema

Nivel 7. Importa source, lexicon y semantic; syntax solo en pruebas para obtener HIR de fuentes. Solo
`pseudolearn_api` lo importa. Prohibido importar VM, runtime, bytecode, la API o UI.

- `lib.rs` expone `transpile(&HirModule, &TranspileRequest) -> TranspileOutcome`.
- `module_view` ofrece consultas totales sobre el HIR (sin índices directos).
- `member_spellings` fija, una vez por traducción y por destino, el nombre de cada campo, de cada clase y el
  conjunto de nombres finales de las variables locales; los emisores lo consultan en vez de deletrear
  nombres crudos en cada sitio.
- `code_lines` acumula líneas con sangría y el tramo de origen de cada línea; ese tramo es el que la
  API convierte en nodo de la vista del programa para resaltar líneas en la app.
- `support_requests` registra qué funciones de apoyo pidió la traducción y cierra sus dependencias.
- `rust_target` y `python_target` son los dos emisores. Cada uno separa tipos, declaraciones,
  clases, funciones, sentencias, control, expresiones, llamadas, lugares y catálogo de apoyo.

Si una construcción no tiene traducción, el emisor la registra como `Blocker` con su identidad
pública y su tramo, y el resultado es `TranspileOutcome::Unavailable`: nunca se entrega un programa
parcial.

## 4. Decisiones de diseño y fundamentos técnicos

Problema: la traducción vivía en la app y reconstruía en Dart los tipos que el motor ya conocía, por
lo que cada construcción nueva exigía reinterpretar semántica y casi ningún programa con tareas,
variantes o clases tenía equivalente. Elección: traducir desde el HIR tipado, que ya resuelve tipos,
nombres, monomorfiza genéricos y modela tareas, canales, variantes y clausuras. Se descartó ampliar la
vista del programa con tipos para seguir emitiendo en Dart: duplicaba el analizador.

Correspondencias principales:

- Tipos: Entero `i64`/`int`, Real `f64`/`float`, Lógico `bool`, Carácter `char`/`str`, Cadena
  `String`/`str`. Arreglos `Vec` anidados y listas, siempre por referencia. Registros `struct` con
  `Clone` (Rust) y `@dataclass` con `copy()` (Python): asignar, pasar o devolver un registro copia.
  Enumerados `enum` con `Display` y `Enum` con `__str__`. Vector y Diccionario son referencias
  compartidas: `Rc<RefCell<Vec<T>>>`, un `Dictionary` propio que conserva el orden de inserción (Rust
  no tiene un mapa ordenado por inserción) y `list`/`dict`.
- Salida: reales con al menos un decimal (`Display` de Rust y `Decimal(repr(x))` en Python dan la
  representación más corta sin exponente), lógicos con las palabras del perfil.
- Operadores: `\` y `%` truncan hacia cero como el motor (Python necesita `int_divide`); `^` entero
  rechaza exponentes negativos; `/` real atrapa la división entre cero.
- Azar: se porta xoshiro256** con siembra splitmix64 y el rechazo de `next_below` del runtime; la
  semilla es la de la petición o, sin semilla, el reloj del sistema.
- Variantes: `Opcional` es `Option`/`Some`-`Nothing`, `Resultado` es `Result`/`Ok`-`Err` y las
  variantes de usuario son `enum` con campos con nombre o clases de datos anidadas. `Segun` sobre una
  variante es `match` y los primeros enlaces del caso se convierten en el patrón.
- `Propagar` es `?` en Rust; en Python, `propagate` lanza una excepción que la función captura y
  devuelve como resultado.
- `Diferir`: en Python, `try/finally`. En Rust se emiten las limpiezas pendientes al final del bloque
  y antes de cada `return`, `break` o `Propagar`, en orden inverso; un `Propagar` con limpiezas
  pendientes se escribe como `match` explícito.
- Parámetros por referencia: `&mut` en Rust. Python no tiene referencias: la función devuelve los
  valores finales de esos parámetros y quien llama los reasigna (`a, b = intercambiar(a, b)`). Los
  arreglos ya se comparten y no se devuelven.
- Clases sin herencia: `struct` + `impl` con `Rc<RefCell<T>>`. Jerarquías en Rust: un `trait
  <Clase>Kind` por clase con accesores a su parte de datos, la clase hija contiene a la madre en
  `base`, el cuerpo de cada método es una función genérica `<clase>_<método><T: Kind + ?Sized>` (así
  `Este.m()` despacha dinámicamente aunque el cuerpo esté en la clase madre) y `Super.m()` llama a esa
  función genérica. Los campos sin valor por omisión (objetos, canales, funciones) se guardan como
  `Option`. Python usa herencia de clases directamente.
- Clausuras: se emiten antes de la sentencia que las usa (`move` + `Rc<dyn Fn>` en Rust, `def`
  anidada en Python); las variables capturadas nunca se reasignan, así que adelantar la creación no
  cambia el valor capturado.
- Captura de fallos de `Tareas`: el ámbito guarda el primer error, los posteriores y las hermanas canceladas,
  cancela a las hermanas vivas y abandona el resto del cuerpo del dueño (`run_body` en Rust; cancelación del
  dueño absorbida en Python). El informe es el registro `FalloTareas` del HIR dentro de un `Opcional`.
- `Elegir`: `select_receive` recorre los canales en orden textual y devuelve la primera rama lista (dato o
  cierre); si ninguna lo está, se inscribe en todas. Para que una inscripción obsoleta no se quede con el aviso
  de otro receptor, un envío o un cierre despiertan a todos los receptores en espera, que reintentan en orden
  FIFO.
- Nombres: los nombres de los destinos, de los módulos importados y de las funciones de apoyo están reservados y
  el nombre del usuario recibe el sufijo `_value`; una función cuyo nombre coincide con el nombre final de una
  variable local, incluido uno con sufijo de desambiguación como `total_2`, recibe el sufijo `_routine`.
- Campos y clases: el lenguaje distingue `fooBar` y `foo_bar`, pero ambos destinos los escriben `foo_bar`; antes
  eso producía campos duplicados en Rust y, en Python, dos campos que se pisaban en silencio. Elección: los
  segmentos de nombre de campo de todo el módulo (clases, campos de registro aplanados y registros) se deletrean
  con una sola tabla inyectiva en orden de declaración (`foo_bar`, `foo_bar_2`), de modo que tampoco chocan entre
  una clase y su ancestro; las clases emitidas se deletrean en orden de declaración evitando los nombres de
  enumerados, registros con campos y variantes, con sufijo numérico (`MiItem2`). Se descarta una tabla por clase:
  obligaría a conocer al dueño en cada sitio que escribe un campo y no cubriría la jerarquía. Se descarta cambiar
  la regla de deletreo para todos los nombres: cambiaría la salida de los programas sin colisión.
- Tareas y canales: Rust usa `async fn` y un ejecutor cooperativo de un hilo con cola FIFO, escrito
  con la biblioteca estándar (`Wake`, `poll_fn`), un `TaskScope` que une a sus hijas al cerrar el
  ámbito y un `Channel` acotado con cierre. Python usa `asyncio`, cuya cola de listos también es FIFO.
  Se descartaron hilos del sistema operativo: el orden de la salida dejaría de ser determinista.

Fuentes consultadas: documentación de Rust (`std::task::Wake`, coerción a objetos de *trait* con
*upcasting*, ámbito de temporales de la edición 2024) y de Python 3.11 (`asyncio`, `match`,
`dataclasses`). Se tomó el modelo de ejecutor de un hilo y la coerción entre `Rc<RefCell<dyn …>>`; se
rechazó depender de `tokio`, `serde_json` o cualquier biblioteca fuera de la estándar.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Las funciones de apoyo de los
destinos son texto de salida (constantes de cadena), no código de este crate. El código emitido no
lleva comentarios.

## 6. Decisiones de producto que condicionan el código

`API.PROGRAM.VIEW#R17` y `#R18`: el código equivalente se ofrece solo si toda construcción tiene
traducción; en otro caso se nombran las construcciones con su tramo. El destino Python exige 3.11
(`match`, `asyncio`) y el destino Rust la edición 2024.

## 7. Verificación, testing y aseguramiento de calidad

- `tests/` refleja `src/`: pruebas de caja negra de `transpile` para cada destino con caminos felices
  (programa vacío, tareas, variantes, registros, clases), infelices (construcción sin traducción) y
  límites (literales enteros extremos, nombres reservados del destino). `tests/member_spellings.rs` cubre
  campos, campos heredados, clases y registros con el mismo deletreo, y funciones que coinciden con una local
  sufijada. `pseudolearn_api/tests/python_builtin_reservation.rs` traduce cada programa del corpus a Python,
  reúne los integrados y módulos que la salida realmente usa y exige que una variable del usuario con cada uno de
  esos nombres se renombre.
- Barrido diferencial en `pseudolearn_api/tests/equivalent_code_sweep.rs` (ignorado por omisión):
  ejecuta cada caso `execute` del corpus que termina con normalidad en el motor, lo traduce, lo
  compila con `rustc --edition 2024` o lo ejecuta con `python3.11 -I` y compara la salida byte a byte.
  Se acota con `SWEEP_FILES` (rutas del corpus separadas por `:`), `SWEEP_TARGET` (`rust` o
  `python`) y `SWEEP_DIRECTORY`, y deja el informe en `report.txt`.

## 8. Fuentes consultadas y genealogía conceptual

Ver la sección 4. El oráculo de equivalencia es la salida del motor, no una captura del destino.

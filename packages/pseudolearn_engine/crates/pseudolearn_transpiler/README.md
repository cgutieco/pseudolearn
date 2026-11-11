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

- Red y HTTP (`RedCap`, `PeticionHttp`, `RespuestaHttp`) y JSON (`ValorJson`, `ErrorJson`) se informan como
  construcción `capability` en ambos destinos. Rust no tiene TLS, cliente HTTP ni JSON en su biblioteca estándar.
  Python sí tiene `urllib` y `json`, pero reproducir la política de red del motor (redirecciones entregadas al
  programa, límites de respuesta, errores tipados) y el texto canónico y los códigos de error de JSON exige un
  port propio que aún no está hecho.
- En Rust, `AhoraLocal` (`clock_local_now`) se informa como `capability`: la biblioteca estándar no expone la zona
  horaria del sistema. Python la obtiene con `time.localtime().tm_gmtoff`. El resto de `FechaHora` sí se traduce.
- En Rust, `Instantanea` copia en profundidad primitivos, cadenas, enumerados, registros, variantes de usuario,
  vectores y diccionarios (`rust_snapshots`: un `impl Snapshot` por tipo, emitido junto al auxiliar solo cuando
  el programa lo usa y solo para tipos cuyos campos son todos copiables). Los alias internos del grafo no se
  conservan como pide la regla del corpus. Los objetos de clase los rechaza el lenguaje
  (`snapshotNotSupported`). `Copiar` de un objeto de una jerarquía de clases en Rust se informa como
  `builtin:shallowCopy`.
- En Rust, una variable declarada sin valor y de tipo escalar, cadena, enumerado o registro con `Default` se emite
  como `let mut x: T = Default::default();`: el análisis garantiza la asignación definida antes de cada lectura, pero
  `rustc` no la prueba cuando se asigna en las ramas de un `match` o campo a campo (E0381). Las variables de otros
  tipos siguen declarándose sin valor.
- Barrido diferencial de `lang/*.md` y `lib/*.md` sin HTTP ni JSON: Rust 1234 de 1274 y Python 1246 de 1274, con
  22 muestras omitidas porque su anfitrión simulado no se puede reproducir en un sistema real (sección 7). En
  ambos destinos fallan, además de los pendientes por destino de arriba, `lib.core.math` C25 y C26 (último bit de
  `asen` y `acos`, ver más abajo) y `lang.types.vector` C19 (un comparador incoherente que siempre devuelve -1
  deja un orden que depende del algoritmo de ordenación de cada destino). En Rust no compilan además 26 muestras
  por causas ajenas a capacidades: genéricos e interfaces genéricas (parámetros de tipo sin monomorfizar),
  funciones como valor mostradas o comparadas, registros con préstamos solapados o campos de tipo primitivo,
  un enumerado vacío en `Segun` y un parámetro por valor reasignado; y `lang.types.variant` C10 se informa como
  `array_without_default` (arreglo de variantes sin valor por omisión). En Python difieren por las mismas causas de funciones como valor y registros, y por
  `lang.subprogram.by-reference` C4 y `lang.subprogram.scope` C9.
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
- `effect_functions` es la tabla compartida por ambos destinos que hace corresponder cada identidad de operación
  de capacidad o de biblioteca (`HirExpression::Effect`) con el nombre de su función de apoyo, y reserva esos
  nombres para que ninguna variable del usuario los oculte. Una identidad ausente de la tabla es un pendiente.
- `rust_target` y `python_target` son los dos emisores. Cada uno separa tipos, declaraciones,
  clases, funciones, sentencias, control, expresiones, llamadas, lugares y catálogo de apoyo. Para los efectos,
  cada destino tiene su emisor (`*_effects`), su catálogo de orden, dependencias e importaciones
  (`*_effect_catalog`) y las fuentes de apoyo por familia (`*_support_host`, `*_support_files`,
  `*_support_library`, `*_support_time`; en Rust además `rust_support_file_contents` y
  `rust_support_channels`, que reúne canales, `Elegir`, cancelación y temporizadores).

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
- Cancelación con limpiezas en Rust: antes la tarea cancelada por el fallo de una hermana se descartaba sin
  ejecutar sus `Diferir`, porque las limpiezas se emiten en línea en cada salida. Elección: cancelación
  cooperativa. Cada tarea ocupa una ranura con su tarea madre; `cancel_task` marca la tarea y, de forma
  recursiva, a sus descendientes vivas y la vuelve a encolar. Las esperas hoja (canal, `Elegir`, tarea,
  temporizador) nunca terminan en una tarea cancelada, así que no consumen datos. Un punto de espera con
  limpiezas pendientes en una función cancelable se emite como `until_cancelled(espera)`: si la tarea está
  cancelada y ya no tiene descendientes vivas, ejecuta las limpiezas de esa función en orden inverso y se aparca
  en `unwound()`; la función que la llamó observa lo mismo y ejecuta las suyas, de la más interna a la más
  externa. El ejecutor descarta una tarea cancelada cuando queda aparcada sin descendientes vivas, y la guarda
  `Finish` completa su aviso de fin incluso si se descarta antes de empezar. Así el dueño de un ámbito anidado
  espera a que sus hijas terminen sus limpiezas antes de ejecutar las propias. Los puntos de espera sin
  limpiezas siguen siendo `.await` simples. Se descartaron: guardas `Drop` con las limpiezas (tomarían prestadas
  las variables locales que el cuerpo sigue modificando), el desenrollado por pánico (no ejecuta código en
  línea) y devolver `Result<_, Cancelada>` desde cada función suspendible (cambiaría todas las firmas y
  chocaría con `Propagar`). Python ya obtiene este comportamiento de `asyncio` y `try/finally`.
- Capacidades y biblioteca de efectos: cada operación es una llamada a una función de apoyo con el nombre de su
  identidad (`clock_now(&clock)`, `file_open(&directory, "a", "lectura")`); los receptores y los textos que no
  son literales se pasan por referencia en Rust. Las operaciones falibles devuelven `Result<T, IoError>` en Rust
  y `Ok`/`Err` en Python. El registro `ErrorES` del HIR se emite con el nombre fijo `IoError` y el deletreo de
  campos del perfil; Rust le añade `IoError::new(código, incierto)` para que el apoyo no dependa del perfil, y
  Python lo construye por posición. Los tipos de capacidad son `Console`, `Arguments`, `Environment`, `Clock`,
  `Timer`, `Directory`, `File` y `DateTime`; `Bytes` es `Vec<u8>`/`bytes`, y `Vector<Cadena>` sigue siendo
  `Rc<RefCell<Vec<String>>>`/`list`. La semántica sigue al anfitrión físico (`pseudolearn_host`) y a la
  validación del runtime: autoridad plena inicial, derechos de lectura y escritura que una derivación no puede
  ampliar, ruta vacía o con NUL como `ruta_invalida`, cierre compartido por todas las copias de la capacidad
  (`Rc` en Rust, objeto mutable en Python) en lugar de la generación de la tabla, y los mismos códigos de
  `ErrorES`. El confinamiento de un directorio derivado combina la comprobación léxica del anfitrión
  (`checked_path`) con la canonicalización de la ruta; sin descriptores de `cap-std`, que no pertenecen a la
  biblioteca estándar, un cambio concurrente del sistema de archivos entre la comprobación y la apertura no
  queda cubierto. `EstablecerCodigoSalida` guarda el código y `main` termina con `finish_with_exit_code()` o
  `sys.exit`. El reloj y el temporizador usan nanosegundos reales: `Aguardar timer.Esperar(n)` en una función
  asíncrona registra un plazo en la cola de temporizadores del ejecutor, que solo duerme cuando no hay tareas
  listas y descarta los plazos de tareas terminadas; sin `Aguardar`, la espera bloquea el hilo.
- Biblioteca pura: las funciones de texto reutilizan los auxiliares existentes (`substring`, `text_position`,
  `replace_all`, `split_text`) o añaden uno por operación; `Decimales` redondea los empates alejándose de cero
  sobre la expansión decimal exacta (Rust con `{:.1100}` y Python con `decimal` de precisión 1200). `FechaHora`
  porta el calendario civil del motor (`days_from_civil`, `civil_from_days`), su validación y su formato ISO.
- Funciones numéricas: un receptor literal (`raiz(4)`, `abs(-3)`) se escribe con el tipo explícito
  (`f64::sqrt(4.0)`), porque `rustc` no infiere el tipo de un literal usado como receptor de método. `min` y
  `max` reales usan `real_minimum` y `real_maximum`, que tratan los ceros con signo como el motor.
- Métodos suspendibles: el lenguaje rechaza `Suspendible` en métodos y constructores
  (`suspendibleModifierNotAllowed`), así que las jerarquías no necesitan futuros en caja y no se traducen.

Fuentes consultadas: documentación de Rust (`std::task::Wake`, `std::future::pending`, coerción a objetos de
*trait* con *upcasting*, ámbito de temporales de la edición 2024, `std::fs`, `std::io::ErrorKind`) y de Python
3.11 (`asyncio`, `match`, `dataclasses`, `os`, `errno`, `decimal`, `time.localtime`). Se tomó el modelo de ejecutor de un hilo y la coerción entre `Rc<RefCell<dyn …>>`; se
rechazó depender de `tokio`, `serde_json` o cualquier biblioteca fuera de la estándar.

## 5. Reglas de legibilidad, estilo y estructura de código

Código inglés sin comentarios, doc, allow, expect, pánicos ni unsafe. Las funciones de apoyo de los
destinos son texto de salida (constantes de cadena), no código de este crate. El código emitido no
lleva comentarios.

## 6. Decisiones de producto que condicionan el código

`API.PROGRAM.VIEW#R17` y `#R18`: el código equivalente se ofrece solo si toda construcción tiene
traducción; en otro caso se nombran las construcciones con su tramo. `#R19` exige traducir en ambos destinos las
capacidades y la biblioteca que caben en la biblioteca estándar, con la semántica de `LANG.CAPABILITY.MODEL`, y
ejecutar las limpiezas de las tareas canceladas; deja pendientes la red, HTTP, JSON y, en Rust, la hora local. El destino Python exige 3.11
(`match`, `asyncio`) y el destino Rust la edición 2024.

## 7. Verificación, testing y aseguramiento de calidad

- `tests/` refleja `src/`: pruebas de caja negra de `transpile` para cada destino con caminos felices
  (programa vacío, tareas, variantes, registros, clases), infelices (construcción sin traducción) y
  límites (literales enteros extremos, nombres reservados del destino). `tests/member_spellings.rs` cubre
  campos, campos heredados, clases y registros con el mismo deletreo, y funciones que coinciden con una local
  sufijada. `pseudolearn_api/tests/python_builtin_reservation.rs` traduce cada programa del corpus a Python,
  reúne los integrados y módulos que la salida realmente usa y exige que una variable del usuario con cada uno de
  esos nombres se renombre.
- `tests/effect_functions.rs`, `tests/rust_effects.rs`, `tests/python_effects.rs`, `tests/rust_tasks.rs` y
  `tests/rust_builtins.rs` cubren capacidades y biblioteca en ambos destinos, los pendientes (JSON en ambos y la
  hora local solo en Rust), la reserva de nombres de apoyo, el código de salida, el temporizador con y sin
  `Aguardar`, la espera cancelable con limpiezas frente a la espera simple, los receptores literales, los ceros
  con signo y el azar.
- Barrido diferencial en `pseudolearn_api/tests/equivalent_code_sweep.rs` (ignorado por omisión):
  ejecuta cada caso `execute` del corpus que termina con normalidad en el motor, con el `anfitrion` simulado del
  caso, lo traduce, lo compila con `rustc --edition 2024` o lo ejecuta con `python3.11 -I -u` y compara la salida
  byte a byte, con la salida de error mezclada en el mismo flujo como hace el motor. `equivalent_code_sweep/host.rs`
  reproduce el anfitrión en una carpeta temporal: archivos y directorios bajo `root/`, la carpeta de trabajo en la
  que `SolicitarDirectorio("root")` o `(".")` llegan a esa raíz, entorno limpio con las variables del caso,
  argumentos y la falla `permiso_denegado` de `file_open` como archivo sin permisos. Las lecturas de reloj y
  temporizador son reales, así que en esos casos compara la salida con cada número sustituido por `#`. Omite
  (`SKIP`) los anfitriones que un sistema real no puede reproducir: otras fallas inyectadas, reloj agotado,
  archivos fuera de la carpeta de trabajo, nombres que solo difieren en mayúsculas y claves como
  `offset_seconds`. Se acota con `SWEEP_FILES` (rutas absolutas del corpus separadas por `:`), `SWEEP_TARGET`
  (`rust` o `python`) y `SWEEP_DIRECTORY`, y deja el informe en `report.txt`.

## 8. Fuentes consultadas y genealogía conceptual

Ver la sección 4. El oráculo de equivalencia es la salida del motor, no una captura del destino.

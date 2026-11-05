# pseudolearn_semantic

## 1. Qué es y qué no es

Produce un HIR tipado desde la resolución estática. El análisis registra firmas antes de resolver cuerpos y produce expresiones tipadas en columnas.

Fuera de alcance: otras responsabilidades del motor, UI, I/O libre y construcciones nuevas.

| Pendiente | Dependencia | Hito técnico |
|---|---|---|
| Consumir el HIR desde lowering y ampliar propiedades de ejecución | RI verificada | Motor de ejecución |

## 2. Guía operativa y ciclo de vida

Rust exacto del miembro, rustfmt y Clippy. Biblioteca del workspace; no se despliega por separado.
La implementación se verifica desde el workspace con `cargo xtask verify` y conformidad del sujeto engine.
La comprobación disponible usa, desde la raíz del monorepo,
`cargo run --manifest-path packages/pseudolearn_rust_checks/Cargo.toml -p pseudolearn_check_command -- layers packages/pseudolearn_engine`.

## 3. Arquitectura y modelo del sistema

Nivel 3. Dependencias internas permitidas: pseudolearn_abi, pseudolearn_source, pseudolearn_project, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax. Externas: biblioteca estándar; serde_json solo en pruebas del HIR contra el corpus.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

`project_profile` comparte entre API y servicio la resolución de perfil por argumento de archivo, excepción y perfil del paquete, palabra de apertura y perfil de la petición. El lexicon detecta solo la primera palabra reservada que fija el perfil; la capa semántica reúne esa señal con la política de proyecto existente para evitar que consumidores resuelvan perfiles con reglas divergentes.

Estructuras y algoritmos: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; resolución de jerarquía y ranuras virtuales en mundo cerrado.

Invariantes: No hay fases semánticas con errores sintácticos; un símbolo inválido no genera cascadas (`DIAG.CLASSES`).

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

Tipos de capacidad (`capability_types`): `find_capability_kind`, `capability_canonical_name` y `is_capability_name` reconocen los nombres de capacidades del lenguaje (`Consola`, `Argumentos`, `Directorio`, `Archivo`, `Reloj`, `Temporizador` y sus contrapartes en inglés) y los asocian canónicamente con `pseudolearn_abi::CapabilityKind` (`LANG.CAPABILITY.MODEL`). Esto permite que el análisis semántico verifique firmas y tipos de capacidades sin acoplar la semántica al runtime del motor.

Verificación de pureza y efectos (`effect_check`, `effect_pure_values`): `effect_check::check` construye el grafo de llamadas (llamadas directas, métodos virtuales, constructores y valores de función, incluidas las clausuras y los argumentos función que recibe cada llamada) y propaga la impureza hasta punto fijo. Una unidad escrita con `Funcion`/`Function` es pura (la pureza se decide por el lexema de la declaración): se rechaza con `pureFunctionSideEffect` si contiene `Escribir`, `Leer` o una operación de capacidad con efecto, y con `pureFunctionTransitiveSideEffect` si alcanza otra unidad impura. Además, `local_registry` registra en `HirModule.pure_locals` los vínculos locales y parámetros cuyo tipo función fue escrito con `Funcion`/`function` (conservados por `FlowBindings`), y `effect_pure_values::check_pure_function_values` verifica en todas las unidades del programa (`Algoritmo`, `SubProceso`, `Metodo` y `Constructor`) que ninguna asignación ni argumento pasado a un vínculo puro entregue una clausura o subprograma con efectos secundarios (`LANG.CAPABILITY.PURITY` R3). La implementación de un método de `Interfaz` declarado `Funcion` impura se rechaza con `pureFunctionInterfaceImpurity`. Los diagnósticos transitivos, de valores función puros y de interfaz llevan como `related` la cadena causal, unidad por unidad hasta la que realiza el efecto directo (`propagate_effects` guarda el primer llamado impuro de menor orden de declaración y `causal_chain` lo recorre). Pruebas: `tests/effect_check.rs` (lectura directa, cadena A→B→C con su cadena causal, recursión mutua impura y pura, clausuras anidadas, asignación y paso de subprograma con efecto a tipo `Funcion(...)` desde `Algoritmo` frente a `SubProceso(...)`, método con efecto, interfaz directa, indirecta y pura, `SubProceso` aceptado, función vacía).

## 4. Decisiones de diseño y fundamentos técnicos

La división real amplía explícitamente ambos operandos enteros en el HIR; el tipo de resultado real no sustituye las conversiones de entrada. Se descarta emitir una operación entera y etiquetar su resultado como real.

Problema: produce un hir tipado desde la resolución estática respetando los observables del corpus.
Elección: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; resolución de jerarquía y ranuras virtuales en mundo cerrado.
Alternativas descartadas y fundamento: Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.


Problema: la traducción necesita identidades, tipos y designadores estables, sin resolver nombres otra vez.
Elección: seis responsabilidades separadas: registro de unidades y firmas, jerarquía, resolución de
variables por unidad, tipos, flujo y emisión. `HirModule` conserva funciones, clases, locales,
columnas de expresiones y columnas de sentencias. Los identificadores de arena son tipos distintos.
Cada expresión tiene tipo internado, clase escalar o referencia y tramo. `HirPlace` distingue ubicaciones
asignables; `Widen` materializa la ampliación entero → real. Las incorporadas usan la firma generada.
Los nombres locales se registran en orden de declaración. `block_scopes` mantiene una tabla contigua de vínculos
y marcas de entrada; cada rama y cuerpo de bucle introduce un ámbito y al salir se restaura el vínculo exterior.
Los bloques hermanos admiten nombres iguales, el sombreado se advierte con origen relacionado y una declaración
terminada se distingue de un nombre desconocido. No se reserva un mapa por bloque. El flujo de asignación sí se separa por
rama y combina con intersección al salir de una condición. Una resolución inválida conserva la causa
y evita diagnósticos derivados. Los campos se resuelven desde el tipo del receptor y su clase propietaria.
La auditoría consume además fuentes regenerables de see_generators en ambos vocabularios,
sin importar el sistema de especificaciones como crate. La emisión del HIR se habilita solo sin errores; las advertencias no la bloquean.
Alternativas descartadas: resolución global, copiar lexemas de tipos y volver a interpretar el texto en lowering.

Cada repetición de inferencia restaura los símbolos locales originales y conserva únicamente los tipos inferidos de parámetros. Los vínculos locales tienen tipo explícito y nunca se crean por primera asignación. La sesión no guarda estado de variables inferidas: la asignación nunca fija ni ensancha el tipo de un vínculo y la ficha de ayuda no informa inferencia. Se descartó conservar ese estado por si el lenguaje lo recuperara, porque ninguna regla del corpus lo exige (`SCOPE-YAGNI`). Los códigos `inferredVariableType`, `widenedVariableType` y `typeConflictOnInferredVariable` siguen en el catálogo de diagnósticos sin emisor; retirarlos es una decisión de catálogo registrada como pendiente. La repetición elimina temporales de patrones y evita que diagnósticos o lecturas de una pasada alteren la siguiente. Antes de publicar el HIR se resuelven las referencias a parámetros cuyo tipo se completó durante el análisis. Los estados internos Unknown/Error no se publican como tipos válidos del lenguaje.

Los emisores completan los argumentos tipados del catálogo: aridad numérica, tipos inferidos,
compatibilidad de asignación y clase propietaria de miembros privados. Los tipos primitivos usan
identidades del léxico; los nombres de clases son datos del usuario y no se confunden con esas identidades.

El análisis para servicios (`analyze_for_service`) conserva, además del módulo HIR y los diagnósticos, los símbolos,
las ocurrencias de cada símbolo (declaración, lectura y escritura, incluidas las declaraciones de campos) y los tipos de
expresión por intervalo. `service_collection` los recopila desde el módulo ya construido; no vuelve a resolver nombres.

Los constructores comprueban la llamada inicial al constructor de la superclase cuando este exige argumentos. `constructor_rules` publica la consulta estructural del primer constructor padre para que el lowering use el mismo criterio, sin duplicar interpretación del HIR.

Problema: un proyecto aporta varios árboles y fuentes a un único HIR. Elección: `analyze_project` registra
declaraciones de todas las unidades, resuelve imports y exportaciones por identidad y solo después analiza los
cuerpos. La sesión conserva un par árbol y fuente por unidad y un ámbito de nombres por unidad (subprogramas,
clases y alias de módulo); cambiar de unidad guarda y carga ese ámbito, de modo que los verificadores existentes
siguen consultando mapas de nombres locales y reciben identidades globales. Cada función y clase registra su
unidad en `UnitTable`, que también guarda los calificadores de módulo, las funciones exportadas y la entrada
seleccionada. Se rechaza concatenar fuentes y analizar módulos con sesiones separadas, porque renumerar
identidades dentro de columnas de expresiones multiplicaría los puntos de fallo.

La resolución de perfiles de archivos de proyecto se comparte aquí entre API y servicio. Aplica la misma precedencia de perfil explícito, excepción de manifiesto, perfil de paquete, apertura detectada y solicitud de proyecto. El detalle de discrepancia viaja junto al perfil elegido; ningún consumidor vuelve a implementar la política.

Problema: importar, reexportar y alias deben conservar una sola identidad. Elección: `module_symbols` extrae
declaraciones y directivas; `module_exports` calcula la tabla de exportación de cada módulo (símbolos públicos
más reexportaciones encadenadas, memoizada y con guarda contra recursión, de modo que un ciclo termina sin
colgarse); `module_imports` crea los enlaces locales y detecta colisiones. `module_cycles` recoge una arista por
cada `Importar` o `Exportar` cuya ruta nombra un módulo (exista o no el símbolo), la entrega al algoritmo de
`pseudolearn_project` y emite `importCycle` en la primera arista que sale del módulo menor, con la cadena en el
argumento y un tramo relacionado por cada arista siguiente, cada uno con la identidad de su propio archivo. Con un
ciclo, `analyze_project` termina tras reportar los diagnósticos de enlace: no registra firmas ni analiza cuerpos, y
no devuelve HIR. Un alias solo cambia el nombre local. El orden de registro es el orden de rutas del
catálogo; una clase importada comparte `ClassId` con su origen, por lo que la desvirtualización por jerarquía
conserva su mundo cerrado. Un alias de módulo solo resuelve llamadas a subprogramas (`alias.Nombre(...)`); las
clases se importan por símbolo. El nombre de enlace de una función o clase de proyecto lleva el calificador
del módulo para que dos símbolos homónimos de paquetes distintos no colisionen en la RI. Las funciones públicas
no se avisan como no usadas, porque su uso puede estar fuera del proyecto.

### Perfil por unidad y alias obligatorio

Cada `ProjectUnit` lleva el perfil de su archivo; `switch_unit` lo instala en las opciones, de modo que la búsqueda de
funciones estándar y el resto del análisis usan el vocabulario de la unidad en curso, también cuando una llamada cruza a
otra unidad. Al enlazar un `Importar`, el nombre local (alias o último segmento) que es palabra reservada del perfil de la
unidad que importa produce `reservedImportNeedsAlias`; un alias legal lo resuelve y el símbolo conserva su identidad, que
es independiente del lexema. Descartado: renombrar el símbolo en el módulo exportador o inventar un escape de nombres.

### Constantes, enumerados y registros por valor

**Constantes.** `Constante nombre Como tipo <- expresión` se calcula durante el registro, no en ejecución. El evaluador
(`constant_nodes`, `constant_evaluator`, `constant_arithmetic`) recorre el árbol sintáctico y no el HIR, porque el
inicializador no debe pasar por la comprobación de variables ni dejar lecturas en el análisis de uso. Admite literales,
otras constantes, miembros de enumerado, signos, `NO`, `+ - * / div mod`, comparaciones, `Y`/`O` con cortocircuito y
concatenación de texto; la potencia, las variables y las llamadas dan `constantNotEvaluable`. Cada constante tiene
estado (`Pendiente`, `Evaluando`, `Valor`, `Fallida`) en una tabla contigua con sus ámbitos de nombres (módulo y función);
evaluar una constante evalúa antes las que referencia, con un ciclo reportado una sola vez y dependientes que fallan en
silencio. El presupuesto por constante es de 10 000 pasos y 65 536 bytes por valor de texto (un valor de exactamente ese
tamaño cabe) y la profundidad de dependencia se acota en 256; los límites se inyectan en la sesión para probar justo
debajo, en el límite y encima sin construir programas enormes. El resultado se pliega como `Literal` en cada uso, por lo
que lowering no conoce las constantes. La aritmética repite la del runtime (enteros comprobados de 64 bits, cociente
truncado, `mod` con mínimo entre -1 igual a 0, real finito y todo divisor cero es error) porque semantic no importa
runtime ni la biblioteca; la conversión de entero a real se copia del algoritmo de la biblioteca y un test la compara con
la conversión exacta. Se rechaza evaluar con funciones de biblioteca para no duplicar ni desviar la matriz de
operaciones. Una constante de módulo es privada del módulo; una constante local se evalúa al declararse y comparte el ámbito
léxico de los demás vínculos. Puede ocultarse un nombre exterior, pero no repetirse en el mismo ámbito.

**Enumerados.** `Type::Enum` es escalar. Cada miembro es un `Literal::Integer` con el ordinal (desde cero, en orden de
declaración) y tipo enumerado, de modo que `Segun`, la igualdad y las constantes lo usan sin ramas nuevas; el nombre
se conserva con su grafía de declaración en `HirEnum` para `Escribir`. Solo admiten `=` y `<>` entre valores del mismo
enumerado; el orden y la aritmética son `incompatibleOperandTypes`. Un enumerado vacío es válido. El nombre comparte
espacio con clases y registros del módulo (`duplicateTypeDeclaration`); los miembros pueden repetirse entre enumerados
porque siempre se cualifican.

**Registros.** `Type::Record` no es un valor de la RI. Semantic calcula las hojas de cada registro en orden de
declaración (`HirRecord.leaf_types`, `leaf_names`, y por campo `offset` y `width`) y crea para cada variable de tipo
registro un `HirLocal` sintético por hoja (`record_locals`, nombre `p.x`, no nombrable por el programa). Así el entorno
SSA de lowering, los acarreos de bucle y las uniones de ramas, que ya operan por `LocalId`, sirven sin cambios. La
contención por valor se detecta con un recorrido iterativo en profundidad que emite un solo diagnóstico por ciclo y
reemplaza el campo ofensor por tipo de error para que el aplanado termine; las hojas se calculan en el orden de
terminación, de modo que los registros anidados ya están listos. Se descarta representar el registro como objeto en el
montón con copia: asignaría memoria en cada copia; su condición de reversión es una medición con cargas de registros que muestre
presión de registros o copia dominante.

**Registros en todas las posiciones (PG-L).** Ninguna posición de registro se rechaza ya por construcción. Decisiones:

- *Firmas de miembros.* Un registro viaja como parámetro y resultado de métodos y constructores con el mismo transporte que
  las variantes incorporadas (un argumento por hoja, una celda de resultado por hoja): no hay comprobación especial.
- *Campo de clase de tipo registro (incrustado).* `class_record_fields` registra el campo lógico (`HirClassRecordField.field`,
  que resuelve `objeto.campo` con tipo registro) y un campo físico por hoja (`campo.hoja`, no nombrable por el programa) en
  `HirClass.fields`, de modo que el mapa de referencias por clase, la copia de objetos y la densidad no cambian y no se asigna
  memoria por copia ni se crea una identidad nueva. `record_access::place` traduce `objeto.campo.sub` a `HirPlace::Field` sobre
  la hoja, o a `HirPlace::FieldRange` cuando el destino es un subregistro. Se descarta la caja oculta porque cada copia crearía
  un objeto observable (`MEM.IDENTITY`).
- *Registro por referencia.* El parámetro conserva una hoja sintética por campo y todas heredan `Passing::Reference`; el
  llamador entrega una celda por hoja (variable, campo incrustado o elemento). El tipo debe coincidir exactamente.
- *Arreglo de registros (desviación de DL-02).* Se descartó extender la RI, el bytecode, la VM y el sujeto nativo con elementos
  de varias hojas: los arreglos de la RI tienen un único `ValueKind` por elemento. Como un arreglo solo vive en variables y
  parámetros (no puede ser campo ni resultado), `array_components` crea un arreglo sintético por hoja (`a.x`), el parámetro
  arreglo se expande a un arreglo por hoja igual que el registro, y `HirPlace::ElementRange` direcciona una hoja de un
  elemento. Cada hoja conserva su estado de definición (DL-03). Condición de reversión: una medición que muestre coste de
  `PL-E03` dominado por los arreglos paralelos, o que el estado de inspección no pueda agrupar las hojas sin ambigüedad.
  Límite: un registro de más de `RECORD_ARRAY_MAXIMUM_LEAVES` (1 024) hojas no es elemento de arreglo
  (`recordArrayTooWide`). Cada `array.new` es un punto seguro cuyo mapa de raíces lista todos los arreglos vivos, así que `n`
  hojas producen `n²` entradas: con 65 535 hojas el proceso agotaba la memoria (medido: 2 000 hojas tardan 5 s en
  depuración y 8 000 tardan 77 s). Como variable o campo de clase el registro admite las 65 535 hojas de
  `RECORD_MAXIMUM_LEAVES` (coste lineal). La vista de estado muestra una variable `q.x` por hoja y, para un arreglo, una
  referencia por hoja (`a.x`) a un arreglo con sus celdas; un campo de clase se lista como `p.x` dentro del objeto. Se
  conserva ese formato por hoja en lugar de agrupar los elementos porque ya es el de las variables registro.

**Exportación de tipos y constantes (PG-L).** Subprogramas, clases, interfaces, enumerados, registros y constantes de nivel
superior son privados salvo `Publico` y se importan y reexportan por símbolo con la misma resolución que subprogramas y clases
(`module_symbols` añade las clases de símbolo; `module_exports` y `module_imports` no distinguen la clase). `module_type_links`
ordena el registro de un proyecto en tres pasos: declarar nombres de tipos y constantes de todas las unidades, enlazar los
símbolos importados en el `TypeScope` de cada unidad (`declared.records/enums/constants/interfaces` apuntan a la identidad de la
unidad dueña, de modo que un alias solo cambia el nombre local) y recién entonces resolver campos de registros, realizaciones de
interfaces y diseños. Una constante importada se evalúa en su unidad dueña (`constant_evaluator::run` restaura la unidad activa)
y se pliega como literal. Se descartó el acceso por alias de módulo (`m.Constante`, `m.Color.Rojo`) por ampliar la resolución de
alias de módulo, hoy limitada a llamadas.

**Coherencia de las firmas públicas (PG-L.02).** Problema: una biblioteca puede exportar un subprograma, un registro, una
interfaz o una clase cuya firma menciona un tipo que el módulo no exporta, y el consumidor no podría nombrar ese tipo ni
construirlo. Elección: `public_signatures` recorre, después de enlazar los módulos, las unidades públicas de cada módulo y recoge
los nodos de tipo de sus firmas (parámetros y resultado de subprogramas; campos de registros; campos, métodos y constructores no
marcados `Privado` de clases; métodos de interfaces), incluidos los argumentos de tipo anidados, y produce
`privateTypeInPublicSignature` en cada aparición de una clase, interfaz, enumerado o registro del mismo módulo sin `Publico`. La
comprobación es sintáctica sobre las declaraciones del módulo (`UnitDeclarations`) para que no dependa del orden de resolución ni
de la importación: un tipo importado es público en su origen y nunca se marca. Los cuerpos y las firmas de unidades privadas no
se comprueban porque ningún consumidor las ve. Se descartó rechazar también `Hereda De` y `Realiza` con tipos privados (no son
firmas) y emitir un solo diagnóstico por unidad (oculta apariciones distintas).

**Símbolos de tipos y constantes para el servicio (PG-L.02).** Problema: el servicio de lenguaje solo conocía locales, funciones,
clases y campos, de modo que navegar o renombrar un registro, un enumerado, una constante o una interfaz no tenía identidad
semántica. Elección: `ServiceSymbolTarget` añade `Record`, `Enum`, `Interface` y `Constant`. Las declaraciones se anotan al
declararlas (`HirModule.name_declarations`, con el tramo de la unidad completa como las clases) y los usos al resolverlos
(`HirModule.name_uses`, con el tramo exacto del identificador): tipo en posición de tipo, nombre de enumerado antes del miembro,
construcción de registro, referencia a constante, `Realiza` y restricción de parámetro de tipo. Una constante carece de entrada
en el HIR, por lo que `constant_names` conserva su nombre y su identidad es el índice del registro de constantes. Como el
conjunto es ordenado y sin repetidos, resolver varias veces el mismo cuerpo no duplica referencias. La ruta de cada `Importar` y
`Exportar` que resuelve a un símbolo es un uso más (`import_uses`, tras enlazar funciones y clases): sin él, renombrar un
símbolo dejaba la declaración de importación apuntando a un nombre inexistente, y eso valía también para funciones y clases. Un
uso por alias conserva su tramo propio y su grafía; el renombrado solo edita ocurrencias con la grafía del símbolo.

Pendientes declarados: registro por referencia a través de valores función (no verificado); acceso a miembros por alias de
módulo (`m.Constante`, `m.Color.Rojo`), descartado hasta que la resolución de alias de módulo deje de limitarse a llamadas.

Los vínculos locales tienen mutabilidad explícita en `HirLocal`; su declaración emite una asignación inicial y no cuenta como modificación. `binding_checker` valida inicialización y destinos de reasignación, incluidos campos de registros por valor y argumentos por referencia. Los objetos pueden mutar a través de un vínculo inmutable. La asignación a un nombre no declarado es error y no crea una variable por inferencia. La inicialización obligatoria reemplaza la trampa de lectura sin valor para locales; campos y elementos conservan su contrato. La forma inicializada es la oficial de la edición: no hay migrador, selector de compatibilidad ni conservación de la sintaxis anterior.

La exhaustividad de enumerados pertenece a `switch_coverage`: cubre ordinales en orden de declaración, permite enumerados vacíos y acepta De Otro Modo como cobertura total. Los errores de patrones se informan primero y suprimen diagnósticos derivados de cobertura. El analizador conserva ramas posteriores al comodín para informar su inalcanzabilidad.

Las variantes incorporadas son agregados identificados en `HirModule.variants`, separados de los registros nombrables. Sus instancias concretas se internan por familia y argumentos. Semantic importa también abi para consumir `VariantLayout`, evitando recalcular una disposición distinta: las hojas canónicas son palabras enteras y referencias, con unión por banco. Solo el opcional de una referencia no nula reutiliza el centinela; el opcional de otro opcional conserva discriminante. Los constructores reciben el tipo contextual de declaraciones, retornos y argumentos. Los patrones introducen vínculos inmutables limitados a su rama; un temporal interno evalúa el selector una vez. La propagación verifica la familia y la identidad exacta del tipo de error. Los resultados pendientes se siguen por vínculo y se unen por caminos; retorno, propagación, patrones y descarte transfieren o satisfacen la obligación. No existe migrador ni lenguaje anterior seleccionable.

Los locales de ramas no son visibles al salir. `Repetir` mantiene sus vínculos durante `Hasta Que`; `Para`
evalúa los límites antes de introducir un control entero local, no reasigna un vínculo exterior y rechaza
modificaciones del control. Las obligaciones de `Resultado` se comprueban al cerrar el ámbito, aunque el
programa nunca vuelva a nombrar el vínculo. `local_visibility` conserva los tramos léxicos para servicios: el
completado excluye declaraciones posteriores, ámbitos terminados y archivos distintos, y restaura nombres
exteriores tras el sombreado. La repetición de inferencia restaura también las constantes y elimina declaraciones
y tramos producidos por la pasada anterior.

Liberación por ámbito (PG-L). Los límites de ámbito sí llegan a los mapas de estado y raíces: `roots::expire` de `bytecode`
retira de cada mapa los registros nombrados cuyo intervalo de visibilidad no contiene la instrucción y que no siguen vivos
por flujo, y la inspección filtra por el intervalo léxico actual. La regla `MEM.MANAGED.UNOBSERVABLE#R3` la acredita con
casos de presupuesto de celdas (bucle, rama y control sin ámbito cerrado) que se cumplen sin cambios de semantic. El
sujeto nativo usa vivacidad por flujo y puede liberar antes que el ámbito léxico; los casos de control que esperan
`cellLimitExceeded` con un vínculo en ámbito pero sin usos futuros quedan para su paridad en `PG-N.05`.

### Genéricos de primer orden y monomorfización acotada

Problema: reutilizar un registro o un subprograma para varios tipos sin que cada valor lleve etiqueta de tipo ni la VM despache por tabla. Elección: monomorfización acotada. Cada combinación canónica de genérico y argumentos de tipo produce un registro o una función ordinarios, de modo que lowering, bytecode, VM y Cranelift no conocen los genéricos y las llamadas siguen siendo directas. Se descarta el borrado de tipos porque obligaría a una representación uniforme por valor (banco escalar frente a referencia, ancho de las hojas de un registro) y a etiquetas o diccionarios en ejecución, que contradicen que ningún valor lleve etiqueta de tipo. Se descarta el diccionario de operaciones por el mismo motivo y porque las restricciones llegan con las interfaces.

Declaración. `generic_registry` recoge, antes de registrar clases, tipos y funciones, los registros, subprogramas, clases, interfaces y variantes con `typeParameters`; ningún registrador ordinario los trata como declaraciones. Las plantillas viajan con `UnitScope` (`GenericScope` con una tabla por forma), igual que `declared`; las importadas se añaden a la tabla del consumidor conservando su unidad (ver «Plantillas entre módulos»). Un nombre repetido entre plantillas, o entre plantilla y declaración ordinaria, se rechaza con los diagnósticos de duplicado existentes. Cada parámetro conserva su nodo `TypeParameter`, de modo que una restricción `T: I<U>` resuelve sus argumentos en el entorno de la propia plantilla.

Tipos. `type_resolution::class_type` consulta primero `generic_names`: un nombre del entorno de tipos (`GenericState.environment`) resuelve a su argumento; `nombre<args>` instancia la clase, la variante o el registro con los argumentos ya resueltos; la cantidad errónea de argumentos, incluida la ausencia o la presencia de argumentos en un tipo no genérico, produce `typeArgumentCountMismatch`. El entorno se sustituye, nunca se fusiona, al entrar en una instancia, de modo que un genérico no ve los parámetros de quien lo llama.

Inferencia. `generic_inference` unifica estructuralmente el nodo de tipo de cada parámetro con el tipo del argumento: parámetro directo, registro genérico (comparando contra el origen canónico de la instancia), arreglo y tipo función con su retorno. Un parámetro de tipo sin determinar o con dos valores distintos produce `cannotInferTypeArgument`. Los argumentos se comprueban una sola vez, antes de inferir, y la conversión y las comprobaciones de asignación las hace después `argument_checker` contra la instancia. No hay instanciación explícita en llamadas: `f<T>(x)` es ambiguo con una comparación y la inferencia por argumentos cubre el alcance de la edición. Un retorno o un parámetro que no aparece en los argumentos no se infiere.

Instancias. La clave de caché es `(unidad, nodo de la plantilla, argumentos canónicos)`; las instancias de función se registran, con su cuerpo, durante la comprobación del llamador y se descartan en cada repetición de inferencia junto con las demás funciones creadas en la pasada; las instancias de registro persisten porque sus identidades alimentan tipos internados. La entrada de la caché se inserta antes de comprobar el cuerpo, de modo que la recursión con los mismos argumentos reutiliza su instancia y la contención recursiva de un registro genérico se detecta con el mismo recorrido de disposición que los registros ordinarios. `generic_labels` nombra cada instancia `nombre<tipos>` con nombres de tipo independientes del perfil, estables para mapas de fuente y fallos AOT. El conjunto es cerrado: solo existen las instancias alcanzables desde código real, y un genérico sin usar no genera ninguna.

Comprobación única del cuerpo (D-PG2-06). Cada plantilla se comprueba una vez por pasada con cada parámetro opaco (`generic_opaque`): un registro sintético sin campos, marcado en `opaque_records`, que `function_containment` trata como no comparable. Un valor opaco solo puede copiarse, pasarse, retornarse y guardarse en campos; operarlo, compararlo o escribirlo es un error en la definición, aunque no haya instancias. Esa instancia de definición se descarta por completo (`generic_discard`: funciones, locales, columnas de expresiones y sentencias, y los conjuntos de uso) y solo conserva sus diagnósticos. Las instancias reales se comprueban con los argumentos concretos y sus diagnósticos repetidos se deduplican por código y tramo. Sin restricciones esto es conservador a propósito: las restricciones llegan con las interfaces y ampliarán lo que un parámetro opaco permite.

Límite. El programa admite como máximo 64 instancias entre funciones, registros, clases, interfaces y variantes (`INSTANCE_LIMIT`); superarlo, incluida la recursión polimórfica expansiva, produce `genericInstanceLimitExceeded` con el genérico y el límite. Las instancias creadas durante una comprobación de definición se cuentan aparte para que no consuman el presupuesto del código real. La profundidad del tipo queda acotada por el mismo límite, porque cada nivel nuevo es una instancia nueva.

Clases e interfaces genéricas (DL-09). Una clase plantilla no se registra como clase: `generic_classes::instantiate` crea, por cada combinación canónica de argumentos, una `HirClass` concreta nombrada `nombre<tipos>`, registra sus campos, constructor y métodos con el entorno de la instancia (`class_registry::members`), resuelve su superclase y sus realizaciones con ese entorno y calcula sus ranuras virtuales (`hierarchy::check_class`). Lowering, bytecode, VM y Cranelift reciben clases ordinarias, y el despacho virtual y el mundo cerrado se conservan. La entrada de caché `(unidad, nodo, argumentos)` se inserta antes de registrar los miembros, de modo que una clase que se nombra a sí misma reutiliza su instancia. El entorno de cada instancia se guarda en `class_environments` y `flow::function` lo instala al comprobar el cuerpo de sus métodos, sin fusionarlo con el del llamador. Una instancia creada durante la comprobación de cuerpos (`checking_bodies`) comprueba en el acto sus realizaciones y los cuerpos de sus métodos, porque el recorrido principal ya fijó su rango de funciones; las creadas al registrar firmas o campos se comprueban en el recorrido ordinario. Como las funciones instanciadas, las clases creadas en una pasada se descartan al repetir la inferencia (`generic_classes::truncate`, usado por `FlowBindings` y por `generic_discard::Snapshot`) y se vuelven a crear en el mismo orden. Cada plantilla de clase se comprueba también con parámetros opacos (`generic_discard::check_functions`), y esa instancia de definición se descarta. `Nuevo C<args>(…)` instancia con argumentos explícitos; sin argumentos, `generic_instantiation` los toma del tipo esperado cuando este es una instancia de la misma plantilla (declaración, asignación, retorno o argumento, vía `check_expected`), y en otro caso informa `typeArgumentCountMismatch`. Se descartó inferir los argumentos desde el constructor: con herencia de una base genérica el diagnóstico de inferencia fallida sería poco claro. Las instancias son invariantes porque cada una es una clase nominal distinta. Los ciclos de herencia entre plantillas se detectan por nombre en `generic_class_cycles` antes de instanciar nada y se informan una sola vez en la plantilla que inicia el recorrido; sus instancias quedan sin superclase. Una plantilla de interfaz produce, por cada argumento, una `HirInterface` concreta (`generic_interfaces`); sus firmas se resuelven con el entorno de la instancia, en `interface_registry::signatures` si la instancia nació antes de que los tipos estuvieran declarados, o en el acto después. Por eso las realizaciones se registran tras las declaraciones de tipos (`unit_resolver::register`): una realización `Realiza I<Punto>` necesita el registro `Punto` declarado. Un parámetro opaco con restricción `T: I<T>` se crea antes de resolver la restricción, que puede nombrarlo. Los métodos no declaran parámetros de tipo propios (el parser lo impide), para no abrir una segunda dimensión de instancias.

Variantes declaradas (DL-10). Una variante no genérica se declara junto a los registros (`user_variants::declare_all`) como un `HirRecord` de marcador registrado en `declared.variants`, separado de `declared.records` para que `Nombre(…)` no la construya como registro. Cada alternativa con campos tiene un registro de carga sintético `Variante.Alternativa`; durante la disposición el registro de la variante lista una pseudocolumna por carga para que `record_cycles` calcule primero las cargas y detecte la contención recursiva por valor con `recursiveRecordContainment`, y al completarse (`user_variants::compute`) se reemplaza por la disposición de abi de las variantes incorporadas (`VariantLayout`, familia `User`), se registra en `HirModule.variants` y pierde sus pseudocolumnas. Así lowering, bytecode, VM y nativo reciben la misma forma que `Opcional` y `Resultado`, sin instrucciones nuevas. `user_variant_values` reconoce `Tipo.Alternativa(…)` y `Tipo.Alternativa` sobre el postfijo de punto que ya produce el parser, cuando el nombre designa una variante y no un vínculo; la carga se construye como el registro sintético y se envuelve en `VariantNew`. Una variante genérica (`generic_variants`) se instancia como los registros genéricos y comparte su caché y sus orígenes; su construcción toma los argumentos del tipo esperado o los infiere cuando cada parámetro es directamente el tipo de un campo de la alternativa, y en otro caso informa `ambiguousVariantType`. `user_variant_patterns` interpreta el patrón `Tipo.Alternativa(v1, …)`: exige que el nombre sea la variante del selector o su plantilla, un vínculo por campo, y vincula cada nombre con la lectura del campo de la carga; la exhaustividad informa las alternativas faltantes con su grafía declarada. Igual que las incorporadas, una variante declarada no admite comparación, escritura ni acceso a campos. Se rechazó representarla como clase sellada: crearía identidades de objeto observables y despacho por subclase, que contradicen el paso por valor de las variantes.

Proyectos. El análisis de proyecto recoge las plantillas de cada unidad antes de registrar sus clases y comprueba sus definiciones unidad por unidad (`generic_discard::check_functions` recorre las unidades; `module_type_links` comprueba registros y variantes genéricos tras las firmas). Antes de PG-L.04 el análisis de proyecto no recogía plantillas y un genérico dentro de un módulo de proyecto quedaba sin declarar; era un hallazgo heredado y se corrigió con esta entrega. Una variante no genérica pública se exporta e importa por símbolo como un registro (`SymbolKind::Variant`, enlazada en `declared.variants`) y participa en la coherencia de firmas públicas.

Plantillas entre módulos (DL-08). `GenericTemplate` guarda la unidad que la declara y su identidad de servicio. Una plantilla con `Publico` es un símbolo más de `module_symbols`, de modo que exportarla, importarla con o sin alias, reexportarla y rechazarla por privada (`privateImport`, `privateReexport`) reutiliza la resolución de exportaciones existente. `module_generic_links::link` copia la plantilla importada en la tabla de plantillas del consumidor bajo el nombre local, sin cambiar su unidad, y `link_modules` expone las plantillas de subprograma de un módulo importado para `alias.plantilla(argumentos)` (`module_calls`). La clave de instancia es `(unidad de la plantilla, nodo, argumentos)`, de modo que dos módulos con los mismos argumentos comparten instancia e identidad de registro. Todo lo que lee el árbol de la plantilla (nombre, firmas, cuerpo, restricciones, campos para inferir) se ejecuta en su unidad con `generic_home::at_home`, que cambia de unidad con `switch_unit` y vuelve a la del llamador; los diagnósticos ubicados en el uso (`argumentCountMismatch`, `cannotInferTypeArgument`, `genericConstraintNotSatisfied`, `genericInstanceLimitExceeded`) se emiten en la unidad del llamador, y los de la definición, en la de la plantilla. Por eso `generic_inference` separa la unificación (en la unidad de la plantilla, sin efectos) del informe. Las instancias se nombran con el calificador del módulo de la plantilla (`geo.genericos.Par<integer>`), que es estable y no depende del orden de los archivos; las interfaces instanciadas conservan el nombre sin calificar porque no llegan a la RI. Las comprobaciones de definición (`generic_discard`) recorren solo las plantillas propias de cada unidad para no repetir las importadas. El lock no cambia: fija los digests de los archivos y las instancias se derivan de ellos. Se descartó instanciar en la unidad del consumidor: cada módulo tendría su propia `Par<Entero>`, dos valores iguales serían de tipos distintos y el cuerpo vería los nombres del consumidor.

Comprobación de plantillas sin instanciar (PG-L.05). La comprobación con parámetros opacos cubre subprogramas, registros, clases, interfaces (sus firmas se resuelven con la instancia de definición) y variantes, use o no su módulo la plantilla y sea o no pública. La instancia de definición de una interfaz no se descarta porque no tiene cuerpo ni consume el presupuesto de instancias reales.

Símbolos de plantilla para el servicio (DL-13). `generic_symbols` registra cada plantilla en `HirModule.templates` y anota su declaración, sus parámetros de tipo y sus usos con `ServiceSymbolTarget::Template` y `TypeParameter`; `service_templates` atribuye a la plantilla las ocurrencias de sus instancias. El README de `pseudolearn_service` documenta las consultas.

Límite de disposición de registros. Un registro tiene como máximo `RECORD_MAXIMUM_LEAVES` (65 535) hojas. `record_cycles::compute` trunca las hojas en ese máximo más una y emite `recordLayoutLimit` en el primer registro que lo supera; los registros que lo contienen heredan el exceso sin repetir el diagnóstico ni construir nombres de hoja. Antes de esta entrega el máximo solo existía en abi y el cálculo era exponencial en tipos genéricos anidados con dos campos (`Par<Par<…>>`), que colgaban el análisis; era un hallazgo heredado. La carga sintética de una alternativa de variante declarada usa el mismo cálculo pero no emite `recordLayoutLimit`: el exceso de una variante lo informa `variantLayoutLimit` (`LANG.TYPES.VARIANT` C12), y emitir ambos duplicaba el diagnóstico.

Límites asumidos y pendientes declarados: la medición de tamaño y tiempo frente a un control no genérico (E-PG-03) queda para la campaña de PG-2.17.

Condición de reversión: si E-PG-03 muestra que los bytes de RI, bytecode u objeto crecen más que proporcionalmente al número de instancias, se evalúa compartir el código de instancias de igual disposición de hojas, comprobando su equivalencia, sin cambiar la semántica de la edición.

## 5. Reglas de legibilidad, estilo y estructura de código

Código en inglés, cero comentarios, sin atributos doc/allow/expect ni unsafe.
Los errores son valores Result. Los límites físicos, nombres y dependencias se leen de architecture.yaml del miembro.
Las fuentes generadas se producen desde la exportación del corpus en OUT_DIR; nunca se copian manualmente.

## 6. Decisiones de producto que condicionan el código

Contratos: `LANG.TYPES.*`, `LANG.DECL.*`, `LANG.SUBPROGRAM.*`, `LANG.CLASS.*` (estático).
La ejecución y la observación conservan la misma semántica; idioma de interfaz y vocabulario son independientes.
Los identificadores del usuario, el texto original y la salida del programa se conservan.

## 7. Verificación, testing y aseguramiento de calidad

Tests en tests/ espejo de src/, internos en archivos hermanos separados.
Camino feliz e infeliz, texto vacío, Unicode, tamaño cero, profundidad extrema y bordes numéricos.
Conformidad ejecuta los casos del corpus sin copiarlos como tests Rust.
Verificadores de capas, comentarios, nombres, límites, seguridad y atributos con casos negativos;
formato, Clippy, auditoría de dependencias y pruebas diferenciales según los contratos de este crate.

## 8. Fuentes consultadas y genealogía conceptual

Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.


### Funciones como valores y ámbitos de ejecución

Las firmas función se internan estructuralmente mediante registros sintéticos de dos hojas; `function_types` conserva tipos, orden, modos de paso y retorno exactos. `closure_checker` registra cada literal y mantiene la pila de ámbitos exteriores. `capture_analysis` registra solo capturas inmutables utilizadas, propaga las transitivas y rechaza mutabilidad o préstamo con origen relacionado. `capture_environment` crea proxies locales y una clase interna tipada cuyo tamaño se comprueba antes del lowering. Las funciones nombradas usadas como valor reciben un envoltorio con parámetro de entorno; sus llamadas conocidas conservan el camino directo. Las repeticiones de inferencia descartan funciones y entornos creados en la pasada anterior. El análisis de contención rechaza comparación de funciones incluso dentro de registros; no compara sus dos palabras como datos ordinarios.

## Colecciones, interfaces e iteración con limpieza

Las interfaces solo expresan restricciones nominales. El registro resuelve firmas y realizaciones explícitas; la comprobación de clases incluye métodos públicos heredados y firma exacta. Cuando una sobrescritura incompatible ya tiene diagnóstico y el método resuelto incumple una operación de interfaz, el análisis agrega a `related` el tramo de esa firma del contrato. Así la API puede asociar el diagnóstico existente a la realización correspondiente sin comparar firmas en el consumidor. Los parámetros opacos solo permiten métodos declarados por su restricción. La monomorfización conserva el método de la clase real: usa llamadas directas cuando el receptor se conoce y el despacho virtual existente cuando corresponde, sin tablas de interfaces. Las colecciones usan identidades de clase sintéticas privadas y metadatos tipados de hojas, con permutación escalar antes de referencias; no son instancias ordinarias de clase. Esto reutiliza Type::Object en las fronteras existentes sin perder la información necesaria para verificar las operaciones. El índice de `Vector` y de `Diccionario` se comprueba por asignabilidad y se ensancha igual que un argumento. Un literal de un carácter es `Carácter` y ningún tipo lo acepta como `Cadena`, por lo que las claves de texto de los casos del corpus tienen al menos dos caracteres. Los vínculos de Para Cada son inmutables por valor. ControlContext separa bucles y limpieza por función; las limpiezas se resuelven en el punto de registro y sus efectos sobre resultados pendientes se aplican a las salidas.

Los tests de estas capacidades se ejecutaron en selecciones acotadas; la conformidad del corpus queda pendiente de la revisión editorial independiente de los contratos nuevos.


El análisis de efectos recorre exhaustivamente los operandos del HIR, incluidos condiciones, índices,
variantes, colecciones y límites de bucle. Un recorrido iterativo evita desbordar la pila de análisis;
las aristas incluyen destinos virtuales de mundo cerrado y orígenes de valores funcionales locales y
capturados. Todas las ramas se visitan aunque una anterior ya tenga efecto: detener el recorrido
perdería aristas transitivas. Los casos del corpus se leen desde los tests espejo, sin duplicarlos.


Los tipos opacos de capacidad y Bytes usan clases sintéticas con identidad propia; no se aceptan
constructores ordinarios para falsificar una capacidad. Las solicitudes y los métodos se resuelven
contra la tabla generada del ABI. ErrorES es un registro con código y bandera de incertidumbre,
compatible con las variantes Resultado ya existentes. Los efectos quedan explícitos en el HIR.

## Tipos de fallos y canales

`task_failure_types` infiere un único error exacto y transferible por ámbito, registra
`FalloTareas<E>` y construye `Opcional<FalloTareas<E>>` al salir. El agregado expone `Primero`,
`Asociados` y `Canceladas` con sus nombres activos de perfil. Un lanzamiento consume su resultado
falible mediante el ámbito: no dispara la obligación de resultado descartado de una llamada ordinaria.
El vínculo del ámbito exige consumo por patrón, propagación compatible o descarte explícito;
`result_obligations` y el cierre de ámbitos informan `taskScopeFailureUnused` si queda pendiente.
`task_bindings` declara los vínculos implícitos e inicializa sus componentes sin duplicar declaraciones.

`channel_types` representa cada instancia por un registro interno de identidad escalar y comprueba
transferibilidad transitiva. `channel_checker` exige contexto de tipo para `Canal(n)`, devuelve lógico
al enviar y opcional al recibir, exige espera explícita y rechaza operaciones desde funciones puras.
`select_checker` crea vínculos inmutables locales a cada rama y comprueba un mínimo de dos recepciones.
Los nombres de tipo y método son contextuales; `Elegir` y `FinElegir` son reservados. Los recorridos de
efectos incluyen canales, lanzamientos y las ramas de elección para conservar la comprobación transitiva.

Pruebas dirigidas: filtros `task_failure_types`, `channel_types` y `select_checker` de
`cargo test -p pseudolearn_semantic --lib`.

## Aislamiento e instantáneas

`transferability` concentra el predicado estructural usado por argumentos de lanzamiento, elementos
de canal y errores de tareas. Recorre iterativamente los campos por nombre, variantes y componentes incorporados;
rechaza funciones aunque solo capturen escalares, clases, colecciones mutables, asas de tarea y
parámetros genéricos opacos. Detecta ciclos de tipos sin recursión infinita y entrega tipo y ruta del
primer componente rechazado a los diagnósticos. Bytes no expone mutación y conserva transferibilidad.

`snapshot_support` comprueba el grafo estático que acepta `Instantanea`; `snapshot_types` conserva
`Inmutable<T>` como tipo distinto, sin conversiones implícitas. Las lecturas de elementos, campos,
variantes y enlaces de iteración conservan la restricción en los resultados mutables. Las escrituras
y los métodos mutadores se rechazan antes de bajar a RI. Se toma de Swift Sendable la comprobación
estructural y de Pony el aislamiento transitivo; se rechazan actores, capacidades de referencia y
préstamos visibles en el lenguaje. Una tarea terminada entrega su resultado sin exigir transferibilidad.

`FalloTareas<E>.Asociados` tiene tipo `Inmutable<Vector<E>>`: el informe puede transferirse sin
exponer una colección mutable compartida. La construcción del informe crea su vector propio y
solo presenta su vista inmutable; no se añade una copia redundante.

## Tipos HTTP contextuales

`http_types` resuelve `RedCap`, `MetodoHttp`, `PeticionHttp` y `RespuestaHttp` como tipos
incorporados; `MetodoHttp` expone únicamente sus seis miembros canónicos en ambos perfiles. Los
nombres son contextuales y no se agregan palabras reservadas, para evitar cambiar el análisis de
identificadores existentes. `RedCap` y los valores HTTP conservan la transferibilidad estructural
necesaria para enviar solicitudes desde tareas suspendibles.

## Expresiones de inspección

`inspection_expression` recibe el árbol de una expresión y un entorno explícito de nombres/tipos; reutiliza resolución léxica, operadores, campos e índices del analizador ordinario. Valida el subconjunto sin llamadas antes de comprobar tipos. Cada valor del marco es un parámetro inmutable; los literales de texto se convierten en capturas adicionales para que la ejecución temporal pueda conservar un heap aislado con identidades estables sin reinterpretar texto. No importa API, VM ni timeline.

La inspección reconstruye vistas de registros aplanados desde las capturas léxicas explícitas; el acceso a campos usa el HIR y lowering de registros existentes. Un nombre de arreglo puede inspeccionarse como referencia sin materializar sus celdas. Las llamadas siguen rechazadas aunque sean puras o pertenezcan a una colección.

## Ampliación numérica y de colecciones

Los miembros nuevos se resuelven por identidad contextual del receptor. Ordenar acepta un comparador síncrono por valor de dos argumentos T y resultado Entero. La búsqueda admite primitivos; Claves registra un Vector del tipo de clave. min/max usan widestNumeric y amplían únicamente si participa un Real.

Claves conserva el envoltorio Inmutable al consultar un diccionario inmutable, mediante el mismo contrato de lectura que el resto de los resultados referenciales no transferibles. Una copia nueva no elimina la garantía de tipos del receptor; la búsqueda de primitivos conserva resultados transferibles.

## Entorno y fecha y hora (`PG-S.05`, `PG-S.06`)

`Entorno`/`Environment` se resuelve como nombre de capacidad (`capability_types.rs`) y `FechaHora`/`DateTime` como
tipo opaco de efecto (`effect_types.rs`), con `Opcional<FechaHora>` construido por `json_types.rs` junto al resto de
opcionales de efecto. Ninguna construcción de registros como resultado: el valor de calendario es opaco (DS-13).

## Ampliación de argumentos de operaciones D2 (`PG-S.08`, `PS-V-03`)

Hipótesis `PS-V-03` refutada: `assignable` aceptaba un entero para un parámetro real de una operación D2, pero el
argumento llegaba al IR como `i64` y la verificación de tipos del IR rechazaba la llamada (`analysisFailed`).
`effect_checker::check_argument` envuelve ahora el argumento entero en `HirExpression::Widen` cuando el parámetro es real,
con el mismo `widen` que usan las asignaciones. `Decimales(7, 2)` produce `7.00`.

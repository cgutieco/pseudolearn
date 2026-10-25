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

Nivel 3. Dependencias internas permitidas: pseudolearn_abi, pseudolearn_source, pseudolearn_diagnostics, pseudolearn_lexicon, pseudolearn_syntax. Externas: biblioteca estándar; serde_json solo en pruebas del HIR contra el corpus.
Prohibido importar capas superiores, paquetes de UI o internos de otros miembros.

Estructuras y algoritmos: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; resolución de jerarquía y ranuras virtuales en mundo cerrado.

Invariantes: No hay fases semánticas con errores sintácticos; un símbolo inválido no genera cascadas (`DIAG.CLASSES`).

Ejecución síncrona determinista; los efectos del anfitrión solo cruzan capacidades inyectadas.

## 4. Decisiones de diseño y fundamentos técnicos

La división real amplía explícitamente ambos operandos enteros en el HIR; el tipo de resultado real no sustituye las conversiones de entrada. Se descarta emitir una operación entera y etiquetar su resultado como real.

Problema: produce un hir tipado desde la resolución estática respetando los observables del corpus.
Elección: Columnas con índices tipados (`LocalId`, `FunctionId`, `ExpressionId`, `TypeId`) en columnas; resolución de nombres y después de tipos; HIR tipado con la clase de valor de cada expresión; resolución de jerarquía y ranuras virtuales en mundo cerrado.
Alternativas descartadas y fundamento: Arenas con índices tipados evitan referencias enlazadas y sus tiempos de vida. Se rechaza Rc<RefCell<…>> por coste y errores dinámicos de préstamo.


Problema: la traducción necesita identidades, tipos y designadores estables, sin resolver nombres otra vez.
Elección: seis responsabilidades separadas: registro de unidades y firmas, jerarquía, resolución de
variables por unidad, tipos y rigor, flujo y emisión. `HirModule` conserva funciones, clases, locales,
columnas de expresiones y columnas de sentencias. Los identificadores de arena son tipos distintos.
Cada expresión tiene tipo internado, clase escalar o referencia y tramo. `HirPlace` distingue ubicaciones
asignables; `Widen` materializa la ampliación entero → real. Las incorporadas usan la firma generada.
El nombre de una variable pertenece al algoritmo, subprograma o método; los bloques estructurados
comparten ese ámbito, como exige `LANG.SUBPROGRAM.SCOPE`. El flujo de asignación sí se separa por
rama y combina con intersección al salir de una condición. Una resolución inválida conserva la causa
y evita diagnósticos derivados. Los campos se resuelven desde el tipo del receptor y su clase propietaria.
La auditoría consume además fuentes regenerables de see_generators en ambos vocabularios y rigores,
sin importar el sistema de especificaciones como crate. La emisión del HIR se habilita solo sin errores; las advertencias no la bloquean.
Alternativas descartadas: resolución global, copiar lexemas de tipos y volver a interpretar el texto en lowering.

Cada repetición de inferencia restaura los símbolos locales originales y conserva únicamente los tipos inferidos de parámetros. Los vínculos locales tienen tipo explícito y nunca se crean por primera asignación. La repetición elimina temporales de patrones y evita que diagnósticos o lecturas de una pasada alteren la siguiente. Antes de publicar el HIR se resuelven las referencias a parámetros cuyo tipo se completó durante el análisis. Los estados internos Unknown/Error no se publican como tipos válidos del lenguaje.

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
operaciones. Una constante de módulo es privada del módulo y la local es visible en todo su cuerpo; una variable local
puede ocultar una constante de módulo, pero no repetir el nombre de otra constante de su ámbito.

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

Pendientes declarados de esta entrega: registros como elemento de arreglo, campo de clase, y parámetro o resultado de
métodos y constructores (diagnosticados, `recordArrayElementNotSupported`, `recordClassFieldNotSupported`,
`recordMemberSignatureNotSupported`, con excepción de las variantes incorporadas que sí se transportan en firmas de métodos); paso por referencia de registros (`recordPassedByReference`); visibilidad `Publico`/`Privado` y exportación de constantes, enumerados y
registros entre módulos de un proyecto, que hoy son privados del módulo.

Los vínculos locales tienen mutabilidad explícita en `HirLocal`; su declaración emite una asignación inicial y no cuenta como modificación. `binding_checker` valida inicialización y destinos de reasignación, incluidos campos de registros por valor y argumentos por referencia. Los objetos pueden mutar a través de un vínculo inmutable. La asignación a un nombre no declarado es error en ambos rigores y no crea inferencia flexible. La inicialización obligatoria reemplaza la trampa de lectura sin valor para locales; campos y elementos conservan su contrato. La forma inicializada es la oficial de la edición: no hay migrador, selector de compatibilidad ni conservación de la sintaxis anterior.

La exhaustividad de enumerados pertenece a `switch_coverage`: cubre ordinales en orden de declaración, permite enumerados vacíos y acepta De Otro Modo como cobertura total. Los errores de patrones se informan primero y suprimen diagnósticos derivados de cobertura. El analizador conserva ramas posteriores al comodín para informar su inalcanzabilidad.

Las variantes incorporadas son agregados identificados en `HirModule.variants`, separados de los registros nombrables. Sus instancias concretas se internan por familia y argumentos. Semantic importa también abi para consumir `VariantLayout`, evitando recalcular una disposición distinta: las hojas canónicas son palabras enteras y referencias, con unión por banco. Solo el opcional de una referencia no nula reutiliza el centinela; el opcional de otro opcional conserva discriminante. Los constructores reciben el tipo contextual de declaraciones, retornos y argumentos. Los patrones introducen vínculos inmutables limitados a su rama; un temporal interno evalúa el selector una vez. La propagación verifica la familia y la identidad exacta del tipo de error. Los resultados pendientes se siguen por vínculo y se unen por caminos; retorno, propagación, patrones y descarte transfieren o satisfacen la obligación. No existe migrador ni lenguaje anterior seleccionable.

Los locales declarados dentro de caminos que pueden no ejecutarse no se consideran inicializados al salir; la lectura sin inicialización definida es error en ambos rigores. Los campos y elementos conservan sus comprobaciones de ejecución.

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

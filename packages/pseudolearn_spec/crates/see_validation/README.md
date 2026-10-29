# see_validation

## 1. Qué es y qué no es

Aplica esquema, identidad, referencias, ciclo de vida, clasificación, hashes y vínculos. Mientras el versionado está congelado, una identidad nueva debe empezar estable en `1.0.0` sin `cambio`; una identidad existente conserva estado y versión, y no puede avanzar ni retroceder de estado. Las ediciones oficiales pueden cambiar texto y bloques, pero conservan identidad, estado y versión, omiten `cambio` y requieren reanclaje explícito. La estabilidad sigue exigiendo revisión independiente y evidencia en los sujetos declarados. El validador no completa `revisado_por`. Al reabrirse el versionado, los cambios usan las transiciones e incrementos de versión clasificados. El esquema JSON versionado usa únicamente type, required, properties, additionalProperties, enum, const, minLength, minimum, maximum, minItems, maxItems, uniqueItems, items, $ref, anyOf, oneOf y not; el evaluador limita su profundidad. `maximum`, `maxItems` y `not` permiten expresar límites de respuesta HTTP y exclusión de cuerpos ambiguos sin validación especial acoplada al anfitrión. No anuncia soporte general de JSON Schema.

## 2. Guía operativa y ciclo de vida

`cargo test -p see_validation`; `cargo check -p see_validation` desde el miembro. No se despliega.

## 3. Arquitectura y modelo del sistema

Imports internos permitidos: model, graph, change. Prohibidas las capas superiores y los sujetos. `src/` implementa la capa; `tests/` refleja módulos.

## 4. Decisiones de diseño y fundamentos técnicos

Las definiciones admiten valor como objeto normativo. `helpCatalog` usa el esquema `help-catalog/1`: verifica identidades y papeles únicos, identidades léxicas enlazadas a su fuente, disponibilidad 2026 por perfil/rigor, contenido es/en, anclajes y ejemplos con versión exacta, y exclusiones tipadas sin solapamiento con fichas disponibles. Los ejemplos no contienen resultados duplicados; su referencia debe quedar dentro de la disponibilidad de la ficha. Los casos admiten semilla opcional de entero; las fichas bilingües y las firmas se verifican estructuralmente, sin presentar esta revisión como ejecución de reference.

La validación del catálogo compara los operadores declarados con las producciones de asignación y
expresión, deriva las palabras reservadas del vocabulario y las incorporadas de la biblioteca, y
comprueba cada rol declarado contra una producción de gramática vigente. La ficha de identificadores
ancla `LANG.LEXICAL.IDENTIFIER#R1` para describir el alfabeto español en ambos rigores y la
normalización NFC; mantiene explícitas la distinción de caja y acentos, sin atribuir equivalencia
general a los homógrafos. La matriz identidad/rol
requiere una ficha o exclusión con disponibilidad completa en 2026, ambos perfiles y ambos rigores;
cada token cubierto debe tener una parte editorial es/en propia. La función `coverage_matrix` expone
las filas ordenadas que justifican el 100 % y los negativos ejercitan identidad duplicada, rol sin
ficha, alias, exclusión incompatible y traducción ausente.

Los ejemplos se validan en dos niveles. La forma exige perfil igual al idioma, rigor y perfil dentro de la
disponibilidad de la ficha, clase de un conjunto cerrado y ninguna referencia repetida por idioma. Las
referencias resuelven el caso exacto y derivan su clase (`executable`, `accepted` o `diagnostic`) de su
operación y esperado; una clase distinta, un caso retirado o una ficha sin ejemplo en algún idioma son
errores. El validador no ejecuta programas: la ejecución del caso pertenece a los sujetos de conformidad.

El catálogo tiene tres comprobaciones separadas: la integridad estructural, que vive aquí y no ejecuta ni
importa el motor; la ejecución de los ejemplos, que corresponde a los sujetos de conformidad sobre sus
casos; y la revisión editorial independiente de la prosa, que ninguna herramienta sustituye. Los
diagnósticos tienen el prefijo `SEE-HELP-CATALOG` y una causa cada uno: ficha sin papel declarado
(`no declared inventory role`), anclaje retirado o roto (`stale anchor`), identidad léxica retirada
(`stale token identity`), ejemplo inválido (`stale example`), clase discrepante (`mismatched kind`),
traducción ausente (`uncovered … identity`), identidad repetida (`duplicate`), exclusión abusiva
(`overlaps an available card`, `must name an alias`) y recurso demasiado profundo (`nesting exceeds`).
Cada uno se ejercita con un fixture aislado de `fixtures/help-catalog/` aplicado sobre el catálogo real:
el catálogo vigente debe quedar sin diagnósticos y cada fixture debe ser rechazado por su diagnóstico.
La prueba exige un mínimo de fixtures para que borrarlos no la debilite.

El texto editorial es texto plano: el validador rechaza `<`, `>`, comillas inversas, `&`, `\`, corchetes y `|`, esquemas de URI activos (`javascript:`, `data:`, `file:`, `command:`, `http(s):`, `mailto:` y cualquier `://`), caracteres de control o de dirección, campos fuera de longitud (título 80, propósito 560, resto 280), demasiados elementos por lista (16 partes, 8 restricciones, 8 errores comunes, 6 ejemplos) y más de 4 096 bytes de texto por idioma. Cada rechazo tiene fixture propio. Este control es la primera defensa; los clientes escapan de todos modos.

Problema: responsabilidades independientes. Elección: crate por capa con contratos tipados.
Se descarta importar sujetos o capas superiores para preservar la dirección.

Problema: el límite portable de análisis debe llegar a los consumidores como dato validado.
Elección: `analysisLimits` contiene un único campo `nesting`, entero positivo representable en u32.
La exportación conserva el recurso y los generadores lo consumen. Se rechaza fijarlo otra vez en el parser
y se rechazan campos desconocidos o valores cero, negativos, fraccionarios y fuera de rango.

El recurso `unsupportedConstructs` valida aperturas, cierres, diagnóstico y forma de apertura.
Son datos no reservados; el parser solo reconoce su posición estructural.

La conformidad de propiedades se valida contra su esquema propio y el corpus: referencia exacta a una
propiedad vigente, unicidad, semilla u64 y muestras positivas. Los contraejemplos no se convierten en
casos esperados. Una propiedad sin ejecutor no se declara cumplida.

## 5. Reglas de legibilidad, estilo y estructura de código

Reglas y límites en `architecture.yaml` del miembro; código inglés sin comentarios ni unsafe.

## 6. Decisiones de producto que condicionan el código

El sistema especifica y contrasta el lenguaje vigente. Ninguna lógica del motor vive aquí.

## 7. Verificación, testing y aseguramiento de calidad

`cargo xtask verify` desde el miembro; casos felices, infelices y límites en tests espejo.

## 8. Fuentes consultadas y genealogía conceptual

Plan aprobado del sistema SEE. Las bibliotecas externas son infraestructura, nunca autoridad sobre el comportamiento de PseudoLearn.

El esquema admite `cancelacion_prueba` como ordinal entero no negativo de un sondeo.
El campo no se interpreta como un presupuesto de sentencias y se rechazan tipos y signos inválidos.

El catálogo acepta identidades de contextualVocabulary como fuente léxica distinta del vocabulario reservado. La cobertura combina ambos inventarios para exigir ficha y parte bilingüe por identidad sin cambiar la clasificación léxica del lenguaje.


Los casos con anfitrion se validan contra la forma cerrada host del esquema see/1 y contra restricciones
de rutas, octetos e incertidumbre de escritura. El proveedor es exclusivamente declarativo y en memoria:
validar estos datos no ejecuta ni importa al sujeto. Los negativos distinguen forma inválida, escape,
octeto fuera de rango, permiso desconocido, secuencias `effect_seq` no crecientes en `anfitrion_observado.efectos`,
`efecto_pendiente` sin terminación `awaiting_effect` y combinaciones incoherentes entre `grabar_y_reproducir`,
`alterar_cinta` y `reproduccion_fallo`.

La clave `anfitrion.http` acepta guiones declarativos por método y URL con estados, cabeceras, cuerpos
textuales o de bytes, fallos e incertidumbre. `alterar_cinta: alterar_solicitud` permite probar la
divergencia HTTP durante reproducción. Se valida como dato cerrado; el validador no ejecuta el guion
ni abre conexiones. Los nuevos discriminantes de fallo se prueban con positivos y negativos aislados.

# pseudolearn_lowering

## 1. Qué es y qué no es

Traduce el HIR a representación intermedia observable. Diseño aprobado; implementación pendiente en R5.
No añade construcciones del lenguaje, UI ni efectos libres del anfitrión.

| Pendiente | Dependencia | Fase |
|---|---|---|
| Implementación y pruebas del diseño descrito | Contratos y puertas previas verificadas | R5 |

## 2. Guía operativa y ciclo de vida

Versión exacta de rust-toolchain.toml del miembro. La carpeta aún no contiene manifiesto ni código.
Al implementarla se incorpora al workspace y se retira pending de architecture.yaml. Comprobación
actual: `cargo xtask verify` y `rust-checks layers` del miembro. No se despliega por separado.

## 3. Arquitectura y modelo del sistema

Nivel 4. Importa semantic, ir y diagnostics; solo biblioteca estándar externa. Prohibido importar capas superiores, UI, Dart o el sistema de especificaciones como código.

Traducción procedural de expresiones, asignación, controles, entrada y salida; después llamadas y objetos. CFG SSA con análisis de asignación definida, celdas para referencias, masas y orígenes. Se marca la arista de retroceso de componentes cíclicos sin masa para sondeo.

Invariantes: Cada bloque tiene una masa igual a su cantidad de stmt.enter. Las conversiones están explícitas en Widen; no se vuelven a resolver nombres ni a interpretar fuente.

## 4. Decisiones de diseño y fundamentos técnicos

Escribir evalúa todos sus operandos antes del único out.write. Para evalúa inicial, final y paso una vez, comprueba paso, prueba inclusive por signo e incrementa con comprobación aun tras la última iteración. Los índices de celdas por referencia se evalúan y comprueban antes de llamar. La desvirtualización usa la jerarquía cerrada. Se omite value.require solo para lecturas demostradas asignadas; los enteros restantes reciben definición SSA.

La implementación permanece secuencial y determinista. La exportación del corpus es una dependencia
de datos. Las técnicas que requieren medición se aceptan solo tras conservar resultados y criterios.

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

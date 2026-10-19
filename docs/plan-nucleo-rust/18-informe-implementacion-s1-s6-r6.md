# 18 — Implementación S1–S6 y cambio clasificado de rendimiento

Fecha: 2026-10-19. Rama `feature/agregar-ruta-de-especificacion`. R6 cerrada por autorización explícita de la persona responsable, con incumplimientos aceptados; publicación autorizada mediante commit y push sin coautoría. R7 no se inicia.

## 1. Qué se construyó

- **S2:** emisión release sin verificador Cranelift; depuración y arneses de codegen, incluidos los de release mediante configuración explícita, conservan verificación. La RI siempre pasa `verify_module`.
- **S1:** eliminación por punto fijo de parámetros CLIF sin uso, sin cambiar firmas de entrada; comparación de rango para suma y resta con constante; prueba de productores definidos que conserva la comprobación de NaN; registro de fallo y retorno compartidos por función, conservando sitio y datos de carácter.
- **S4:** desplazamiento constante solo si la clase estática y todos sus descendientes comparten carga útil. El cálculo de disposición pertenece a la frontera ABI y no se copia.
- **S3:** lectura rápida de enteros parcialmente definidos; caminos terminales limitados a arreglos de rango uno y campos. El runtime determina el diagnóstico y un éxito inesperado produce `internalFault`. Regiones de alias para contexto, montón, celdas y raíces; las direcciones desconocidas y las llamadas mantienen comportamiento conservador. Las celdas conservan reunión. La prueba con RI manual también detectó y corrigió el contexto de lexema de un receptor ausente, sin alterar el diagnóstico de un campo sin inicializar en un objeto existente.
- **S5:** parámetros arreglo por asa en `pseudolearn_lowering`, con las mismas firmas en llamadas directas, métodos, constructores y superllamadas. `LANG.TYPES.ARRAY` y `LANG.STMT.ASSIGNMENT` excluyen reasignar el arreglo completo; los elementos y campos referenciados siguen usando celdas. AOT enraíza asas y presta los parámetros originales y sus copias equivalentes por `value.require`; no extiende esa prueba a fusiones ni asignaciones nuevas. La política `AllLive` permanece disponible para comparación diagnóstica.
- **S6:** mínimo automático configurable en `MemoryOptions`, conservando 4096 en VM y usando 262144 en AOT; cálculo común para asignación, consulta previa y ventana en línea. Histéresis con reposición bajo 8192 palabras libres y reserva de al menos 16384. Raíces de arreglos solo cuando hay posible recorrido o recolección.
- **Corpus y techo:** `PERF.AOT.LEVEL@1.0.0` clasifica el cambio de significado y separa Cranelift ≤1,70 frente a V1F del nivel optimizado futuro ≤1,30 frente a V1F-S. `PERF.SUITE.AWFY-CORE@0.2.0` añade el contrato del denominador. Lock, exportación y vínculos quedan actualizados. V1F-S es la variante 9 de ceiling; añade definición y recolección desde raíces de marcos sin importar el motor ni modificar las variantes 0–8.
- **Arnés:** intervalo versión 2 con `settle_session` incluido y tiempo de entrada auxiliar. Los resúmenes históricos conservan versión 1 y umbral 1,30; se rechazan versiones mezcladas e intervalos auxiliares inválidos. Cada README propietario contiene el fundamento correspondiente.

## 2. Resultado de los tests

Los cuatro `cargo xtask verify` terminan con código 0: motor, spec, ceiling y rust-checks. Los logs reportan respectivamente **701, 148, 30 y 45 pruebas** aprobadas. Incluyen formato, Clippy estricto, arquitectura, nombres, comentarios, límites, seguridad y auditoría de dependencias conforme a cada miembro.

Las pruebas nuevas cubren ambos extremos enteros, constantes a ambos lados de suma y resta, ciclos de parámetros muertos, NaN y productores desconocidos, jerarquías con desplazamientos iguales y distintos, raíces prestadas y valores nuevos, definición parcial de arreglos, presión de límite y recolección forzada. V1F-S contrasta las diez cargas con el corpus, incluidos modo forzado, indefinidos, ciclos, recuperación y límite vivo.

Los accesos terminales comparan código, argumentos y tramo con la VM. Un runtime simulado que devuelve éxito en cada una de las cuatro entradas terminales termina con `internalFault`. Las celdas gestionadas de elemento y campo conservan el éxito bajo GC forzada.

Storage n=7, cinco procesos AOT independientes por variante y el **mismo objeto** antes y después de S6: RSS máxima **3.538.944 → 2.965.504 bytes** (−16,20 %); todas las salidas son `5461`. Es RSS del proceso completo, con arranque, no una medida aislada del montón. Los contadores originales y hashes están conservados.

## 3. Resultado de los verificadores y campaña

- `see validate`: 146 especificaciones válidas; `see lock --check` y `see export --check`, correctos.
- `see conform --subject engine`: 1512 observaciones, **0 divergencias**.
- `see conform --subject aot`: 1208 observaciones, **0 divergencias**.
- Diferencial nativo: **808 comparaciones, 0 diferencias, 0 exenciones y 0 diferencias no contractuales de tramo o aviso**.
- El contraste congelado reference/engine conserva 1180 comparaciones, 94 exenciones previas y 188 diferencias no contractuales de tramo o aviso, con 0 no resueltas. La conformidad de reference reporta 134 divergencias con el corpus; no se modifica Dart ni se añaden exenciones.

Campaña formal nueva: [`r6-paired-s1-s6`](../../packages/pseudolearn_benchmarks/results/r6-paired-s1-s6/summary.json), **10 procesos × 30 parejas por carga, 3000 parejas**. Procedencia capturada antes del runtime y los objetos medidos; los **1152 hashes de fuente** coinciden al comprobarlos tras la campaña. No hubo compilaciones ni perfiles concurrentes durante las muestras y no se descartó ninguna.

| Familia | Razón frente a V1F | Límite | Resultado |
|---|---:|---:|---|
| Arreglos | 1,721792× | 1,70× | Incumple |
| Numérica | 1,523839× | 1,70× | Cumple |
| Objetos | 1,448865× | 1,70× | Cumple |
| Recursiva | 2,191876× | 1,70× | Incumple |

| Carga | Razón AOT/V1F | Emisión mediana, ms |
|---|---:|---:|
| Sieve | 1,528302× | 0,351666 |
| Queens | 1,939778× | 1,003541 |
| Mandelbrot | 1,167726× | 0,764041 |
| NBody | 1,988553× | 6,264500 |
| Permute | 2,191876× | 0,948417 |
| Bounce | 1,325173× | 2,212667 |
| List | 1,066293× | 1,250500 |
| Richards | 1,735414× | 10,384417 |
| Storage | 3,000000× | 1,181709 |
| Towers | 0,867892× | 1,526625 |

La máxima mediana de emisión es **10,384417 ms**, Richards: margen de **4,615583 ms** frente a 15 ms. La mayor muestra individual de emisión es 11,870834 ms. Las diez cargas superan a la VM; la aceleración mínima sobre su API es **11,554206×**, Storage. R2 y R3 pasan en esta campaña; **R1 no pasa** y el trabajador termina con código 1 conservando toda la evidencia.

Las razones por familia de la campaña histórica `r6-paired-inline-allocator` son 2,123754 / 2,392524 / 2,566000 / 2,253247 para arreglos / numérica / objetos / recursiva. Ninguna razón de familia aumenta más de 3 %; esto es una comparación descriptiva, porque el intervalo histórico excluye conciliación. Los tiempos auxiliares de entrada se conservan en los crudos y se resumen con el mismo cuantil empírico usado por el arnés en `implementation.json`.

Se conservan **163 candidatos** de punto de cambio; no equivalen a 163 cambios independientes ni permiten declarar estacionariedad. La resolución observada del reloj es 41 ns. Frecuencia, colocación de CPU y carga externa no están controladas. El bootstrap de medias por proceso es un estimador distinto de los cocientes de medianas de la puerta; sus intervalos no se usan para convertir los incumplimientos en éxitos.

## 4. Decisiones y pendientes

La comparación aislada de Permute conserva objeto, CLIF, ensamblado, símbolos, configuración, runtime común y 300 muestras por variante, con orden alternado entre procesos. **AllLive: 1,607835×; Borrowed: 2,182227×.** El objeto pasa de 3984 a 3864 bytes y cambian registros y posiciones de funciones. La regresión queda aislada a la política de raíces en esas variantes; su causa microarquitectónica sigue sin demostrarse, sin contadores de caché o ramas. No se añade alineación ni ajuste específico para Permute. La campaña formal confirma el resultado desfavorable de recursiva.

El nivel Cranelift **no queda certificado**: arreglos excede la puerta y recursiva conserva la anomalía. S1–S6 están implementadas y verificadas semánticamente; una sola campaña no acredita el criterio exploratorio de tres campañas de emisión. V1F-S está implementado y probado como denominador experimental; no se afirma rendimiento de un backend optimizado inexistente.

Los primeros intentos encontraron falta de espacio, el bloqueo de avisos de cargo-deny fuera del sandbox y un timeout al compilar la CLI antes del saludo del adaptador. Se resolvieron retirando únicamente artefactos regenerables, concediendo el acceso de verificación y precompilando la CLI. No se borraron resultados ni se modificaron campañas anteriores, V1F o la línea base.

Evidencia adicional: [`r6-s1-s6-diagnostics`](../../packages/pseudolearn_benchmarks/results/r6-s1-s6-diagnostics/implementation.json), con logs de verificación y conformidad, RSS y experimento de Permute.

La persona responsable autoriza posteriormente el cierre de R6, el commit y el push sin coautoría (D-R6-03). **No se cumplieron todos los casos ni criterios de aceptación.** Permanecen pendientes el objetivo de rendimiento de arreglos y recursiva y las comprobaciones aún no acreditadas en el plan y manifiesto AOT. Este cierre acepta esa deuda: no cambia los umbrales, no certifica el nivel Cranelift y no añade exenciones. Harán falta optimizaciones de arquitectura o microarquitectura y mediciones que demuestren sus causas; no se atribuye la anomalía de Permute a una causa no probada. Las mejoras posteriores requieren autorización propia.

**PHASE-STOP:** R6 queda cerrada con estos incumplimientos expresos y publicación autorizada en la rama única. R7 no se inicia.

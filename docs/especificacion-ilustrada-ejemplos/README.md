# Ejemplos de lectura de la Especificación ilustrada

Tres secciones de muestra para evaluar tono, figuras y profundidad antes de aprobar el plan
[`../plan-especificacion-ilustrada.md`](../plan-especificacion-ilustrada.md).

| Archivo | Sección | Qué muestra |
|---|---|---|
| [`03-01-tipos-primitivos.html`](03-01-tipos-primitivos.html) | 3.1 Tipos primitivos | Los cinco tipos, sus límites exactos, la regla con huecos de los reales, el mapa de conversiones y cómo guarda el motor cada valor |
| [`06-01-decision-si.html`](06-01-decision-si.html) | 6.1 La decisión `Si` | Forma, diagrama de raíles, figura por pasos, estructograma, cortocircuito, errores reales y bloques básicos de la representación intermedia |
| [`11-03-tareas.html`](11-03-tareas.html) | 11.3 Tareas, `Lanzar` y `Aguardar` | Mapa de la concurrencia, agenda paso a paso, frontera de aislamiento, fallos, línea de tiempo de un productor y un consumidor, memoria de las tareas |

Se abren con doble clic en cualquier navegador; [`index.html`](index.html) es la portada con el índice general.
Siguen el tema claro u oscuro del sistema.
Están diseñadas primero para teléfono: las figuras miden 340 unidades de ancho y se leen a tamaño real en una
pantalla de 375 puntos; en escritorio se centran a un máximo de 420 puntos. No muestran identificadores
internos del corpus: la trazabilidad hacia las reglas vive solo en las fuentes y en el compilador.

## Qué son y qué no son

Son una **maqueta del resultado final**, escrita a mano en HTML para poder leerla hoy. En la implementación
del plan, el contenido se escribirá en el formato fuente del miembro `pseudolearn_reference`, el compilador
resaltará el código con el motor real, ejecutará cada programa y generará la representación intermedia y la
traza; la app y la web solo pintarán el resultado.

Los programas, salidas, diagnósticos, representación intermedia y trazas se obtuvieron con la CLI compilada
(`pseudo ejecutar`, `pseudo ri`, `pseudo ejecutar --traza`) el 7 de noviembre de 2026 y se copiaron sin
editar. El resaltado de esta maqueta lo hace un script local con una lista de palabras; en el producto lo hará
el motor.

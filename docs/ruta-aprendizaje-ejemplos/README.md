# Lecciones de muestra de la ruta de aprendizaje

Tres lecciones completas para evaluar tono, estructura, figuras, ejercicios y enlaces a la Especificación antes de
aprobar el plan [`../plan-ruta-aprendizaje.md`](../plan-ruta-aprendizaje.md).

| Archivo | Lección | Qué muestra |
|---|---|---|
| [`0-1-tu-primer-problema.html`](0-1-tu-primer-problema.html) | 0.1 Tu primer problema | Empezar sin saber nada: el ciclo PseudoLearn completo, el primer programa en minutos, ninguna mención a memoria ni variables |
| [`1-3-repetir-mientras-haga-falta.html`](1-3-repetir-mientras-haga-falta.html) | 1.3 Repetir mientras haga falta | Una lección intermedia: ficha del problema, roles de variables, tabla por vuelta, invariante, tarjetas de recuerdo, la figura de la Especificación incrustada por referencia y cinco tipos de ejercicio |
| [`4-1-calcular-sin-cambiar-nada.html`](4-1-calcular-sin-cambiar-nada.html) | 4.1 Calcular sin cambiar nada | La apertura de un paradigma: sus cuatro preguntas, el problema hilo del kiosco, núcleo puro y borde con efectos, sustitución paso a paso y comparación honesta con el paradigma anterior |

[`index.html`](index.html) es el mapa de la ruta completa con las tres muestras resaltadas. Se abren con doble clic en
cualquier navegador y siguen el tema claro u oscuro del sistema.

## Qué conviene revisar

- **Orden de los términos.** Cada lección lista en su cabecera los términos que introduce. Ninguno se usa antes de su
  lección dueña; los que vienen de lecciones anteriores aparecen como tarjeta «Recuerda» con enlace, no como explicación.
- **Enlaces a la Especificación.** Las píldoras azules «Especificación §x.y» son el único lugar donde se remite a la sintaxis
  exacta, las reglas y los límites. La ruta no los repite. Todas apuntan a secciones ya publicadas, con su número real.
- **Ejercicios.** Ninguno dicta los pasos. Cada uno lleva tipo, nivel (semilla, brote o árbol), pistas en escalera y, cuando
  aplica, un desplegable para docentes con la solución y los casos ocultos.

## Qué son y qué no son

Son una **maqueta del resultado**, escrita a mano en HTML para poder leerla hoy. Reutilizan la hoja de estilos y el script de
[`../especificacion-ilustrada-ejemplos/`](../especificacion-ilustrada-ejemplos/) en vez de copiarlos, y agregan solo los
componentes propios de la ruta en [`recursos/ruta.css`](recursos/ruta.css).

Los programas y sus salidas se obtuvieron con la CLI compilada (`pseudo ejecutar`) el 7 de noviembre de 2026 y se copiaron
sin editar. El bucle infinito de la lección 1.3 se ejecutó con `--sentencias 10000`. El resaltado lo hace el script local de la
Especificación ilustrada con una lista de palabras; en el producto lo hará el motor.

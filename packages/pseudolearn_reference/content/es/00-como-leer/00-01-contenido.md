---
id: lectura.contenido
numero: "0.1"
tipo: concepto
titulo: Qué vas a encontrar
anclas: [LANG.EDITION.MODEL#R1, LANG.PROGRAM.STRUCTURE#R1]
terminos: [especificación, sección, parte]
---

::: frase
Esta especificación describe todo el lenguaje PseudoLearn y su motor, con ejemplos que se ejecutan de verdad cada vez que se construye.
:::

## Cómo funciona {#funciona}

La especificación está dividida en trece partes y seis apéndices. Cada parte trata un tema y cada sección explica una sola idea. Puedes leerla de principio a fin o saltar directamente a lo que necesitas.

Las partes siguen el orden en que una persona suele aprender a programar. Primero las piezas sueltas del texto, luego los datos, después las instrucciones y al final cómo trabaja el motor por dentro.

```figura id=mapa-partes
pie: El recorrido de la especificación. Las partes de arriba sostienen a las de abajo; los apéndices sirven para consultar.
```

Todos los programas de esta especificación se ejecutaron con el motor real de PseudoLearn. Debajo de cada uno ves lo que escribió y cómo terminó. Si algún día el motor cambiara su comportamiento, la especificación dejaría de construirse hasta corregir el texto.

```programa id=hola titulo="El primer programa" ejecutar
Algoritmo Hola
  Escribir "Hola, mundo";
FinAlgoritmo
```

```salida
Hola, mundo
```

## Capas de lectura {#capas}

Cada sección tiene un cuerpo que se entiende sin conocimientos previos. Alrededor del cuerpo hay recuadros que puedes leer o saltar:

| Recuadro | Para qué sirve |
|---|---|
| En una frase | La idea de la sección resumida en una oración |
| Límite exacto | El número preciso cuando hace falta: rangos, tamaños, profundidades |
| Errores frecuentes | Los mensajes reales del motor y cómo arreglarlos |
| Por dentro | Lo que hace el motor: representación intermedia y traza |
| Para docentes | Confusiones típicas y preguntas para la clase |

El cuerpo nunca depende de los recuadros plegables. Puedes saltarte todos los «Por dentro» sin perder el hilo.

::: nota
Esta especificación explica el lenguaje a personas. No es un curso paso a paso: para eso está la ruta de aprendizaje. Tampoco es la descripción interna del código del motor.
:::

::: resumen
- Trece partes ordenadas de lo pequeño a lo grande y seis apéndices de consulta.
- Una idea por sección, con figura, ejemplos ejecutados y resumen.
- Los recuadros plegables son opcionales.
- Cada ejemplo se ejecutó con el motor al construir la especificación.
:::

::: vease
- [Convenciones tipográficas](#lectura.convenciones)
- [Qué es PseudoLearn](#vision.que-es)
- [Glosario](#apendice.glosario)
:::

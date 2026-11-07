---
id: inicio.errores.buses-romper
leccion: inicio.errores
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Romper el programa de los buses
---

::: enunciado
Este programa calcula cuántos buses de 40 asientos hacen falta. Con 95 alumnos dice 3, que es correcto. Encuentra una cantidad de alumnos con la que se equivoque.
:::

```programa rol=defectuoso
Algoritmo Buses
  Definir alumnos Como Entero;
  Leer alumnos;
  Escribir alumnos div 40 + 1;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Buses
  Definir alumnos Como Entero;
  Leer alumnos;
  Escribir techo(alumnos / 40);
FinAlgoritmo
```

```casos
visible | 95 | 3
```

```rompe
80
40
120
```

::: pistas
1. Haz ejemplos a mano con varias cantidades. ¿Cuándo hace falta exactamente un número entero de buses?
2. Piensa en los casos borde: ¿qué pasa justo cuando los alumnos llenan los buses sin que sobre nadie?
3. Recuerda a Beto en [la primera lección](ruta:inicio.primer-problema): sumar 1 «por si sobra» falla cuando no sobra nada.
4. Con 80 alumnos el programa dice 3 y hacen falta 2. Cierra con la variante.
:::

::: variante
Encuentra otra cantidad que lo rompa, y una tercera mayor que 100. (Cualquier múltiplo de 40: 40, 120, 160.)
:::

::: docentes
Cualquier múltiplo de 40 rompe el programa. Pide que expliquen por qué antes de escribir la entrada.
:::

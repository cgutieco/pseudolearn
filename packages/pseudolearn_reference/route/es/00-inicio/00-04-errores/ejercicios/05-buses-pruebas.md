---
id: inicio.errores.buses-pruebas
leccion: inicio.errores
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Casos para los buses
---

::: enunciado
Escribe entre 2 y 4 casos de prueba para el programa de los buses de 40 asientos, de modo que cualquier versión equivocada falle al menos uno.
:::

```programa rol=referencia
Algoritmo Buses
  Definir alumnos Como Entero;
  Leer alumnos;
  Escribir techo(alumnos / 40);
FinAlgoritmo
```

```programa rol=mutante id=sin-redondeo
Algoritmo Buses
  Definir alumnos Como Entero;
  Leer alumnos;
  Escribir alumnos div 40;
FinAlgoritmo
```

```programa rol=mutante id=uno-de-mas
Algoritmo Buses
  Definir alumnos Como Entero;
  Leer alumnos;
  Escribir alumnos div 40 + 1;
FinAlgoritmo
```

```programa rol=mutante id=redondeo-cercano
Algoritmo Buses
  Definir alumnos Como Entero;
  Leer alumnos;
  Escribir redon(alumnos / 40);
FinAlgoritmo
```

```casos
visible | 95 | 3
```

```casos-solucion minimo=2 maximo=4
95 | 3
80 | 2
```

::: pistas
1. Un caso descubre una versión equivocada si con esa entrada la versión muestra otra cosa. ¿Qué entradas separan a una versión de otra?
2. Piensa en las zonas: alumnos que llenan los buses justo, y alumnos que sobran por poco o por mucho.
3. Necesitas al menos un caso donde la división sea exacta y otro donde sobre poco.
4. 95 → 3 descubre a quien no redondea; 80 → 2 descubre a quien suma uno de más. Cierra con la variante.
:::

::: variante
¿Hay una sola entrada que descubra a las tres versiones equivocadas a la vez? (No: 81 → 3 descubre a dos de ellas, pero a quien suma uno de más no.)
:::

::: docentes
Versiones equivocadas: sin redondeo, una de más y redondeo al más cercano. El redondeo al más cercano cae con cualquier caso que sobre poco, como 81 o 95.
:::

---
id: imperativo.mientras.alcancia-pruebas
leccion: imperativo.mientras
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Las pruebas de la alcancía
---

::: enunciado
No escribas código. Escribe cuatro precios con la respuesta correcta para cada uno, de modo que cualquier versión equivocada de la alcancía falle al menos uno.
:::

```programa rol=referencia
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro < precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```programa rol=mutante id=menor-o-igual
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro <= precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```programa rol=mutante id=ahorro-en-cero
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 0;
  Mientras ahorro < precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```programa rol=mutante id=suma-antes
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro < precio Hacer
    dia <- dia + 1;
    ahorro <- ahorro + guardaHoy;
    guardaHoy <- guardaHoy + 1;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```programa rol=mutante id=dia-en-cero
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 0;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro < precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```casos
visible | 50 | Día 9 con 54 monedas
```

```casos-solucion minimo=4 maximo=4
50 | Día 9 con 54 monedas
54 | Día 9 con 54 monedas
2 | Día 1 con 2 monedas
1000 | Día 44 con 1034 monedas
```

::: pistas
1. Escribe los ejemplos a mano de la ficha. ¿Cuáles son casos borde?
2. Imagina errores posibles: una condición que se pasa por uno, una caja que empieza mal, dos líneas en otro orden. ¿Qué precio los descubre?
3. Hace falta un precio que se junte exacto y uno que alcance el primer día.
4. 50, 54, 2 y 1000, con sus respuestas de la lección, descubren a todas las versiones equivocadas. Cierra con la variante.
:::

::: variante
¿Cuál de los cuatro precios podrías quitar sin dejar escapar ninguna versión equivocada? (Pruébalo: la app te dice cuál sobrevive.)
:::

::: docentes
Versiones equivocadas: `<=` en la condición, la alcancía empezando en 0, sumar antes de aumentar lo de cada día y el día empezando en 0. Un conjunto sin un precio exacto (como 54) y sin uno menor o igual que 2 no detecta la primera.
:::

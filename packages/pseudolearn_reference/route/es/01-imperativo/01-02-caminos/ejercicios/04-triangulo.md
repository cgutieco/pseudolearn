---
id: imperativo.caminos.triangulo
leccion: imperativo.caminos
tipo: resolver
nivel: brote
obligatorio: true
titulo: ¿Qué triángulo es?
---

::: enunciado
Lee tres lados, en centímetros enteros, y muestra `equilátero` si los tres son iguales, `isósceles` si solo dos lo son, `escaleno` si son todos distintos, o «no es triángulo» si con esos lados no se puede armar uno. Se puede armar un triángulo cuando cada lado es menor que la suma de los otros dos.
:::

```programa rol=referencia
Algoritmo Triangulo
  Definir a Como Entero;
  Definir b Como Entero;
  Definir c Como Entero;
  Leer a;
  Leer b;
  Leer c;
  Si a >= b + c O b >= a + c O c >= a + b Entonces
    Escribir "no es triángulo";
  Sino
    Si a = b Y b = c Entonces
      Escribir "equilátero";
    Sino
      Si a = b O b = c O a = c Entonces
        Escribir "isósceles";
      Sino
        Escribir "escaleno";
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```casos
visible | 3 ; 3 ; 3 | equilátero
visible | 3 ; 4 ; 5 | escaleno
oculto | 2 ; 2 ; 3 | isósceles
oculto | 1 ; 2 ; 3 | no es triángulo
oculto | 5 ; 1 ; 1 | no es triángulo
oculto | 2 ; 3 ; 2 | isósceles
```

::: pistas
1. Arma una tabla de decisión: ¿qué preguntas hay que hacer, y qué casos las distinguen?
2. Hay una pregunta que va antes que todas: si no es triángulo, no tiene sentido preguntar cuántos lados son iguales.
3. Para isósceles, cualquier par de lados iguales sirve: hay tres pares posibles.
4. Primero «no es triángulo» con tres comparaciones unidas por `O`; después equilátero; después isósceles; el resto es escaleno. Cierra con la variante.
:::

::: variante
Agrega `rectángulo` cuando el cuadrado del lado mayor es la suma de los cuadrados de los otros dos. (Con 3, 4 y 5.)
:::

::: explicacion
Casos ocultos: lados iguales en distintas posiciones (2, 3, 2) y triángulos imposibles con el lado grande primero (5, 1, 1). Error frecuente: comprobar isósceles solo con `a = b`.
:::

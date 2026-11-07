---
id: imperativo.contado.primo-romper
leccion: imperativo.contado
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Un primo demasiado confiado
---

::: enunciado
Este programa acierta con 7 y con 9. Encuentra un número con el que se equivoque.
:::

```programa rol=defectuoso
Algoritmo Primo
  Definir n Como Entero;
  Leer n;
  Definir esPrimo Como Logico <- Verdadero;
  Para d <- 2 Hasta n - 1 Hacer
    Si n mod d = 0 Entonces
      esPrimo <- Falso;
      Salir;
    FinSi
  FinPara
  Si esPrimo Entonces
    Escribir "Es primo";
  Sino
    Escribir "No es primo";
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Primo
  Definir n Como Entero;
  Leer n;
  Definir esPrimo Como Logico <- n >= 2;
  Para d <- 2 Hasta n - 1 Hacer
    Si n mod d = 0 Entonces
      esPrimo <- Falso;
      Salir;
    FinSi
  FinPara
  Si esPrimo Entonces
    Escribir "Es primo";
  Sino
    Escribir "No es primo";
  FinSi
FinAlgoritmo
```

```casos
visible | 7 | Es primo
visible | 9 | No es primo
```

```rompe
1
0
```

::: pistas
1. Vuelve a la ficha de la lección. ¿Qué ejemplos son casos borde?
2. ¿Qué pasa con un número para el que el bucle da cero vueltas?
3. Si no hay divisores que probar, la respuesta depende solo del valor con que arranca la caja de la respuesta.
4. Con 1 el programa dice «Es primo», y 1 no es primo. Cierra con la variante.
:::

::: variante
¿Hay algún número mayor que 1 que lo rompa? (No: para todos ellos el bucle prueba al menos un divisor o, con 2, ninguno y acierta.)
:::

::: docentes
Rompen el programa el 1, el 0 y los negativos: para ellos el bucle no da vueltas y la respuesta queda en verdadero. La referencia arranca con `n >= 2`.
:::

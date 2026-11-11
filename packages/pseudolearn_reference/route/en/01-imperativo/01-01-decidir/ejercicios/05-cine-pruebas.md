---
id: imperativo.decidir.cine-pruebas
leccion: imperativo.decidir
tipo: disenar-pruebas
nivel: brote
obligatorio: false
titulo: Cases for the cinema
---

::: enunciado
Write between 2 and 4 test cases for the cinema program, so that any wrong version fails at least one of them.
:::

```programa rol=referencia
Algoritmo Cinema
  Definir age Como Entero;
  Leer age;
  Si age < 12 Entonces
    Escribir "Pays 5";
  Sino
    Escribir "Pays 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=incluye-borde
Algoritmo Cinema
  Definir age Como Entero;
  Leer age;
  Si age <= 12 Entonces
    Escribir "Pays 5";
  Sino
    Escribir "Pays 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=borde-bajo
Algoritmo Cinema
  Definir age Como Entero;
  Leer age;
  Si age < 11 Entonces
    Escribir "Pays 5";
  Sino
    Escribir "Pays 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=borde-alto
Algoritmo Cinema
  Definir age Como Entero;
  Leer age;
  Si age < 13 Entonces
    Escribir "Pays 5";
  Sino
    Escribir "Pays 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=precios-cambiados
Algoritmo Cinema
  Definir age Como Entero;
  Leer age;
  Si age < 12 Entonces
    Escribir "Pays 8";
  Sino
    Escribir "Pays 5";
  FinSi
FinAlgoritmo
```

```casos
visible | 10 | Pays 5
```

```casos-solucion minimo=2 maximo=4
11 | Pays 5
12 | Pays 8
```

::: pistas
1. The wrong versions move the edge or swap the prices. Which ages notice those changes?
2. Use the partition: one case per region is not enough if the edge moves one step.
3. Choose both sides of the edge.
4. 11 → `Pays 5` and 12 → `Pays 8` uncover them all. Close with the variant.
:::

::: variante
Why are 10 and 30 not enough? (No version that moves the edge one step changes what it charges at 10 or at 30.)
:::

::: explicacion
Wrong versions: including 12, edge at 11, edge at 13 and swapped prices. The one that includes 12 and the one with the edge at 13 are the same as each other for whole ages, but neither is the same as the right one.
:::

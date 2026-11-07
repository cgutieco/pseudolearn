---
id: imperativo.decidir.cine-pruebas
leccion: imperativo.decidir
tipo: disenar-pruebas
nivel: brote
obligatorio: false
titulo: Casos para el cine
---

::: enunciado
Escribe entre 2 y 4 casos de prueba para el programa del cine, de modo que cualquier versión equivocada falle al menos uno.
:::

```programa rol=referencia
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad < 12 Entonces
    Escribir "Paga 5";
  Sino
    Escribir "Paga 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=incluye-borde
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad <= 12 Entonces
    Escribir "Paga 5";
  Sino
    Escribir "Paga 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=borde-bajo
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad < 11 Entonces
    Escribir "Paga 5";
  Sino
    Escribir "Paga 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=borde-alto
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad < 13 Entonces
    Escribir "Paga 5";
  Sino
    Escribir "Paga 8";
  FinSi
FinAlgoritmo
```

```programa rol=mutante id=precios-cambiados
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad < 12 Entonces
    Escribir "Paga 8";
  Sino
    Escribir "Paga 5";
  FinSi
FinAlgoritmo
```

```casos
visible | 10 | Paga 5
```

```casos-solucion minimo=2 maximo=4
11 | Paga 5
12 | Paga 8
```

::: pistas
1. Las versiones equivocadas mueven el borde o cambian los precios. ¿Qué edades notan esos cambios?
2. Usa la partición: un caso por región no alcanza si el borde se mueve un paso.
3. Elige los dos lados del borde.
4. 11 → `Paga 5` y 12 → `Paga 8` descubren a todas. Cierra con la variante.
:::

::: variante
¿Por qué 10 y 30 no alcanzan? (Ninguna versión que mueva el borde un paso cambia lo que cobra a 10 o a 30.)
:::

::: docentes
Versiones equivocadas: incluir el 12, borde en 11, borde en 13 y precios cambiados. La que incluye el 12 y la del borde en 13 son iguales entre sí con edades enteras, pero ninguna es igual a la correcta.
:::

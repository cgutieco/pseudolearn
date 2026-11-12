---
id: imperativo.esquemas.buscar-pruebas
leccion: imperativo.esquemas
tipo: disenar-pruebas
nivel: arbol
obligatorio: false
titulo: Casos para una búsqueda
---

::: enunciado
Un programa lee 5 números y después un número buscado, y muestra la posición de la primera aparición del buscado, o -1 si no está. Escribe entre 3 y 4 casos de prueba de modo que cualquier versión equivocada falle al menos uno.
:::

```programa rol=referencia
Algoritmo Buscar
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir posicion Como Entero <- -1;
  Para i <- 0 Hasta 4 Hacer
    Si v[i] = buscado Entonces
      posicion <- i;
      Salir;
    FinSi
  FinPara
  Escribir posicion;
FinAlgoritmo
```

```programa rol=mutante id=ultima-aparicion
Algoritmo Buscar
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir posicion Como Entero <- -1;
  Para i <- 0 Hasta 4 Hacer
    Si v[i] = buscado Entonces
      posicion <- i;
    FinSi
  FinPara
  Escribir posicion;
FinAlgoritmo
```

```programa rol=mutante id=desde-uno
Algoritmo Buscar
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir posicion Como Entero <- -1;
  Para i <- 1 Hasta 4 Hacer
    Si v[i] = buscado Entonces
      posicion <- i;
      Salir;
    FinSi
  FinPara
  Escribir posicion;
FinAlgoritmo
```

```programa rol=mutante id=cero-si-falta
Algoritmo Buscar
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Definir buscado Como Entero;
  Leer buscado;
  Definir posicion Como Entero <- 0;
  Para i <- 0 Hasta 4 Hacer
    Si v[i] = buscado Entonces
      posicion <- i;
      Salir;
    FinSi
  FinPara
  Escribir posicion;
FinAlgoritmo
```

```casos
visible | 4 ; 8 ; 15 ; 16 ; 23 ; 15 | 2
```

```casos-solucion minimo=3 maximo=4
3 ; 7 ; 9 ; 7 ; 1 ; 7 | 1
7 ; 1 ; 2 ; 3 ; 4 ; 7 | 0
1 ; 2 ; 3 ; 4 ; 5 ; 9 | -1
```

::: pistas
1. Imagina cómo puede equivocarse una búsqueda: dónde empieza, cuándo se detiene, qué responde si no encuentra.
2. Cada caso tiene que poner a prueba una de esas decisiones.
3. Hace falta un buscado repetido, uno en la primera posición y uno que no está.
4. Con repetidos (3, 7, 9, 7, 1 y 7 → 1), en la posición 0 (7, 1, 2, 3, 4 y 7 → 0) y ausente (→ -1). Cierra con la variante.
:::

::: variante
¿Por qué el caso visible no descubre a ninguna de las tres versiones equivocadas? (El 15 aparece una vez, no está en la posición 0 y sí está.)
:::

::: explicacion
Versiones equivocadas: devuelve la última aparición, empieza a buscar en la posición 1 y responde 0 cuando no encuentra. Cada uno de los tres casos de la solución descubre a una.
:::

---
id: imperativo.arreglos.rotar
leccion: imperativo.arreglos
tipo: resolver
nivel: arbol
obligatorio: false
titulo: Rotar un lugar
---

::: enunciado
Lee 5 números y muéstralos rotados un lugar a la derecha: el último pasa a ser el primero y los demás se corren una posición. Uno por línea.
:::

```programa rol=referencia
Algoritmo Rotar
  Dimension v[5] Como Entero;
  Para i <- 0 Hasta 4 Hacer
    Leer v[i];
  FinPara
  Escribir v[4];
  Para i <- 0 Hasta 3 Hacer
    Escribir v[i];
  FinPara
FinAlgoritmo
```

```casos
visible | 1 ; 2 ; 3 ; 4 ; 5 | 5 ⏎ 1 ⏎ 2 ⏎ 3 ⏎ 4
visible | 7 ; 8 ; 9 ; 10 ; 11 | 11 ⏎ 7 ⏎ 8 ⏎ 9 ⏎ 10
oculto | 9 ; 0 ; 0 ; 0 ; 0 | 0 ⏎ 9 ⏎ 0 ⏎ 0 ⏎ 0
oculto | 1 ; 1 ; 1 ; 1 ; 2 | 2 ⏎ 1 ⏎ 1 ⏎ 1 ⏎ 1
oculto | 3 ; 4 ; 5 ; 6 ; 7 | 7 ⏎ 3 ⏎ 4 ⏎ 5 ⏎ 6
```

::: pistas
1. A mano con 1, 2, 3, 4, 5: ¿qué posición sale primero? ¿Y después?
2. Guarda los cinco en un arreglo, como en [la lección](ruta:imperativo.arreglos).
3. El primero que se muestra es el de la última casilla; después, los demás en orden.
4. Muestra `v[4]` y después recorre de 0 a 3. Cierra con la variante.
:::

::: variante
Rota de verdad el arreglo, moviendo los valores dentro de él, y después muéstralo de 0 a 4. (Hace falta guardar el último antes de correr los demás.)
:::

::: docentes
La solución más corta no mueve nada: solo cambia el orden en que se muestra. La variante obliga a mover los valores, de atrás hacia adelante.
:::

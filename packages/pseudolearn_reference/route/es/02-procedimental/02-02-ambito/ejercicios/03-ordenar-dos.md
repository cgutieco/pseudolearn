---
id: procedimental.ambito.ordenar-dos
leccion: procedimental.ambito
tipo: resolver
nivel: brote
obligatorio: true
titulo: El menor primero
---

::: enunciado
Lee dos números y muéstralos como `menor mayor`, separados por un espacio.
:::

::: restriccion
Un subprograma `OrdenarDos` recibe las dos cajas y deja el menor en la primera y el mayor en la segunda; el principal solo lee, llama y muestra.
:::

```programa rol=referencia
SubProceso OrdenarDos(a Como Entero Por Referencia, b Como Entero Por Referencia)
  Si a > b Entonces
    Definir guardado Como Entero <- a;
    a <- b;
    b <- guardado;
  FinSi
FinSubProceso

Algoritmo Principal
  Definir primero, segundo Como Entero;
  Leer primero;
  Leer segundo;
  OrdenarDos(primero, segundo);
  Escribir primero, " ", segundo;
FinAlgoritmo
```

```casos
visible | 9 ; 4 | 4 9
visible | 2 ; 7 | 2 7
oculto | 5 ; 5 | 5 5
oculto | -1 ; -3 | -3 -1
oculto | 0 ; 10 | 0 10
```

```aserciones
- declara-subprograma | OrdenarDos | 2 | Falta el subprograma OrdenarDos, que recibe las dos cajas.
```

::: pistas
1. ¿Cuándo hay que cambiar algo y cuándo no?
2. Es el intercambio del ejercicio anterior, hecho solo cuando hace falta.
3. Las dos cajas tienen que volver cambiadas: préstalas.
4. Si la primera es mayor que la segunda, intercámbialas. Cierra con la variante.
:::

::: variante
Haz que `OrdenarDos` retorne además si tuvo que intercambiar.
:::

::: explicacion
Casos ocultos: iguales, negativos y ya ordenados. Error frecuente: pasar las cajas por valor, que muestra el orden original.
:::

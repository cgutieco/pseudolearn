---
id: exterior.http.que-romper
leccion: exterior.http
tipo: romperlo
nivel: brote
obligatorio: false
titulo: Solo el 200
---

::: enunciado
Este programa dice «bien» o «problema» según el código de una respuesta. Con 200 y con 503 acierta. Encuentra un código con el que se equivoque.
:::

```programa rol=defectuoso
Funcion palabra <- ComoLeFue(codigo Como Entero)
  Definir palabra Como Cadena;
  Si codigo = 200 Entonces
    palabra <- "bien";
  Sino
    palabra <- "problema";
  FinSi
FinFuncion

Algoritmo Estado
  Definir codigo Como Entero;
  Leer codigo;
  Escribir ComoLeFue(codigo);
FinAlgoritmo
```

```programa rol=referencia
Funcion palabra <- ComoLeFue(codigo Como Entero)
  Definir palabra Como Cadena;
  Si codigo >= 200 Y codigo <= 299 Entonces
    palabra <- "bien";
  Sino
    palabra <- "problema";
  FinSi
FinFuncion

Algoritmo Estado
  Definir codigo Como Entero;
  Leer codigo;
  Escribir ComoLeFue(codigo);
FinAlgoritmo
```

```casos
visible | 200 | bien
visible | 503 | problema
```

```rompe
201
204
```

::: pistas
1. ¿Qué códigos dicen que salió bien?
2. Todos los del 200 al 299, no solo el 200.
3. Este programa solo acepta el 200 exacto.
4. Con 201 dice «problema» y salió bien. Cierra con la variante.
:::

::: variante
¿Hay algún código que este programa marque como bien y no lo sea?
:::

::: explicacion
Lo rompe cualquier código entre 201 y 299. La variante tiene respuesta negativa: el programa solo dice «bien» con el 200, que sí es bien.
:::

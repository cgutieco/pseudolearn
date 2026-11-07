---
id: inicio.nombres.reparto-caramelos
leccion: inicio.nombres
tipo: resolver
nivel: semilla
obligatorio: true
titulo: Repartir caramelos
---

::: enunciado
Hay 47 caramelos para 6 amigos. Todos reciben la misma cantidad, y los que no alcanzan para una vuelta completa quedan en la bolsa. Muestra exactamente la frase «Cada amigo recibe 7 y sobran 5», calculando los dos números.
:::

```programa rol=inicial
Algoritmo Caramelos
  Definir caramelos Como Entero <- 47;
  Definir amigos Como Entero <- 6;
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Caramelos
  Definir caramelos Como Entero <- 47;
  Definir amigos Como Entero <- 6;
  Escribir "Cada amigo recibe ", caramelos div amigos, " y sobran ", caramelos mod amigos;
FinAlgoritmo
```

```casos
visible | — | Cada amigo recibe 7 y sobran 5
```

::: pistas
1. A mano: ¿cuántas vueltas completas de 6 caramelos salen de 47? ¿Cuántos quedan?
2. Hay dos operaciones que reparten: una dice cuánto toca a cada uno y la otra cuánto queda. Están en [la lección](ruta:inicio.nombres).
3. `Escribir` puede mostrar textos y cuentas separados por comas, en el orden que quieras.
4. `Escribir "Cada amigo recibe ", caramelos div amigos, " y sobran ", caramelos mod amigos;`. Cierra con la variante.
:::

::: variante
Llega un amigo más. ¿Qué muestra ahora el programa? (Respuesta: `Cada amigo recibe 6 y sobran 5`.)
:::

::: docentes
Solución con `div` y `mod` sobre las variables. Error frecuente: escribir `7` y `5` a mano, que pasa el caso pero no la variante.
:::

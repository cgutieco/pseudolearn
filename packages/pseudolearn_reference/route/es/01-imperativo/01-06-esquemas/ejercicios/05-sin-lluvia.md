---
id: imperativo.esquemas.sin-lluvia
leccion: imperativo.esquemas
tipo: resolver
nivel: arbol
obligatorio: false
titulo: La racha sin lluvia
---

::: enunciado
Lee 10 días: 1 si llovió y 0 si no. Muestra cuántos días duró la racha más larga sin lluvia. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo SinLluvia
  Dimension dias[10] Como Entero;
  Para i <- 0 Hasta 9 Hacer
    Leer dias[i];
  FinPara
  Definir racha Como Entero <- 0;
  Definir masLarga Como Entero <- 0;
  Para Cada llovio En dias Hacer
    Si llovio = 0 Entonces
      racha <- racha + 1;
      Si racha > masLarga Entonces
        masLarga <- racha;
      FinSi
    Sino
      racha <- 0;
    FinSi
  FinPara
  Escribir masLarga;
FinAlgoritmo
```

```casos
visible | 0 ; 0 ; 1 ; 0 ; 0 ; 0 ; 1 ; 1 ; 0 ; 0 | 3
visible | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 | 0
oculto | 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 ; 0 | 10
oculto | 1 ; 0 ; 0 ; 0 ; 0 ; 1 ; 0 ; 1 ; 0 ; 0 | 4
oculto | 0 ; 1 ; 0 ; 1 ; 0 ; 1 ; 0 ; 1 ; 0 ; 0 | 2
```

::: pistas
1. Es pariente de las olas de calor de [la lección](ruta:imperativo.esquemas). ¿Qué cambia?
2. Una caja sigue la racha actual y otra recuerda la más larga.
3. Si actualizas la más larga en cada día sin lluvia, no hace falta revisar nada después del bucle.
4. Sin lluvia: la racha sube y, si supera a la más larga, la reemplaza. Con lluvia: la racha vuelve a 0. Cierra con la variante.
:::

::: variante
Muestra también en qué día empezó la racha más larga.
:::

::: explicacion
Actualizar la más larga dentro de la rama sin lluvia evita el error de la última racha. Casos ocultos: los diez días secos y la racha más larga al final.
:::

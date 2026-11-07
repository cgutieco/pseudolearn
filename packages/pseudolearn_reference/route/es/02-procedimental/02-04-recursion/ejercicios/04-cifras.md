---
id: procedimental.recursion.cifras
leccion: procedimental.recursion
tipo: resolver
nivel: arbol
obligatorio: false
titulo: ¿Cuántas cifras?
---

::: enunciado
Lee un número entero no negativo y muestra cuántas cifras tiene. El programa muestra solo el número.
:::

```programa rol=referencia
Funcion cantidad <- Cifras(n Como Entero)
  Definir cantidad Como Entero;
  Si n < 10 Entonces
    cantidad <- 1;
  Sino
    cantidad <- 1 + Cifras(n div 10);
  FinSi
FinFuncion

Algoritmo Principal
  Definir n Como Entero;
  Leer n;
  Escribir Cifras(n);
FinAlgoritmo
```

```casos
visible | 1234 | 4
visible | 7 | 1
oculto | 0 | 1
oculto | 100000 | 6
oculto | 10 | 2
```

::: pistas
1. ¿Qué números tienen una sola cifra? ¿Cuántas cifras tiene 1234 si le quitas la última?
2. Repasa cómo se quita la última cifra en [la lección 1.4](ruta:imperativo.contado), con la suma de las cifras.
3. Caso base: menos de 10. Caso recursivo: una cifra más que el número sin la última.
4. Si `n < 10`, tiene 1 cifra; si no, `1 + Cifras(n div 10)`. Cierra con la variante.
:::

::: variante
Escribe la suma de las cifras con recursión, sin bucles.
:::

::: docentes
El 0 es el caso borde: tiene una cifra. Una solución con `Si n = 0` como caso base cuenta 0 cifras para el 0.
:::

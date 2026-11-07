---
id: imperativo.contado.suma-digitos
leccion: imperativo.contado
tipo: resolver
nivel: arbol
obligatorio: false
titulo: La suma de las cifras
---

::: enunciado
Lee un número entero no negativo y muestra la suma de sus cifras. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo SumaCifras
  Definir n Como Entero;
  Definir suma Como Entero <- 0;
  Leer n;
  Mientras n > 0 Hacer
    suma <- suma + n mod 10;
    n <- n div 10;
  FinMientras
  Escribir suma;
FinAlgoritmo
```

```casos
visible | 1234 | 10
visible | 9 | 9
oculto | 0 | 0
oculto | 1000 | 1
oculto | 9999 | 36
```

::: pistas
1. A mano con 1234: ¿cómo separas la última cifra? ¿Cómo te quedas con el resto del número?
2. Repartir de a 10 separa la última cifra de las demás. Repasa el reparto en [la lección 0.2](ruta:inicio.nombres).
3. ¿Sabes cuántas cifras tiene el número? Eso decide la forma de repetir.
4. Mientras queden cifras: suma `n mod 10` y quédate con `n div 10`. Cierra con la variante.
:::

::: variante
Muestra cuántas cifras tiene el número. ¿Qué pasa con el 0?
:::

::: docentes
No se sabe de antemano cuántas cifras hay: va `Mientras`. El 0 da cero vueltas y suma 0, que es correcto.
:::

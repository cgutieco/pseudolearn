---
id: imperativo.mientras.frijol
leccion: imperativo.mientras
tipo: resolver
nivel: brote
obligatorio: true
titulo: El frijol mágico
---

::: enunciado
Plantas un frijol mágico que ya mide unos centímetros; el programa lee cuántos. El primer día crece 1 centímetro, y cada día crece el doble de lo que creció el día anterior. ¿Cuántos días tarda en llegar a la ventana, que está a 100 centímetros del suelo? El programa muestra solo el número de días.
:::

```programa rol=referencia
Algoritmo Frijol
  Definir altura Como Entero;
  Leer altura;
  Definir crecimiento Como Entero <- 1;
  Definir dias Como Entero <- 0;
  Mientras altura < 100 Hacer
    altura <- altura + crecimiento;
    crecimiento <- crecimiento * 2;
    dias <- dias + 1;
  FinMientras
  Escribir dias;
FinAlgoritmo
```

```casos
visible | 3 | 7
visible | 100 | 0
oculto | 99 | 1
oculto | 0 | 7
oculto | 50 | 6
```

::: pistas
1. Haz la tabla a mano para 3 centímetros. ¿Qué caja cambia sumando y cuál cambia multiplicando?
2. Se parece a [la alcancía](ruta:imperativo.mientras): allá lo de cada día crecía de 1 en 1; aquí se duplica.
3. Necesitas una altura, un crecimiento y una caja que cuente los días. La pregunta: ¿todavía no llega a 100?
4. Mientras la altura sea menor que 100: suma el crecimiento, duplícalo y cuenta un día. Cierra con la variante.
:::

::: variante
¿Y si la ventana está a 1000 centímetros? (Con 3 centímetros, tarda 10 días.)
:::

::: docentes
Casos ocultos: 99 → 1 (un día basta), 0 → 7, 50 → 6 (51, 53, 57, 65, 81, 113). Error frecuente: duplicar el crecimiento antes de sumarlo, que da 6 con 3 centímetros.
:::

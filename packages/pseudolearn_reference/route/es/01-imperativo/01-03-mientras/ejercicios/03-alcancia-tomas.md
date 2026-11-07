---
id: imperativo.mientras.alcancia-tomas
leccion: imperativo.mientras
tipo: romperlo
nivel: brote
obligatorio: true
titulo: La alcancía de Tomás
---

::: enunciado
Tomás escribió su versión de la alcancía. Con precio 50 muestra «Día 9 con 54 monedas», igual que la tuya. Pero está mal. Encuentra un precio con el que se equivoque.
:::

```programa rol=defectuoso
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro <= precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Alcancia
  Definir precio Como Entero;
  Leer precio;
  Definir dia Como Entero <- 1;
  Definir guardaHoy Como Entero <- 2;
  Definir ahorro Como Entero <- 2;
  Mientras ahorro < precio Hacer
    dia <- dia + 1;
    guardaHoy <- guardaHoy + 1;
    ahorro <- ahorro + guardaHoy;
  FinMientras
  Escribir "Día ", dia, " con ", ahorro, " monedas";
FinAlgoritmo
```

```casos
visible | 50 | Día 9 con 54 monedas
```

```rompe
54
2
```

::: pistas
1. Vuelve a la ficha del problema. ¿Cuál de los ejemplos a mano es un caso borde?
2. Compara la condición de Tomás con la tuya. ¿Cuándo dan respuestas distintas esas dos preguntas?
3. Prueba con un precio que Lucía pueda juntar exacto.
4. Con precio 54 Tomás dice «Día 10 con 65 monedas»; con precio 2, «Día 2 con 5». Cierra con la variante.
:::

::: variante
Corrige la condición de Tomás cambiando un solo signo.
:::

::: docentes
Rompen la versión de Tomás los precios que se juntan exacto: 2, 5, 9, 14, 20, 27, 35, 44, 54. La app ejecuta el precio propuesto en las dos versiones y acepta si difieren.
:::

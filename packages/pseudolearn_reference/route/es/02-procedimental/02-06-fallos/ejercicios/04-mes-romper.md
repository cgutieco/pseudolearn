---
id: procedimental.fallos.mes-romper
leccion: procedimental.fallos
tipo: romperlo
nivel: brote
obligatorio: true
titulo: Un mes de más
---

::: enunciado
Este programa valida un número de mes: muestra «válido» o «inválido». Acierta con 5 y con 13. Encuentra un número con el que se equivoque.
:::

```programa rol=defectuoso
Algoritmo Mes
  Definir mes Como Entero;
  Leer mes;
  Si mes >= 0 Y mes <= 12 Entonces
    Escribir "válido";
  Sino
    Escribir "inválido";
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Mes
  Definir mes Como Entero;
  Leer mes;
  Si mes >= 1 Y mes <= 12 Entonces
    Escribir "válido";
  Sino
    Escribir "inválido";
  FinSi
FinAlgoritmo
```

```casos
visible | 5 | válido
visible | 13 | inválido
```

```rompe
0
```

::: pistas
1. ¿Qué números son meses? Dibuja la partición y marca los bordes.
2. Probaron un caso del medio y uno de afuera por arriba. ¿Qué borde no probaron?
3. Prueba los dos lados del borde de abajo.
4. Con 0 el programa dice «válido», y no hay mes 0. Cierra con la variante.
:::

::: variante
Corrige la validación cambiando un solo número.
:::

::: explicacion
Solo el 0 rompe este programa: los negativos ya quedan afuera. Es el error de borde de [la lección 1.1](ruta:imperativo.decidir), ahora dentro de una validación.
:::

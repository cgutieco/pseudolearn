---
id: imperativo.decidir.cine-romper
leccion: imperativo.decidir
tipo: romperlo
nivel: brote
obligatorio: true
titulo: El cine de la otra escuela
---

::: enunciado
El cine de otra escuela cobra igual que el nuestro: menores de 12, 5 pesos; los demás, 8. Su programa acierta con 10 y con 30 años. Encuentra una edad con la que cobre mal.
:::

```programa rol=defectuoso
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad > 12 Entonces
    Escribir "Paga 8";
  Sino
    Escribir "Paga 5";
  FinSi
FinAlgoritmo
```

```programa rol=referencia
Algoritmo Cine
  Definir edad Como Entero;
  Leer edad;
  Si edad < 12 Entonces
    Escribir "Paga 5";
  Sino
    Escribir "Paga 8";
  FinSi
FinAlgoritmo
```

```casos
visible | 10 | Paga 5
visible | 30 | Paga 8
```

```rompe
12
```

::: pistas
1. Dibuja la partición del cine. ¿Qué casos ya probaron, y qué zona quedó sin probar?
2. Los errores se esconden en los bordes. Prueba los dos lados del borde.
3. Con 11 los dos programas cobran 5. ¿Y con el número siguiente?
4. Con 12 años el programa cobra 5 y debería cobrar 8. Cierra con la variante.
:::

::: variante
Corrige el programa cambiando un solo signo, sin cambiar los textos. (Con `>=`.)
:::

::: docentes
Solo el 12 rompe este programa: es el único entero donde `> 12` y `>= 12` difieren. Por eso un caso de cada lado del borde es obligatorio.
:::

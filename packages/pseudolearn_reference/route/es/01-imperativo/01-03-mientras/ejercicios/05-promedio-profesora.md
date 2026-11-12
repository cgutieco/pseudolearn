---
id: imperativo.mientras.promedio-profesora
leccion: imperativo.mientras
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El promedio de la profesora
---

::: enunciado
La profesora dicta las notas del examen una por una. Cuando termina, dice -1. El programa muestra el promedio de las notas; si no dictó ninguna, muestra «No hay notas».
:::

```programa rol=referencia
Algoritmo Promedio
  Definir nota Como Entero;
  Definir suma Como Entero <- 0;
  Definir cantidad Como Entero <- 0;
  Leer nota;
  Mientras nota <> -1 Hacer
    suma <- suma + nota;
    cantidad <- cantidad + 1;
    Leer nota;
  FinMientras
  Si cantidad = 0 Entonces
    Escribir "No hay notas";
  Sino
    Escribir suma / cantidad;
  FinSi
FinAlgoritmo
```

```casos
visible | 14 ; 17 ; 11 ; -1 | 14.0
visible | -1 | No hay notas
oculto | 10 ; -1 | 10.0
oculto | 0 ; 0 ; -1 | 0.0
oculto | 7 ; 8 ; -1 | 7.5
```

::: pistas
1. ¿Qué valor avisa que terminaron las notas? ¿Qué dos cosas necesitas saber para calcular un promedio?
2. Es [la alcancía dictada](ruta:imperativo.mientras) con una caja más.
3. Una caja para la suma y otra para la cantidad. Antes de dividir, ¿qué pasa si la cantidad es cero?
4. Lee, suma y cuenta hasta el -1; después, si la cantidad es 0 muestra «No hay notas» y si no, la suma entre la cantidad. Cierra con la variante.
:::

::: variante
Muestra también la nota más alta. (Lo vas a necesitar en la próxima lección.)
:::

::: explicacion
Sin comprobar la cantidad, el caso «-1 directo» se detiene con una división entre cero. Las notas 0 y 0 comprueban que el aviso no se confunde con una nota baja.
:::

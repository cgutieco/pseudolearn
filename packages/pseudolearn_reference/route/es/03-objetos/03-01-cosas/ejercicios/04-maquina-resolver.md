---
id: objetos.cosas.maquina-resolver
leccion: objetos.cosas
tipo: resolver
nivel: brote
obligatorio: false
titulo: Las ventas de las dos máquinas
---

::: enunciado
Cada máquina empieza con 10 latas y cobra 3 pesos por lata. Lee números de máquina, 1 o 2, uno por venta, hasta un 0. Una venta en una máquina sin latas no se hace y se avisa con «Máquina 1 sin latas» (o 2). Al final muestra `Máquina 1: ` y `Máquina 2: ` con sus latas y su dinero, como en la lección: `Máquina 1: 8 latas, 6 pesos`.
:::

```programa rol=referencia
Clase Maquina
  Definir stock, recaudado, precio Como Entero;

  Metodo Constructor(latas Como Entero)
    Este.stock <- latas;
    Este.recaudado <- 0;
    Este.precio <- 3;
  FinMetodo

  Metodo Vender() Como Logico
    Si Este.stock = 0 Entonces
      Retornar Falso;
    FinSi
    Este.stock <- Este.stock - 1;
    Este.recaudado <- Este.recaudado + Este.precio;
    Retornar Verdadero;
  FinMetodo

  Metodo Estado() Como Cadena
    Retornar ConvertirATexto(Este.stock) + " latas, " + ConvertirATexto(Este.recaudado) + " pesos";
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir primera Como Maquina <- Nuevo Maquina(10);
  Definir segunda Como Maquina <- Nuevo Maquina(10);
  Definir numero Como Entero;
  Leer numero;
  Mientras numero <> 0 Hacer
    Si numero = 1 Entonces
      Si NO primera.Vender() Entonces
        Escribir "Máquina 1 sin latas";
      FinSi
    Sino
      Si NO segunda.Vender() Entonces
        Escribir "Máquina 2 sin latas";
      FinSi
    FinSi
    Leer numero;
  FinMientras
  Escribir "Máquina 1: ", primera.Estado();
  Escribir "Máquina 2: ", segunda.Estado();
FinAlgoritmo
```

```casos
visible | 1 ; 1 ; 2 ; 0 | Máquina 1: 8 latas, 6 pesos ⏎ Máquina 2: 9 latas, 3 pesos
visible | 0 | Máquina 1: 10 latas, 0 pesos ⏎ Máquina 2: 10 latas, 0 pesos
oculto | 2 ; 2 ; 2 ; 0 | Máquina 1: 10 latas, 0 pesos ⏎ Máquina 2: 7 latas, 9 pesos
oculto | 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 1 ; 0 | Máquina 1 sin latas ⏎ Máquina 1 sin latas ⏎ Máquina 1: 0 latas, 30 pesos ⏎ Máquina 2: 10 latas, 0 pesos
oculto | 1 ; 2 ; 1 ; 2 ; 0 | Máquina 1: 8 latas, 6 pesos ⏎ Máquina 2: 8 latas, 6 pesos
```

::: pistas
1. ¿Cuántos objetos hacen falta? ¿Qué decide a cuál se le pide la venta?
2. Usa la clase de las máquinas de [la lección](ruta:objetos.cosas).
3. Crea dos máquinas; en el bucle, el número leído elige a cuál pedirle `Vender()`.
4. Mientras el número no sea 0, si es 1 vende la primera y si no la segunda; al final muestra los dos estados. Cierra con la variante.
:::

::: variante
Agrega un método `Cargar(latas)` y un código 3 que cargue 5 latas en la máquina que tenga menos.
:::

::: docentes
Casos ocultos: ventas en una sola máquina, una máquina que se queda sin latas (las dos ventas de más solo avisan) y ventas alternadas.
:::

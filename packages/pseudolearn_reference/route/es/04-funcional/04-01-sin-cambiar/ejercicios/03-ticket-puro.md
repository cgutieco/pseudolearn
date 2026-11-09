---
id: funcional.sin-cambiar.ticket-puro
leccion: funcional.sin-cambiar
tipo: resolver
nivel: brote
obligatorio: true
titulo: Un ticket puro
---

::: enunciado
Lee dos ventas, cada una con código de producto y cantidad, y muestra el total con descuento. Los precios son los del kiosco: 1 Jugo 3, 2 Sándwich 5, 3 Alfajor 2, 4 Agua 1 y 5 Fruta 2. Por cada 10 pesos se descuenta 1.
:::

::: restriccion
El precio, el importe y el descuento son funciones; el algoritmo principal solo lee y muestra.
:::

```programa rol=referencia
Funcion valor <- PrecioDe(codigo Como Entero)
  Definir valor Como Entero;
  Segun codigo Hacer
    1:
      valor <- 3;
    2:
      valor <- 5;
    3:
      valor <- 2;
    4:
      valor <- 1;
    De Otro Modo:
      valor <- 2;
  FinSegun
FinFuncion

Funcion importe <- Linea(precio Como Entero, cantidad Como Entero)
  Definir importe Como Entero;
  importe <- precio * cantidad;
FinFuncion

Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Algoritmo Ticket
  Definir codigo1, cantidad1, codigo2, cantidad2 Como Entero;
  Leer codigo1;
  Leer cantidad1;
  Leer codigo2;
  Leer cantidad2;
  Escribir ConDescuento(Linea(PrecioDe(codigo1), cantidad1) + Linea(PrecioDe(codigo2), cantidad2));
FinAlgoritmo
```

```casos
visible | 1 ; 3 ; 2 ; 2 | 18
visible | 4 ; 1 ; 4 ; 1 | 2
oculto | 2 ; 10 ; 2 ; 10 | 90
oculto | 3 ; 5 ; 5 ; 0 | 9
oculto | 1 ; 0 ; 1 ; 0 | 0
```

```aserciones
- declara-subprograma | ConDescuento | 1 | Falta la función ConDescuento, que recibe el total.
```

::: pistas
1. ¿Qué parte es cálculo y qué parte toca el mundo?
2. Usa las funciones de la caja funcional de [la lección](ruta:funcional.sin-cambiar).
3. Una función para el precio de un código, otra para el importe de una línea y otra para el descuento.
4. El principal lee los cuatro datos y muestra una sola expresión que compone las funciones. Cierra con la variante.
:::

::: variante
Muestra también cuánto se ahorró con el descuento, sin calcular nada dos veces.
:::

::: explicacion
En «3, 5, 5, 0» son 5 alfajores (10 pesos) y 0 frutas: total 10, con descuento 9. La aserción comprueba que exista `ConDescuento`; que sea pura lo comprueba el motor al compilarla.
:::

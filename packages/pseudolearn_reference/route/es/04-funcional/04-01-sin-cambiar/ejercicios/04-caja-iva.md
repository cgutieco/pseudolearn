---
id: funcional.sin-cambiar.caja-iva
leccion: funcional.sin-cambiar
tipo: modificar
nivel: arbol
obligatorio: false
titulo: La caja con IVA
---

::: enunciado
Otra caja del kiosco funciona, pero nadie se anima a cambiarla. Reescríbela como un núcleo que solo calcula y un borde que lee y muestra. Tiene que mostrar lo mismo para cualquier compra.
:::

::: restriccion
El IVA y el descuento son funciones puras; el algoritmo principal compone las dos en una sola expresión.
:::

```programa rol=inicial
SubProceso CobrarConIva(total Como Entero Por Referencia)
  total <- total + total * 18 div 100;
  total <- total - total div 10;
  Escribir "Total: ", total;
FinSubProceso

Algoritmo Caja
  Definir compra Como Entero;
  Leer compra;
  CobrarConIva(compra);
FinAlgoritmo
```

```programa rol=referencia
Funcion monto <- ConDescuento(total Como Entero)
  Definir monto Como Entero;
  monto <- total - total div 10;
FinFuncion

Funcion conImpuesto <- ConIva(total Como Entero)
  Definir conImpuesto Como Entero;
  conImpuesto <- total + total * 18 div 100;
FinFuncion

Algoritmo Caja
  Definir compra Como Entero;
  Leer compra;
  Escribir "Total: ", ConDescuento(ConIva(compra));
FinAlgoritmo
```

```casos
visible | 100 | Total: 107
visible | 0 | Total: 0
oculto | 9 | Total: 9
oculto | 50 | Total: 54
oculto | 1000 | Total: 1062
```

```aserciones
- declara-subprograma | ConIva | 1 | Falta la función ConIva, que recibe el total.
- declara-subprograma | ConDescuento | 1 | Falta la función ConDescuento, que recibe el total.
```

::: pistas
1. ¿Cuántos cálculos distintos hace `CobrarConIva`? ¿Cuál de sus líneas toca el mundo?
2. Uno de los cálculos ya lo tienes: es el descuento de [la lección](ruta:funcional.sin-cambiar).
3. Una función `ConIva` y, en el principal, una sola expresión que componga las dos.
4. `Escribir "Total: ", ConDescuento(ConIva(compra));`. Cierra con la variante.
:::

::: variante
El IVA pasa a ser un dato que se lee. ¿Qué funciones cambian?
:::

::: explicacion
El orden de la composición importa: `ConIva(ConDescuento(100))` da otro resultado. Que eso se vea en una sola línea es el punto del ejercicio.
:::

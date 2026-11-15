---
id: procedimental.modulos
numero: "2.7"
tipo: leccion
titulo: Big programs
duracion: 25
problema_breve: The kiosk split into files
necesita: [procedimental.fallos]
introduce: [modulo, importar, visibilidad]
usa: [subprograma, descomposicion, arbol-de-descomposicion, funcion-pura]
---

::: frase
A module brings together what changes for the same reason and shows outside only what is needed.
:::

## The problem {#problema}

::: problema
The kiosk program has the stock, the sales and the receipts mixed in a single file of **400 lines**. Two classmates want to work at the same time, and a piece `Total` of the receipt clashes with another `Total` of the sales.

**How is it shared out into parts that do not tread on each other?**
:::

## Try it {#intentalo}

::: intento
Group these names into three piles: `AddStock`, `RemoveStock`, `HasStock`, `Amount`, `WithDiscount`, `Sell`, `ReceiptLine`, `CloseReceipt`, `ReceiptTotal` and `DayTotal`.
:::

::: respuesta
One pile for the stock (`AddStock`, `RemoveStock`, `HasStock`), another for the sales (`Amount`, `WithDiscount`, `Sell`, `DayTotal`) and another for the receipts (`ReceiptLine`, `CloseReceipt`, `ReceiptTotal`). Each pile changes for a different reason: the stock, the prices or the format of the paper.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The same as before: what changes is how the program is shared out.
- **What does it look like?** The decomposition tree of the report card, in [lesson 2.1](ruta:procedimental.dividir): each big branch can be a file.
- **Which parts does it split into?** It splits into three files, one per pile, and a fourth one with the main algorithm.

```figura id=ruta-kiosco-modulos
pie: The arrows go from whoever uses to whoever is used, and never make a cycle.
```

## The new tool {#herramienta}

A [[def:modulo|module]] is a file with one responsibility. To use from one module what another offers you have to [[def:importar|import]] it with `Import`. [[def:visibilidad|Visibility]] decides what can be used from outside: only what is marked `Public` can be imported; the rest is private to the module.

```figura-especificacion seccion=programas.modulos figura=paquete-modulos
```

```programa id=modulo-ventas titulo="store/sales.psl"
Publico SubProceso Amount(price Como Entero, quantity Como Entero) Como Entero
  Retornar price * quantity;
FinSubProceso

Publico SubProceso WithDiscount(sum Como Entero) Como Entero
  Retornar sum - sum div 10;
FinSubProceso

SubProceso RoundCents(sum Como Entero) Como Entero
  Retornar sum;
FinSubProceso
```

```programa id=modulo-principal titulo="store/main.psl"
Importar store.sales;

Algoritmo Main
  Escribir sales.WithDiscount(sales.Amount(3, 7));
FinAlgoritmo
```

A project of several modules needs a file that describes it and runs as a whole, which is why these blocks have no button to run them here. How a project is put together is in [the Specification](especificacion:programas.modulos).

::: especificacion
- programas.modulos
- programas.estructura
:::

## Write {#escribir fase=3}

The kiosk ends up in four modules:

| Module | Responsibility | Uses |
|---|---|---|
| `inventory` | how much stock there is of each product | — |
| `sales` | prices, discounts and the day's total | `inventory` |
| `receipts` | the format of each line and of the closing | `sales` |
| `main` | reading the sales and calling the others | `inventory`, `sales`, `receipts` |

Now `sales.DayTotal` and `receipts.ReceiptTotal` no longer clash: each name lives in its module, and whoever uses them calls them with the module's name in front.

## Test {#probar fase=4}

Each module is tested on its own, through what it makes public. `sales` is tested by calling `Amount` and `WithDiscount` with a table of cases, like the pure functions of [lesson 2.3](ruta:procedimental.puras), without reading anything or looking at receipts.

## Improve {#mejorar fase=5}

In one sentence: «The kiosk is shared out into modules by responsibility, and each one shows only what the others need».

Making a helper subprogram private, such as `RoundCents`, breaks nobody: nobody else could use it. Making it public turns it into a commitment: from then on, others can depend on it.

## What you learned {#aprendiste}

::: resumen
- {modulo,importar} A module is a file with one responsibility; importing is using what another module offers.
- {visibilidad} Visibility decides what can be used from outside: what is public is a commitment, what is private can change.
:::

## Practise {#practica}

::: practica
- procedimental.modulos.a-que-modulo
- procedimental.modulos.publico-privado
- procedimental.modulos.orden-dependencias
- procedimental.modulos.un-archivo
- procedimental.modulos.ciclo
:::

::: profundizar titulo="Common pitfalls"
- **Modules by kind of construction.** A module of «all the functions» and another of «all the records» change for a thousand reasons. Group by what changes together.
- **Everything public.** Every public name is a promise. Justify every `Public`.
:::

::: siguiente
Time to rebuild the kiosk with all of this.
:::

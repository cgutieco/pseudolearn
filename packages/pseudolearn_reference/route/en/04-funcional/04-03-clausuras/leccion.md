---
id: funcional.clausuras
numero: "4.3"
tipo: leccion
titulo: Functions that remember
duracion: 30
problema_breve: This week's discount campaign
necesita: [funcional.orden-superior]
introduce: [clausura, fabrica-de-funciones]
usa: [funcion-como-valor, orden-superior, mapear, funcion-pura, ambito, parametro]
---

::: frase
A closure is a function that carries with it the values it needs.
:::

## The problem {#problema}

::: problema
Each week, the kiosk launches a discount campaign whose **percentage is read at the start**: 10, 20, 25… The `Map` of the previous lesson needs a function that receives a single value, the price.

**How is that function created if the percentage is not known when the program is written?**
:::

## Try it {#intentalo}

::: intento
Write in words which function would be needed for 10 % and which for 20 %. What do they have in common?
:::

::: respuesta
For 10 %: «take a tenth off the price». For 20 %: «take a fifth off the price». Both do the same with a different number. That number is not known when the program is written: the function has to be made when it is read.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The percentage and the prices go in; the discounted prices come out.
- **What does it look like?** The `Map` of [lesson 4.2](ruta:funcional.orden-superior), with a function that does not exist yet.
- **Which part is calculation and which part touches the world?** Asking for the percentage touches the world; making the function and applying it is calculation.

The plan: a function that **makes** discount functions. It receives the percentage and gives back a one-parameter function that already has it inside.

## The new tool {#herramienta}

A function can be written right where it is needed, without a name: `Function(price As Integer) As Integer … EndFunction;`. If it uses a value from outside, it takes it along. A function that remembers values from the moment it was created is a [[def:clausura|closure]]. And a function that receives data and gives back a function prepared with it is a [[def:fabrica-de-funciones|function factory]].

```figura id=ruta-mochila
pie: The factory keeps the percentage in the backpack of the function it gives back; the function uses it each time it is called.
paso: The factory receives 20 and keeps it in the new function's backpack.
paso: Later, the function receives a price and uses the 20 it carries in the backpack.
```

```figura-especificacion seccion=tipos.funciones figura=clausura
```

```programa id=sumador titulo="A manufactured adder" ejecutar
Funcion made <- MakeAdder(amount Como Entero)
  Definir made Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + amount;
  FinFuncion;
FinFuncion

Algoritmo Add
  Definir plusThree Como Funcion(Entero) Como Entero <- MakeAdder(3);
  Escribir plusThree(4);
FinAlgoritmo
```

```salida
7
```

What a closure can keep in its backpack has a rule: a value that is reassigned later cannot be captured. It is in [the Specification](especificacion:tipos.funciones).

::: especificacion
- tipos.funciones
:::

## Write {#escribir fase=3}

```programa id=campanas titulo="This week's campaign" ejecutar
Funcion made <- MakeDiscount(percentage Como Entero)
  Definir made Como Funcion(Entero) Como Entero <- Funcion(price Como Entero) Como Entero
    Retornar price - price * percentage div 100;
  FinFuncion;
FinFuncion

Funcion mapped <- Map(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir mapped Como Vector<Entero> <- Vector();
  Para Cada item En v Hacer
    mapped.Agregar(f(item));
  FinPara
FinFuncion

Algoritmo Campaigns
  Definir percentage Como Entero;
  Leer percentage;
  Definir prices Como Vector<Entero> <- Vector();
  prices.Agregar(50);
  prices.Agregar(30);
  prices.Agregar(20);
  Definir discount Como Funcion(Entero) Como Entero <- MakeDiscount(percentage);
  Escribir Map(prices, discount);
FinAlgoritmo
```

```entrada
10
```

```salida
[45, 27, 18]
```

## Test {#probar fase=4}

| Percentage | Prices 50, 30 and 20 | Why |
|---|---|---|
| 10 | [45, 27, 18] | normal case |
| 0 | [50, 30, 20] | edge: the prices do not change |
| 100 | [0, 0, 0] | edge: all free |

## Improve {#mejorar fase=5}

In one sentence: «The factory receives this week's percentage and gives back a discount that remembers it».

Two campaigns at once are two functions from the same factory: `MakeDiscount(10)` and `MakeDiscount(25)`, each with its own backpack.

## What you learned {#aprendiste}

::: resumen
- {clausura} A closure is a function that remembers values from the moment it was created.
- {fabrica-de-funciones} A function factory receives data and gives back a function prepared with it.
:::

## Practise {#practica}

::: practica
- funcional.clausuras.sumador-predecir
- funcional.clausuras.captura-cambiante
- funcional.clausuras.multiplicador
- funcional.clausuras.componer
- funcional.clausuras.mochila
:::

::: profundizar titulo="Common pitfalls"
- **Believing the closure sees later changes.** Here there can be none: the engine does not allow capturing something that is reassigned later.
- **Confusing the factory with the manufactured function.** `MakeDiscount` receives a percentage; the function it gives back receives a price.
:::

::: siguiente
An order marked as delivered has no delivery time. Can that error be made impossible even to write?
:::

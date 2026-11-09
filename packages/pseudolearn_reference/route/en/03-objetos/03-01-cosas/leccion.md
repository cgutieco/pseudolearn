---
id: objetos.cosas
numero: "3.1"
tipo: apertura
titulo: Things that know and do
duracion: 40
problema_breve: The two vending machines
necesita: [procedimental.proyecto]
introduce: [programacion-orientada-a-objetos, objeto, clase, atributo, metodo, constructor, instancia]
usa: [paradigma, programacion-procedimental, registro, campo, subprograma, parametro, valor-de-retorno]
---

::: frase
An object keeps its own state and knows how to do the operations that belong to it.
:::

## The problem {#problema}

::: problema
The kiosk has **two vending machines**. Each one has its **stock** of cans, the **money** collected and the **price**, 3 pesos. The current program uses `stock1`, `dinero1`, `stock2` and `dinero2`, and repeats the selling code for each machine. Yesterday, a sale at machine 1 took a can off machine 2.

**How is it written so that each machine looks after its own data?**
:::

## Try it {#intentalo}

::: intento
Find in this program the line that takes off from the wrong machine.

```programa id=maquinas-sueltas titulo="Two machines with loose boxes"
```
:::

::: respuesta
It is the second-to-last line: the second sale charges at machine 1 but takes the can off machine 2. With four loose boxes and the selling code repeated, getting the number wrong is very easy.
:::

## A new paradigm {#paradigma}

In [[def:programacion-orientada-a-objetos|object-oriented programming]], a program is built from objects: things that keep their own state and know how to do the operations that belong to them.

::: paradigma
- pregunta: what if data came with its own operations and knew how to look after itself?
- metafora: a real vending machine. Inside it has cans and coins; outside, buttons. Nobody puts a hand in to take a can. It stops working at one point: a program object can be created as many times as needed.
- historia: in 1967, Ole-Johan Dahl and Kristen Nygaard presented Simula, the first language with classes and objects. In the 1970s, Alan Kay's team at Xerox PARC created Smalltalk, where everything is an object that receives messages.
- costo: you have to decide which things exist and what each one knows how to do; a bad split complicates more than it helps.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The sales of each machine go in; the state of each one comes out: cans and money.
- **What does it look like?** A record of [lesson 2.5](ruta:procedimental.datos), with a new detail: the operations go together with the data.
- **Who has the information to do this?** The machine itself: it knows its stock, its money and its price, so it is the one that has to know how to sell and load cans.

## The new tool {#herramienta}

A [[def:clase|class]] describes a kind of thing: what it knows and what it knows how to do. What it knows are its [[def:atributo|attributes]]; what it knows how to do, its [[def:metodo|methods]]. With a class you create [[def:objeto|objects]], and each one is an [[def:instancia|instance]] of that class, with its own values.

```figura id=ruta-molde
pie: The cutter says what shape the biscuits have; each biscuit has its own decoration. The analogy fails at one point: the cutter also says what each biscuit knows how to do.
paso: A star-shaped cutter: the class.
paso: Three biscuits made with the same cutter, each decorated differently: three objects with their own state.
```

```figura-especificacion seccion=objetos.clase figura=clase-objetos
```

The [[def:constructor|constructor]] is the method that prepares a new object with its initial values. It runs when the object is created with `New`:

```figura-especificacion seccion=objetos.constructor figura=nuevo-pasos
```

```programa id=contador titulo="A counter" ejecutar
```

```salida
2
```

Inside a method, `This` is the object that received the call: `pasos.Incrementar()` changes the value of `pasos` and of no other counter.

::: especificacion
- objetos.clase
- objetos.metodos
- objetos.constructor
:::

## Write {#escribir fase=3}

```programa id=maquinas titulo="Two machines that look after themselves" ejecutar
```

```salida
true true true
Máquina 1: 8 latas, 6 pesos
Máquina 2: 9 latas, 3 pesos
```

Each `Vender()` returns whether it could sell: all three times, yes. There is no longer a way to sell at one machine and take off at another: each sale is asked of a machine, and the machine changes only its own data.

## Test {#probar fase=4}

A machine without cans does not sell: `Vender` returns false and changes nothing.

```programa id=sin-stock titulo="An empty machine" ejecutar
```

```salida
false 0 0
```

## Improve {#mejorar fase=5}

In one sentence: «Each machine is an object that keeps its cans and its money, and knows how to sell without touching the others».

A third machine is one more line: `New Maquina(10)`.

| | Loose boxes | Objects |
|---|---|---|
| Adding a machine | four new boxes and another copy of the selling code | one line |
| Getting the machine wrong | easy: change a number | impossible: it is asked of the machine |
| Where the selling rule lives | in each copy | in a single method |

## What you learned {#aprendiste}

::: resumen
- {programacion-orientada-a-objetos} Building a program from objects that keep their state and work together is object-oriented programming.
- {clase,objeto,instancia} A class describes a kind of object; each object created with it is an instance.
- {atributo,metodo} The attributes are what the object knows; the methods, what it knows how to do.
- {constructor} The constructor prepares a new object with its initial values.
:::

## Practise {#practica}

::: practica
- objetos.cosas.mascota
- objetos.cosas.dos-contadores
- objetos.cosas.alcancia-objeto
- objetos.cosas.maquina-resolver
- objetos.cosas.clase-u-objeto
- objetos.cosas.cronometro-objeto
:::

::: profundizar titulo="Common pitfalls"
- **«The class and the object are the same».** Use the cutter figure: one cutter, many biscuits.
- **A method that does not use the object's state.** When it does not touch `This`, it is probably a function that goes outside.
- **Attributes that should be local variables.** A value that only one method uses during a call is not part of the state.
:::

::: siguiente
Someone left the canteen card with a negative balance. How do you prevent it from the object?
:::

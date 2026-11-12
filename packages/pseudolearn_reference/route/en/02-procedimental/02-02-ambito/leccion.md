---
id: procedimental.ambito
numero: "2.2"
tipo: leccion
titulo: What each part sees
duracion: 30
problema_breve: The balance that does not double
necesita: [procedimental.dividir]
introduce: [ambito, paso-por-valor, paso-por-referencia, pila-de-llamadas, marco]
usa: [subprograma, llamada, parametro, valor-de-retorno, variable, asignar]
pieza: 5
---

::: frase
Each call works with its own boxes, unless it is lent a box of whoever calls.
:::

## The problem {#problema}

::: problema
On students' day, the kiosk doubles the balance of each canteen card. The program calls `Double(balance)`, which does `balance <- balance * 2`. With a balance of **10**, when it comes back the program still shows **10**.

**Why did it not change, and what is the best way to fix it?**
:::

## Try it {#intentalo}

::: intento
Predict what this program shows before running it.

```programa id=duplicar-copia titulo="The balance that does not double"
SubProceso Double(balance Como Entero)
  balance <- balance * 2;
FinSubProceso

Algoritmo Card
  Definir balance Como Entero <- 10;
  Double(balance);
  Escribir balance;
FinAlgoritmo
```
:::

::: respuesta
It shows **10**. The subprogram doubled **its copy** of the balance: the `balance` box inside is another box, with the same name, that disappears when it comes back.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The card balance goes in; the doubled balance has to come out.
- **What does it look like?** The sticker swap of [lesson 0.2](ruta:inicio.nombres): assigning copies a value, it does not tie two boxes together.
- **Which parts does it split into?** You have to understand what the subprogram receives and choose how to get the result back.

## The new tool {#herramienta}

The [[def:ambito|scope]] of a name is the part of the program where it exists. The boxes declared inside a subprogram, and its parameters, only exist while the subprogram runs.

The usual way is [[def:paso-por-valor|pass by value]]: the subprogram receives a copy of the value. It can change its copy as much as it likes, and whoever called does not notice.

```figura-especificacion seccion=subprogramas.parametros figura=paso-valor
```

With [[def:paso-por-referencia|pass by reference]], the subprogram does not receive a copy: it works with the very box of whoever calls. It is marked with `By Reference` on the parameter.

```figura-especificacion seccion=subprogramas.referencia figura=referencia-salida
```

```programa id=valor-y-referencia titulo="By value and by reference" ejecutar
SubProceso A(x Como Entero)
  x <- x + 5;
FinSubProceso

SubProceso B(x Como Entero Por Referencia)
  x <- x + 5;
FinSubProceso

Algoritmo Main
  Definir n Como Entero <- 5;
  A(n);
  Escribir n;
  B(n);
  Escribir n;
FinAlgoritmo
```

```salida
5
10
```

To follow a program with subprograms you picture a stack. Each call opens a [[def:marco|frame]] with its own boxes on top of the stack, and closes it when it comes back. The [[def:pila-de-llamadas|call stack]] is the tower of frames open at each moment.

```figura-especificacion seccion=subprogramas.llamada figura=llamada-marcos
```

::: especificacion
- subprogramas.ambito
- subprogramas.parametros
- subprogramas.referencia
- subprogramas.llamada
:::

## Write {#escribir fase=3}

There are two fixes. The first makes `Double` return the double, and whoever calls decides to keep it:

```programa id=duplicar-retorno titulo="Doubling with a return" ejecutar
SubProceso Double(balance Como Entero) Como Entero
  Retornar balance * 2;
FinSubProceso

Algoritmo Card
  Definir balance Como Entero <- 10;
  balance <- Double(balance);
  Escribir balance;
FinAlgoritmo
```

```salida
20
```

The second lends the box to the subprogram:

```programa id=duplicar-referencia titulo="Doubling with the lent box" ejecutar
SubProceso Double(balance Como Entero Por Referencia)
  balance <- balance * 2;
FinSubProceso

Algoritmo Card
  Definir balance Como Entero <- 10;
  Double(balance);
  Escribir balance;
FinAlgoritmo
```

```salida
20
```

## Test {#probar fase=4}

Follow the stack in the version with a return:

| Moment | Frames on the stack | Visible boxes |
|---|---|---|
| Before calling | Card | `balance` = 10 |
| Inside `Double` | Card, Double | the copy `balance` = 10 |
| On returning | Card | `balance` = 10, and the value 20 comes back |
| After assigning | Card | `balance` = 20 |

While `Double` runs, the outer `balance` exists but cannot be seen from inside: the inner one hides it.

## Improve {#mejorar fase=5}

In one sentence: «A subprogram works with copies, unless it is lent the box».

Compare the two solutions. With a return, whoever reads `balance <- Double(balance);` sees that the balance changes. With the lent box, the call `Double(balance);` gives no warning: the change stays hidden. It is better to return, unless you have to give back more than one value.

## What you learned {#aprendiste}

::: resumen
- {ambito} The scope is the part of the program where a name exists; the variables of a subprogram do not exist outside it.
- {paso-por-valor,paso-por-referencia} By value, the subprogram receives a copy; by reference, it works with the box of whoever calls.
- {pila-de-llamadas,marco} Every call opens a frame with its boxes on top of the stack and closes it when it comes back.
:::

## Practise {#practica}

::: practica
- procedimental.ambito.cinco-diez
- procedimental.ambito.cambiar-figuritas
- procedimental.ambito.ordenar-dos
- procedimental.ambito.quien-existe
- procedimental.ambito.retorno-o-referencia
:::

::: profundizar titulo="Common pitfalls"
- **«They are the same box because they have the same name».** The program of the problem takes it apart: the inner `balance` is another box.
- **Lending the box for everything.** It hides the changes. Read a call and say which boxes change without looking at the subprogram.
- **«The boxes of the subprogram survive between calls».** Every call opens a new frame, with new boxes.
:::

::: siguiente
A subprogram that computes a price also asks for it and shows it. Why does that stop it from being used in another calculation and tested?
:::

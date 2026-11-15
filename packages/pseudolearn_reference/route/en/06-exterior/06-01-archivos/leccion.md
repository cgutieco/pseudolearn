---
id: exterior.archivos
numero: "6.1"
tipo: leccion
titulo: Keeping it for tomorrow
duracion: 35
problema_breve: The stock that is lost on closing
necesita: [concurrente.elegir]
introduce: [archivo, capacidad, limpieza-diferida]
usa: [nucleo-puro, funcion-pura, resultado-con-error, efecto]
---

::: frase
What is in memory is lost on closing; what is saved in a file stays for tomorrow.
:::

## The problem {#problema}

::: problema
The kiosk closes every day with the stock of its five products: juice 10, sandwich 5, biscuit 8, water 12 and fruit 6. The next day the program starts again from zero and **the stock was lost**.

**How do you keep the stock for next time, and what happens if nothing has been saved yet?**
:::

## Try it {#intentalo}

::: intento
What should the program say on the first day, when nothing was ever saved?
:::

::: respuesta
That there is no saved inventory, and start with the initial stock. It is not an error of the program: it is an expected situation, and the program handles it.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The stock of the five products goes in; out comes a text saved outside the program, which is read again tomorrow.
- **What does it look like?** The pure core and the edge of Part IV: building the lines is calculation; saving them touches the world.
- **What can fail outside the program?** The file may not exist, and the folder may not give permission.

## The new tool {#herramienta}

A [[def:archivo|file]] keeps text outside the memory: it is still there when the program ends.

```figura id=ruta-memoria-y-disco
pie: The boxes live in memory and disappear on closing; the file stays on the disk.
paso: The program saves the stock into the file.
paso: The program closed: the memory was emptied and the file is still there.
```

To touch a folder, the program asks for permission. That permission is a [[def:capacidad|capability]]: `requestDirectory` gives the one for a folder, and with it a file is opened. Each step can fail, so it gives back a `Result`, and `Propagate` passes the error to whoever called.

```figura-especificacion seccion=biblioteca.archivos figura=archivo-capas
```

An open file has to be closed, even if the subprogram leaves early because of an error. So as not to forget it, you write a [[def:limpieza-diferida|deferred cleanup]]: `Defer` keeps some orders that run on leaving, in reverse order.

```figura-especificacion seccion=control.diferir figura=diferir-pila
```

```programa id=puerta-luz titulo="Going in and out of the room" ejecutar
SubProceso Visit()
  Escribir "I open the door";
  Diferir
    Escribir "I close the door";
  FinDiferir
  Escribir "I turn on the light";
  Diferir
    Escribir "I turn off the light";
  FinDiferir
  Escribir "I read for a while";
FinSubProceso

Algoritmo Room
  Visit();
FinAlgoritmo
```

```salida
I open the door
I turn on the light
I read for a while
I turn off the light
I close the door
```

::: especificacion
- biblioteca.archivos
- biblioteca.texto
- control.diferir
- tareas.efectos
:::

## Write {#escribir fase=3}

```programa id=inventario-archivo titulo="Saving and reading the stock" ejecutar
Funcion line <- StockLine(name Como Cadena, stock Como Entero)
  Definir line Como Cadena;
  line <- name + ";" + ATexto(stock);
FinFuncion

SubProceso Save(text Como Cadena) Como Resultado<Entero, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("stock.txt", "escritura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.EscribirTexto(text);
FinSubProceso

SubProceso Load() Como Resultado<Cadena, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("stock.txt", "lectura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.LeerTexto();
FinSubProceso

Algoritmo Inventory
  Definir text Como Cadena <- StockLine("juice", 10) + "\n" + StockLine("sandwich", 5) + "\n" + StockLine("biscuit", 8) + "\n" + StockLine("water", 12) + "\n" + StockLine("fruit", 6);
  Segun Save(text) Hacer
    Exito(bytes): Escribir "Saved: ", bytes, " bytes";
    Error(report): Escribir "Could not save: ", report.Codigo;
  FinSegun
  Segun Load() Hacer
    Exito(loaded): Escribir loaded;
    Error(report): Escribir "No saved inventory (", report.Codigo, ")";
  FinSegun
FinAlgoritmo
```

```anfitrion
{}
```

```salida
Saved: 46 bytes
juice;10
sandwich;5
biscuit;8
water;12
fruit;6
```

`StockLine` is a pure function: it builds one line of the file. `Save` and `Load` are the edge: they ask for the capability, open the file and close it with a deferred cleanup. `Discard` makes it explicit that whether closing went well does not matter.

On the first day there is no file. Reading does not stop the program: a `Failure` arrives with the code `no_encontrado`, and the program decides what to do.

```programa id=inventario-sin-archivo titulo="The first day" ejecutar
SubProceso Load() Como Resultado<Cadena, ErrorES>
  Definir folder Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir file Como ArchivoCap <- Propagar folder.Abrir("stock.txt", "lectura");
  Diferir
    Descartar file.Cerrar();
  FinDiferir
  Retornar file.LeerTexto();
FinSubProceso

Algoritmo FirstDay
  Segun Load() Hacer
    Exito(loaded): Escribir loaded;
    Error(report): Escribir "No saved inventory (", report.Codigo, ")";
  FinSegun
FinAlgoritmo
```

```anfitrion
{}
```

```salida
No saved inventory (no_encontrado)
```

## Test {#probar fase=4}

| Case | What happens |
|---|---|
| First day, without a file | `No saved inventory` |
| Day with a file | the five lines are read |
| An empty line in the file | `StockFromLine` marks it as invalid |

The pure part, `StockLine` and its inverse `StockFromLine`, is tested with cases like any function. The part with effects is tested with a memory host: a simulated folder that starts empty.

## Improve {#mejorar fase=5}

In one sentence: «The lines are built with pure functions, and only the edge opens, writes and closes the file».

It is the pure core and the edge of Part IV: if tomorrow the stock is saved somewhere else, only the edge changes.

## What you learned {#aprendiste}

::: resumen
- {archivo} A file keeps text outside the memory; it is still there when the program ends.
- {capacidad} A capability is the permission the program asks for to touch something outside; asking for it can fail.
- {limpieza-diferida} A deferred cleanup is written next to what needs it and runs on leaving, in reverse order.
:::

## Practise {#practica}

::: practica
- exterior.archivos.orden-diferir
- exterior.archivos.linea-stock
- exterior.archivos.stock-de-linea
- exterior.archivos.que-puede-fallar
- exterior.archivos.limpieza-lugar
- exterior.archivos.linea-pruebas
:::

::: profundizar titulo="Common pitfalls"
- **«The file saves itself».** Nothing stays saved if the program does not write it.
- **«If the file does not exist, the program crashes».** A `Failure` arrives that is handled, as on the first day.
- **Believing the deferred cleanup runs where it is written.** It runs on leaving the subprogram; the door and light program shows it.
:::

::: siguiente
Another application wants to read the inventory. In what form is it written so that any program understands it?
:::

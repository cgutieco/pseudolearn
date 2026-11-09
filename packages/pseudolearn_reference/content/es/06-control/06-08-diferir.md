---
id: control.diferir
numero: "6.8"
tipo: construccion
titulo: "Limpiezas con `Diferir`"
anclas: [LANG.CONTROL.CLEANUP#R1, LANG.CONTROL.CLEANUP#R2]
fichas: [construction.defer]
diagnosticos: [controlTransferInsideCleanup]
terminos: [limpieza, ámbito]
---

::: frase
`Diferir` deja apuntado algo que hay que hacer al salir del bloque actual, pase lo que pase: cerrar un archivo, apagar una luz, dejar las cosas como estaban.
:::

## Cómo se escribe {#escribe}

```forma
Diferir
  «instrucciones»
FinDiferir
```

```railes produccion=deferStatement contextuales=Diferir,FinDiferir
```

::: partes
- `Diferir` abre la limpieza.
- «instrucciones» es lo que se hará al salir. No se ejecuta ahora.
- `FinDiferir` cierra la limpieza.
:::

## Cómo funciona {#funciona}

Cuando la ejecución llega a `Diferir`, el cuerpo **no se ejecuta**: se apunta en una pila. Al salir del bloque que contiene el `Diferir` —por el final, por `Salir`, por `Retornar` o por un error propagado— se ejecutan las limpiezas apuntadas, **de la última a la primera**.

```programa id=puerta-luz titulo="Lo último que se abre, lo primero que se cierra" ejecutar
Algoritmo Ordenado
  Escribir "abro la puerta";
  Diferir
    Escribir "cierro la puerta";
  FinDiferir
  Escribir "enciendo la luz";
  Diferir
    Escribir "apago la luz";
  FinDiferir
  Escribir "leo un rato";
FinAlgoritmo
```

```salida
abro la puerta
enciendo la luz
leo un rato
apago la luz
cierro la puerta
```

```figura id=diferir-pila
pie: Las limpiezas se apilan al alcanzarlas y se ejecutan al revés al salir del bloque.
paso: Se alcanza el primer `Diferir`: «cierro la puerta» entra en la pila.
paso: Se alcanza el segundo: «apago la luz» queda encima.
paso: Al terminar el bloque se saca primero la de arriba, «apago la luz», y después «cierro la puerta».
```

Solo cuenta lo que se **alcanza**: un `Diferir` que está en una rama no tomada no apunta nada. Dentro de un bucle, cada vuelta apunta sus propias limpiezas y las ejecuta al terminar esa vuelta:

```programa id=vueltas-diferir titulo="Limpiezas por vuelta" ejecutar
Algoritmo Vueltas
  Para i <- 1 Hasta 3 Hacer
    Diferir
      Escribir "fin de la vuelta ", i;
    FinDiferir
    Si i = 2 Entonces
      Salir;
    FinSi
    Escribir "vuelta ", i;
  FinPara
FinAlgoritmo
```

```salida
vuelta 1
fin de la vuelta 1
fin de la vuelta 2
```

::: limite
- Dentro de una limpieza no se admiten `Retornar`, `Salir`, `Propagar` ni otro `Diferir`.
- Si el programa falla con una trampa, termina en el acto **sin** ejecutar las limpiezas pendientes.
- `Retornar` calcula su resultado antes de las limpiezas: una limpieza no puede ocultar el valor ni el error que se devuelve.
:::

::: errores
```programa id=diferir-salir titulo="Salir dentro de una limpieza" ejecutar
Algoritmo LimpiezaMala
  Para i <- 1 Hasta 2 Hacer
    Diferir
      Salir;
    FinDiferir
  FinPara
FinAlgoritmo
```

```diagnosticos
controlTransferInsideCleanup
```
:::

::: por-dentro
El motor copia el cuerpo de cada limpieza en cada salida del bloque, en orden inverso. Por eso la representación intermedia de `puerta-luz` tiene las dos escrituras finales después de «leo un rato».

```ri programa=puerta-luz
```
:::

::: nota
La pila de platos ayuda: el último que se pone es el primero que se quita. Predice la salida de `vueltas-diferir` antes de ejecutarla: la vuelta 2 limpia aunque salga con `Salir`.
:::

::: resumen
- `Diferir` apunta una limpieza para cuando se salga del bloque.
- Las limpiezas se ejecutan al revés del orden en que se alcanzaron.
- Se ejecutan al salir por el final, `Salir`, `Retornar` o un error propagado.
- Una trampa termina el programa sin ejecutarlas.
:::

::: vease
- [Salir de un bucle](#control.salir)
- [Archivos](#biblioteca.archivos)
- [Retornar](#subprogramas.retornar)
:::

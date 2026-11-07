---
id: procedimental.ambito
numero: "2.2"
tipo: leccion
titulo: Lo que cada parte ve
duracion: 30
problema_breve: El saldo que no se duplica
necesita: [procedimental.dividir]
introduce: [ambito, paso-por-valor, paso-por-referencia, pila-de-llamadas, marco]
usa: [subprograma, llamada, parametro, valor-de-retorno, variable, asignar]
pieza: 5
---

::: frase
Cada llamada trabaja con sus propias cajas, salvo que se le preste una caja de quien llama.
:::

## El problema {#problema}

::: problema
En el día del estudiante, el kiosco duplica el saldo de cada tarjeta del comedor. El programa llama a `Duplicar(saldo)`, que hace `saldo <- saldo * 2`. Con un saldo de **10**, al volver el programa sigue mostrando **10**.

**¿Por qué no cambió, y cuál es la mejor forma de arreglarlo?**
:::

## Inténtalo {#intentalo}

::: intento
Predice qué muestra este programa antes de ejecutarlo.

```programa id=duplicar-copia titulo="El saldo que no se duplica"
SubProceso Duplicar(saldo Como Entero)
  saldo <- saldo * 2;
FinSubProceso

Algoritmo Tarjeta
  Definir saldo Como Entero <- 10;
  Duplicar(saldo);
  Escribir saldo;
FinAlgoritmo
```
:::

::: respuesta
Muestra **10**. El subprograma duplicó **su copia** del saldo: la caja `saldo` de adentro es otra caja, que se llama igual y desaparece al volver.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra el saldo de la tarjeta; tiene que salir el saldo duplicado.
- **¿A qué se parece?** Al intercambio de figuritas de [la lección 0.2](ruta:inicio.nombres): asignar copia un valor, no ata dos cajas.
- **¿En qué partes se divide?** Hay que entender qué recibe el subprograma y elegir cómo hacer llegar el resultado de vuelta.

## La herramienta nueva {#herramienta}

El [[def:ambito|ámbito]] de un nombre es la parte del programa donde existe. Las cajas declaradas dentro de un subprograma, y sus parámetros, solo existen mientras el subprograma se ejecuta.

Lo normal es el [[def:paso-por-valor|paso por valor]]: el subprograma recibe una copia del dato. Puede cambiar su copia todo lo que quiera, y quien llamó no se entera.

```figura-especificacion seccion=subprogramas.parametros figura=paso-valor
```

Con el [[def:paso-por-referencia|paso por referencia]], el subprograma no recibe una copia: trabaja con la caja misma de quien llama. Se marca con `Por Referencia` en el parámetro.

```figura-especificacion seccion=subprogramas.referencia figura=referencia-salida
```

```programa id=valor-y-referencia titulo="Por valor y por referencia" ejecutar
SubProceso A(x Como Entero)
  x <- x + 5;
FinSubProceso

SubProceso B(x Como Entero Por Referencia)
  x <- x + 5;
FinSubProceso

Algoritmo Principal
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

Para seguir un programa con subprogramas se imagina una pila. Cada llamada abre un [[def:marco|marco]] con sus propias cajas encima de la pila, y lo cierra al volver. La [[def:pila-de-llamadas|pila de llamadas]] es la torre de marcos abiertos en cada momento.

```figura-especificacion seccion=subprogramas.llamada figura=llamada-marcos
```

::: especificacion
- subprogramas.ambito
- subprogramas.parametros
- subprogramas.referencia
- subprogramas.llamada
:::

## Escribir {#escribir fase=3}

Hay dos arreglos. El primero hace que `Duplicar` retorne el doble, y quien llama decide guardarlo:

```programa id=duplicar-retorno titulo="Duplicar con retorno" ejecutar
SubProceso Duplicar(saldo Como Entero) Como Entero
  Retornar saldo * 2;
FinSubProceso

Algoritmo Tarjeta
  Definir saldo Como Entero <- 10;
  saldo <- Duplicar(saldo);
  Escribir saldo;
FinAlgoritmo
```

```salida
20
```

El segundo le presta la caja al subprograma:

```programa id=duplicar-referencia titulo="Duplicar con la caja prestada" ejecutar
SubProceso Duplicar(saldo Como Entero Por Referencia)
  saldo <- saldo * 2;
FinSubProceso

Algoritmo Tarjeta
  Definir saldo Como Entero <- 10;
  Duplicar(saldo);
  Escribir saldo;
FinAlgoritmo
```

```salida
20
```

## Probar {#probar fase=4}

Sigue la pila en la versión con retorno:

| Momento | Marcos en la pila | Cajas visibles |
|---|---|---|
| Antes de llamar | Tarjeta | `saldo` = 10 |
| Dentro de `Duplicar` | Tarjeta, Duplicar | la copia `saldo` = 10 |
| Al retornar | Tarjeta | `saldo` = 10, y el valor 20 vuelve |
| Después de asignar | Tarjeta | `saldo` = 20 |

Mientras se ejecuta `Duplicar`, el `saldo` de afuera existe pero no se ve desde adentro: el de adentro lo tapa.

## Mejorar {#mejorar fase=5}

En una frase: «Un subprograma trabaja con copias, salvo que se le preste la caja».

Compara las dos soluciones. Con retorno, quien lee `saldo <- Duplicar(saldo);` ve que el saldo cambia. Con la caja prestada, la llamada `Duplicar(saldo);` no avisa nada: el cambio queda escondido. Conviene retornar, salvo que haya que devolver más de un valor.

## Lo que aprendiste {#aprendiste}

::: resumen
- {ambito} El ámbito es la parte del programa donde existe un nombre; las variables de un subprograma no existen afuera.
- {paso-por-valor,paso-por-referencia} Por valor, el subprograma recibe una copia; por referencia, trabaja con la caja de quien llama.
- {pila-de-llamadas,marco} Toda llamada abre un marco con sus cajas encima de la pila y lo cierra al volver.
:::

## Practica {#practica}

::: practica
- procedimental.ambito.cinco-diez
- procedimental.ambito.cambiar-figuritas
- procedimental.ambito.ordenar-dos
- procedimental.ambito.quien-existe
- procedimental.ambito.retorno-o-referencia
:::

::: docentes
- **«Son la misma caja porque se llaman igual».** El programa del problema lo desarma: el `saldo` de adentro es otra caja.
- **Prestar la caja para todo.** Esconde los cambios. Pide que lean una llamada y digan qué cajas cambian sin mirar el subprograma.
- **«Las cajas del subprograma sobreviven entre llamadas».** Toda llamada abre un marco nuevo, con cajas nuevas.
:::

::: siguiente
Un subprograma que calcula un precio también lo pregunta y lo muestra. ¿Por qué eso impide usarlo en otro cálculo y probarlo?
:::

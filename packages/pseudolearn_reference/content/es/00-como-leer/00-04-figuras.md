---
id: lectura.figuras
numero: "0.4"
tipo: concepto
titulo: Cómo leer las figuras
anclas: [ENG.STATE.SNAPSHOT#R1, ENG.TRACE.EVENTS#R1]
terminos: [figura, paso, memoria, traza]
---

::: frase
Las figuras muestran lo que no se ve en el texto del programa: la memoria, el orden en que se ejecuta cada parte y lo que registra el motor.
:::

## Cómo funciona {#funciona}

Hay dos clases de figuras. Las **fijas** explican una idea con un solo dibujo. Las **figuras por pasos** cuentan una ejecución: debajo tienen los botones «Anterior» y «Siguiente» y un texto que explica cada paso.

Las figuras por pasos van acompañadas de **zonas**. Cada zona es un panel que crece a medida que avanzas:

- **Memoria**: las variables y su valor en ese momento.
- **Salida**: lo que el programa ya escribió.
- **Traza**: los sucesos que registró el motor, como «entra en sentencia» o «decisión».

```figura id=leer-figura
pie: Una figura por pasos. El dibujo resalta la parte que se ejecuta; las zonas de abajo acumulan memoria, salida y traza.
paso: El motor crea la variable `total` con el valor 0.
paso: Suma 5 y el total pasa a valer 5.
paso: Escribe el total. La salida recibe la línea «5».
panel Memoria 1: `total` = 0
panel Memoria 2: `total` = 5
panel Salida 3: 5
panel Traza 1: entra en sentencia · línea 2
panel Traza 2: entra en sentencia · línea 3
panel Traza 3: escribe · 5
```

Este es el programa que cuenta la figura:

```programa id=suma titulo="Sumar y escribir" ejecutar
Algoritmo Suma
  Definir total Como Entero <- 0;
  total <- total + 5;
  Escribir total;
FinAlgoritmo
```

```salida
5
```

## Colores de las figuras {#colores}

Las figuras usan los mismos colores que el editor y cambian solas con el tema claro u oscuro. Las cajas de línea continua son valores o instrucciones; las de línea discontinua son huecos o cosas que todavía no existen. El rojo marca lo que falla o no se ejecuta; el verde, lo que termina bien.

::: resumen
- Las figuras fijas explican una idea; las figuras por pasos cuentan una ejecución.
- Las zonas Memoria, Salida y Traza crecen con cada paso.
- Los colores siguen al editor y al tema del sistema.
:::

::: vease
- [El viaje de un programa](#vision.viaje)
- [Observación: traza y puntos de control](#motor.observacion)
:::

---
id: funcional.clausuras
numero: "4.3"
tipo: leccion
titulo: Funciones que recuerdan
duracion: 30
problema_breve: La campaña de descuento de la semana
necesita: [funcional.orden-superior]
introduce: [clausura, fabrica-de-funciones]
usa: [funcion-como-valor, orden-superior, mapear, funcion-pura, ambito, parametro]
---

::: frase
Una clausura es una función que se lleva consigo los valores que necesita.
:::

## El problema {#problema}

::: problema
Cada semana, el kiosco lanza una campaña de descuento cuyo **porcentaje se lee al empezar**: 10, 20, 25… El `Mapear` de la lección anterior necesita una función que reciba un solo dato, el precio.

**¿Cómo se crea esa función si el porcentaje no se conoce al escribir el programa?**
:::

## Inténtalo {#intentalo}

::: intento
Escribe en palabras qué función haría falta para el 10 % y cuál para el 20 %. ¿Qué tienen en común?
:::

::: respuesta
Para el 10 %: «al precio, réstale su décima parte». Para el 20 %: «al precio, réstale su quinta parte». Las dos hacen lo mismo con un número distinto. Ese número no se conoce al escribir el programa: hay que fabricar la función cuando se lee.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran el porcentaje y los precios; salen los precios con descuento.
- **¿A qué se parece?** Al `Mapear` de [la lección 4.2](ruta:funcional.orden-superior), con una función que todavía no existe.
- **¿Qué parte es cálculo y qué parte toca el mundo?** Pedir el porcentaje toca el mundo; fabricar la función y aplicarla es cálculo.

El plan: una función que **fabrica** funciones de descuento. Recibe el porcentaje y devuelve una función de un parámetro que ya lo tiene adentro.

## La herramienta nueva {#herramienta}

Una función se puede escribir en el lugar donde se necesita, sin nombre: `Funcion(precio Como Entero) Como Entero … FinFuncion;`. Si usa un valor de afuera, se lo lleva consigo. Una función que recuerda valores del momento en que se creó es una [[def:clausura|clausura]]. Y una función que recibe datos y devuelve una función preparada con ellos es una [[def:fabrica-de-funciones|fábrica de funciones]].

```figura id=ruta-mochila
pie: La fábrica guarda el porcentaje en la mochila de la función que devuelve; la función lo usa cada vez que se la llama.
paso: La fábrica recibe 20 y lo guarda en la mochila de la función nueva.
paso: Más tarde, la función recibe un precio y usa el 20 que lleva en la mochila.
```

```figura-especificacion seccion=tipos.funciones figura=clausura
```

```programa id=sumador titulo="Un sumador fabricado" ejecutar
Funcion fabricada <- CrearSumador(cantidad Como Entero)
  Definir fabricada Como Funcion(Entero) Como Entero <- Funcion(x Como Entero) Como Entero
    Retornar x + cantidad;
  FinFuncion;
FinFuncion

Algoritmo Sumar
  Definir masTres Como Funcion(Entero) Como Entero <- CrearSumador(3);
  Escribir masTres(4);
FinAlgoritmo
```

```salida
7
```

Qué puede guardar una clausura en su mochila tiene una regla: un valor que después se reasigna no se puede capturar. Está en [la Especificación](especificacion:tipos.funciones).

::: especificacion
- tipos.funciones
:::

## Escribir {#escribir fase=3}

```programa id=campanas titulo="La campaña de la semana" ejecutar
Funcion fabricada <- CrearDescuento(porcentaje Como Entero)
  Definir fabricada Como Funcion(Entero) Como Entero <- Funcion(precio Como Entero) Como Entero
    Retornar precio - precio * porcentaje div 100;
  FinFuncion;
FinFuncion

Funcion nuevos <- Mapear(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir nuevos Como Vector<Entero> <- Vector();
  Para Cada elemento En v Hacer
    nuevos.Agregar(f(elemento));
  FinPara
FinFuncion

Algoritmo Campanas
  Definir porcentaje Como Entero;
  Leer porcentaje;
  Definir precios Como Vector<Entero> <- Vector();
  precios.Agregar(50);
  precios.Agregar(30);
  precios.Agregar(20);
  Definir descuento Como Funcion(Entero) Como Entero <- CrearDescuento(porcentaje);
  Escribir Mapear(precios, descuento);
FinAlgoritmo
```

```entrada
10
```

```salida
[45, 27, 18]
```

## Probar {#probar fase=4}

| Porcentaje | Precios 50, 30 y 20 | Por qué |
|---|---|---|
| 10 | [45, 27, 18] | caso normal |
| 0 | [50, 30, 20] | borde: los precios no cambian |
| 100 | [0, 0, 0] | borde: todo gratis |

## Mejorar {#mejorar fase=5}

En una frase: «La fábrica recibe el porcentaje de la semana y devuelve un descuento que lo recuerda».

Dos campañas a la vez son dos funciones de la misma fábrica: `CrearDescuento(10)` y `CrearDescuento(25)`, cada una con su propia mochila.

## Lo que aprendiste {#aprendiste}

::: resumen
- {clausura} Una clausura es una función que recuerda valores del momento en que se creó.
- {fabrica-de-funciones} Una fábrica de funciones recibe datos y devuelve una función preparada con ellos.
:::

## Practica {#practica}

::: practica
- funcional.clausuras.sumador-predecir
- funcional.clausuras.captura-cambiante
- funcional.clausuras.multiplicador
- funcional.clausuras.componer
- funcional.clausuras.mochila
:::

::: profundizar titulo="Tropiezos frecuentes"
- **Creer que la clausura ve cambios posteriores.** Aquí no puede haberlos: el motor no deja capturar algo que después se reasigna.
- **Confundir la fábrica con la función fabricada.** `CrearDescuento` recibe un porcentaje; la función que devuelve recibe un precio.
:::

::: siguiente
Un pedido marcado como entregado no tiene hora de entrega. ¿Se puede hacer que ese error ni siquiera se pueda escribir?
:::

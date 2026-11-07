---
id: funcional.orden-superior
numero: "4.2"
tipo: leccion
titulo: Funciones que reciben funciones
duracion: 40
problema_breve: Tres bucles que cambian en una línea
necesita: [funcional.sin-cambiar]
introduce: [funcion-como-valor, orden-superior, mapear, filtrar, reducir]
usa: [funcion-pura, vector, esquema, acumulador, nucleo-puro, parametro]
---

::: frase
Si lo único que cambia entre dos bucles es una operación, la operación puede ser un dato.
:::

## El problema {#problema}

::: problema
El kiosco tiene sus precios en una lista: **3, 5, 2, 1 y 2**. Hay tres programas: uno **suma 1 peso** a cada precio, otro los **duplica** y otro les **resta 1**. Los tres tienen el mismo recorrido y cambian en una sola línea.

**¿Cómo se escribe el recorrido una sola vez?**
:::

## Inténtalo {#intentalo}

::: intento
Imagina los tres programas uno al lado del otro. ¿Qué línea es distinta en cada uno?
:::

::: respuesta
Solo la que calcula el precio nuevo: `precio + 1`, `precio * 2` o `precio - 1`. Todo lo demás, crear el vector nuevo, recorrer y agregar, es idéntico. Si esa línea fuera un dato, el recorrido se escribiría una vez.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran los precios y la operación; sale un vector nuevo con los precios cambiados.
- **¿A qué se parece?** A los esquemas de [la lección 1.6](ruta:imperativo.esquemas): recorrer, filtrar y acumular, siempre con la misma forma.
- **¿Qué parte es cálculo y qué parte toca el mundo?** Todo es cálculo: solo mostrar el resultado toca el mundo.

```figura id=ruta-cinta
pie: Tres máquinas para colecciones: una cambia cada caja, otra deja pasar algunas y otra junta todas en un valor.
paso: Cada precio pasa por una máquina que lo cambia: sale una cinta del mismo largo.
paso: Una compuerta deja pasar solo los precios que cumplen una condición.
paso: Un embudo junta todos los precios en un solo valor.
```

## La herramienta nueva {#herramienta}

En PseudoLearn, una función es un valor más: se puede guardar y pasar a otra función, por su nombre. Eso es tratar una [[def:funcion-como-valor|función como valor]]. Una función que recibe o devuelve funciones es de [[def:orden-superior|orden superior]]. El tipo de un parámetro que es una función dice qué recibe y qué devuelve: `Funcion(Entero) Como Entero`.

```programa id=aplicar-dos-veces titulo="Aplicar dos veces" ejecutar
Funcion siguiente <- MasUno(x Como Entero)
  Definir siguiente Como Entero;
  siguiente <- x + 1;
FinFuncion

Funcion resultado2 <- AplicarDosVeces(f Como Funcion(Entero) Como Entero, x Como Entero)
  Definir resultado2 Como Entero;
  resultado2 <- f(f(x));
FinFuncion

Algoritmo Dos
  Escribir AplicarDosVeces(MasUno, 5);
FinAlgoritmo
```

```salida
7
```

Con funciones como parámetros, tres esquemas se escriben una sola vez. [[def:mapear|Mapear]] aplica una función a cada elemento y da otro vector del mismo largo. [[def:filtrar|Filtrar]] se queda con los elementos que cumplen una condición. [[def:reducir|Reducir]] combina todos los elementos en un solo valor, empezando por un valor inicial.

::: especificacion
- tipos.funciones
- tipos.vectores
- subprogramas.pureza
:::

## Escribir {#escribir fase=3}

```programa id=mapear-filtrar-reducir titulo="Mapear, filtrar y reducir" ejecutar
Funcion siguiente <- MasUno(x Como Entero)
  Definir siguiente Como Entero;
  siguiente <- x + 1;
FinFuncion

Funcion barato <- EsBarato(precio Como Entero)
  Definir barato Como Logico;
  barato <- precio <= 2;
FinFuncion

Funcion total <- Sumar(a Como Entero, b Como Entero)
  Definir total Como Entero;
  total <- a + b;
FinFuncion

Funcion nuevos <- Mapear(v Como Vector<Entero>, f Como Funcion(Entero) Como Entero)
  Definir nuevos Como Vector<Entero> <- Vector();
  Para Cada elemento En v Hacer
    nuevos.Agregar(f(elemento));
  FinPara
FinFuncion

Funcion elegidos <- Filtrar(v Como Vector<Entero>, condicion Como Funcion(Entero) Como Logico)
  Definir elegidos Como Vector<Entero> <- Vector();
  Para Cada elemento En v Hacer
    Si condicion(elemento) Entonces
      elegidos.Agregar(elemento);
    FinSi
  FinPara
FinFuncion

Funcion acumulado <- Reducir(v Como Vector<Entero>, f Como Funcion(Entero, Entero) Como Entero, inicial Como Entero)
  Definir acumulado Como Entero <- inicial;
  Para Cada elemento En v Hacer
    acumulado <- f(acumulado, elemento);
  FinPara
FinFuncion

Algoritmo Precios
  Definir precios Como Vector<Entero> <- Vector();
  precios.Agregar(3);
  precios.Agregar(5);
  precios.Agregar(2);
  precios.Agregar(1);
  precios.Agregar(2);
  Escribir Mapear(precios, MasUno);
  Escribir Filtrar(precios, EsBarato);
  Escribir Reducir(precios, Sumar, 0);
FinAlgoritmo
```

```salida
[4, 6, 3, 2, 3]
[2, 1, 2]
13
```

`Mapear` no sabe qué hace `MasUno`: solo sabe que recibe un número y devuelve otro. Lo mismo `Filtrar` con `EsBarato` y `Reducir` con `Sumar`.

## Probar {#probar fase=4}

Con un vector vacío, `Mapear` y `Filtrar` dan un vector vacío, y `Reducir` da el valor inicial: es el caso borde de las tres.

| Llamada | Con los precios | Con un vector vacío |
|---|---|---|
| `Mapear(v, MasUno)` | [4, 6, 3, 2, 3] | [] |
| `Filtrar(v, EsBarato)` | [2, 1, 2] | [] |
| `Reducir(v, Sumar, 0)` | 13 | 0 |

## Mejorar {#mejorar fase=5}

En una frase: «El recorrido se escribe una vez, y la operación que cambia se le pasa como dato».

Los tres programas del problema quedan en tres llamadas a `Mapear`, con `MasUno`, `Doble` y `MenosUno`. Y se pueden componer: el total de los precios baratos con aumento es `Reducir(Mapear(Filtrar(precios, EsBarato), MasUno), Sumar, 0)`.

## Lo que aprendiste {#aprendiste}

::: resumen
- {funcion-como-valor,orden-superior} Una función puede pasarse como dato; una función que recibe o devuelve funciones es de orden superior.
- {mapear,filtrar,reducir} Mapear aplica una función a cada elemento; filtrar se queda con los que cumplen una condición; reducir combina todos en un solo valor.
:::

## Practica {#practica}

::: practica
- funcional.orden-superior.mapear-predecir
- funcional.orden-superior.cual-de-las-tres
- funcional.orden-superior.pares
- funcional.orden-superior.maximo-reducir
- funcional.orden-superior.tres-en-uno
- funcional.orden-superior.por-que-pasar
:::

::: docentes
- **Llamar a la función en lugar de pasarla.** `Mapear(v, MasUno(1))` le pasa un número, no la función. El motor lo rechaza por tipo.
- **Reducir con un valor inicial equivocado.** Con el mayor, empezar en 0 falla con números negativos.
- **Querer mapear cuando se necesita filtrar.** Pregunta: ¿el resultado tiene el mismo largo o puede ser más corto?
:::

::: siguiente
Cada semana hay una campaña con otro porcentaje de descuento, que se lee al empezar. ¿Se puede fabricar una función a partir de un dato?
:::

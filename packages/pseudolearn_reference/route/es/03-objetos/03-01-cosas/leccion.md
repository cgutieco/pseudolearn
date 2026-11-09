---
id: objetos.cosas
numero: "3.1"
tipo: apertura
titulo: Cosas que saben y hacen
duracion: 40
problema_breve: Las dos máquinas expendedoras
necesita: [procedimental.proyecto]
introduce: [programacion-orientada-a-objetos, objeto, clase, atributo, metodo, constructor, instancia]
usa: [paradigma, programacion-procedimental, registro, campo, subprograma, parametro, valor-de-retorno]
---

::: frase
Un objeto guarda su propio estado y sabe hacer las operaciones que le corresponden.
:::

## El problema {#problema}

::: problema
El kiosco tiene **dos máquinas expendedoras**. Cada una tiene su **stock** de latas, el **dinero** recaudado y el **precio**, de 3 pesos. El programa actual usa `stock1`, `dinero1`, `stock2` y `dinero2`, y repite el código de vender para cada máquina. Ayer, una venta en la máquina 1 descontó una lata de la máquina 2.

**¿Cómo se escribe para que cada máquina cuide sus propios datos?**
:::

## Inténtalo {#intentalo}

::: intento
Encuentra en este programa la línea que descuenta de la máquina equivocada.

```programa id=maquinas-sueltas titulo="Dos máquinas con cajas sueltas"
Algoritmo Maquinas
  Definir stock1, dinero1, stock2, dinero2 Como Entero;
  stock1 <- 10;
  dinero1 <- 0;
  stock2 <- 10;
  dinero2 <- 0;
  stock1 <- stock1 - 1;
  dinero1 <- dinero1 + 3;
  stock2 <- stock2 - 1;
  dinero1 <- dinero1 + 3;
FinAlgoritmo
```
:::

::: respuesta
Es la penúltima línea: la segunda venta cobra en la máquina 1 pero descuenta la lata de la máquina 2. Con cuatro cajas sueltas y el código de vender repetido, equivocarse de número es muy fácil.
:::

## Un paradigma nuevo {#paradigma}

La [[def:programacion-orientada-a-objetos|programación orientada a objetos]] arma un programa con objetos: cosas que guardan su propio estado y saben hacer las operaciones que les corresponden.

::: paradigma
- pregunta: ¿y si los datos vinieran con sus propias operaciones y supieran cuidarse solos?
- metafora: una máquina expendedora real. Por dentro tiene latas y monedas; por fuera, botones. Nadie mete la mano para sacar una lata. Deja de valer en un punto: un objeto de programa se puede crear cuantas veces haga falta.
- historia: en 1967, Ole-Johan Dahl y Kristen Nygaard presentaron Simula, el primer lenguaje con clases y objetos. En la década de 1970, el equipo de Alan Kay en Xerox PARC creó Smalltalk, donde todo es un objeto que recibe mensajes.
- costo: hay que decidir qué cosas existen y qué sabe hacer cada una; un mal reparto complica más de lo que ayuda.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran las ventas de cada máquina; sale el estado de cada una: latas y dinero.
- **¿A qué se parece?** A un registro de [la lección 2.5](ruta:procedimental.datos), con un detalle nuevo: las operaciones van junto con los datos.
- **¿Quién tiene la información para hacer esto?** La máquina misma: sabe su stock, su dinero y su precio, y por eso es la que tiene que saber vender y cargar latas.

## La herramienta nueva {#herramienta}

Una [[def:clase|clase]] describe un tipo de cosa: qué sabe y qué sabe hacer. Lo que sabe son sus [[def:atributo|atributos]]; lo que sabe hacer, sus [[def:metodo|métodos]]. Con una clase se crean [[def:objeto|objetos]], y cada uno es una [[def:instancia|instancia]] de esa clase, con sus propios valores.

```figura id=ruta-molde
pie: El molde dice qué forma tienen las galletas; cada galleta tiene su propia decoración. La analogía falla en un punto: el molde también dice qué sabe hacer cada galleta.
paso: Un molde con forma de estrella: la clase.
paso: Tres galletas hechas con el mismo molde, cada una decorada distinto: tres objetos con su propio estado.
```

```figura-especificacion seccion=objetos.clase figura=clase-objetos
```

El [[def:constructor|constructor]] es el método que prepara un objeto nuevo con sus valores iniciales. Se ejecuta al crearlo con `Nuevo`:

```figura-especificacion seccion=objetos.constructor figura=nuevo-pasos
```

```programa id=contador titulo="Un contador" ejecutar
Clase Contador
  Definir valor Como Entero;

  Metodo Constructor()
    Este.valor <- 0;
  FinMetodo

  Metodo Incrementar()
    Este.valor <- Este.valor + 1;
  FinMetodo

  Metodo Actual() Como Entero
    Retornar Este.valor;
  FinMetodo
FinClase

Algoritmo Contar
  Definir pasos Como Contador <- Nuevo Contador();
  pasos.Incrementar();
  pasos.Incrementar();
  Escribir pasos.Actual();
FinAlgoritmo
```

```salida
2
```

Dentro de un método, `Este` es el objeto que recibió la llamada: `pasos.Incrementar()` cambia el valor de `pasos` y de ningún otro contador.

::: especificacion
- objetos.clase
- objetos.metodos
- objetos.constructor
:::

## Escribir {#escribir fase=3}

```programa id=maquinas titulo="Dos máquinas que se cuidan solas" ejecutar
Clase Maquina
  Definir stock, recaudado, precio Como Entero;

  Metodo Constructor(latas Como Entero)
    Este.stock <- latas;
    Este.recaudado <- 0;
    Este.precio <- 3;
  FinMetodo

  Metodo Vender() Como Logico
    Si Este.stock = 0 Entonces
      Retornar Falso;
    FinSi
    Este.stock <- Este.stock - 1;
    Este.recaudado <- Este.recaudado + Este.precio;
    Retornar Verdadero;
  FinMetodo

  Metodo Estado() Como Cadena
    Retornar ConvertirATexto(Este.stock) + " latas, " + ConvertirATexto(Este.recaudado) + " pesos";
  FinMetodo
FinClase

Algoritmo Kiosco
  Definir primera Como Maquina <- Nuevo Maquina(10);
  Definir segunda Como Maquina <- Nuevo Maquina(10);
  Escribir primera.Vender(), " ", primera.Vender(), " ", segunda.Vender();
  Escribir "Máquina 1: ", primera.Estado();
  Escribir "Máquina 2: ", segunda.Estado();
FinAlgoritmo
```

```salida
Verdadero Verdadero Verdadero
Máquina 1: 8 latas, 6 pesos
Máquina 2: 9 latas, 3 pesos
```

Cada `Vender()` retorna si pudo vender: las tres veces, sí. Ya no hay forma de vender en una máquina y descontar en otra: cada venta se le pide a una máquina, y la máquina cambia solo sus propios datos.

## Probar {#probar fase=4}

Una máquina sin latas no vende: `Vender` retorna falso y no cambia nada.

```programa id=sin-stock titulo="Una máquina vacía" ejecutar
Clase Maquina
  Definir stock, recaudado, precio Como Entero;

  Metodo Constructor(latas Como Entero)
    Este.stock <- latas;
    Este.recaudado <- 0;
    Este.precio <- 3;
  FinMetodo

  Metodo Vender() Como Logico
    Si Este.stock = 0 Entonces
      Retornar Falso;
    FinSi
    Este.stock <- Este.stock - 1;
    Este.recaudado <- Este.recaudado + Este.precio;
    Retornar Verdadero;
  FinMetodo
FinClase

Algoritmo Vacia
  Definir maquina Como Maquina <- Nuevo Maquina(0);
  Escribir maquina.Vender(), " ", maquina.stock, " ", maquina.recaudado;
FinAlgoritmo
```

```salida
Falso 0 0
```

## Mejorar {#mejorar fase=5}

En una frase: «Cada máquina es un objeto que guarda sus latas y su dinero, y sabe vender sin tocar a las otras».

Una tercera máquina es una línea más: `Nuevo Maquina(10)`.

| | Cajas sueltas | Objetos |
|---|---|---|
| Agregar una máquina | cuatro cajas nuevas y otra copia del código de vender | una línea |
| Equivocarse de máquina | fácil: cambiar un número | imposible: se le pide a la máquina |
| Dónde vive la regla de vender | en cada copia | en un solo método |

## Lo que aprendiste {#aprendiste}

::: resumen
- {programacion-orientada-a-objetos} La programación orientada a objetos arma un programa con objetos que guardan su estado y colaboran.
- {clase,objeto,instancia} Una clase describe un tipo de objeto; cada objeto creado con ella es una instancia.
- {atributo,metodo} Los atributos son lo que el objeto sabe; los métodos, lo que sabe hacer.
- {constructor} El constructor prepara un objeto nuevo con sus valores iniciales.
:::

## Practica {#practica}

::: practica
- objetos.cosas.mascota
- objetos.cosas.dos-contadores
- objetos.cosas.alcancia-objeto
- objetos.cosas.maquina-resolver
- objetos.cosas.clase-u-objeto
- objetos.cosas.cronometro-objeto
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«La clase y el objeto son lo mismo».** Usa la figura del molde: un molde, muchas galletas.
- **Un método que no usa el estado del objeto.** Cuando no toca `Este`, probablemente es una función que va afuera.
- **Atributos que deberían ser variables locales.** Un dato que solo usa un método durante una llamada no es parte del estado.
:::

::: siguiente
Alguien dejó la tarjeta del comedor con saldo negativo. ¿Cómo se impide desde el objeto?
:::

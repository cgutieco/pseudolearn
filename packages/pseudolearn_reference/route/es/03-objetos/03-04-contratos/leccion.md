---
id: objetos.contratos
numero: "3.4"
tipo: leccion
titulo: Contratos
duracion: 35
problema_breve: Los medios de pago de la caja
necesita: [objetos.identidad]
introduce: [interfaz, polimorfismo, despacho-dinamico]
usa: [clase, objeto, metodo, seleccion-multiple, subprograma, parametro]
---

::: frase
Si el código depende de lo que un objeto promete y no de qué objeto es, se le pueden agregar casos sin tocarlo.
:::

## El problema {#problema}

::: problema
La caja cobra en **efectivo** (sin recargo), con **tarjeta** (5 % de recargo, en pesos enteros) y con **vale** (paga hasta lo que tiene el vale). Hoy la caja pregunta qué medio es y tiene un camino por cada uno, y la semana que viene se agrega la **transferencia**.

**¿Cómo se escribe la caja para que un medio nuevo no obligue a cambiarla?**
:::

## Inténtalo {#intentalo}

::: intento
Calcula cuánto se cobra por 20 pesos con cada medio, si el vale es de 15.
:::

::: respuesta
En efectivo, 20. Con tarjeta, 21: 20 más `20 * 5 div 100`. Con el vale, 15, y faltan 5 que habrá que pagar de otra forma.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran el medio y el monto; sale lo que se cobró.
- **¿A qué se parece?** Al menú del kiosco de [la lección 1.2](ruta:imperativo.caminos): un `Segun` con un caso por opción. Funciona, pero cada opción nueva lo cambia.
- **¿Quién tiene la información para hacer esto?** Todo medio de pago sabe cómo se cobra. Lo que no cambia es que la caja le pide cobrar.

## La herramienta nueva {#herramienta}

Una [[def:interfaz|interfaz]] es un contrato: los métodos que una clase promete tener, sin decir cómo los hace. Una clase la cumple con `Realiza`.

```figura id=ruta-enchufe
pie: La caja es un enchufe; cada medio de pago, un aparato con el mismo enchufe. La analogía falla en un punto: un aparato no cambia lo que hace según quién lo enchufa, y un objeto puede hacer cosas distintas con el mismo pedido.
```

```figura-especificacion seccion=objetos.interfaces figura=interfaz-promesa
```

Usar objetos de clases distintas a través del mismo contrato es [[def:polimorfismo|polimorfismo]]. Cuando la caja pide `medio.Cobrar(monto)`, el motor elige, al ejecutar, el método de la clase real del objeto que recibió: eso es el [[def:despacho-dinamico|despacho dinámico]].

En PseudoLearn una interfaz no se usa como tipo de una variable: se usa como condición de un subprograma genérico. `CobrarCon<T: MedioDePago>` acepta cualquier clase que cumpla el contrato. Los detalles están en [la Especificación](especificacion:objetos.interfaces).

::: especificacion
- objetos.interfaces
:::

## Escribir {#escribir fase=3}

```programa id=medios-de-pago titulo="La caja que acepta cualquier medio" ejecutar
Interfaz MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero;
FinInterfaz

Clase Efectivo Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto;
  FinMetodo
FinClase

Clase Tarjeta Realiza MedioDePago
  Metodo Cobrar(monto Como Entero) Como Entero
    Retornar monto + monto * 5 div 100;
  FinMetodo
FinClase

Clase Vale Realiza MedioDePago
  Privado Definir disponible Como Entero;

  Metodo Constructor(saldo Como Entero)
    Este.disponible <- saldo;
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Entero
    Si monto > Este.disponible Entonces
      Retornar Este.disponible;
    FinSi
    Retornar monto;
  FinMetodo
FinClase

SubProceso CobrarCon<T: MedioDePago>(medio Como T, monto Como Entero) Como Entero
  Retornar medio.Cobrar(monto);
FinSubProceso

Algoritmo Caja
  Escribir "Efectivo: ", CobrarCon(Nuevo Efectivo(), 20);
  Escribir "Tarjeta: ", CobrarCon(Nuevo Tarjeta(), 20);
  Escribir "Vale: ", CobrarCon(Nuevo Vale(15), 20);
FinAlgoritmo
```

```salida
Efectivo: 20
Tarjeta: 21
Vale: 15
```

`CobrarCon` no sabe qué medios existen: solo sabe que el que recibe cumple el contrato `MedioDePago`.

## Probar {#probar fase=4}

| Medio | Monto | Esperado | Por qué |
|---|---|---|---|
| Efectivo | 20 | 20 | sin recargo |
| Tarjeta | 20 | 21 | recargo del 5 % |
| Vale de 15 | 20 | 15 | el vale no alcanza |
| Cualquiera | 0 | 0 | borde: no hay nada que cobrar |

## Mejorar {#mejorar fase=5}

En una frase: «La caja le pide cobrar a un medio de pago que cumple el contrato, sin saber cuál es».

Agregar la transferencia es escribir una clase nueva que realiza `MedioDePago`. `CobrarCon` no cambia. Con el `Segun`, en cambio, había que agregar un caso en la caja y en cualquier otro lugar que eligiera por medio de pago.

## Lo que aprendiste {#aprendiste}

::: resumen
- {interfaz} Una interfaz es un contrato: los métodos que una clase promete tener.
- {polimorfismo,despacho-dinamico} Polimorfismo es usar objetos de clases distintas a través del mismo contrato; el despacho dinámico elige al ejecutar el método de la clase real.
:::

## Practica {#practica}

::: practica
- objetos.contratos.cumple-contrato
- objetos.contratos.que-metodo
- objetos.contratos.transferencia
- objetos.contratos.figuras-area
- objetos.contratos.por-que-contrato
:::

::: docentes
- **Una interfaz con métodos que nadie usa.** El contrato tiene que ser lo que la caja necesita, ni más ni menos.
- **La selección por medio que vuelve a aparecer en otro lado.** Cuando para elegir el medio hace falta una decisión, que sea una sola y en el principio del programa.
- **Confundir una interfaz con compartir código.** Una interfaz promete métodos; no comparte código. La próxima lección muestra cómo se comparte.
:::

::: siguiente
Algunos productos vencen, otros están en oferta y otros las dos cosas. ¿Una clase hija para cada combinación?
:::

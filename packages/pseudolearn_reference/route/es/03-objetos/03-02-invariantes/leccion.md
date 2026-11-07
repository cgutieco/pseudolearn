---
id: objetos.invariantes
numero: "3.2"
tipo: leccion
titulo: Proteger lo que debe ser cierto
duracion: 35
problema_breve: La tarjeta con saldo negativo
necesita: [objetos.cosas]
introduce: [encapsulamiento, invariante-de-clase]
usa: [clase, objeto, atributo, metodo, constructor, invariante, visibilidad, validar, caso-borde]
---

::: frase
Un objeto bien hecho no deja que nadie lo ponga en un estado sin sentido.
:::

## El problema {#problema}

::: problema
La tarjeta del comedor tiene un **saldo** que cualquiera puede cambiar desde afuera. Un programa cobró **50 pesos** a una tarjeta con **30** y dejó el saldo en **-20**. Otro le cargó **-100**.

**¿Cómo se escribe la tarjeta para que eso no pueda pasar, la use quien la use?**
:::

## Inténtalo {#intentalo}

::: intento
Escribe en una frase qué tiene que ser cierto siempre de una tarjeta del comedor.
:::

::: respuesta
El saldo nunca es negativo. Además, cargar y cobrar tienen sentido solo con montos positivos.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran pedidos de cobrar y de cargar; sale si se pudo, y el saldo.
- **¿A qué se parece?** A las validaciones de [la lección 2.6](ruta:procedimental.fallos), pero ahora viven dentro del objeto.
- **¿Quién tiene la información para hacer esto?** La tarjeta: sabe su saldo, así que es la única que puede decidir si un cobro alcanza.

## La herramienta nueva {#herramienta}

::: recuerda termino=invariante
:::

Lo que tiene que ser cierto de todo objeto de una clase, antes y después de cada método, es un [[def:invariante-de-clase|invariante de clase]]. Para la tarjeta: el saldo nunca es negativo.

Para protegerlo hay que [[def:encapsulamiento|encapsular]]: ocultar los atributos, marcándolos `Privado`, y dejar que solo los métodos los cambien. Cada método comprueba el invariante antes de tocar nada.

```figura id=ruta-caja-fuerte
pie: Los atributos quedan adentro; los métodos son ventanillas que deciden qué entra y qué sale.
```

::: recuerda termino=visibilidad
:::

::: especificacion
- objetos.clase
- objetos.metodos
:::

## Escribir {#escribir fase=3}

```programa id=tarjeta titulo="La tarjeta que se cuida sola" ejecutar
Clase Tarjeta
  Privado Definir saldo Como Entero;

  Metodo Constructor(inicial Como Entero)
    Este.saldo <- 0;
    Si inicial > 0 Entonces
      Este.saldo <- inicial;
    FinSi
  FinMetodo

  Metodo Cobrar(monto Como Entero) Como Logico
    Si monto <= 0 O monto > Este.saldo Entonces
      Retornar Falso;
    FinSi
    Este.saldo <- Este.saldo - monto;
    Retornar Verdadero;
  FinMetodo

  Metodo Cargar(monto Como Entero) Como Logico
    Si monto <= 0 Entonces
      Retornar Falso;
    FinSi
    Este.saldo <- Este.saldo + monto;
    Retornar Verdadero;
  FinMetodo

  Metodo Saldo() Como Entero
    Retornar Este.saldo;
  FinMetodo
FinClase

Algoritmo Comedor
  Definir tarjeta Como Tarjeta <- Nuevo Tarjeta(30);
  Escribir tarjeta.Cobrar(50), " ", tarjeta.Saldo();
  Escribir tarjeta.Cargar(-100), " ", tarjeta.Saldo();
  Escribir tarjeta.Cobrar(30), " ", tarjeta.Saldo();
FinAlgoritmo
```

```salida
Falso 30
Falso 30
Verdadero 0
```

El cobro de 50 se rechaza y no cambia nada; la carga de -100 también. El cobro de exactamente 30 se acepta y deja el saldo en 0, que sigue cumpliendo el invariante.

## Probar {#probar fase=4}

| Pedido | Saldo antes | Esperado | Por qué |
|---|---|---|---|
| Cobrar 30 | 30 | Verdadero, queda 0 | borde: alcanza justo |
| Cobrar 31 | 30 | Falso, queda 30 | borde: falta uno |
| Cargar 0 | 30 | Falso, queda 30 | un monto que no es positivo |
| Cargar -5 | 30 | Falso, queda 30 | un monto negativo |

## Mejorar {#mejorar fase=5}

En una frase: «La tarjeta guarda su saldo en privado y solo lo cambia con cobros y cargas que mantienen el saldo sin negativos».

Compárala con la versión de atributo público: allí la regla tenía que repetirse en cada programa que usara la tarjeta, y bastaba uno que la olvidara. Ahora vive en un solo lugar.

## Lo que aprendiste {#aprendiste}

::: resumen
- {encapsulamiento} Encapsular es ocultar los atributos y dejar que solo los métodos los cambien.
- {invariante-de-clase} Un invariante de clase es lo que tiene que ser cierto de todo objeto antes y después de cada método.
:::

## Practica {#practica}

::: practica
- objetos.invariantes.tarjeta-negativa
- objetos.invariantes.no-alcanza
- objetos.invariantes.atributo-privado
- objetos.invariantes.tarjeta-pruebas
- objetos.invariantes.termostato
- objetos.invariantes.invariantes-ascensor
:::

::: docentes
- **«Privado es para esconder errores».** Es para que nadie pueda romper el invariante desde afuera.
- **Validar afuera en vez de en el método.** Funciona hasta que alguien usa la tarjeta desde otro programa.
- **Un método público para asignar cada atributo.** Con un método que pone cualquier saldo, la protección desaparece.
:::

::: siguiente
Copié un pedido para armar otro parecido, le agregué un alfajor a la copia y el original también lo tiene. ¿Qué pasó?
:::

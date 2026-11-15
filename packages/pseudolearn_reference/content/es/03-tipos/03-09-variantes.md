---
id: tipos.variantes
numero: "3.9"
tipo: tipo
titulo: Variantes
anclas: [LANG.TYPES.VARIANT]
fichas: [help.pgl04.variant, help.pgl04.variant_alternative]
diagnosticos: [nonExhaustiveSwitch, variantWithoutAlternatives, duplicateMember]
terminos: [variante, alternativa, patrón]
---

::: frase
Una variante es un tipo cuyos valores pueden tener varias formas distintas, cada una con sus propios datos, como una figura que puede ser un círculo o un rectángulo.
:::

## Cómo se escribe {#escribe}

```forma
Variante «Nombre»
  Alternativa «forma»(«campo» Como «tipo», …)
  Alternativa «forma»
FinVariante
```

## Cómo funciona {#funciona}

Cada **alternativa** es una forma posible del valor. Una alternativa puede llevar campos o ninguno. Un valor se construye con el nombre de la variante, un punto y la alternativa: `Forma.Circulo(2)`.

Para saber qué forma tiene un valor se usa `Segun` con **patrones**: cada rama nombra una alternativa y da nombre a sus campos, que solo existen dentro de esa rama.

```programa id=areas titulo="El área de cada figura" ejecutar
Variante Forma
  Alternativa Circulo(radio Como Entero)
  Alternativa Rectangulo(ancho Como Entero, alto Como Entero)
  Alternativa Punto
FinVariante
SubProceso area(f Como Forma) Como Entero
  Definir total Como Entero <- 0;
  Segun f Hacer
    Forma.Circulo(r): total <- 3 * r * r;
    Forma.Rectangulo(a, h): total <- a * h;
    Forma.Punto: total <- 0;
  FinSegun
  Retornar total;
FinSubProceso
Algoritmo Areas
  Escribir area(Forma.Circulo(1));
  Escribir area(Forma.Rectangulo(3, 4));
  Escribir area(Forma.Punto);
FinAlgoritmo
```

```salida
3
12
0
```

```figura id=variante-formas
pie: Una variante es una caja con varias formas posibles. `Segun` mira qué forma tiene y desempaqueta sus campos.
```

`Segun` tiene que cubrir **todas** las alternativas o tener `De Otro Modo`. Así, si mañana se añade una alternativa nueva, el motor señala cada `Segun` que se ha quedado corto.

```programa id=incompleto titulo="Se olvida una forma" ejecutar
Variante Forma
  Alternativa Circulo(radio Como Entero)
  Alternativa Punto
FinVariante
Algoritmo Incompleto
  Definir f Como Forma <- Forma.Punto;
  Segun f Hacer
    Forma.Circulo(r): Escribir r;
  FinSegun
FinAlgoritmo
```

```diagnosticos
nonExhaustiveSwitch
```

::: limite
- Una variante necesita al menos una alternativa.
- Los nombres de alternativa son únicos dentro de la variante, y los de campo dentro de cada alternativa.
- Una variante es un valor: se copia como un registro.
:::

::: errores
Una variante sin alternativas no tiene ningún valor posible:

```programa id=sin-alternativas titulo="Una variante vacía" ejecutar
Variante Vacia
FinVariante
Algoritmo P
FinAlgoritmo
```

```diagnosticos
variantWithoutAlternatives
```
:::

::: por-dentro
Un valor de variante guarda una etiqueta con la alternativa y, a continuación, los campos de esa alternativa. `Segun` lee la etiqueta y salta directamente a la rama correspondiente.

```ri programa=areas
```
:::

::: resumen
- Una variante tiene varias alternativas, cada una con sus campos.
- Se construye con `Variante.Alternativa(…)`.
- Se consulta con `Segun` y patrones que desempaquetan los campos.
- `Segun` debe cubrir todas las alternativas.
:::

::: vease
- [Opcional y Resultado](#tipos.opcional-resultado)
- [Enumerados](#tipos.enumerados)
- [Segun](#control.segun)
:::

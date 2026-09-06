# Operadores, precedencia y asociatividad

La tabla siguiente ordena los operadores de mayor a menor prioridad. Los de una misma fila comparten
prioridad. La tabla es del lenguaje: ningún perfil de sintaxis la altera.

{{tabla:precedence}}

## Los paréntesis mandan sobre la tabla

Los paréntesis alteran la prioridad y se pueden anidar sin límite. Cuando una expresión es larga,
escribirlos aunque no hagan falta no cambia el resultado y sí cambia quién puede leerla.

{{ejemplo:example-esp-operadores-parentesis}}

## Dos decisiones que conviene recordar

La potencia asocia a la derecha, que es la convención matemática. La negación lógica liga más fuerte
que cualquier comparación, de modo que se aplica a lo que tiene inmediatamente a su derecha.

{{ejemplo:example-esp-operadores-decisiones}}

## La concatenación comparte fila con la suma

Comparten fila porque comparten lexema: qué operación es se decide por los tipos de los operandos, no
por el símbolo. Sumar dos números y concatenar dos cadenas se escriben igual; mezclar un número y una
cadena no es ninguna de las dos y el lenguaje lo rechaza.

{{ejemplo:example-esp-operadores-concatenacion}}

```pseudo
Algoritmo ErrorConcatenar
  Definir mensaje Como Cadena
  mensaje <- "Total: " + 5
FinAlgoritmo
```

{{diagnostico:cannotConcatenateNumberWithText}}

## Los operadores lógicos evalúan en cortocircuito

Evaluado el primer operando, si ya determina el resultado, el segundo no se evalúa. Es observable, y
es lo que permite comprobar una condición y usarla en la misma expresión sin riesgo.

{{ejemplo:example-esp-operadores-cortocircuito}}

## Esta tabla ordena, no tipa

Qué combinaciones de tipos admite cada operador y qué tipo devuelve es otra cuestión, y se responde
en la sección del sistema de tipos.

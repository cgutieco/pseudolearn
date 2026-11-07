---
id: imperativo.decidir.estacionamiento
leccion: imperativo.decidir
tipo: resolver
nivel: arbol
obligatorio: false
titulo: El estacionamiento
---

::: enunciado
El estacionamiento cobra 3 pesos la primera hora y 2 pesos por cada hora o fracción adicional. Menos de una hora se cobra como una. Lee los minutos y muestra el precio. El programa muestra solo el número.
:::

```programa rol=referencia
Algoritmo Estacionamiento
  Definir minutos Como Entero;
  Leer minutos;
  Si minutos <= 60 Entonces
    Escribir 3;
  Sino
    Escribir 3 + techo((minutos - 60) / 60) * 2;
  FinSi
FinAlgoritmo
```

```casos
visible | 45 | 3
visible | 150 | 7
oculto | 60 | 3
oculto | 61 | 5
oculto | 0 | 3
oculto | 600 | 21
```

::: pistas
1. Arma la partición: ¿dónde cambia la forma de cobrar? Haz ejemplos a mano a los dos lados de ese borde.
2. 150 minutos son una hora y 90 minutos más. ¿Cuántas horas o fracciones son esos 90?
3. Primero decide si pasó la primera hora. Si pasó, redondea hacia arriba las horas que siguen.
4. Si los minutos no pasan de 60, cobra 3; si no, `3 + techo((minutos - 60) / 60) * 2`. Cierra con la variante.
:::

::: variante
Los domingos la primera hora es gratis. Agrega un segundo dato, el día, y cobra en consecuencia.
:::

::: docentes
Bordes: 60 y 61 minutos. Error frecuente: usar `div` en lugar de redondear hacia arriba, que cobra 61 minutos como 60.
:::

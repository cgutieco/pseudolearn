---
id: imperativo.caminos
numero: "1.2"
tipo: leccion
titulo: Muchos caminos
duracion: 30
problema_breve: ¿Es bisiesto este año?
necesita: [imperativo.decidir]
introduce: [condicion-compuesta, tabla-de-decision, seleccion-multiple, anidar]
usa: [condicion, decision, particion-de-casos, caso-borde, comparacion]
---

::: frase
Cuando hay muchos casos, una tabla de decisión ordena las preguntas antes de escribir la primera.
:::

## El problema {#problema}

::: problema
Un año es bisiesto si se puede dividir exacto entre **4**, salvo que también se pueda entre **100**; pero los que se pueden dividir exacto entre **400** sí son bisiestos.

**¿Cómo sabe un programa si un año es bisiesto?**
:::

## Inténtalo {#intentalo}

::: intento
Decide a mano si son bisiestos 2024, 2023, 1900 y 2000.
:::

::: respuesta
2024 sí (se divide entre 4 y no entre 100). 2023 no. 1900 no: se divide entre 4 y entre 100, pero no entre 400. 2000 sí: se divide entre 400.
:::

## Entender {#entender fase=1}

::: ficha
- entra: el año.
- sale: «Es bisiesto» o «No es bisiesto».
- relacion: la regla del enunciado, con sus dos excepciones.
- ejemplo: 2024 → es bisiesto.
- ejemplo: 2023 → no es bisiesto.
- ejemplo: 1900 → no es bisiesto (excepción de los 100).
- ejemplo: 2000 → es bisiesto (excepción de los 400).
:::

Los cuatro años son una partición: cada uno cae en una región distinta de la regla. 1900 y 2000 son los bordes de las excepciones, y son los que una solución apurada olvida.

## Planear {#planear fase=2}

Hay tres preguntas: ¿se divide entre 4? ¿entre 100? ¿entre 400? Antes de escribir, conviene ponerlas en una [[def:tabla-de-decision|tabla de decisión]]: una fila por pregunta, una columna por caso y, abajo, el resultado.

```figura id=ruta-tabla-decision-bisiesto
pie: Cada columna es un ejemplo a mano. La tabla muestra qué preguntas cambian el resultado.
```

El orden de las preguntas importa. Si se pregunta primero «¿se divide entre 4?» y se responde enseguida, 1900 sale mal. Hay que empezar por la pregunta más específica.

```figura id=ruta-orden-preguntas
pie: Las preguntas se hacen de la más específica a la más general.
paso: En el orden equivocado, 1900 entra por «¿se divide entre 4?» y sale como bisiesto.
paso: En el orden correcto, 1900 pasa por «¿entre 400?» y «¿entre 100?» y sale como no bisiesto.
```

## La herramienta nueva {#herramienta}

Una [[def:condicion-compuesta|condición compuesta]] combina varias condiciones en una sola con `Y`, `O` y `NO`. `a Y b` es verdadera si las dos lo son; `a O b`, si al menos una lo es; `NO a`, si `a` es falsa.

```figura-especificacion seccion=expresiones.logicos figura=cortocircuito
```

También se puede [[def:anidar|anidar]]: poner una decisión dentro de una rama de otra. Y cuando hay que elegir entre muchos valores posibles de un mismo dato, una [[def:seleccion-multiple|selección múltiple]] con `Segun` evita una escalera de `Si`:

```figura-especificacion seccion=control.segun figura=segun-ramas
```

```programa id=menu titulo="El menú del kiosco" ejecutar
Algoritmo Menu
  Definir codigo Como Entero;
  Leer codigo;
  Segun codigo Hacer
    1:
      Escribir "Jugo 3";
    2:
      Escribir "Sándwich 5";
    3:
      Escribir "Alfajor 2";
    4:
      Escribir "Agua 1";
    5:
      Escribir "Fruta 2";
    De Otro Modo:
      Escribir "No existe";
  FinSegun
FinAlgoritmo
```

```entrada
2
```

```salida
Sándwich 5
```

::: especificacion
- expresiones.logicos
- expresiones.precedencia
- control.segun
- control.si
:::

## Escribir {#escribir fase=3}

Dos soluciones. La primera anida tres decisiones en el orden de la tabla: 400, 100, 4.

```programa id=bisiesto-anidado titulo="Bisiesto, con decisiones anidadas" ejecutar
Algoritmo Bisiesto
  Definir anio Como Entero;
  Leer anio;
  Si anio mod 400 = 0 Entonces
    Escribir "Es bisiesto";
  Sino
    Si anio mod 100 = 0 Entonces
      Escribir "No es bisiesto";
    Sino
      Si anio mod 4 = 0 Entonces
        Escribir "Es bisiesto";
      Sino
        Escribir "No es bisiesto";
      FinSi
    FinSi
  FinSi
FinAlgoritmo
```

```entrada
1900
```

```salida
No es bisiesto
```

La segunda dice la regla en una sola condición compuesta:

```programa id=bisiesto-compuesto titulo="Bisiesto, con una condición compuesta" ejecutar
Algoritmo Bisiesto
  Definir anio Como Entero;
  Leer anio;
  Si (anio mod 4 = 0 Y anio mod 100 <> 0) O anio mod 400 = 0 Entonces
    Escribir "Es bisiesto";
  Sino
    Escribir "No es bisiesto";
  FinSi
FinAlgoritmo
```

```entrada
2000
```

```salida
Es bisiesto
```

## Probar {#probar fase=4}

| Año | A mano | Anidado | Compuesto |
|---|---|---|---|
| 2024 | sí | Es bisiesto | Es bisiesto |
| 2023 | no | No es bisiesto | No es bisiesto |
| 1900 | no | No es bisiesto | No es bisiesto |
| 2000 | sí | Es bisiesto | Es bisiesto |

Los paréntesis de la versión compuesta no son decoración: `Y` y `O` tienen un orden propio, y sin paréntesis la condición agrupa otra cosa. La regla está en [la Especificación](especificacion:expresiones.precedencia).

## Mejorar {#mejorar fase=5}

En una frase: «El programa aplica la regla de los bisiestos preguntando de la excepción más específica a la regla general».

Volvamos al cine de [la lección anterior](ruta:imperativo.decidir): los jueves todos pagan 4. El programa lee el día (de 1 a 7; el 4 es jueves) y la edad. Hay dos órdenes posibles para preguntar:

| Caso | Día 4, edad 10 | Día 4, edad 30 | Día 2, edad 10 | Día 2, edad 30 |
|---|---|---|---|---|
| Jueves primero | 4 | 4 | 5 | 8 |
| Edad primero | 5 | 4 | 5 | 8 |

Si se pregunta primero la edad, el chico de 10 años paga 5 un jueves. Gana el orden «jueves primero».

```programa id=cine-jueves titulo="El cine con jueves" ejecutar
Algoritmo Cine
  Definir dia Como Entero;
  Definir edad Como Entero;
  Leer dia;
  Leer edad;
  Si dia = 4 Entonces
    Escribir "Paga 4";
  Sino
    Si edad < 12 Entonces
      Escribir "Paga 5";
    Sino
      Escribir "Paga 8";
    FinSi
  FinSi
FinAlgoritmo
```

```entrada
4
10
```

```salida
Paga 4
```

## Lo que aprendiste {#aprendiste}

::: resumen
- {condicion-compuesta} `Y`, `O` y `NO` combinan condiciones en una sola.
- {tabla-de-decision} Una tabla de decisión pone cada condición en una fila y cada caso en una columna, antes de escribir.
- {anidar} Anidar es poner una decisión dentro de otra; el orden de las preguntas importa.
- {seleccion-multiple} La selección múltiple elige entre muchos valores posibles de un mismo dato.
:::

## Practica {#practica}

::: practica
- imperativo.caminos.compuesta
- imperativo.caminos.menu-kiosco
- imperativo.caminos.bisiesto-romper
- imperativo.caminos.triangulo
- imperativo.caminos.bisiesto-ordenar
- imperativo.caminos.descuentos
:::

::: profundizar titulo="Tropiezos frecuentes"
- **«Uno u otro, pero no los dos».** Pasa lo contrario: `a O b` también es verdadera cuando las dos lo son. Pruébalo con `Verdadero O Verdadero`.
- **Olvidar los paréntesis.** Escribe la versión compuesta sin paréntesis y busca un año que la rompa.
- **La condición general antes de la específica.** La figura de los dos órdenes lo muestra con 1900.
:::

::: siguiente
Lucía ahorra para una pelota y no sabe cuántos días va a tardar. ¿Cómo se repite algo sin saber cuántas veces?
:::

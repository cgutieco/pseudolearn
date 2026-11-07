---
id: procedimental.fallos
numero: "2.6"
tipo: leccion
titulo: Cuando algo puede fallar
duracion: 35
problema_breve: La inscripción al taller
necesita: [procedimental.datos]
introduce: [valor-opcional, resultado-con-error, propagar, validar]
usa: [subprograma, funcion-pura, error-de-ejecucion, caso-borde, seleccion-multiple, diccionario]
---

::: frase
Un programa falla bien cuando un error esperable es una respuesta con motivo, no una caída.
:::

## El problema {#problema}

::: problema
La inscripción a un taller pide la edad, de **6 a 18 años**, escrita **como texto**. Llegan respuestas como «12», «doce», «-3», «150» y una vacía. El programa no puede detenerse y tiene que decir **por qué** rechaza cada una.

**¿Cómo se escribe?**
:::

## Inténtalo {#intentalo}

::: intento
Decide qué responder a cada una de las cinco respuestas.
:::

::: respuesta
«12» se acepta. «doce» no es un número. «-3» y «150» son números, pero están fuera de rango. La respuesta vacía no es un número.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra un texto; sale la edad aceptada o el motivo del rechazo.
- **¿A qué se parece?** A la calculadora de propinas que se detenía con 0 amigos, en [la lección 0.4](ruta:inicio.errores): un dato raro no debería tirar el programa.
- **¿En qué partes se divide?** Se divide en dos filtros en fila: primero, ¿es un número?; después, ¿está en el rango?

```figura id=ruta-filtro-validacion
pie: Cada filtro deja pasar lo que cumple y desvía lo que no, con su motivo.
```

## La herramienta nueva {#herramienta}

Un [[def:valor-opcional|valor opcional]] es un dato que puede faltar: un `Opcional` es `Algo(valor)` o `Nada`. Buscar una clave en un diccionario devuelve uno, como en la agenda de [la lección anterior](ruta:procedimental.datos).

Un [[def:resultado-con-error|resultado con error]] es un `Resultado`: trae `Exito(valor)` o `Error(motivo)`. Quien lo recibe tiene que atender los dos casos, con un `Segun`.

```figura-especificacion seccion=tipos.opcional-resultado figura=opcional-resultado
```

```programa id=dividir-seguro titulo="Dividir sin caerse" ejecutar
SubProceso DividirSeguro(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("No se puede dividir entre 0");
  FinSi
  Retornar Exito(a div b);
FinSubProceso

Algoritmo Division
  Segun DividirSeguro(10, 0) Hacer
    Exito(cociente): Escribir cociente;
    Error(motivo): Escribir motivo;
  FinSegun
FinAlgoritmo
```

```salida
No se puede dividir entre 0
```

Cuando un subprograma recibe un `Resultado` que no sabe atender, puede [[def:propagar|propagar]] el error: `Propagar` saca el valor si fue un éxito y, si fue un error, lo devuelve enseguida a quien llamó. Los detalles están en [la Especificación](especificacion:tipos.opcional-resultado).

[[def:validar|Validar]] es comprobar una entrada antes de usarla. Para convertir un texto en número existe `AEntero`, pero con un texto que no es un número detiene el programa. Por eso, antes de convertir, la inscripción comprueba con su propia función que el texto sea un número.

::: especificacion
- tipos.opcional-resultado
- biblioteca.conversion
- control.segun
:::

## Escribir {#escribir fase=3}

```programa id=inscripcion titulo="La inscripción" ejecutar
Funcion valido <- EsNumero(texto Como Cadena)
  Definir desde Como Entero <- 0;
  Si Longitud(texto) > 0 Entonces
    Si CaracterEn(texto, 0) = '-' Entonces
      desde <- 1;
    FinSi
  FinSi
  Definir valido Como Logico <- Longitud(texto) > desde;
  Para i <- desde Hasta Longitud(texto) - 1 Hacer
    Si NO Contiene("0123456789", ATexto(CaracterEn(texto, i))) Entonces
      valido <- Falso;
    FinSi
  FinPara
FinFuncion

SubProceso ValidarEdad(texto Como Cadena) Como Resultado<Entero, Cadena>
  Si NO EsNumero(texto) Entonces
    Retornar Error("no es un número");
  FinSi
  Definir edad Como Entero <- AEntero(texto);
  Si edad < 6 O edad > 18 Entonces
    Retornar Error("fuera de rango");
  FinSi
  Retornar Exito(edad);
FinSubProceso

Algoritmo Inscripcion
  Definir texto Como Cadena;
  Leer texto;
  Segun ValidarEdad(texto) Hacer
    Exito(edad): Escribir "Inscripción aceptada: ", edad;
    Error(motivo): Escribir "Rechazada: ", motivo;
  FinSegun
FinAlgoritmo
```

```entrada
doce
```

```salida
Rechazada: no es un número
```

`EsNumero` es una función pura: recorre el texto y comprueba que cada carácter sea una cifra, con un signo menos permitido al principio. `ValidarEdad` aplica los dos filtros en orden y retorna el motivo del primero que falla.

## Probar {#probar fase=4}

| Texto | Esperado | Por qué |
|---|---|---|
| 12 | Inscripción aceptada: 12 | caso normal |
| doce | Rechazada: no es un número | no es un número |
| -3 | Rechazada: fuera de rango | número negativo |
| 150 | Rechazada: fuera de rango | número demasiado grande |
| (vacío) | Rechazada: no es un número | no hay nada que convertir |
| 6 y 18 | aceptadas | los bordes del rango |

## Mejorar {#mejorar fase=5}

En una frase: «El programa comprueba que la edad sea un número y que esté en el rango, y si no, dice cuál de las dos cosas falló».

¿Y si la respuesta vacía tuviera su propio motivo, «vacía»? Se agrega un filtro al principio de `ValidarEdad`, y el resto del programa no cambia.

## Lo que aprendiste {#aprendiste}

::: resumen
- {valor-opcional} Un valor que puede faltar se representa como algo que puede no tener nada adentro.
- {resultado-con-error,propagar} Un resultado con error trae el valor o el motivo del fallo; propagar devuelve el error a quien llamó.
- {validar} Validar es comprobar una entrada antes de usarla.
:::

## Practica {#practica}

::: practica
- procedimental.fallos.segun-resultado
- procedimental.fallos.opcional-o-resultado
- procedimental.fallos.division
- procedimental.fallos.mes-romper
- procedimental.fallos.fecha
- procedimental.fallos.caer-o-avisar
:::

::: docentes
- **Validar demasiado tarde.** Convertir antes de comprobar detiene el programa con «doce». El orden de los filtros importa.
- **Un motivo genérico.** «Error» no le dice a nadie qué corregir. Pide un motivo por cada filtro.
- **Atender el error en el lugar equivocado.** Quien sabe qué mostrar es el algoritmo principal; la validación solo informa.
:::

::: siguiente
El programa del kiosco ya tiene 400 líneas y dos compañeros quieren trabajar a la vez. ¿Cómo se parte en archivos?
:::

---
id: exterior.json
numero: "6.2"
tipo: leccion
titulo: Datos que se entienden entre programas
duracion: 30
problema_breve: El inventario para la página de la escuela
necesita: [exterior.archivos]
introduce: [json, serializar]
usa: [archivo, funcion-pura, concatenar, resultado-con-error]
---

::: frase
JSON es una forma de escribir datos como texto que cualquier programa sabe leer.
:::

## El problema {#problema}

::: problema
La escuela tiene una página que muestra el inventario del kiosco, pero no sabe leer «jugo;10»: espera **JSON**. Hay que **exportar** los cinco productos con su stock.

**¿Cómo se escribe el inventario para que otro programa lo entienda, y cómo se comprueba que quedó bien?**
:::

## Inténtalo {#intentalo}

::: intento
Escribe a mano el JSON de dos productos: jugo con 10 y sándwich con 5.
:::

::: respuesta
`{"jugo": 10, "sandwich": 5}`. Las llaves encierran el objeto; cada clave va entre comillas dobles, seguida de dos puntos y su valor; las entradas se separan con comas.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra el stock de los cinco productos; sale un texto que la página de la escuela sabe leer.
- **¿A qué se parece?** A la línea «jugo;10» de la lección anterior, con otras reglas de escritura.
- **¿Qué puede fallar afuera del programa?** El texto que llega de afuera puede estar roto.

## La herramienta nueva {#herramienta}

[[def:json|JSON]] escribe datos como texto con objetos entre llaves, listas entre corchetes, números, textos entre comillas y valores lógicos. Casi todos los programas lo saben leer.

```figura-especificacion seccion=biblioteca.json figura=json-arbol
```

Convertir un dato en texto para guardarlo o enviarlo, de modo que se pueda reconstruir, es [[def:serializar|serializar]]. Del otro lado, `AnalizarJson` lee el texto y devuelve un `Resultado`: el valor reconstruido o un error con su lugar. `TextoJson` hace el camino de vuelta.

```figura id=ruta-json-viaje
pie: El dato viaja como texto y se reconstruye igual del otro lado.
```

```programa id=ficha-json titulo="Leer una ficha" ejecutar
Algoritmo Ficha
  Segun AnalizarJson('{"nombre": "Ana", "edad": 15}') Hacer
    Exito(ficha):
      Segun ficha.Campo("edad") Hacer
        Algo(edad): Escribir "edad: ", TextoJson(edad);
        Nada: Escribir "sin edad";
      FinSegun
    Error(problema): Escribir problema.Codigo;
  FinSegun
FinAlgoritmo
```

```salida
edad: 15
```

::: especificacion
- biblioteca.json
- expresiones.concatenacion
:::

## Escribir {#escribir fase=3}

```programa id=exportar titulo="Exportar el inventario" ejecutar
Funcion par <- ParJson(nombre Como Cadena, stock Como Entero)
  Definir par Como Cadena;
  par <- '"' + nombre + '": ' + ATexto(stock);
FinFuncion

Funcion texto <- InventarioJson()
  Definir texto Como Cadena;
  texto <- "{" + ParJson("jugo", 10) + ", " + ParJson("sandwich", 5) + ", " + ParJson("alfajor", 8) + ", " + ParJson("agua", 12) + ", " + ParJson("fruta", 6) + "}";
FinFuncion

Algoritmo Exportar
  Definir texto Como Cadena <- InventarioJson();
  Escribir texto;
  Segun AnalizarJson(texto) Hacer
    Exito(inventario): Escribir "Válido: ", inventario.Longitud(), " productos";
    Error(problema): Escribir "Inválido: ", problema.Codigo;
  FinSegun
FinAlgoritmo
```

```salida
{"jugo": 10, "sandwich": 5, "alfajor": 8, "agua": 12, "fruta": 6}
Válido: 5 productos
```

`InventarioJson` es una función pura que arma el texto con `ParJson`, una entrada por producto. Las comillas simples de `ParJson` permiten escribir comillas dobles dentro del texto. El algoritmo vuelve a analizar lo que escribió: si `AnalizarJson` lo acepta, el texto es JSON válido.

## Probar {#probar fase=4}

Caso normal: los cinco productos. Caso borde: un inventario de un solo producto, sin comas. Caso raro: un texto con una coma de más al final. `AnalizarJson` no lo acepta y dice dónde está el problema:

```programa id=json-roto titulo="Una coma de más" ejecutar
Algoritmo Roto
  Segun AnalizarJson('{"jugo": 10,}') Hacer
    Exito(inventario): Escribir TextoJson(inventario);
    Error(problema): Escribir problema.Codigo, " en ", problema.JsonLinea, ":", problema.JsonColumna;
  FinSegun
FinAlgoritmo
```

```salida
SintaxisInvalida en 1:13
```

## Mejorar {#mejorar fase=5}

En una frase: «El inventario se escribe como texto JSON con una función pura, y se comprueba volviéndolo a analizar».

| | `jugo;10` | JSON |
|---|---|---|
| Quién lo lee | solo un programa que conozca las reglas del `;` | casi cualquier programa |
| Qué cuesta | inventar y explicar las reglas | escribir llaves, comillas y comas sin errores |

## Lo que aprendiste {#aprendiste}

::: resumen
- {json} JSON escribe datos como texto con objetos, listas, números y textos; lo leen casi todos los programas.
- {serializar} Serializar es convertir un dato en texto para guardarlo o enviarlo, y poder reconstruirlo.
:::

## Practica {#practica}

::: practica
- exterior.json.json-campo
- exterior.json.par-json
- exterior.json.valido-o-no
- exterior.json.formato
- exterior.json.json-clasificar
- exterior.json.dos-pares
:::

::: docentes
- **Comillas simples dentro del JSON.** JSON solo acepta comillas dobles; las simples son del programa que lo arma.
- **La coma final.** Es el error más común, y `AnalizarJson` lo marca con línea y columna.
- **Creer que JSON es un tipo de archivo.** Es una forma de escribir texto: puede ir en un archivo, en un mensaje o en una respuesta de internet.
:::

::: siguiente
El precio de la fruta importada depende del tipo de cambio del día, y ese dato está en internet. ¿Cómo se le pregunta?
:::

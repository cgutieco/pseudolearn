---
id: procedimental.datos
numero: "2.5"
tipo: leccion
titulo: Darle forma a los datos
duracion: 40
problema_breve: La agenda del curso
necesita: [procedimental.recursion]
introduce: [registro, campo, enumerado, vector, diccionario, clave]
usa: [arreglo, indice, subprograma, esquema, caso-borde]
---

::: frase
Elegir cómo guardar los datos es la mitad de la solución.
:::

## El problema {#problema}

::: problema
La agenda del curso guarda, de cada compañero, su **nombre**, su **teléfono** y su **mes de cumpleaños**. Cada año se suman compañeros nuevos. Hay que poder **buscar el teléfono de alguien por su nombre** y saber **cuántos cumplen años cada mes**.

**¿Cómo conviene guardar la agenda?**
:::

## Inténtalo {#intentalo}

::: intento
Dibuja tres formas de guardar cinco contactos: tres filas de casillas separadas, una fila de fichas con las tres cosas juntas, y una lista donde se busca por el nombre. ¿Cuál responde más fácil cada pregunta?
:::

::: respuesta
Las tres filas separadas obligan a mantener alineadas tres listas: si se agrega un nombre y se olvida el teléfono, todo se corre. La fila de fichas mantiene juntos los datos de cada compañero. La lista por nombre encuentra un teléfono sin recorrer todo. Y contar por mes pide otra lista más, de mes a cantidad.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entran los contactos y un nombre a buscar; salen un teléfono y una cuenta por mes.
- **¿A qué se parece?** Las tres filas separadas son los arreglos paralelos de la caja del kiosco, en [el proyecto de la Parte I](ruta:imperativo.proyecto).
- **¿En qué partes se divide?** Hay que elegir la forma de cada dato según la pregunta que tiene que responder.

```figura id=ruta-forma-de-datos
pie: La misma agenda guardada de tres maneras. Cada una responde más fácil una pregunta distinta.
```

## La herramienta nueva {#herramienta}

Un [[def:registro|registro]] agrupa los datos de una misma cosa; cada dato es un [[def:campo|campo]], y se lee con un punto: `ana.telefono`.

```figura-especificacion seccion=tipos.registros figura=registro-copia
```

```programa id=producto titulo="Un producto del kiosco" ejecutar
Registro Producto
  Definir nombre Como Cadena;
  Definir precio Como Entero;
FinRegistro

Algoritmo Kiosco
  Definir jugo Como Producto <- Producto("Jugo", 3);
  Escribir jugo.nombre, " ", jugo.precio;
FinAlgoritmo
```

```salida
Jugo 3
```

Un [[def:enumerado|enumerado]] es un tipo con una lista cerrada de valores con nombre, como los días de la semana: no hay un octavo día que se pueda escribir por error.

Un [[def:vector|vector]] es una lista que puede crecer: empieza vacía y se le agregan elementos con `Agregar`. Sirve cuando no se sabe cuántos datos habrá.

Un [[def:diccionario|diccionario]] guarda valores que se buscan por una [[def:clave|clave]], como un teléfono que se busca por el nombre. Recuerda el orden en que se agregaron las claves.

```figura-especificacion seccion=tipos.diccionarios figura=diccionario
```

::: especificacion
- tipos.registros
- tipos.enumerados
- tipos.vectores
- tipos.diccionarios
:::

## Escribir {#escribir fase=3}

```programa id=agenda titulo="La agenda" ejecutar
Registro Contacto
  Definir nombre, telefono Como Cadena;
  Definir mes Como Entero;
FinRegistro

Algoritmo Agenda
  Definir agenda Como Vector<Contacto> <- Vector();
  Definir porMes Como Diccionario<Entero, Entero> <- Diccionario();
  Definir nombre, telefono Como Cadena;
  Definir mes Como Entero;
  Para i <- 1 Hasta 4 Hacer
    Leer nombre;
    Leer telefono;
    Leer mes;
    agenda.Agregar(Contacto(nombre, telefono, mes));
    Segun porMes.Buscar(mes) Hacer
      Algo(cantidad): porMes[mes] <- cantidad + 1;
      Nada: porMes[mes] <- 1;
    FinSegun
  FinPara
  Leer nombre;
  Definir encontrado Como Cadena <- "No está";
  Para Cada contacto En agenda Hacer
    Si contacto.nombre = nombre Y encontrado = "No está" Entonces
      encontrado <- contacto.telefono;
    FinSi
  FinPara
  Escribir nombre, ": ", encontrado;
  Para Cada clave En porMes.Claves() Hacer
    Escribir "Mes ", clave, ": ", porMes[clave];
  FinPara
FinAlgoritmo
```

```entrada
Ana
555-1234
5
Beto
555-9876
11
Caro
555-4567
5
Dani
555-2222
3
Caro
```

```salida
Caro: 555-4567
Mes 5: 2
Mes 11: 1
Mes 3: 1
```

El vector de registros responde la búsqueda; el diccionario de mes a cantidad responde la cuenta.

## Probar {#probar fase=4}

| Buscado | Esperado | Por qué |
|---|---|---|
| Caro | su teléfono | un nombre que está |
| Eva | No está | un nombre que no está |
| un nombre repetido | el primer teléfono | la regla: se devuelve el primero |

## Mejorar {#mejorar fase=5}

En una frase: «La agenda guarda una ficha por compañero y cuenta los cumpleaños por mes».

Si hay que agregar el correo de cada contacto, con registros se agrega un campo y una lectura. Con tres filas separadas, habría que agregar una cuarta fila y cuidar que todas sigan alineadas.

## Lo que aprendiste {#aprendiste}

::: resumen
- {registro,campo} Un registro agrupa datos de una misma cosa; cada dato es un campo.
- {enumerado} Un enumerado es un tipo con una lista cerrada de valores con nombre.
- {vector} Un vector es una lista que puede crecer.
- {diccionario,clave} Un diccionario guarda valores que se buscan por una clave.
:::

## Practica {#practica}

::: practica
- procedimental.datos.que-forma
- procedimental.datos.votos-predecir
- procedimental.datos.linea-ticket
- procedimental.datos.votacion
- procedimental.datos.paralelos-a-registros
- procedimental.datos.buscar-telefono
:::

::: docentes
- **Elegir la forma antes de mirar las preguntas.** Pide escribir las preguntas que el programa tiene que responder antes de dibujar la forma.
- **Un registro con un campo por cada contacto.** Un registro describe una sola cosa; muchas cosas van en un vector.
- **Confundir clave con valor.** Aquí, el nombre es la clave y el teléfono el valor: se busca por lo que se sabe.
:::

::: siguiente
La inscripción a un taller pide la edad. Alguien escribe «doce», otro «-3». ¿Cómo falla bien un programa?
:::

---
id: exterior.http
numero: "6.3"
tipo: leccion
titulo: Hablar con internet
duracion: 30
problema_breve: El precio de la fruta importada
necesita: [exterior.json]
introduce: [peticion, codigo-de-estado]
usa: [capacidad, json, nucleo-puro, funcion-pura, resultado-con-error]
---

::: frase
Un programa le pregunta algo a otro por internet enviando una petición, y la respuesta trae un código que dice cómo le fue.
:::

## El problema {#problema}

::: problema
La fruta importada cuesta **2 dólares**, y el kiosco cobra en pesos según el **tipo de cambio del día**, que publica un servicio en internet. A veces el servicio responde y a veces no.

**¿Cuánto cobra hoy el kiosco por la fruta importada, y qué hace si el servicio no responde?**
:::

## Inténtalo {#intentalo}

::: intento
Si el servicio dice que un dólar vale 20 pesos, ¿cuánto cuesta la fruta? ¿Y si no responde?
:::

::: respuesta
**40 pesos**. Si no responde, el kiosco no puede inventar un precio: avisa que el servicio no está disponible.
:::

## Entender y planear {#entender-planear fase=1-2}

- **¿Qué entra y qué sale?** Entra la respuesta del servicio; sale el precio en pesos o un aviso.
- **¿A qué se parece?** Al inventario de la lección anterior: un texto JSON que llega de afuera y hay que leer.
- **¿Qué puede fallar afuera del programa?** La red puede no estar, el servicio puede responder un error y la respuesta puede venir mal escrita.

## La herramienta nueva {#herramienta}

Una [[def:peticion|petición]] le pide algo a otro programa por internet. Para enviarla, el programa pide la capacidad de red con `SolicitarRed`, igual que pedía la de una carpeta. La respuesta trae un texto, el cuerpo, y un [[def:codigo-de-estado|código de estado]] que dice cómo le fue: 200 es bien; los que empiezan con 4 o con 5 son problemas.

```figura-especificacion seccion=biblioteca.http figura=http-ida-vuelta
```

```programa id=clima titulo="Pedir el tiempo que hace" ejecutar
SubProceso ConsultarClima() Como Resultado<Cadena, ErrorES>
  Definir red Como RedCap <- Propagar SolicitarRed();
  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, "https://clima.test/hoy");
  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);
  Escribir "Estado: ", respuesta.Estado();
  Retornar respuesta.CuerpoTexto();
FinSubProceso

Algoritmo Clima
  Segun ConsultarClima() Hacer
    Exito(texto): Escribir texto;
    Error(problema): Escribir problema.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"http": {"GET https://clima.test/hoy": {"estado": 200, "cuerpo": "Soleado, 25"}}}
```

```salida
Estado: 200
Soleado, 25
```

El servicio de este ejemplo no es real: el anfitrión de memoria responde en su lugar, siempre igual. Así el programa se puede probar sin internet.

::: especificacion
- biblioteca.http
- biblioteca.json
:::

## Escribir {#escribir fase=3}

```programa id=cambio titulo="La fruta importada" ejecutar
Funcion pesos <- PrecioEnPesos(dolares Como Entero, cambio Como Entero)
  Definir pesos Como Entero;
  pesos <- dolares * cambio;
FinFuncion

Funcion mensaje <- MensajeDePrecio(cuerpo Como Cadena)
  Definir mensaje Como Cadena <- "La respuesta no trae el cambio";
  Segun AnalizarJson(cuerpo) Hacer
    Exito(datos):
      Segun datos.Campo("dolar") Hacer
        Algo(dolar):
          Segun dolar.ComoEntero() Hacer
            Algo(cambio): mensaje <- "Fruta importada: " + ATexto(PrecioEnPesos(2, cambio)) + " pesos";
            Nada: mensaje <- "El cambio no es un número";
          FinSegun
        Nada: mensaje <- "La respuesta no trae el cambio";
      FinSegun
    Error(problema): mensaje <- "Respuesta mal escrita en la columna " + ATexto(problema.JsonColumna);
  FinSegun
FinFuncion

SubProceso PedirCambio() Como Resultado<Cadena, ErrorES>
  Definir red Como RedCap <- Propagar SolicitarRed();
  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, "https://cambio.test/hoy"));
  Si respuesta.Estado() <> 200 Entonces
    Retornar Exito("Servicio no disponible (" + ATexto(respuesta.Estado()) + ")");
  FinSi
  Definir cuerpo Como Cadena <- Propagar respuesta.CuerpoTexto();
  Retornar Exito(MensajeDePrecio(cuerpo));
FinSubProceso

Algoritmo FrutaImportada
  Segun PedirCambio() Hacer
    Exito(mensaje): Escribir mensaje;
    Error(problema): Escribir "Sin red: ", problema.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"http": {"GET https://cambio.test/hoy": {"estado": 200, "cuerpo": "{\"dolar\": 20}"}}}
```

```salida
Fruta importada: 40 pesos
```

`PrecioEnPesos` y `MensajeDePrecio` son funciones puras: reciben números o texto y devuelven un valor. `PedirCambio` es el borde: pide la red, envía la petición y revisa el código de estado. Con el mismo programa y un servicio caído:

```programa id=cambio-caido titulo="El servicio no responde" ejecutar
Funcion pesos <- PrecioEnPesos(dolares Como Entero, cambio Como Entero)
  Definir pesos Como Entero;
  pesos <- dolares * cambio;
FinFuncion

Funcion mensaje <- MensajeDePrecio(cuerpo Como Cadena)
  Definir mensaje Como Cadena <- "La respuesta no trae el cambio";
  Segun AnalizarJson(cuerpo) Hacer
    Exito(datos):
      Segun datos.Campo("dolar") Hacer
        Algo(dolar):
          Segun dolar.ComoEntero() Hacer
            Algo(cambio): mensaje <- "Fruta importada: " + ATexto(PrecioEnPesos(2, cambio)) + " pesos";
            Nada: mensaje <- "El cambio no es un número";
          FinSegun
        Nada: mensaje <- "La respuesta no trae el cambio";
      FinSegun
    Error(problema): mensaje <- "Respuesta mal escrita en la columna " + ATexto(problema.JsonColumna);
  FinSegun
FinFuncion

SubProceso PedirCambio() Como Resultado<Cadena, ErrorES>
  Definir red Como RedCap <- Propagar SolicitarRed();
  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, "https://cambio.test/hoy"));
  Si respuesta.Estado() <> 200 Entonces
    Retornar Exito("Servicio no disponible (" + ATexto(respuesta.Estado()) + ")");
  FinSi
  Definir cuerpo Como Cadena <- Propagar respuesta.CuerpoTexto();
  Retornar Exito(MensajeDePrecio(cuerpo));
FinSubProceso

Algoritmo FrutaImportada
  Segun PedirCambio() Hacer
    Exito(mensaje): Escribir mensaje;
    Error(problema): Escribir "Sin red: ", problema.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"http": {"GET https://cambio.test/hoy": {"estado": 503, "cuerpo": ""}}}
```

```salida
Servicio no disponible (503)
```

## Probar {#probar fase=4}

| Caso | Qué muestra |
|---|---|
| 200 con el dato | `Fruta importada: 40 pesos` |
| 503 | `Servicio no disponible (503)` |
| 200 con el JSON roto | `Respuesta mal escrita` y la columna |

La función pura se prueba sola, con una tabla de casos, sin red ni anfitrión.

## Mejorar {#mejorar fase=5}

En una frase: «El borde pide el cambio y revisa el código; el precio lo calcula una función pura».

Es el núcleo puro y el borde otra vez: si mañana el cambio viene de un archivo, solo cambia `PedirCambio`.

## Lo que aprendiste {#aprendiste}

::: resumen
- {peticion} Una petición le pide algo a otro programa por internet; la respuesta llega con un cuerpo de texto.
- {codigo-de-estado} El código de estado dice cómo le fue a la petición: 200 es bien; 400 y 500 son problemas.
:::

## Practica {#practica}

::: practica
- exterior.http.estado-clasificar
- exterior.http.precio-pesos
- exterior.http.que-hacer
- exterior.http.predecir-estado
- exterior.http.que-romper
- exterior.http.borde-o-nucleo
:::

::: docentes
- **«Si hay internet, siempre responde 200».** Un servicio puede responder y aun así decir que hubo un problema.
- **Mezclar el cálculo con la petición.** El precio se calcula en una función que no sabe de redes.
- **Creer que la app puede probar la red.** Los ejercicios prueban las funciones puras; la red se simula con un anfitrión de memoria.
:::

::: siguiente
Ya tienes todas las piezas. ¿Cómo queda el kiosco completo?
:::

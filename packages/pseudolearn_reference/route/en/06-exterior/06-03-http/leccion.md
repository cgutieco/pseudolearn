---
id: exterior.http
numero: "6.3"
tipo: leccion
titulo: Talking to the internet
duracion: 30
problema_breve: The price of imported fruit
necesita: [exterior.json]
introduce: [peticion, codigo-de-estado]
usa: [capacidad, json, nucleo-puro, funcion-pura, resultado-con-error]
---

::: frase
A program asks another one something over the internet by sending a request, and the answer brings a code that says how it went.
:::

## The problem {#problema}

::: problema
Imported fruit costs **2 dollars**, and the kiosk charges in pesos according to the **day's exchange rate**, which a service publishes on the internet. Sometimes the service answers and sometimes it does not.

**How much does the kiosk charge today for imported fruit, and what does it do if the service does not answer?**
:::

## Try it {#intentalo}

::: intento
If the service says that a dollar is worth 20 pesos, how much does the fruit cost? And if it does not answer?
:::

::: respuesta
**40 pesos**. If it does not answer, the kiosk cannot make up a price: it warns that the service is not available.
:::

## Understand and plan {#entender-planear fase=1-2}

- **What goes in and what comes out?** The answer of the service goes in; out comes the price in pesos or a warning.
- **What does it look like?** The inventory of the previous lesson: a JSON text that arrives from outside and has to be read.
- **What can fail outside the program?** The network may not be there, the service may answer an error and the answer may come badly written.

## The new tool {#herramienta}

An [[def:peticion|HTTP request]] asks another program for something over the internet. To send it, the program asks for the network capability with `requestNetwork`, just as it asked for that of a folder. The answer brings a text, the body, and a [[def:codigo-de-estado|status code]] that says how it went: 200 is fine; those that start with 4 or with 5 are problems.

```figura-especificacion seccion=biblioteca.http figura=http-ida-vuelta
```

```programa id=clima titulo="Asking for the weather" ejecutar
SubProceso CheckWeather() Como Resultado<Cadena, ErrorES>
  Definir network Como RedCap <- Propagar SolicitarRed();
  Definir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, "https://clima.test/hoy");
  Definir response Como RespuestaHttp <- Propagar network.Enviar(request);
  Escribir "Status: ", response.Estado();
  Retornar response.CuerpoTexto();
FinSubProceso

Algoritmo Weather
  Segun CheckWeather() Hacer
    Exito(text): Escribir text;
    Error(report): Escribir report.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"http": {"GET https://clima.test/hoy": {"estado": 200, "cuerpo": "Sunny, 25"}}}
```

```salida
Status: 200
Sunny, 25
```

The service of this example is not real: the memory host answers in its place, always the same. That way the program can be tested without the internet.

::: especificacion
- biblioteca.http
- biblioteca.json
:::

## Write {#escribir fase=3}

```programa id=cambio titulo="The imported fruit" ejecutar
Funcion pesos <- PriceInPesos(dollars Como Entero, rate Como Entero)
  Definir pesos Como Entero;
  pesos <- dollars * rate;
FinFuncion

Funcion message <- PriceMessage(cuerpo Como Cadena)
  Definir message Como Cadena <- "The response has no rate";
  Segun AnalizarJson(cuerpo) Hacer
    Exito(data):
      Segun data.Campo("dollar") Hacer
        Algo(dollar):
          Segun dollar.ComoEntero() Hacer
            Algo(rate): message <- "Imported fruit: " + ATexto(PriceInPesos(2, rate)) + " pesos";
            Nada: message <- "The rate is not a number";
          FinSegun
        Nada: message <- "The response has no rate";
      FinSegun
    Error(report): message <- "Badly written response at column " + ATexto(report.JsonColumna);
  FinSegun
FinFuncion

SubProceso RequestRate() Como Resultado<Cadena, ErrorES>
  Definir network Como RedCap <- Propagar SolicitarRed();
  Definir response Como RespuestaHttp <- Propagar network.Enviar(PeticionHttp(MetodoHttp.GET, "https://cambio.test/hoy"));
  Si response.Estado() <> 200 Entonces
    Retornar Exito("Service unavailable (" + ATexto(response.Estado()) + ")");
  FinSi
  Definir cuerpo Como Cadena <- Propagar response.CuerpoTexto();
  Retornar Exito(PriceMessage(cuerpo));
FinSubProceso

Algoritmo ImportedFruit
  Segun RequestRate() Hacer
    Exito(message): Escribir message;
    Error(report): Escribir "No network: ", report.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"http": {"GET https://cambio.test/hoy": {"estado": 200, "cuerpo": "{\"dollar\": 20}"}}}
```

```salida
Imported fruit: 40 pesos
```

`PriceInPesos` and `PriceMessage` are pure functions: they receive numbers or text and give back a value. `RequestRate` is the edge: it asks for the network, sends the request and checks the status code. With the same program and a service that is down:

```programa id=cambio-caido titulo="The service does not answer" ejecutar
Funcion pesos <- PriceInPesos(dollars Como Entero, rate Como Entero)
  Definir pesos Como Entero;
  pesos <- dollars * rate;
FinFuncion

Funcion message <- PriceMessage(cuerpo Como Cadena)
  Definir message Como Cadena <- "The response has no rate";
  Segun AnalizarJson(cuerpo) Hacer
    Exito(data):
      Segun data.Campo("dollar") Hacer
        Algo(dollar):
          Segun dollar.ComoEntero() Hacer
            Algo(rate): message <- "Imported fruit: " + ATexto(PriceInPesos(2, rate)) + " pesos";
            Nada: message <- "The rate is not a number";
          FinSegun
        Nada: message <- "The response has no rate";
      FinSegun
    Error(report): message <- "Badly written response at column " + ATexto(report.JsonColumna);
  FinSegun
FinFuncion

SubProceso RequestRate() Como Resultado<Cadena, ErrorES>
  Definir network Como RedCap <- Propagar SolicitarRed();
  Definir response Como RespuestaHttp <- Propagar network.Enviar(PeticionHttp(MetodoHttp.GET, "https://cambio.test/hoy"));
  Si response.Estado() <> 200 Entonces
    Retornar Exito("Service unavailable (" + ATexto(response.Estado()) + ")");
  FinSi
  Definir cuerpo Como Cadena <- Propagar response.CuerpoTexto();
  Retornar Exito(PriceMessage(cuerpo));
FinSubProceso

Algoritmo ImportedFruit
  Segun RequestRate() Hacer
    Exito(message): Escribir message;
    Error(report): Escribir "No network: ", report.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{"http": {"GET https://cambio.test/hoy": {"estado": 503, "cuerpo": ""}}}
```

```salida
Service unavailable (503)
```

## Test {#probar fase=4}

| Case | What it shows |
|---|---|
| 200 with the datum | `Imported fruit: 40 pesos` |
| 503 | `Service unavailable (503)` |
| 200 with broken JSON | `Badly written response` and the column |

The pure function is tested on its own, with a table of cases, without a network or a host.

## Improve {#mejorar fase=5}

In one sentence: «The edge asks for the rate and checks the code; the price is computed by a pure function».

It is the pure core and the edge again: if tomorrow the rate comes from a file, only `RequestRate` changes.

## What you learned {#aprendiste}

::: resumen
- {peticion} An HTTP request asks another program for something over the internet; the answer arrives with a body of text.
- {codigo-de-estado} The status code says how the request went: 200 is fine; 400 and 500 are problems.
:::

## Practise {#practica}

::: practica
- exterior.http.estado-clasificar
- exterior.http.precio-pesos
- exterior.http.que-hacer
- exterior.http.predecir-estado
- exterior.http.que-romper
- exterior.http.borde-o-nucleo
:::

::: profundizar titulo="Common pitfalls"
- **«If there is internet, it always answers 200».** A service can answer and still say there was a problem.
- **Mixing the calculation with the request.** The price is computed in a function that knows nothing about networks.
- **Believing that the app can test the network.** The exercises test the pure functions; the network is simulated with a memory host.
:::

::: siguiente
You now have all the pieces. What does the complete kiosk look like?
:::

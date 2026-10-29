---
{
  "formato": "see/1",
  "id": "LIB.HTTP",
  "titulo": "Tipos y operaciones HTTP",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Capacidad de red por origen y valores HTTP inmutables con respuestas explícitas.",
  "titulo_en": "HTTP types and operations",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.IO",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TASK.ISOLATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "ENG.EXEC.EFFECT-COMMIT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "ENG.EFFECT.TAPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "RT.HOST.INTERFACE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "API.PROJECT.MANIFEST",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "API.WIRE-FORMAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "API.EXECUTE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Tipos y operaciones HTTP

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "SolicitarRed devuelve Resultado<RedCap, ErrorES> y exige el permiso red. La capacidad solo contiene los orígenes concedidos por el anfitrión. Limitar acepta un origen perteneciente a esa capacidad y devuelve otra capacidad cuyo conjunto es ese único origen; un origen no concedido produce DestinoDenegado. Cerrar invalida la capacidad.",
  "verificacion": ["C1", "C2", "C3", "C9"]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "hola\n", "terminacion": "completed"},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConLimiteRespuesta(16).ConTiempoMaximo(1000);\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar response.CuerpoTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withResponseLimit(16).withTimeout(1000);\ndefine response as HttpResponse <- propagate net.send(request);\nreturn response.textBody();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/a": {
        "estado": 200,
        "cabeceras": [["content-type", "text/plain"]],
        "cuerpo": "hola"
      }
    }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "{{lexema:booleanFalse}}\n", "terminacion": "completed"},
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net): Escribir \"concedida\";\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net): write \"granted\";\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {"permissions": [], "requested_permissions": ["red"]}
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "{{lexema:booleanFalse}}\n", "terminacion": "completed"},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<RedCap, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nRetornar net.Limitar(\"https://other.test\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(net): Escribir \"concedida\";\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<NetworkCap, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nreturn net.restrict(\"https://other.test\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(net): write \"granted\";\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/a": {"estado": 200}}
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "MetodoHttp es un enumerado cerrado con GET, HEAD, POST, PUT, PATCH y DELETE, con la misma grafía en ambos perfiles. PeticionHttp es inmutable. ConCabecera, ConCuerpo, ConCuerpoTexto, ConLimiteRespuesta y ConTiempoMaximo devuelven una petición nueva. Enviar acepta solo las seis variantes declaradas; no añade Content-Type ni otra cabecera por omisión.",
  "verificacion": ["C4"]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "404\n{{lexema:booleanFalse}}\neco\n0\n204\n204\n204\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 7}
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir get Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/missing\");\nDefinir missing Como RespuestaHttp <- Propagar net.Enviar(get);\nEscribir missing.Estado();\nEscribir missing.EsExito();\nDefinir post Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/echo\").ConCuerpoTexto(\"eco\");\nDefinir echoed Como RespuestaHttp <- Propagar net.Enviar(post);\nEscribir Propagar echoed.CuerpoTexto();\nDefinir head Como PeticionHttp <- PeticionHttp(MetodoHttp.HEAD, \"https://fake.test/head\");\nDefinir headed Como RespuestaHttp <- Propagar net.Enviar(head);\nEscribir headed.Cuerpo().Longitud();\nDefinir put Como PeticionHttp <- PeticionHttp(MetodoHttp.PUT, \"https://fake.test/update\");\nDefinir updated Como RespuestaHttp <- Propagar net.Enviar(put);\nEscribir updated.Estado();\nDefinir patch Como PeticionHttp <- PeticionHttp(MetodoHttp.PATCH, \"https://fake.test/patch\");\nDefinir patched Como RespuestaHttp <- Propagar net.Enviar(patch);\nEscribir patched.Estado();\nDefinir delete Como PeticionHttp <- PeticionHttp(MetodoHttp.DELETE, \"https://fake.test/delete\");\nDefinir deleted Como RespuestaHttp <- Propagar net.Enviar(delete);\nEscribir deleted.Estado();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value < 0 Entonces\nEscribir value;\nFinSi\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine get as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/missing\");\ndefine missing as HttpResponse <- propagate net.send(get);\nwrite missing.status();\nwrite missing.isSuccess();\ndefine post as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/echo\").withTextBody(\"eco\");\ndefine echoed as HttpResponse <- propagate net.send(post);\nwrite propagate echoed.textBody();\ndefine head as HttpRequest <- HttpRequest(HttpMethod.HEAD, \"https://fake.test/head\");\ndefine headed as HttpResponse <- propagate net.send(head);\nwrite headed.body().length();\ndefine put as HttpRequest <- HttpRequest(HttpMethod.PUT, \"https://fake.test/update\");\ndefine updated as HttpResponse <- propagate net.send(put);\nwrite updated.status();\ndefine patch as HttpRequest <- HttpRequest(HttpMethod.PATCH, \"https://fake.test/patch\");\ndefine patched as HttpResponse <- propagate net.send(patch);\nwrite patched.status();\ndefine delete as HttpRequest <- HttpRequest(HttpMethod.DELETE, \"https://fake.test/delete\");\ndefine deleted as HttpResponse <- propagate net.send(delete);\nwrite deleted.status();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value < 0 then\nwrite value;\nendIf\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/missing": {"estado": 404},
      "POST https://fake.test/echo": {"estado": 500, "cuerpo": "eco"},
      "HEAD https://fake.test/head": {"estado": 200, "cuerpo": "ignorado"},
      "PUT https://fake.test/update": {"estado": 204},
      "PATCH https://fake.test/patch": {"estado": 204},
      "DELETE https://fake.test/delete": {"estado": 204}
    }
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Enviar valida en el motor antes de consultar al anfitrión: la capacidad está abierta, la URL usa http o https y tiene host ASCII sin credenciales, el origen está concedido, los nombres de cabecera son tokens HTTP y sus valores no contienen CR, LF ni NUL. Rechaza las cabeceras host, content-length, transfer-encoding, connection, upgrade, te, trailer, keep-alive, proxy-*, cookie, set-cookie y accept-encoding. GET y HEAD no admiten cuerpo. Los fallos de validación son ErrorES y no consultan al anfitrión.",
  "verificacion": ["C5"]
}
```

```caso
{
  "id": "C5",
  "regla": "R3",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n", "terminacion": "completed", "anfitrion_observado": {"llamadas": 7}},
  "programas": {
    "es": "SubProceso Send(request Como PeticionHttp) Como Resultado<Cadena, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Url());\nFinSubProceso\nAlgoritmo Main\nSegun Send(PeticionHttp(MetodoHttp.GET, \"ftp://fake.test/a\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nSegun Send(PeticionHttp(MetodoHttp.GET, \"https://user@fake.test/a\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nSegun Send(PeticionHttp(MetodoHttp.GET, \"fake.test/a\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nSegun Send(PeticionHttp(MetodoHttp.GET, \"https://tést.test/a\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nSegun Send(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConCuerpoTexto(\"x\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nSegun Send(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConCabecera(\"host\", \"fake.test\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nSegun Send(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConCabecera(\"x-test\", \"a\\r\\nb\")) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Send(request as HttpRequest) as result<string, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine response as HttpResponse <- propagate net.send(request);\nreturn success(response.url());\nendSubroutine\nalgorithm Main\nswitch Send(HttpRequest(HttpMethod.GET, \"ftp://fake.test/a\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nswitch Send(HttpRequest(HttpMethod.GET, \"https://user@fake.test/a\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nswitch Send(HttpRequest(HttpMethod.GET, \"fake.test/a\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nswitch Send(HttpRequest(HttpMethod.GET, \"https://tést.test/a\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nswitch Send(HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withTextBody(\"x\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nswitch Send(HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withHeader(\"host\", \"fake.test\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nswitch Send(HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withHeader(\"x-test\", \"a\\r\\nb\")) do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/a": {"estado": 200}}
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una respuesta completa con estado 100 a 599, excepto 101, es Exito(RespuestaHttp); las respuestas 3xx, 4xx y 5xx no se convierten en ErrorES. EsExito es verdadero solo entre 200 y 299. Cuerpo conserva los octetos y CuerpoTexto devuelve Resultado<Cadena, ErrorES> con Utf8Invalido si no son UTF-8. Cabecera ignora mayúsculas ASCII y une los valores repetidos con coma y espacio; NombresCabeceras devuelve nombres en minúsculas una sola vez en orden de primera aparición.",
  "verificacion": ["C6", "C12"]
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "a, b\n255\n{{lexema:booleanFalse}}\n", "terminacion": "completed"},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/binary\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nSegun response.Cabecera(\"X-Test\") Hacer\nAlgo(value): Escribir value;\nNada: Escribir \"missing\";\nFinSegun\nEscribir response.Cuerpo().En(0);\nSegun response.CuerpoTexto() Hacer\nExito(text): Escribir text;\nError(problem): Escribir problem.Incierto;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value < 0 Entonces\nEscribir value;\nFinSi\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/binary\");\ndefine response as HttpResponse <- propagate net.send(request);\nswitch response.header(\"x-test\") do\nsome(value): write value;\nnone: write \"missing\";\nendSwitch\nwrite response.body().at(0);\nswitch response.textBody() do\nsuccess(text): write text;\nfailure(problem): write problem.uncertain;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value < 0 then\nwrite value;\nendIf\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/binary": {
        "estado": 599,
        "cabeceras": [["X-Test", "a"], ["x-test", "b"]],
        "cuerpo_bytes": [255]
      }
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "GET y HEAD son de solo lectura y no pueden producir Uncertain. POST, PUT, PATCH y DELETE pueden mutar; un fallo incierto de su envío conserva Incierto verdadero. Una llamada Enviar produce una sola solicitud al anfitrión y no se reintenta automáticamente. Cuando varias tareas esperan envíos HTTP, cada efecto conserva la tarea que lo pidió y la cinta distingue el orden de petición del orden de entrega.",
  "verificacion": ["C7", "C10"]
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "{{lexema:booleanTrue}}\n", "terminacion": "completed", "anfitrion_observado": {"llamadas": 2, "estado_cinta": "uncertain_external_state"}},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/write\");\nSegun net.Enviar(request) Hacer\nExito(response): Retornar Exito(Falso);\nError(problem): Retornar Exito(problem.Incierto);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/write\");\nswitch net.send(request) do\nsuccess(response): return success(false);\nfailure(problem): return success(problem.uncertain);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"POST https://fake.test/write": {"fallo": "conexion_fallida", "incierto": true}}
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cinta registra para network_send el estado, las cabeceras, el cuerpo y la URL final de la respuesta. Las cabeceras authorization y las clasificadas como credencial se sustituyen por SecretHandle antes de serializar; la respuesta completa se conserva para reproducirla. Una petición distinta de la registrada produce replay_divergence. En reproducción y al consultar el pasado no se envía una petición al anfitrión.",
  "verificacion": ["C8", "C11"]
}
```

```caso
{
  "id": "C8",
  "regla": "R6",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "200\n", "terminacion": "completed", "anfitrion_observado": {"estado_cinta": "non_reproducible_redacted", "efectos": [{"effect_seq": 2, "capability_kind": "network", "operation": "network_send", "outcome": "committed", "secret_key_id": "k1"}]}},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/secret\").ConCabecera(\"authorization\", \"Bearer secreto\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/secret\").withHeader(\"authorization\", \"Bearer secreto\");\ndefine response as HttpResponse <- propagate net.send(request);\nreturn success(response.status());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "grabar_y_reproducir": true,
    "secrets": {"authorization": {"key_id": "k1", "value": "secreto"}},
    "secret_keys": {"k1": "clave"},
    "http": {"GET https://fake.test/secret": {"estado": 200}}
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "{{lexema:booleanFalse}}\n", "terminacion": "completed"},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir closed Como Logico <- Propagar net.Cerrar();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nSegun net.Enviar(request) Hacer\nExito(response): Retornar Exito(Falso);\nError(problem): Retornar Exito(problem.Incierto);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine closed as boolean <- propagate net.close();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\nswitch net.send(request) do\nsuccess(response): return success(false);\nfailure(problem): return success(problem.uncertain);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/a": {"estado": 200}}
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R5",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n202\n2\n201\n1\n200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4,
      "estado_cinta": "reproducible",
      "efectos": [
        {"effect_seq": 1, "task_id": 0, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 4, "task_id": 3, "delivery_seq": 2, "capability_kind": "network", "operation": "network_send", "outcome": "committed"},
        {"effect_seq": 3, "task_id": 2, "delivery_seq": 5, "capability_kind": "network", "operation": "network_send", "outcome": "committed"},
        {"effect_seq": 2, "task_id": 1, "delivery_seq": 8, "capability_kind": "network", "operation": "network_send", "outcome": "committed"}
      ]
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Fetch(label Como Entero, net Como RedCap, url Como Cadena)\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, url);\nSegun Aguardar net.Enviar(request) Hacer\nExito(response): Escribir label;\nEscribir response.Estado();\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(1, net, \"https://fake.test/one\");\nLanzar Fetch(2, net, \"https://fake.test/two\");\nLanzar Fetch(3, net, \"https://fake.test/three\");\nFinTareas\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fetch(label as integer, net as NetworkCap, url as string)\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, url);\nswitch await net.send(request) do\nsuccess(response): write label;\nwrite response.status();\nfailure(problem): write problem.uncertain;\nendSwitch\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks\nspawn Fetch(1, net, \"https://fake.test/one\");\nspawn Fetch(2, net, \"https://fake.test/two\");\nspawn Fetch(3, net, \"https://fake.test/three\");\nendTasks\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "grabar_y_reproducir": true,
    "orden_entrega": [4, 3, 2],
    "http": {
      "GET https://fake.test/one": {"estado": 200},
      "GET https://fake.test/two": {"estado": 201},
      "GET https://fake.test/three": {"estado": 202}
    }
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R6",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "reproduccion_fallo": "replay_divergence"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\ndefine response as HttpResponse <- propagate net.send(request);\nreturn success(response.status());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/a": {"estado": 200}},
    "alterar_cinta": "alterar_solicitud"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R4",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n{{lexema:booleanTrue}}\n0\n0\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "efectos": [
        {"effect_seq": 1, "task_id": 0, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 2, "task_id": 0, "capability_kind": "network", "operation": "network_send", "outcome": "committed"},
        {"effect_seq": 6, "task_id": 0, "capability_kind": "network", "operation": "network_send", "outcome": "failed"}
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir empty Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/empty\"));\nEscribir empty.Estado();\nEscribir empty.EsExito();\nEscribir empty.Cuerpo().Longitud();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/informational\")) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Exito(0);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine empty as HttpResponse <- propagate net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/empty\"));\nwrite empty.status();\nwrite empty.isSuccess();\nwrite empty.body().length();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/informational\")) do\nsuccess(response): return success(1);\nfailure(problem): return success(0);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/empty": {"estado": 200},
      "GET https://fake.test/informational": {"estado": 101}
    }
  }
}
```

RedCap conserva los orígenes concedidos en la autoridad del motor; los bytes de respuesta y los valores de petición son inmutables. MetodoHttp reconoce sus seis miembros en contexto sin añadir palabras reservadas. Los guiones de anfitrion.http solo se ejecutan en el anfitrión de memoria y nunca abren conexiones.

Una respuesta 1xx informativa pertenece al transporte y debe consumirse antes de entregar una respuesta completa. El anfitrión de memoria modela una respuesta final completa; la validación del motor acepta estados 100 a 599 salvo 101 para mantener el contrato común con adaptadores.

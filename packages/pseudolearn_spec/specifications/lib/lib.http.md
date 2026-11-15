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
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Capacidad de red por origen y valores HTTP inmutables con respuestas explícitas.",
  "titulo_en": "HTTP types and operations",
  "edicion": {
    "introducida_en": "2027"
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
  "texto": "SolicitarRed devuelve Resultado<RedCap, ErrorES> con autoridad plena sobre cualquier destino http o https. Limitar acepta un origen y devuelve otra capacidad de ese único origen; si la capacidad ya estaba limitada, otro origen produce DestinoDenegado. Cerrar invalida la capacidad. No se requieren concesiones ni configuración de orígenes.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C9",
    "C28",
    "C29",
    "C30",
    "C31"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConLimiteRespuesta(16).ConTiempoMaximo(1000);\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar response.CuerpoTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withResponseLimit(16).withTimeout(1000);\ndefine response as HttpResponse <- propagate net.send(request);\nreturn response.textBody();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/a": {
        "estado": 200,
        "cabeceras": [
          [
            "content-type",
            "text/plain"
          ]
        ],
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
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net): Escribir \"concedida\";\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net): write \"granted\";\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "faults": [
      {
        "operation": "request_network",
        "code": "permiso_denegado"
      }
    ]
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<RedCap, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Definir limited Como RedCap <- Propagar net.Limitar(\"https://fake.test\");\n  Retornar limited.Limitar(\"https://other.test\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(net): Escribir \"concedida\";\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result<NetworkCap, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Define limited As NetworkCap <- Propagate net.restrict(\"https://fake.test\");\n  Return limited.restrict(\"https://other.test\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(net): Write \"granted\";\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/a": {
        "estado": 200
      }
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "MetodoHttp es un enumerado cerrado con GET, HEAD, POST, PUT, PATCH y DELETE, con la misma grafía en ambos perfiles. PeticionHttp es inmutable. ConCabecera, ConCuerpo, ConCuerpoTexto, ConLimiteRespuesta y ConTiempoMaximo devuelven una petición nueva. ConLimiteRespuesta recibe un tope en bytes y ConTiempoMaximo un plazo en nanosegundos, la misma unidad que Reloj y Temporizador. Enviar acepta solo las seis variantes declaradas; no añade Content-Type ni otra cabecera por omisión.",
  "verificacion": ["C4", "C33", "C34", "C35", "C36", "C37", "C38"]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "404\n{{lexema:booleanFalse}}\neco\n0\n204\n204\n204\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 7
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Definir get Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/missing\");\n  Definir missing Como RespuestaHttp <- Propagar net.Enviar(get);\n  Escribir missing.Estado();\n  Escribir missing.EsExito();\n  Definir post Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/echo\").ConCuerpoTexto(\"eco\");\n  Definir echoed Como RespuestaHttp <- Propagar net.Enviar(post);\n  Escribir Propagar echoed.CuerpoTexto();\n  Definir head Como PeticionHttp <- PeticionHttp(MetodoHttp.HEAD, \"https://fake.test/head\");\n  Definir headed Como RespuestaHttp <- Propagar net.Enviar(head);\n  Escribir headed.Cuerpo().Longitud();\n  Definir put Como PeticionHttp <- PeticionHttp(MetodoHttp.PUT, \"https://fake.test/update\");\n  Definir updated Como RespuestaHttp <- Propagar net.Enviar(put);\n  Escribir updated.Estado();\n  Definir patch Como PeticionHttp <- PeticionHttp(MetodoHttp.PATCH, \"https://fake.test/patch\");\n  Definir patched Como RespuestaHttp <- Propagar net.Enviar(patch);\n  Escribir patched.Estado();\n  Definir delete Como PeticionHttp <- PeticionHttp(MetodoHttp.DELETE, \"https://fake.test/delete\");\n  Definir deleted Como RespuestaHttp <- Propagar net.Enviar(delete);\n  Escribir deleted.Estado();\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(value): Si value < 0 Entonces\n        Escribir value;\n      FinSi\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result<Integer, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Define get As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/missing\");\n  Define missing As HttpResponse <- Propagate net.send(get);\n  Write missing.status();\n  Write missing.isSuccess();\n  Define post As HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/echo\").withTextBody(\"eco\");\n  Define echoed As HttpResponse <- Propagate net.send(post);\n  Write Propagate echoed.textBody();\n  Define head As HttpRequest <- HttpRequest(HttpMethod.HEAD, \"https://fake.test/head\");\n  Define headed As HttpResponse <- Propagate net.send(head);\n  Write headed.body().length();\n  Define put As HttpRequest <- HttpRequest(HttpMethod.PUT, \"https://fake.test/update\");\n  Define updated As HttpResponse <- Propagate net.send(put);\n  Write updated.status();\n  Define patch As HttpRequest <- HttpRequest(HttpMethod.PATCH, \"https://fake.test/patch\");\n  Define patched As HttpResponse <- Propagate net.send(patch);\n  Write patched.status();\n  Define delete As HttpRequest <- HttpRequest(HttpMethod.DELETE, \"https://fake.test/delete\");\n  Define deleted As HttpResponse <- Propagate net.send(delete);\n  Write deleted.status();\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(value): If value < 0 Then\n        Write value;\n      EndIf\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/missing": {
        "estado": 404
      },
      "POST https://fake.test/echo": {
        "estado": 500,
        "cuerpo": "eco"
      },
      "HEAD https://fake.test/head": {
        "estado": 200,
        "cuerpo": "ignorado"
      },
      "PUT https://fake.test/update": {
        "estado": 204
      },
      "PATCH https://fake.test/patch": {
        "estado": 204
      },
      "DELETE https://fake.test/delete": {
        "estado": 204
      }
    }
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Enviar valida antes de consultar al anfitrión: capacidad abierta, URL http o https con host ASCII sin credenciales, atenuación voluntaria de origen, nombres de cabecera como tokens HTTP y valores sin CR, LF ni NUL. Rechaza únicamente cabeceras controladas por el transporte: host, content-length, transfer-encoding, connection, upgrade, te, trailer, keep-alive y accept-encoding. Cookie y set-cookie se admiten en nativo; el navegador informa sus restricciones como PeticionInvalida de plataforma. GET y HEAD no admiten cuerpo. Los fallos de validación son ErrorES y no consultan al anfitrión.",
  "verificacion": [
    "C5",
    "C32"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n{{lexema:booleanFalse}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 7
    }
  },
  "programas": {
    "es": "SubProceso Send(request Como PeticionHttp) Como Resultado<Cadena, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Definir response Como RespuestaHttp <- Propagar net.Enviar(request);\n  Retornar Exito(response.Url());\nFinSubProceso\n\nAlgoritmo Main\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"ftp://fake.test/a\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"https://user@fake.test/a\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"fake.test/a\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"https://tést.test/a\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConCuerpoTexto(\"x\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConCabecera(\"host\", \"fake.test\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Segun Send(PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\").ConCabecera(\"x-test\", \"a\\r\\nb\")) Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Send(request As HttpRequest) As Result<String, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate net.send(request);\n  Return Success(response.url());\nEndSubroutine\n\nAlgorithm Main\n  Switch Send(HttpRequest(HttpMethod.GET, \"ftp://fake.test/a\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Switch Send(HttpRequest(HttpMethod.GET, \"https://user@fake.test/a\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Switch Send(HttpRequest(HttpMethod.GET, \"fake.test/a\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Switch Send(HttpRequest(HttpMethod.GET, \"https://tést.test/a\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Switch Send(HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withTextBody(\"x\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Switch Send(HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withHeader(\"host\", \"fake.test\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Switch Send(HttpRequest(HttpMethod.GET, \"https://fake.test/a\").withHeader(\"x-test\", \"a\\r\\nb\")) Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/a": {
        "estado": 200
      }
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una respuesta completa con estado 100 a 599, excepto 101, es Exito(RespuestaHttp); las respuestas 3xx, 4xx y 5xx no se convierten en ErrorES. EsExito es verdadero solo entre 200 y 299. Cuerpo conserva los octetos y CuerpoTexto devuelve Resultado<Cadena, ErrorES> con Utf8Invalido si no son UTF-8. Cabecera ignora mayúsculas ASCII y une los valores repetidos con coma y espacio; NombresCabeceras devuelve nombres en minúsculas una sola vez en orden de primera aparición.",
  "verificacion": ["C6", "C12", "C39", "C40", "C41", "C42", "C43", "C44", "C45"]
}
```

```caso
{
  "id": "C6",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "a, b\n255\n{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Definir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/binary\");\n  Definir response Como RespuestaHttp <- Propagar net.Enviar(request);\n  Segun response.Cabecera(\"X-Test\") Hacer\n    Algo(value): Escribir value;\n    Nada: Escribir \"missing\";\n  FinSegun\n  Escribir response.Cuerpo().En(0);\n  Segun response.CuerpoTexto() Hacer\n    Exito(text): Escribir text;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(value): Si value < 0 Entonces\n        Escribir value;\n      FinSi\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result<Integer, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/binary\");\n  Define response As HttpResponse <- Propagate net.send(request);\n  Switch response.header(\"x-test\") Do\n    Some(value): Write value;\n    None: Write \"missing\";\n  EndSwitch\n  Write response.body().at(0);\n  Switch response.textBody() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(value): If value < 0 Then\n        Write value;\n      EndIf\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/binary": {
        "estado": 599,
        "cabeceras": [
          [
            "X-Test",
            "a"
          ],
          [
            "x-test",
            "b"
          ]
        ],
        "cuerpo_bytes": [
          255
        ]
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
  "texto": "GET y HEAD son de solo lectura y no pueden producir Uncertain. POST, PUT, PATCH y DELETE pueden mutar; si el fallo ocurre antes del primer byte de la petición, se resuelve como Failed con Incierto falso, y si ocurre tras iniciar el envío y antes de recibir la respuesta completa, se resuelve como Uncertain con Incierto verdadero. Una llamada Enviar produce una sola solicitud al anfitrión y ningún componente reintenta automáticamente ningún método. Si la tarea que espera se cancela, el efecto queda abandoned, el adaptador aborta la conexión y no afirma que el servidor no lo procesó. Cuando varias tareas esperan envíos HTTP, cada efecto conserva la tarea que lo pidió y la cinta distingue el orden de petición del orden de entrega.",
  "verificacion": ["C7", "C10", "C25", "C26", "C27"]
}
```

```caso
{
  "id": "C7",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "uncertain_external_state",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "uncertain"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/write\");\nSegun net.Enviar(request) Hacer\nExito(response): Retornar Exito(Falso);\nError(problem): Retornar Exito(problem.Incierto);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/write\");\nswitch net.send(request) do\nsuccess(response): return success(false);\nfailure(problem): return success(problem.uncertain);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "POST https://fake.test/write": {
        "fallo": "conexion_fallida",
        "incierto": true
      }
    }
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "failed"
        }
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/read-cut\")) Hacer\nExito(response): Escribir Verdadero;\nError(problem): Escribir problem.Incierto;\nFinSegun\nError(denied): Escribir denied.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net):\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/read-cut\")) do\nsuccess(response): write true;\nfailure(problem): write problem.uncertain;\nendSwitch\nfailure(denied): write denied.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/read-cut": {
        "fallo": "conexion_fallida",
        "incierto": false
      }
    }
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "uncertain_external_state",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "uncertain"
        }
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nSegun net.Enviar(PeticionHttp(MetodoHttp.DELETE, \"https://fake.test/delete-cut\")) Hacer\nExito(response): Escribir Falso;\nError(problem): Escribir problem.Incierto;\nFinSegun\nError(denied): Escribir denied.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\nswitch requestNetwork() do\nsuccess(net):\nswitch net.send(HttpRequest(HttpMethod.DELETE, \"https://fake.test/delete-cut\")) do\nsuccess(response): write false;\nfailure(problem): write problem.uncertain;\nendSwitch\nfailure(denied): write denied.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "DELETE https://fake.test/delete-cut": {
        "fallo": "conexion_fallida",
        "incierto": true
      }
    }
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "done\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 1,
      "estado_cinta": "uncertain_external_state",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "task_id": 1,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "abandoned"
        }
      ],
      "reproduccion_fallo": "replay_non_reproducible"
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Wait(net Como RedCap)\nDescartar Aguardar net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/abandoned-post\"));\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas failureReport\nLanzar Wait(net);\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nEscribir \"done\";\nError(denied): Escribir denied.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait(net as NetworkCap)\ndiscard await net.send(HttpRequest(HttpMethod.POST, \"https://fake.test/abandoned-post\"));\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"problem\");\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks failureReport\nspawn Wait(net);\nspawn Fail();\nendTasks\ndiscard failureReport;\nwrite \"done\";\nfailure(denied): write denied.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C28",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir red Como RedCap <- Propagar SolicitarRed();\nDefinir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/no-script\"));\nRetornar Exito(respuesta.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(estado): Escribir estado;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine network as NetworkCap <- propagate requestNetwork();\ndefine response as HttpResponse <- propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/no-script\"));\nreturn success(response.status());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(status): write status;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/no-script": {
        "estado": 200
      }
    }
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cinta registra para network_send el estado, las cabeceras, el cuerpo y la URL final de la respuesta. Las cabeceras authorization y las clasificadas como credencial se sustituyen por SecretHandle antes de serializar; la respuesta completa se conserva para reproducirla solo cuando la petición no lleva credenciales; con credenciales la cinta queda non_reproducible_redacted y reproducirla falla con replay_non_reproducible. Una petición distinta de la registrada produce replay_divergence. En reproducción y al consultar el pasado no se envía una petición al anfitrión.",
  "verificacion": ["C8", "C11"]
}
```

```caso
{
  "id": "C8",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "estado_cinta": "non_reproducible_redacted",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "committed",
          "secret_key_id": "k1"
        }
      ],
      "reproduccion_fallo": "replay_non_reproducible"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/secret\").ConCabecera(\"authorization\", \"Bearer secreto\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/secret\").withHeader(\"authorization\", \"Bearer secreto\");\ndefine response as HttpResponse <- propagate net.send(request);\nreturn success(response.status());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "secrets": {
      "authorization": {
        "key_id": "k1",
        "value": "secreto"
      }
    },
    "secret_keys": {
      "k1": "clave"
    },
    "http": {
      "GET https://fake.test/secret": {
        "estado": 200
      }
    }
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Definir closed Como Logico <- Propagar net.Cerrar();\n  Definir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\n  Segun net.Enviar(request) Hacer\n    Exito(response): Retornar Exito(Falso);\n    Error(problem): Retornar Exito(problem.Incierto);\n  FinSegun\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Incierto;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result<Boolean, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Define closed As Boolean <- Propagate net.close();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\n  Switch net.send(request) Do\n    Success(response): Return Success(False);\n    Failure(problem): Return Success(problem.uncertain);\n  EndSwitch\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(value): Write value;\n    Failure(problem): Write problem.uncertain;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/a": {
        "estado": 200
      }
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n202\n2\n201\n1\n200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "task_id": 0,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 4,
          "task_id": 3,
          "delivery_seq": 2,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "committed"
        },
        {
          "effect_seq": 3,
          "task_id": 2,
          "delivery_seq": 5,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "task_id": 1,
          "delivery_seq": 8,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Fetch(label Como Entero, net Como RedCap, url Como Cadena)\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, url);\nSegun Aguardar net.Enviar(request) Hacer\nExito(response): Escribir label;\nEscribir response.Estado();\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(1, net, \"https://fake.test/one\");\nLanzar Fetch(2, net, \"https://fake.test/two\");\nLanzar Fetch(3, net, \"https://fake.test/three\");\nFinTareas\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fetch(label as integer, net as NetworkCap, url as string)\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, url);\nswitch await net.send(request) do\nsuccess(response): write label;\nwrite response.status();\nfailure(problem): write problem.uncertain;\nendSwitch\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks\nspawn Fetch(1, net, \"https://fake.test/one\");\nspawn Fetch(2, net, \"https://fake.test/two\");\nspawn Fetch(3, net, \"https://fake.test/three\");\nendTasks\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true,
    "orden_entrega": [
      4,
      3,
      2
    ],
    "http": {
      "GET https://fake.test/one": {
        "estado": 200
      },
      "GET https://fake.test/two": {
        "estado": 201
      },
      "GET https://fake.test/three": {
        "estado": 202
      }
    }
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "reproduccion_fallo": "replay_divergence"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nRetornar Exito(response.Estado());\nFinSubProceso\nAlgoritmo Main\nDescartar Probe();\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\ndefine response as HttpResponse <- propagate net.send(request);\nreturn success(response.status());\nendSubroutine\nalgorithm Main\ndiscard Probe();\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/a": {
        "estado": 200
      }
    },
    "alterar_cinta": "alterar_solicitud"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n{{lexema:booleanTrue}}\n0\n0\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "efectos": [
        {
          "effect_seq": 1,
          "task_id": 0,
          "capability_kind": "network",
          "operation": "request_network",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "task_id": 0,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "committed"
        },
        {
          "effect_seq": 6,
          "task_id": 0,
          "capability_kind": "network",
          "operation": "network_send",
          "outcome": "failed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir empty Como RespuestaHttp <- Propagar net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/empty\"));\nEscribir empty.Estado();\nEscribir empty.EsExito();\nEscribir empty.Cuerpo().Longitud();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/informational\")) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Exito(0);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine empty as HttpResponse <- propagate net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/empty\"));\nwrite empty.status();\nwrite empty.isSuccess();\nwrite empty.body().length();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/informational\")) do\nsuccess(response): return success(1);\nfailure(problem): return success(0);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/empty": {
        "estado": 200
      },
      "GET https://fake.test/informational": {
        "estado": 101
      }
    }
  }
}
```

RedCap es un valor opaco cuya atenuación voluntaria conserva un único origen; los bytes de respuesta y los valores de petición son inmutables. MetodoHttp reconoce sus seis miembros en contexto sin añadir palabras reservadas. Los guiones de anfitrion.http solo se ejecutan en el doble de prueba del corpus y nunca abren conexiones.

Una respuesta 1xx informativa pertenece al transporte y debe consumirse antes de entregar una respuesta completa. El anfitrión de memoria modela una respuesta final completa; la validación del motor acepta estados 100 a 599 salvo 101 para mantener el contrato común con adaptadores.

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Enviar aplica max_http_body_bytes, max_http_wire_bytes, max_http_header_bytes, max_http_headers y max_http_timeout_nanos del anfitrión. ConLimiteRespuesta y ConTiempoMaximo solo reducen los límites efectivos: el plazo efectivo es el menor entre max_http_timeout_nanos y el valor de ConTiempoMaximo, ambos en nanosegundos; el exceso de respuesta, cabeceras o cuerpo de solicitud devuelve LimiteExcedido, y un valor solicitado no positivo devuelve PeticionInvalida. El límite de cabeceras cuenta los bytes UTF-8 del nombre y valor más cuatro bytes por campo para los delimitadores. Un plazo declarado agotado por el anfitrión produce TiempoAgotado; GET no es incierto y una mutación POST puede ser incierta tras el envío. Estos errores son valores de ErrorES y no terminaciones del programa.",
  "verificacion": ["C13", "C14", "C15", "C16", "C17", "C18", "C19", "C20", "C21", "C22", "C23", "C24"]
}
```

```caso
{
  "id": "C13",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/exact\").ConLimiteRespuesta(4)) Hacer\nExito(response): Retornar Exito(response.Cuerpo().Longitud());\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/exact\").withResponseLimit(4)) do\nsuccess(response): return success(response.body().length());\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/exact": {
        "estado": 200,
        "cuerpo": "1234"
      }
    }
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "limite_excedido\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/over\").ConLimiteRespuesta(4)) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/over\").withResponseLimit(4)) do\nsuccess(response): return success(1);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/over": {
        "estado": 200,
        "cuerpo": "12345"
      }
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/clipped\").ConLimiteRespuesta(8)) Hacer\nExito(response): Retornar Exito(response.Cuerpo().Longitud());\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/clipped\").withResponseLimit(8)) do\nsuccess(response): return success(response.body().length());\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "limites": {
    "max_http_body_bytes": 4
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/clipped": {
        "estado": 200,
        "cuerpo": "1234"
      }
    }
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "peticion_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Segun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/zero-response\").ConLimiteRespuesta(0)) Hacer\n    Exito(response): Retornar Exito(1);\n    Error(problem): Retornar Error(problem);\n  FinSegun\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result<Integer, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Switch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/zero-response\").withResponseLimit(0)) Do\n    Success(response): Return Success(1);\n    Failure(problem): Return Failure(problem);\n  EndSwitch\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(value): Write value;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C17",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "peticion_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Segun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/zero-time\").ConTiempoMaximo(0)) Hacer\n    Exito(response): Retornar Exito(1);\n    Error(problem): Retornar Error(problem);\n  FinSegun\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result<Integer, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Switch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/zero-time\").withTimeout(0)) Do\n    Success(response): Return Success(1);\n    Failure(problem): Return Failure(problem);\n  EndSwitch\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(value): Write value;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C18",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "tiempo_agotado\n{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/get-timeout\").ConTiempoMaximo(1000)) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nEscribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/get-timeout\").withTimeout(1000)) do\nsuccess(response): return success(1);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nwrite problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/get-timeout": {
        "fallo": "tiempo_agotado"
      }
    }
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "tiempo_agotado\n{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/post-timeout\").ConCuerpoTexto(\"dato\").ConTiempoMaximo(1000)) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nEscribir problem.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.POST, \"https://fake.test/post-timeout\").withTextBody(\"data\").withTimeout(1000)) do\nsuccess(response): return success(1);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nwrite problem.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "POST https://fake.test/post-timeout": {
        "fallo": "tiempo_agotado",
        "incierto": true
      }
    }
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "limite_excedido\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/headers\")) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/headers\")) do\nsuccess(response): return success(1);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "limites": {
    "max_http_headers": 1
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/headers": {
        "estado": 200,
        "cabeceras": [
          [
            "x-one",
            "1"
          ],
          [
            "x-two",
            "2"
          ]
        ]
      }
    }
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "limite_excedido\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/host-limit\").ConLimiteRespuesta(8)) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/host-limit\").withResponseLimit(8)) do\nsuccess(response): return success(1);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "limites": {
    "max_http_body_bytes": 4
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/host-limit": {
        "estado": 200,
        "cuerpo": "12345"
      }
    }
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/wire-exact\").ConCuerpoTexto(\"ab\")) Hacer\nExito(response): Retornar Exito(response.Estado());\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.POST, \"https://fake.test/wire-exact\").withTextBody(\"ab\")) do\nsuccess(response): return success(response.status());\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "limites": {
    "max_http_wire_bytes": 2
  },
  "anfitrion": {
    "http": {
      "POST https://fake.test/wire-exact": {
        "estado": 200
      }
    }
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "limite_excedido\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/wire-over\").ConCuerpoTexto(\"ab\")) Hacer\nExito(response): Retornar Exito(1);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.POST, \"https://fake.test/wire-over\").withTextBody(\"ab\")) do\nsuccess(response): return success(1);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "limites": {
    "max_http_wire_bytes": 1
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C24",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\nlimite_excedido\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Fetch(net Como RedCap, url Como Cadena)\nSegun Aguardar net.Enviar(PeticionHttp(MetodoHttp.GET, url)) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun SolicitarRed() Hacer\nExito(net):\nTareas\nLanzar Fetch(net, \"https://fake.test/first\");\nLanzar Fetch(net, \"https://fake.test/second\");\nFinTareas\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fetch(net as NetworkCap, url as string)\nswitch await net.send(HttpRequest(HttpMethod.GET, url)) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nendSubroutine\nalgorithm Main\nswitch requestNetwork() do\nsuccess(net):\ntasks\nspawn Fetch(net, \"https://fake.test/first\");\nspawn Fetch(net, \"https://fake.test/second\");\nendTasks\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "limites": {
    "max_pending_network": 1
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/first": {
        "estado": 200
      },
      "GET https://fake.test/second": {
        "estado": 201
      }
    }
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Soleado, 25\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso ConsultarClima() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://clima.test/hoy\");\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar respuesta.CuerpoTexto();\nFinSubProceso\n\nAlgoritmo Clima\n  Segun ConsultarClima() Hacer\n    Exito(texto): Escribir texto;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine CheckWeather() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://clima.test/hoy\");\n  Define response As HttpResponse <- Propagate network.send(request);\n  Return response.textBody();\nEndSubroutine\n\nAlgorithm Weather\n  Switch CheckWeather() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://clima.test/hoy": {
        "estado": 200,
        "cuerpo": "Soleado, 25"
      }
    }
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\ndestino_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Pedir(red Como RedCap, direccion Como Cadena)\n  Segun red.Enviar(PeticionHttp(MetodoHttp.GET, direccion)) Hacer\n    Exito(respuesta): Escribir respuesta.Estado();\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nSubProceso SoloTienda() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir tienda Como RedCap <- Propagar red.Limitar(\"https://tienda.test\");\n  Pedir(tienda, \"https://tienda.test/precios\");\n  Pedir(tienda, \"https://otro.test/precios\");\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Tienda\n  Descartar SoloTienda();\nFinAlgoritmo\n",
    "en": "Subroutine Fetch(network As NetworkCap, address As String)\n  Switch network.send(HttpRequest(HttpMethod.GET, address)) Do\n    Success(response): Write response.status();\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nSubroutine OnlyShop() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define shop As NetworkCap <- Propagate network.restrict(\"https://tienda.test\");\n  Fetch(shop, \"https://tienda.test/precios\");\n  Fetch(shop, \"https://otro.test/precios\");\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Shop\n  Discard OnlyShop();\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://tienda.test/precios": {
        "estado": 200
      },
      "GET https://otro.test/precios": {
        "estado": 200
      }
    }
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\nOK\ncapacidad_cerrada\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso UsarYCerrar() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/hora\");\n  Definir primera Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Escribir primera.Estado();\n  Definir cerrada Como Logico <- Propagar red.Cerrar();\n  Si cerrada Entonces\n    Escribir \"OK\";\n  FinSi\n  Definir segunda Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar Exito(segunda.Estado());\nFinSubProceso\n\nAlgoritmo CerrarRed\n  Segun UsarYCerrar() Hacer\n    Exito(estado): Escribir estado;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine UseAndClose() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/hora\");\n  Define first As HttpResponse <- Propagate network.send(request);\n  Write first.status();\n  Define closed As Boolean <- Propagate network.close();\n  If closed Then\n    Write \"OK\";\n  EndIf\n  Define second As HttpResponse <- Propagate network.send(request);\n  Return Success(second.status());\nEndSubroutine\n\nAlgorithm CloseNetwork\n  Switch UseAndClose() Do\n    Success(status): Write status;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/hora": {
        "estado": 200
      }
    }
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Estado: 201\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso GuardarNota() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://notas.test/nuevas\").ConCuerpoTexto(\"Comprar pan\");\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar Exito(respuesta.Estado());\nFinSubProceso\n\nAlgoritmo EnviarNota\n  Segun GuardarNota() Hacer\n    Exito(estado): Escribir \"Estado: \", estado;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SaveNote() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.POST, \"https://notas.test/nuevas\").withTextBody(\"Comprar pan\");\n  Define response As HttpResponse <- Propagate network.send(request);\n  Return Success(response.status());\nEndSubroutine\n\nAlgorithm SendNote\n  Switch SaveNote() Do\n    Success(status): Write \"Estado: \", status;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "POST https://notas.test/nuevas": {
        "estado": 201
      }
    }
  }
}
```

```caso
{
  "id": "C33",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "El Principito\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso BuscarLibro() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://libros.test/titulo\");\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar respuesta.CuerpoTexto();\nFinSubProceso\n\nAlgoritmo Biblioteca\n  Segun BuscarLibro() Hacer\n    Exito(titulo): Escribir titulo;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine FindBook() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://libros.test/titulo\");\n  Define response As HttpResponse <- Propagate network.send(request);\n  Return response.textBody();\nEndSubroutine\n\nAlgorithm Library\n  Switch FindBook() Do\n    Success(title): Write title;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://libros.test/titulo": {
        "estado": 200,
        "cuerpo": "El Principito"
      }
    }
  }
}
```

```caso
{
  "id": "C34",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso PedirEnEspanol() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir base Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://saludos.test/hola\");\n  Definir peticion Como PeticionHttp <- base.ConCabecera(\"accept-language\", \"es\");\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar respuesta.CuerpoTexto();\nFinSubProceso\n\nAlgoritmo Idioma\n  Segun PedirEnEspanol() Hacer\n    Exito(texto): Escribir texto;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine AskInSpanish() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define plain As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://saludos.test/hola\");\n  Define request As HttpRequest <- plain.withHeader(\"accept-language\", \"es\");\n  Define response As HttpResponse <- Propagate network.send(request);\n  Return response.textBody();\nEndSubroutine\n\nAlgorithm Language\n  Switch AskInSpanish() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://saludos.test/hola": {
        "estado": 200,
        "cuerpo": "Hola"
      }
    }
  }
}
```

```caso
{
  "id": "C35",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Estado: 204\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso SubirDatos() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir datos Como Bytes <- BytesDesdeTexto(\"123\");\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.PUT, \"https://datos.test/archivo\").ConCuerpo(datos);\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar Exito(respuesta.Estado());\nFinSubProceso\n\nAlgoritmo Subir\n  Segun SubirDatos() Hacer\n    Exito(estado): Escribir \"Estado: \", estado;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine UploadData() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define data As Bytes <- bytesFromText(\"123\");\n  Define request As HttpRequest <- HttpRequest(HttpMethod.PUT, \"https://datos.test/archivo\").withBody(data);\n  Define response As HttpResponse <- Propagate network.send(request);\n  Return Success(response.status());\nEndSubroutine\n\nAlgorithm Upload\n  Switch UploadData() Do\n    Success(status): Write \"Estado: \", status;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "PUT https://datos.test/archivo": {
        "estado": 204
      }
    }
  }
}
```

```caso
{
  "id": "C36",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Mensaje 7\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso PublicarMensaje() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://foro.test/mensajes\").ConCuerpoTexto(\"Hola a todos\");\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(peticion);\n  Retornar respuesta.CuerpoTexto();\nFinSubProceso\n\nAlgoritmo Foro\n  Segun PublicarMensaje() Hacer\n    Exito(texto): Escribir texto;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine PostMessage() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define request As HttpRequest <- HttpRequest(HttpMethod.POST, \"https://foro.test/mensajes\").withTextBody(\"Hola a todos\");\n  Define response As HttpResponse <- Propagate network.send(request);\n  Return response.textBody();\nEndSubroutine\n\nAlgorithm Forum\n  Switch PostMessage() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "POST https://foro.test/mensajes": {
        "estado": 201,
        "cuerpo": "Mensaje 7"
      }
    }
  }
}
```

```caso
{
  "id": "C37",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "13\nlimite_excedido\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Descargar(red Como RedCap, limite Como Entero)\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://cuentos.test/corto\").ConLimiteRespuesta(limite);\n  Segun red.Enviar(peticion) Hacer\n    Exito(respuesta): Escribir respuesta.Cuerpo().Longitud();\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nSubProceso Probar() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Descargar(red, 100);\n  Descargar(red, 5);\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Limites\n  Descartar Probar();\nFinAlgoritmo\n",
    "en": "Subroutine Download(network As NetworkCap, limit As Integer)\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://cuentos.test/corto\").withResponseLimit(limit);\n  Switch network.send(request) Do\n    Success(response): Write response.body().length();\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nSubroutine Try() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Download(network, 100);\n  Download(network, 5);\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Limits\n  Discard Try();\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://cuentos.test/corto": {
        "estado": 200,
        "cuerpo": "Habia una vez"
      }
    }
  }
}
```

```caso
{
  "id": "C38",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\ntiempo_agotado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Consultar(red Como RedCap, direccion Como Cadena)\n  Definir peticion Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, direccion).ConTiempoMaximo(2000000000);\n  Segun red.Enviar(peticion) Hacer\n    Exito(respuesta): Escribir respuesta.Estado();\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nSubProceso Probar() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Consultar(red, \"https://rapido.test/hora\");\n  Consultar(red, \"https://lento.test/hora\");\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Esperas\n  Descartar Probar();\nFinAlgoritmo\n",
    "en": "Subroutine Ask(network As NetworkCap, address As String)\n  Define request As HttpRequest <- HttpRequest(HttpMethod.GET, address).withTimeout(2000000000);\n  Switch network.send(request) Do\n    Success(response): Write response.status();\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nSubroutine Try() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Ask(network, \"https://rapido.test/hora\");\n  Ask(network, \"https://lento.test/hora\");\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Waits\n  Discard Try();\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://rapido.test/hora": {
        "estado": 200
      },
      "GET https://lento.test/hora": {
        "fallo": "tiempo_agotado"
      }
    }
  }
}
```

```caso
{
  "id": "C39",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Estado: 404\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso VerEstado() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/perdida\"));\n  Retornar Exito(respuesta.Estado());\nFinSubProceso\n\nAlgoritmo Estado\n  Segun VerEstado() Hacer\n    Exito(estado): Escribir \"Estado: \", estado;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SeeStatus() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/perdida\"));\n  Return Success(response.status());\nEndSubroutine\n\nAlgorithm Status\n  Switch SeeStatus() Do\n    Success(status): Write \"Estado: \", status;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/perdida": {
        "estado": 404
      }
    }
  }
}
```

```caso
{
  "id": "C40",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "OK 200\nError 404\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Revisar(red Como RedCap, direccion Como Cadena)\n  Segun red.Enviar(PeticionHttp(MetodoHttp.GET, direccion)) Hacer\n    Exito(respuesta):\n      Si respuesta.EsExito() Entonces\n        Escribir \"OK \", respuesta.Estado();\n      Sino\n        Escribir \"Error \", respuesta.Estado();\n      FinSi\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nSubProceso Probar() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Revisar(red, \"https://fake.test/inicio\");\n  Revisar(red, \"https://fake.test/perdida\");\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Respuestas\n  Descartar Probar();\nFinAlgoritmo\n",
    "en": "Subroutine Check(network As NetworkCap, address As String)\n  Switch network.send(HttpRequest(HttpMethod.GET, address)) Do\n    Success(response):\n      If response.isSuccess() Then\n        Write \"OK \", response.status();\n      Else\n        Write \"Error \", response.status();\n      EndIf\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nSubroutine Try() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Check(network, \"https://fake.test/inicio\");\n  Check(network, \"https://fake.test/perdida\");\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Responses\n  Discard Try();\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/inicio": {
        "estado": 200
      },
      "GET https://fake.test/perdida": {
        "estado": 404
      }
    }
  }
}
```

```caso
{
  "id": "C41",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "text/plain\n-\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso VerCabeceras() Como Resultado<Entero, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/nota\"));\n  Segun respuesta.Cabecera(\"Content-Type\") Hacer\n    Algo(tipo): Escribir tipo;\n    Nada: Escribir \"-\";\n  FinSegun\n  Segun respuesta.Cabecera(\"x-autor\") Hacer\n    Algo(autor): Escribir autor;\n    Nada: Escribir \"-\";\n  FinSegun\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Cabeceras\n  Descartar VerCabeceras();\nFinAlgoritmo\n",
    "en": "Subroutine SeeHeaders() As Result<Integer, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/nota\"));\n  Switch response.header(\"Content-Type\") Do\n    Some(kind): Write kind;\n    None: Write \"-\";\n  EndSwitch\n  Switch response.header(\"x-autor\") Do\n    Some(author): Write author;\n    None: Write \"-\";\n  EndSwitch\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Headers\n  Discard SeeHeaders();\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/nota": {
        "estado": 200,
        "cabeceras": [
          [
            "content-type",
            "text/plain"
          ]
        ],
        "cuerpo": "hola"
      }
    }
  }
}
```

```caso
{
  "id": "C42",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "content-type\nx-autor\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso ListarCabeceras() Como Resultado<Vector<Cadena>, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/nota\"));\n  Retornar Exito(respuesta.NombresCabeceras());\nFinSubProceso\n\nAlgoritmo NombresDeCabeceras\n  Segun ListarCabeceras() Hacer\n    Exito(nombres):\n      Para Cada nombre En nombres Hacer\n        Escribir nombre;\n      FinPara\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ListHeaders() As Result<Vector<String>, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/nota\"));\n  Return Success(response.headerNames());\nEndSubroutine\n\nAlgorithm HeaderNames\n  Switch ListHeaders() Do\n    Success(names):\n      For Each name In names Do\n        Write name;\n      EndFor\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/nota": {
        "estado": 200,
        "cabeceras": [
          [
            "Content-Type",
            "text/plain"
          ],
          [
            "X-Autor",
            "Ana"
          ]
        ]
      }
    }
  }
}
```

```caso
{
  "id": "C43",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Total: 4\n137\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso DescargarImagen() Como Resultado<Bytes, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/icono\"));\n  Retornar Exito(respuesta.Cuerpo());\nFinSubProceso\n\nAlgoritmo Imagen\n  Segun DescargarImagen() Hacer\n    Exito(datos):\n      Escribir \"Total: \", datos.Longitud();\n      Escribir datos.En(0);\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine DownloadImage() As Result<Bytes, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/icono\"));\n  Return Success(response.body());\nEndSubroutine\n\nAlgorithm Picture\n  Switch DownloadImage() Do\n    Success(data):\n      Write \"Total: \", data.length();\n      Write data.at(0);\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/icono": {
        "estado": 200,
        "cuerpo_bytes": [
          137,
          80,
          78,
          71
        ]
      }
    }
  }
}
```

```caso
{
  "id": "C44",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "¡Buenos días!\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso LeerFrase() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/frase\"));\n  Retornar respuesta.CuerpoTexto();\nFinSubProceso\n\nAlgoritmo Frase\n  Segun LeerFrase() Hacer\n    Exito(texto): Escribir texto;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ReadPhrase() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/frase\"));\n  Return response.textBody();\nEndSubroutine\n\nAlgorithm Phrase\n  Switch ReadPhrase() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/frase": {
        "estado": 200,
        "cuerpo": "¡Buenos días!"
      }
    }
  }
}
```

```caso
{
  "id": "C45",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "https://fake.test/inicio\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso VerDireccion() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/inicio#arriba\"));\n  Retornar Exito(respuesta.Url());\nFinSubProceso\n\nAlgoritmo Direccion\n  Segun VerDireccion() Hacer\n    Exito(direccion): Escribir direccion;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SeeAddress() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define response As HttpResponse <- Propagate network.send(HttpRequest(HttpMethod.GET, \"https://fake.test/inicio#arriba\"));\n  Return Success(response.url());\nEndSubroutine\n\nAlgorithm Address\n  Switch SeeAddress() Do\n    Success(address): Write address;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/inicio": {
        "estado": 200
      }
    }
  }
}
```

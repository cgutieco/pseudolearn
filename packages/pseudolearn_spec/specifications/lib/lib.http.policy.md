---
{
  "formato": "see/1",
  "id": "LIB.HTTP.POLICY",
  "titulo": "Política de seguridad HTTP",
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
  "resumen": "Reglas de destinos, redirecciones y garantías de los adaptadores HTTP.",
  "titulo_en": "HTTP security policy",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LIB.HTTP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LIB.IO",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "ENG.EFFECT.TAPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Política de seguridad HTTP

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un destino HTTP usa esquema http o https, un host ASCII válido y el puerto efectivo. Se admite cualquier destino, incluido loopback, direcciones privadas y http público. El fragmento nunca se envía. Se rechazan hosts con credenciales y formas numéricas alternativas de IPv4, incluidas una sola cifra decimal, hexadecimal, octal y direcciones decimales con menos o más de cuatro componentes.",
  "verificacion": [
    "C1",
    "C9"
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
    "salida": "url_invalida\nurl_invalida\nurl_invalida\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://2130706433/a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://0x7f000001/a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://0177.0.0.1/a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://2130706433/a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://0x7f000001/a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://0177.0.0.1/a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/grant": {
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
    "salida": "200\n201\n202\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"http://127.0.0.1:8080/a\")) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"http://192.168.0.5/a\")) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"http://plain.test/a\")) Hacer\nExito(response): Escribir response.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"http://127.0.0.1:8080/a\")) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nswitch net.send(HttpRequest(HttpMethod.GET, \"http://192.168.0.5/a\")) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nswitch net.send(HttpRequest(HttpMethod.GET, \"http://plain.test/a\")) do\nsuccess(response): write response.status();\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET http://127.0.0.1:8080/a": {
        "estado": 200
      },
      "GET http://192.168.0.5/a": {
        "estado": 201
      },
      "GET http://plain.test/a": {
        "estado": 202
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
  "texto": "Los adaptadores nativos no siguen redirecciones, no añaden ni persisten cookies ni consultan proxies ambientales o del sistema y siempre validan certificados TLS. El navegador sigue sus restricciones de plataforma y puede seguir redirecciones, devolviendo la URL final; los límites de plataforma se devuelven como ErrorES tipados con su causa. Solo el anfitrión puede añadir raíces de confianza de prueba; el programa no puede desactivar TLS.",
  "verificacion": [
    "C6",
    "revision_humana"
  ],
  "justificacion": "Los casos derivados verifican el contrato; las pruebas de transporte comprueban las diferencias físicas de plataforma."
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "302\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/start\").ConCabecera(\"Authorization\", \"demo\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nEscribir response.Estado();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value):\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/start\").withHeader(\"Authorization\", \"demo\");\ndefine response as HttpResponse <- propagate net.send(request);\nwrite response.status();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value):\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/start": {
        "estado": 302,
        "cabeceras": [
          [
            "location",
            "/next"
          ]
        ]
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
  "texto": "Redirigida acepta solo 301, 302, 303, 307 y 308, y exactamente una cabecera location. Resuelve location contra RespuestaHttp.Url y elimina el fragmento. Rechaza la falta o repetición de location con RedireccionDenegada y permite descender de https a http. Un 303, o un 301/302 sobre POST, produce GET sin cuerpo; 307/308 conservan método y cuerpo. Al cambiar el origen retira authorization, proxy-authorization, cookie, set-cookie y nombres token, key, secret o terminados en -token, -key o -secret sin distinguir mayúsculas ASCII. No envía; Enviar comprueba únicamente la atenuación voluntaria de la capacidad.",
  "verificacion": [
    "C2",
    "C3",
    "C4",
    "C5",
    "C8",
    "C10",
    "revision_humana"
  ],
  "justificacion": "Los casos derivados verifican el contrato; las pruebas de transporte comprueban las diferencias físicas de plataforma."
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "chain\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 5
    }
  },
  "programas": {
    "es": "SubProceso Follow(net Como RedCap) Como Resultado<Cadena, ErrorES>\nDefinir first_request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a/start\");\nDefinir first_response Como RespuestaHttp <- Propagar net.Enviar(first_request);\nDefinir second_request Como PeticionHttp <- Propagar first_request.Redirigida(first_response);\nDefinir second_response Como RespuestaHttp <- Propagar net.Enviar(second_request);\nDefinir third_request Como PeticionHttp <- Propagar second_request.Redirigida(second_response);\nDefinir third_response Como RespuestaHttp <- Propagar net.Enviar(third_request);\nDefinir fourth_request Como PeticionHttp <- Propagar third_request.Redirigida(third_response);\nDefinir fourth_response Como RespuestaHttp <- Propagar net.Enviar(fourth_request);\nRetornar fourth_response.CuerpoTexto();\nFinSubProceso\nSubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nRetornar Follow(net);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Follow(net as NetworkCap) as result<string, IoError>\ndefine first_request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a/start\");\ndefine first_response as HttpResponse <- propagate net.send(first_request);\ndefine second_request as HttpRequest <- propagate first_request.redirected(first_response);\ndefine second_response as HttpResponse <- propagate net.send(second_request);\ndefine third_request as HttpRequest <- propagate second_request.redirected(second_response);\ndefine third_response as HttpResponse <- propagate net.send(third_request);\ndefine fourth_request as HttpRequest <- propagate third_request.redirected(third_response);\ndefine fourth_response as HttpResponse <- propagate net.send(fourth_request);\nreturn fourth_response.textBody();\nendSubroutine\nsubroutine Probe() as result<string, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nreturn Follow(net);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/a/start": {
        "estado": 302,
        "cabeceras": [
          [
            "location",
            "../b"
          ]
        ]
      },
      "GET https://fake.test/b": {
        "estado": 301,
        "cabeceras": [
          [
            "location",
            "/c"
          ]
        ]
      },
      "GET https://fake.test/c": {
        "estado": 308,
        "cabeceras": [
          [
            "location",
            "../done"
          ]
        ]
      },
      "GET https://fake.test/done": {
        "estado": 200,
        "cuerpo": "chain"
      }
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "303\n307\n308\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request303 Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/submit303\").ConCuerpoTexto(\"discard\");\nDefinir response303 Como RespuestaHttp <- Propagar net.Enviar(request303);\nDefinir redirected303 Como PeticionHttp <- Propagar request303.Redirigida(response303);\nDefinir result303 Como RespuestaHttp <- Propagar net.Enviar(redirected303);\nEscribir Propagar result303.CuerpoTexto();\nDefinir request307 Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/submit307\").ConCuerpoTexto(\"keep\");\nDefinir response307 Como RespuestaHttp <- Propagar net.Enviar(request307);\nDefinir redirected307 Como PeticionHttp <- Propagar request307.Redirigida(response307);\nDefinir result307 Como RespuestaHttp <- Propagar net.Enviar(redirected307);\nEscribir Propagar result307.CuerpoTexto();\nDefinir request308 Como PeticionHttp <- PeticionHttp(MetodoHttp.POST, \"https://fake.test/submit308\").ConCuerpoTexto(\"keep\");\nDefinir response308 Como RespuestaHttp <- Propagar net.Enviar(request308);\nDefinir redirected308 Como PeticionHttp <- Propagar request308.Redirigida(response308);\nDefinir result308 Como RespuestaHttp <- Propagar net.Enviar(redirected308);\nEscribir Propagar result308.CuerpoTexto();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request303 as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/submit303\").withTextBody(\"discard\");\ndefine response303 as HttpResponse <- propagate net.send(request303);\ndefine redirected303 as HttpRequest <- propagate request303.redirected(response303);\ndefine result303 as HttpResponse <- propagate net.send(redirected303);\nwrite propagate result303.textBody();\ndefine request307 as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/submit307\").withTextBody(\"keep\");\ndefine response307 as HttpResponse <- propagate net.send(request307);\ndefine redirected307 as HttpRequest <- propagate request307.redirected(response307);\ndefine result307 as HttpResponse <- propagate net.send(redirected307);\nwrite propagate result307.textBody();\ndefine request308 as HttpRequest <- HttpRequest(HttpMethod.POST, \"https://fake.test/submit308\").withTextBody(\"keep\");\ndefine response308 as HttpResponse <- propagate net.send(request308);\ndefine redirected308 as HttpRequest <- propagate request308.redirected(response308);\ndefine result308 as HttpResponse <- propagate net.send(redirected308);\nwrite propagate result308.textBody();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "POST https://fake.test/submit303": {
        "estado": 303,
        "cabeceras": [
          [
            "location",
            "/done303"
          ]
        ]
      },
      "GET https://fake.test/done303": {
        "estado": 200,
        "cuerpo": "303"
      },
      "POST https://fake.test/submit307": {
        "estado": 307,
        "cabeceras": [
          [
            "location",
            "/done307"
          ]
        ]
      },
      "POST https://fake.test/done307": {
        "estado": 200,
        "cuerpo": "307"
      },
      "POST https://fake.test/submit308": {
        "estado": 308,
        "cabeceras": [
          [
            "location",
            "/done308"
          ]
        ]
      },
      "POST https://fake.test/done308": {
        "estado": 200,
        "cuerpo": "308"
      }
    }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "redireccion_denegada\nredireccion_denegada\naccepted\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso RedirectCode(request Como PeticionHttp, response Como RespuestaHttp) Como Cadena\n  Segun request.Redirigida(response) Hacer\n    Exito(next): Retornar \"accepted\";\n    Error(problem): Retornar problem.Codigo;\n  FinSegun\nFinSubProceso\n\nSubProceso Probe() Como Resultado<Entero, ErrorES>\n  Definir net Como RedCap <- Propagar SolicitarRed();\n  Definir unsupportedRequest Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/unsupported\");\n  Definir unsupportedResponse Como RespuestaHttp <- Propagar net.Enviar(unsupportedRequest);\n  Escribir RedirectCode(unsupportedRequest, unsupportedResponse);\n  Definir missingRequest Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/missing\");\n  Definir missingResponse Como RespuestaHttp <- Propagar net.Enviar(missingRequest);\n  Escribir RedirectCode(missingRequest, missingResponse);\n  Definir downgradeRequest Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/downgrade\");\n  Definir downgradeResponse Como RespuestaHttp <- Propagar net.Enviar(downgradeRequest);\n  Escribir RedirectCode(downgradeRequest, downgradeResponse);\n  Retornar Exito(0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito(value): Escribir value;\n    Error(problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine RedirectCode(request As HttpRequest, response As HttpResponse) As String\n  Switch request.redirected(response) Do\n    Success(next): Return \"accepted\";\n    Failure(problem): Return problem.code;\n  EndSwitch\nEndSubroutine\n\nSubroutine Probe() As Result<Integer, IoError>\n  Define net As NetworkCap <- Propagate requestNetwork();\n  Define unsupportedRequest As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/unsupported\");\n  Define unsupportedResponse As HttpResponse <- Propagate net.send(unsupportedRequest);\n  Write RedirectCode(unsupportedRequest, unsupportedResponse);\n  Define missingRequest As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/missing\");\n  Define missingResponse As HttpResponse <- Propagate net.send(missingRequest);\n  Write RedirectCode(missingRequest, missingResponse);\n  Define downgradeRequest As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/downgrade\");\n  Define downgradeResponse As HttpResponse <- Propagate net.send(downgradeRequest);\n  Write RedirectCode(downgradeRequest, downgradeResponse);\n  Return Success(0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success(value): Write value;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/unsupported": {
        "estado": 304,
        "cabeceras": [
          [
            "location",
            "/next"
          ]
        ]
      },
      "GET https://fake.test/missing": {
        "estado": 302
      },
      "GET https://fake.test/downgrade": {
        "estado": 302,
        "cabeceras": [
          [
            "location",
            "http://fake.test/insecure"
          ]
        ]
      }
    }
  }
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
    "salida": "200\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/start\").ConCabecera(\"Authorization\", \"demo\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nDefinir redirected Como PeticionHttp <- Propagar request.Redirigida(response);\nSegun net.Enviar(redirected) Hacer\nExito(finalResponse): Escribir finalResponse.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value):\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/start\").withHeader(\"Authorization\", \"demo\");\ndefine response as HttpResponse <- propagate net.send(request);\ndefine redirected as HttpRequest <- propagate request.redirected(response);\nswitch net.send(redirected) do\nsuccess(finalResponse): write finalResponse.status();\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value):\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/start": {
        "estado": 302,
        "cabeceras": [
          [
            "location",
            "https://other.test/next"
          ]
        ]
      },
      "GET https://other.test/next": {
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
  "texto": "El adaptador nativo resuelve un nombre una sola vez y conecta solo a una dirección de esa respuesta. No aplica política SSRF ni filtra rangos de direcciones. Un host con forma numérica IPv4 alternativa es UrlInvalida. Los errores del sistema se informan como ErrorES de plataforma.",
  "verificacion": [
    "C1",
    "C7",
    "revision_humana"
  ],
  "justificacion": "Los casos derivados verifican el contrato; las pruebas de transporte comprueban las diferencias físicas de plataforma."
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "url_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://2130706433./a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value):\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://2130706433./a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value):\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/grant": {
        "estado": 200
      }
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "redireccion_denegada\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/duplicate\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nSegun request.Redirigida(response) Hacer\nExito(next): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value):\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/duplicate\");\ndefine response as HttpResponse <- propagate net.send(request);\nswitch request.redirected(response) do\nsuccess(next): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value):\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/duplicate": {
        "estado": 302,
        "cabeceras": [
          [
            "location",
            "/first"
          ],
          [
            "location",
            "/second"
          ]
        ]
      }
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "301\nhttps://fake.test/nuevo\nPágina nueva\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso SeguirMudanza() Como Resultado<Cadena, ErrorES>\n  Definir red Como RedCap <- Propagar SolicitarRed();\n  Definir primera Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/viejo\");\n  Definir aviso Como RespuestaHttp <- Propagar red.Enviar(primera);\n  Escribir aviso.Estado();\n  Definir segunda Como PeticionHttp <- Propagar primera.Redirigida(aviso);\n  Definir respuesta Como RespuestaHttp <- Propagar red.Enviar(segunda);\n  Escribir respuesta.Url();\n  Retornar respuesta.CuerpoTexto();\nFinSubProceso\n\nAlgoritmo Mudanza\n  Segun SeguirMudanza() Hacer\n    Exito(texto): Escribir texto;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine FollowMove() As Result<String, IoError>\n  Define network As NetworkCap <- Propagate requestNetwork();\n  Define first As HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/viejo\");\n  Define notice As HttpResponse <- Propagate network.send(first);\n  Write notice.status();\n  Define second As HttpRequest <- Propagate first.redirected(notice);\n  Define response As HttpResponse <- Propagate network.send(second);\n  Write response.url();\n  Return response.textBody();\nEndSubroutine\n\nAlgorithm Move\n  Switch FollowMove() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/viejo": {
        "estado": 301,
        "cabeceras": [
          [
            "location",
            "/nuevo"
          ]
        ]
      },
      "GET https://fake.test/nuevo": {
        "estado": 200,
        "cuerpo": "Página nueva"
      }
    }
  }
}
```

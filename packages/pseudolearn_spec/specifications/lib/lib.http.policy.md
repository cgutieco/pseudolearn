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
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Reglas de destinos, redirecciones y garantías de los adaptadores HTTP.",
  "titulo_en": "HTTP security policy",
  "edicion": {
    "introducida_en": "2026"
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
  "texto": "Un destino HTTP usa esquema http o https, un host ASCII válido y el puerto efectivo. http solo es válido para un origen local concedido expresamente para pruebas. El fragmento nunca se envía. Se rechazan hosts con credenciales y formas numéricas alternativas de IPv4, incluidas una sola cifra decimal, hexadecimal, octal y direcciones decimales con menos o más de cuatro componentes.",
  "verificacion": ["C1"]
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
  "espera": {
    "salida": "url_invalida\nurl_invalida\nurl_invalida\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://2130706433/a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://0x7f000001/a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://0177.0.0.1/a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://2130706433/a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://0x7f000001/a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://0177.0.0.1/a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/grant": {"estado": 200}
    }
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los adaptadores HTTP que realizan solicitudes reales no siguen redirecciones, no añaden cookies, no consultan variables ni configuración ambiental de proxy y siempre validan certificados TLS. Solo la configuración del anfitrión puede añadir raíces de confianza de prueba; el programa no puede desactivar la validación TLS.",
  "verificacion": ["C6", "revision_humana"],
  "justificacion": "C6 verifica que una respuesta 3xx llega al programa sin un segundo envío. Las pruebas de política de la CLI comprueban que el contexto solo admite raíces explícitas del anfitrión y que los rangos privados se filtran antes del transporte; la comprobación de certificados y proxies reales pertenece a la batería de red excluida de esta iteración."
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "302\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 1}
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/start\").ConCabecera(\"Authorization\", \"demo\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nEscribir response.Estado();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/start\").withHeader(\"Authorization\", \"demo\");\ndefine response as HttpResponse <- propagate net.send(request);\nwrite response.status();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/start": {
        "estado": 302,
        "cabeceras": [["location", "/next"]]
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
  "texto": "Redirigida acepta solo 301, 302, 303, 307 y 308, y exactamente una cabecera location. Resuelve location contra RespuestaHttp.Url y elimina el fragmento. Rechaza la falta o repetición de location y el descenso de https a http con RedireccionDenegada. Un 303, o un 301/302 sobre POST, produce GET sin cuerpo; 307/308 conservan método y cuerpo. Al cambiar el origen retira authorization, proxy-authorization, cookie, set-cookie y nombres de cabecera que sean token, key o secret o terminen en -token, -key o -secret, sin distinguir mayúsculas ASCII. Redirigida no comprueba permisos ni envía; Enviar valida el origen nuevo.",
  "verificacion": ["C2", "C3", "C4", "C5", "C8", "revision_humana"],
  "justificacion": "Los tests de redirección inspeccionan la nueva petición para cubrir la retención de credenciales en el mismo origen y su retirada al cambiarlo; los casos del anfitrión falso cubren la cadena explícita, el rechazo de downgrade y la nueva validación de permiso al enviar."
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "chain\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 4}
  },
  "programas": {
    "es": "SubProceso Follow(net Como RedCap) Como Resultado<Cadena, ErrorES>\nDefinir first_request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a/start\");\nDefinir first_response Como RespuestaHttp <- Propagar net.Enviar(first_request);\nDefinir second_request Como PeticionHttp <- Propagar first_request.Redirigida(first_response);\nDefinir second_response Como RespuestaHttp <- Propagar net.Enviar(second_request);\nDefinir third_request Como PeticionHttp <- Propagar second_request.Redirigida(second_response);\nDefinir third_response Como RespuestaHttp <- Propagar net.Enviar(third_request);\nDefinir fourth_request Como PeticionHttp <- Propagar third_request.Redirigida(third_response);\nDefinir fourth_response Como RespuestaHttp <- Propagar net.Enviar(fourth_request);\nRetornar fourth_response.CuerpoTexto();\nFinSubProceso\nSubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nRetornar Follow(net);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Follow(net as NetworkCap) as result<string, IoError>\ndefine first_request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a/start\");\ndefine first_response as HttpResponse <- propagate net.send(first_request);\ndefine second_request as HttpRequest <- propagate first_request.redirected(first_response);\ndefine second_response as HttpResponse <- propagate net.send(second_request);\ndefine third_request as HttpRequest <- propagate second_request.redirected(second_response);\ndefine third_response as HttpResponse <- propagate net.send(third_request);\ndefine fourth_request as HttpRequest <- propagate third_request.redirected(third_response);\ndefine fourth_response as HttpResponse <- propagate net.send(fourth_request);\nreturn fourth_response.textBody();\nendSubroutine\nsubroutine Probe() as result<string, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nreturn Follow(net);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/a/start": {"estado": 302, "cabeceras": [["location", "../b"]]},
      "GET https://fake.test/b": {"estado": 301, "cabeceras": [["location", "/c"]]},
      "GET https://fake.test/c": {"estado": 308, "cabeceras": [["location", "../done"]]},
      "GET https://fake.test/done": {"estado": 200, "cuerpo": "chain"}
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
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
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "POST https://fake.test/submit303": {"estado": 303, "cabeceras": [["location", "/done303"]]},
      "GET https://fake.test/done303": {"estado": 200, "cuerpo": "303"},
      "POST https://fake.test/submit307": {"estado": 307, "cabeceras": [["location", "/done307"]]},
      "POST https://fake.test/done307": {"estado": 200, "cuerpo": "307"},
      "POST https://fake.test/submit308": {"estado": 308, "cabeceras": [["location", "/done308"]]},
      "POST https://fake.test/done308": {"estado": 200, "cuerpo": "308"}
    }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "redireccion_denegada\nredireccion_denegada\nredireccion_denegada\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso RedirectCode(request Como PeticionHttp, response Como RespuestaHttp) Como Cadena\nSegun request.Redirigida(response) Hacer\nExito(next): Retornar \"accepted\";\nError(problem): Retornar problem.Codigo;\nFinSegun\nFinSubProceso\nSubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir unsupportedRequest Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/unsupported\");\nDefinir unsupportedResponse Como RespuestaHttp <- Propagar net.Enviar(unsupportedRequest);\nEscribir RedirectCode(unsupportedRequest, unsupportedResponse);\nDefinir missingRequest Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/missing\");\nDefinir missingResponse Como RespuestaHttp <- Propagar net.Enviar(missingRequest);\nEscribir RedirectCode(missingRequest, missingResponse);\nDefinir downgradeRequest Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/downgrade\");\nDefinir downgradeResponse Como RespuestaHttp <- Propagar net.Enviar(downgradeRequest);\nEscribir RedirectCode(downgradeRequest, downgradeResponse);\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine RedirectCode(request as HttpRequest, response as HttpResponse) as string\nswitch request.redirected(response) do\nsuccess(next): return \"accepted\";\nfailure(problem): return problem.code;\nendSwitch\nendSubroutine\nsubroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine unsupportedRequest as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/unsupported\");\ndefine unsupportedResponse as HttpResponse <- propagate net.send(unsupportedRequest);\nwrite RedirectCode(unsupportedRequest, unsupportedResponse);\ndefine missingRequest as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/missing\");\ndefine missingResponse as HttpResponse <- propagate net.send(missingRequest);\nwrite RedirectCode(missingRequest, missingResponse);\ndefine downgradeRequest as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/downgrade\");\ndefine downgradeResponse as HttpResponse <- propagate net.send(downgradeRequest);\nwrite RedirectCode(downgradeRequest, downgradeResponse);\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/unsupported": {"estado": 304, "cabeceras": [["location", "/next"]]},
      "GET https://fake.test/missing": {"estado": 302},
      "GET https://fake.test/downgrade": {"estado": 302, "cabeceras": [["location", "http://fake.test/insecure"]]}
    }
  }
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
  "espera": {
    "salida": "destino_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/start\").ConCabecera(\"Authorization\", \"demo\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nDefinir redirected Como PeticionHttp <- Propagar request.Redirigida(response);\nSegun net.Enviar(redirected) Hacer\nExito(finalResponse): Escribir finalResponse.Estado();\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/start\").withHeader(\"Authorization\", \"demo\");\ndefine response as HttpResponse <- propagate net.send(request);\ndefine redirected as HttpRequest <- propagate request.redirected(response);\nswitch net.send(redirected) do\nsuccess(finalResponse): write finalResponse.status();\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/start": {"estado": 302, "cabeceras": [["location", "https://other.test/next"]]}
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El adaptador nativo resuelve un nombre una sola vez, comprueba todas las direcciones de esa respuesta y solo permite conectar a una dirección de ese mismo conjunto comprobado. Deniega loopback, privadas RFC 1918, enlace local, únicas locales, multidifusión, no especificadas y direcciones IPv4 mapeadas en IPv6 que pertenezcan a esos rangos; una concesión local de prueba solo admite direcciones loopback. Un nombre con forma numérica IPv4 alternativa es UrlInvalida.",
  "verificacion": ["C1", "revision_humana"],
  "justificacion": "C1 verifica el rechazo observable de las formas numéricas alternativas. network_address_policy_tests.rs y network_resolver_tests.rs cubren los rangos, la comprobación del conjunto completo y una sola resolución; la conexión real fijada a una IP se verifica en la batería de red excluida de esta iteración."
}
```

```caso
{
  "id": "C7",
  "regla": "R4",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "url_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://2130706433./a\")) Hacer\nExito(response): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://2130706433./a\")) do\nsuccess(response): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/grant": {"estado": 200}
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R3",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "redireccion_denegada\n",
    "terminacion": "completed",
    "anfitrion_observado": {"llamadas": 1}
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/duplicate\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nSegun request.Redirigida(response) Hacer\nExito(next): Escribir \"accepted\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/duplicate\");\ndefine response as HttpResponse <- propagate net.send(request);\nswitch request.redirected(response) do\nsuccess(next): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {
      "GET https://fake.test/duplicate": {
        "estado": 302,
        "cabeceras": [["location", "/first"], ["location", "/second"]]
      }
    }
  }
}
```

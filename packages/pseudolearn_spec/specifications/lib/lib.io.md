---
{
  "formato": "see/1",
  "id": "LIB.IO",
  "titulo": "Tipos y operaciones de entrada y salida",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Tipo Bytes, variantes portables de ErrorES, separación estricta texto/binario y limpieza con Diferir.",
  "titulo_en": "Input and output types and operations",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.CONTROL.CLEANUP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Tipos y operaciones de entrada y salida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El tipo incorporado Bytes representa una secuencia contigua y gestionada de octetos en el montón. Proporciona longitud y acceso posicional seguro impidiendo corrupciones de memoria.",
  "verificacion": [
    "C1",
    "C15",
    "C16",
    "C17"
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
    "salida": "3\n255\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Bytes, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerBytes();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value.Longitud(); Escribir value.En(1);\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<Bytes, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readBytes();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value.length(); write value.at(1);\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        0,
        255,
        128
      ]
    },
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El tipo ErrorES modela de manera portable los errores de entrada y salida con variantes para NoEncontrado, PermisoDenegado, YaExiste, FinDeArchivo, Utf8Invalido, RutaInvalida, CapacidadCerrada, TiempoAgotado, Interrumpido, UrlInvalida, PeticionInvalida, DestinoDenegado, ConexionFallida, CertificadoInvalido, RespuestaInvalida, LimiteExcedido y RedireccionDenegada, junto a una bandera booleana incierto para indicar incertidumbre sobre si la mutación externa llegó a confirmarse.",
  "verificacion": [
    "C2",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C18"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Bytes, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerBytes();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value.Longitud(); Escribir value.En(1);\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<Bytes, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readBytes();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value.length(); write value.at(1);\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        0,
        255,
        128
      ]
    },
    "faults": [
      {
        "operation": "request_directory",
        "code": "permiso_denegado"
      }
    ]
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones de lectura y escritura textual sobre capacidades exigen validación UTF-8 estricta. Todo contenido no conforme con UTF-8 produce ErrorES::Utf8Invalido sin sustitución silenciosa de bytes inválidos. Las capacidades iniciales de directorio aceptan rutas del sistema absolutas o relativas a la carpeta de trabajo, incluidos componentes ..; Subdirectorio es la atenuación voluntaria que confina rutas y derechos sin amplificación. PermisoDenegado sin atenuación solo procede de la plataforma.",
  "verificacion": [
    "C3",
    "C19",
    "C20",
    "C21"
  ]
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
    "salida": "utf8_invalido\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        255
      ]
    }
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La sentencia Diferir ejecuta la limpieza léxica al salir del ámbito, retornar o propagar errores con Propagar. Si ocurre un fallo en la operación primaria, la limpieza se ejecuta y preserva el ErrorES primario intacto sin ocultarlo.",
  "verificacion": [
    "C4",
    "C5",
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\nreturn file.readText();\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    }
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "utf8_invalido\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir text Como Cadena <- Propagar file.LeerTexto();\nRetornar Exito(text);\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\ndefine text as string <- propagate file.readText();\nreturn success(text);\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        255
      ]
    }
  }
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
    "salida": "utf8_invalido\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir text Como Cadena <- Propagar file.LeerTexto();\nRetornar Exito(text);\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\ndefine text as string <- propagate file.readText();\nreturn success(text);\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        255
      ]
    },
    "faults": [
      {
        "operation": "file_close",
        "code": "interrumpido"
      }
    ]
  }
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
    "salida": "salida\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 7
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nPara index <- 1 Hasta 3 Con Paso 1 Hacer\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nDefinir text Como Cadena <- Propagar file.LeerTexto();\nSi index = 2 Entonces\nSalir;\nFinSi\nFinPara\nRetornar Exito(\"salida\");\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\nfor index <- 1 to 3 with step 1 do\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\ndefine text as string <- propagate file.readText();\nif index = 2 then\nbreak;\nendIf\nendFor\nreturn success(\"salida\");\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "no_encontrado\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"missing\", \"lectura\");\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"missing\", \"read\");\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    }
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"\", \"lectura\");\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"\", \"read\");\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "capacidad_cerrada\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDescartar file.Cerrar();\nDefinir content Como Bytes <- Propagar file.LeerBytes();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndiscard file.close();\ndefine content as Bytes <- propagate file.readBytes();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    }
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ya_existe\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    },
    "faults": [
      {
        "operation": "file_open",
        "code": "ya_existe"
      }
    ]
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "interrumpido\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir content Como Bytes <- Propagar file.LeerBytes();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine content as Bytes <- propagate file.readBytes();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    },
    "faults": [
      {
        "operation": "file_read_bytes",
        "code": "interrumpido"
      }
    ]
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "tiempo_agotado\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nRetornar timer.Esperar(-5);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine timer as Timer <- propagate requestTimer();\nreturn timer.wait(-5);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C14",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "fin_de_archivo\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": []
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n0\n255\n128\n3\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 7,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir content Como Bytes <- Propagar file.LeerBytes();\nDefinir out Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"escritura\");\nDefinir written Como Entero <- Propagar out.EscribirBytes(content);\nDefinir back Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nDefinir again Como Bytes <- Propagar back.LeerBytes();\nEscribir again.Longitud();\nEscribir again.En(0);\nEscribir again.En(1);\nEscribir again.En(2);\nRetornar Exito(written);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine content as Bytes <- propagate file.readBytes();\ndefine out as FileCap <- propagate directory.open(\"b\", \"write\");\ndefine written as integer <- propagate out.writeBytes(content);\ndefine back as FileCap <- propagate directory.open(\"b\", \"read\");\ndefine again as Bytes <- propagate back.readBytes();\nwrite again.length();\nwrite again.at(0);\nwrite again.at(1);\nwrite again.at(2);\nreturn success(written);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        0,
        255,
        128
      ]
    }
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir content Como Bytes <- Propagar file.LeerBytes();\nEscribir content.En(3);\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine content as Bytes <- propagate file.readBytes();\nwrite content.at(3);\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": [
        0,
        255,
        128
      ]
    }
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n0\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"e\", \"lectura\");\nDefinir content Como Bytes <- Propagar file.LeerBytes();\nEscribir content.Longitud();\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"e\", \"read\");\ndefine content as Bytes <- propagate file.readBytes();\nwrite content.length();\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "e": ""
    }
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/limited\").ConLimiteRespuesta(1)) Hacer\nExito(response): Retornar Exito(0);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir \"aceptada\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/limited\").withResponseLimit(1)) do\nsuccess(response): return success(0);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "espera": {
    "salida": "limite_excedido\n",
    "terminacion": "completed"
  },
  "anfitrion": {
    "http": {
      "GET https://fake.test/limited": {
        "estado": 200,
        "cuerpo": "xy"
      }
    }
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"/absolute/a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"/absolute/a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\nreturn file.readText();\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "/absolute/a": "hola"
    }
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"../a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"../a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\nreturn file.readText();\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "../a": "hola"
    }
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4
    }
  },
  "programas": {
    "es": "SubProceso Leer1(directory Como DirectorioCap) Como Resultado<Cadena, ErrorES>\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"C:/work/a\", \"lectura\");\nDiferir\nDescartar file.Cerrar();\nFinDiferir\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nDefinir opened Como Resultado<DirectorioCap, ErrorES> <- SolicitarDirectorio(\"root\");\nSegun opened Hacer\nExito(root): Segun Leer1(root) Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Leer1(directory as DirCap) as result<string, IoError>\ndefine file as FileCap <- propagate directory.open(\"C:/work/a\", \"read\");\ndefer\ndiscard file.close();\nendDefer\nreturn file.readText();\nendSubroutine\nalgorithm Main\ndefine opened as result<DirCap, IoError> <- requestDirectory(\"root\");\nswitch opened do\nsuccess(root): switch Leer1(root) do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "C:/work/a": "hola"
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Directorio.Existe(ruta) devuelve Logico verdadero si la ruta designa un archivo o un directorio, y falso si no hay nada en ella; Directorio.EsDirectorio(ruta) devuelve verdadero solo si designa un directorio. Ambas son efectos falibles que exigen el derecho de lectura de la capacidad, resuelven la ruta como Abrir y devuelven falso, no un error, ante una ruta ausente.",
  "verificacion": [
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29"
  ]
}
```

```caso
{
  "id": "C22",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.exists(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.exists(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.exists(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "directories": [
      "d"
    ]
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
    "salida": "0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.exists(\"missing\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    },
    "grabar_y_reproducir": true
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
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.EsDirectorio(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.isDirectory(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
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
    "salida": "0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.EsDirectorio(\"d/a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.isDirectory(\"d/a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    }
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.EsDirectorio(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.isDirectory(\"missing\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.exists(\".\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Directorio.Listar(ruta) devuelve un Vector<Cadena> con los nombres, no las rutas, de las entradas inmediatas del directorio designado, sin . ni .., ordenados por puntos de código del nombre; el orden del sistema de archivos nunca es observable. Un directorio vacío produce un vector vacío, una ruta ausente produce NoEncontrado, una ruta que designa un archivo produce RutaInvalida y un nombre que no es UTF-8 válido produce Utf8Invalido.",
  "verificacion": [
    "C30",
    "C31",
    "C32",
    "C33",
    "C34",
    "C35",
    "C36"
  ]
}
```

```caso
{
  "id": "C30",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\"e\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.list(\"e\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "directories": [
      "e"
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3:a,b,s\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.list(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/b": "1",
      "d/a": "2",
      "d/s/x": "3"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4:B,a,b,á\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.list(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/b": "1",
      "d/a": "2",
      "d/B": "3",
      "d/á": "4"
    }
  }
}
```

```caso
{
  "id": "C33",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:a,d\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.list(\".\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "1",
      "d/x": "2"
    }
  }
}
```

```caso
{
  "id": "C34",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "no_encontrado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.list(\"missing\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "1"
    }
  }
}
```

```caso
{
  "id": "C35",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Listar(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.list(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "1"
    }
  }
}
```

```caso
{
  "id": "C36",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:a,b\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\nRetornar inner.Listar(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura\");\nreturn inner.list(\".\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "1",
      "d/b": "2",
      "x": "3"
    }
  }
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Directorio.Borrar(ruta) elimina un archivo o un directorio vacío y devuelve verdadero; nunca es recursivo. Una ruta ausente produce NoEncontrado, un directorio no vacío produce PeticionInvalida sin borrar nada y la capacidad raíz designada por . no puede borrarse (RutaInvalida). Exige el derecho de escritura.",
  "verificacion": [
    "C37",
    "C38",
    "C39",
    "C40",
    "C41"
  ]
}
```

```caso
{
  "id": "C37",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Borrar(\"a\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.delete(\"a\");\nreturn directory.exists(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C38",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Borrar(\"e\");\nRetornar directory.Existe(\"e\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.delete(\"e\");\nreturn directory.exists(\"e\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "directories": [
      "e"
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C39",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Borrar(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.delete(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C40",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "no_encontrado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Borrar(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.delete(\"missing\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C41",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Borrar(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.delete(\".\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    }
  }
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Directorio.Renombrar(origen, destino) mueve un archivo o un directorio y devuelve verdadero; nunca sobrescribe. Un origen ausente o un padre del destino ausente produce NoEncontrado, un destino existente produce YaExiste sin modificar nada y mover un directorio dentro de sí mismo produce RutaInvalida. Exige el derecho de escritura y ambas rutas se confinan igual. Comprobar y renombrar no es una operación atómica; cuando el sistema interrumpe una mutación que pudo confirmarse el error lleva incierto verdadero.",
  "verificacion": [
    "C42",
    "C43",
    "C44",
    "C45",
    "C46",
    "C47",
    "C48"
  ]
}
```

```caso
{
  "id": "C42",
  "regla": "R8",
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
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Renombrar(\"a\", \"b\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.rename(\"a\", \"b\");\ndefine file as FileCap <- propagate directory.open(\"b\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "hola"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C43",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Renombrar(\"a\", \"b\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.rename(\"a\", \"b\");\nreturn directory.exists(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    }
  }
}
```

```caso
{
  "id": "C44",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Renombrar(\"d\", \"n\");\nRetornar directory.Existe(\"n/a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.rename(\"d\", \"n\");\nreturn directory.exists(\"n/a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C45",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ya_existe\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"a\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.rename(\"a\", \"b\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x",
      "b": "y"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C46",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "no_encontrado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"missing\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.rename(\"missing\", \"b\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C47",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nDefinir step1 Como Logico <- Propagar inner.Renombrar(\"a\", \"b\");\nRetornar directory.Existe(\"d/b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura_escritura\");\ndefine step1 as boolean <- propagate inner.rename(\"a\", \"b\");\nreturn directory.exists(\"d/b\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    }
  }
}
```

```caso
{
  "id": "C48",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"d\", \"d/n\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.rename(\"d\", \"d/n\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    }
  }
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Directorio.CrearDirectorio(ruta) crea un único nivel de directorio y devuelve verdadero. Una ruta que ya designa un archivo o un directorio produce YaExiste y un padre ausente produce NoEncontrado; no se crean niveles intermedios. Exige el derecho de escritura.",
  "verificacion": [
    "C49",
    "C50",
    "C51",
    "C52",
    "C53"
  ]
}
```

```caso
{
  "id": "C49",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.CrearDirectorio(\"n\");\nRetornar directory.EsDirectorio(\"n\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.createDirectory(\"n\");\nreturn directory.isDirectory(\"n\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C50",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ya_existe\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.CrearDirectorio(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.createDirectory(\"d\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C51",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ya_existe\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.CrearDirectorio(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.createDirectory(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    }
  }
}
```

```caso
{
  "id": "C52",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "no_encontrado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.CrearDirectorio(\"p/n\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\nreturn directory.createDirectory(\"p/n\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C53",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1:n\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Vector<Cadena>, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.CrearDirectorio(\"n\");\nRetornar directory.Listar(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(names): Escribir names.Longitud(), \":\", Unir(names, \",\");\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<vector<string>, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine step1 as boolean <- propagate directory.createDirectory(\"n\");\nreturn directory.list(\".\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(names): write names.length(), \":\", join(names, \",\");\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "ArchivoCap.AgregarTexto(texto) y ArchivoCap.AgregarBytes(bytes) escriben al final del contenido actual del archivo, lo crean si el archivo ya no existe y devuelven el número de octetos escritos; AgregarTexto escribe el UTF-8 del texto sin transformarlo. Exigen el derecho de escritura de la capacidad de archivo y no modifican los modos de Abrir, por lo que abrir en escritura sigue vaciando el archivo.",
  "verificacion": [
    "C54",
    "C55",
    "C56",
    "C57",
    "C58",
    "C59"
  ]
}
```

```caso
{
  "id": "C54",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ab\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura_escritura\");\nDefinir step1 Como Entero <- Propagar file.AgregarTexto(\"a\");\nDefinir step2 Como Entero <- Propagar file.AgregarTexto(\"b\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"read_write\");\ndefine step1 as integer <- propagate file.appendText(\"a\");\ndefine step2 as integer <- propagate file.appendText(\"b\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C55",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "xy\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura_escritura\");\nDefinir step1 Como Entero <- Propagar file.EscribirTexto(\"x\");\nDefinir step2 Como Entero <- Propagar file.AgregarTexto(\"y\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"read_write\");\ndefine step1 as integer <- propagate file.writeText(\"x\");\ndefine step2 as integer <- propagate file.appendText(\"y\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C56",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura_escritura\");\nRetornar file.AgregarTexto(\"é\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"read_write\");\nreturn file.appendText(\"é\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C57",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "é\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura_escritura\");\nDefinir extra Como Bytes <- BytesDesdeTexto(\"é\");\nDefinir step1 Como Entero <- Propagar file.AgregarBytes(extra);\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"read_write\");\ndefine extra as Bytes <- bytesFromText(\"é\");\ndefine step1 as integer <- propagate file.appendBytes(extra);\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C58",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.AgregarTexto(\"z\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.appendText(\"z\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C59",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "capacidad_cerrada\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura_escritura\");\nDescartar file.Cerrar();\nRetornar file.AgregarTexto(\"z\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"read_write\");\ndiscard file.close();\nreturn file.appendText(\"z\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R11",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las operaciones de directorio y de archivo de R5 a R10 se resuelven siempre a través de la capacidad que las recibe: en una capacidad atenuada por Subdirectorio ninguna ruta, absoluta o con .., sale del directorio confinado (RutaInvalida), consultar sin derecho de lectura o mutar sin derecho de escritura produce PermisoDenegado y una capacidad cerrada produce CapacidadCerrada. Cada una se graba en la cinta como efecto del sistema de archivos y la reproducción devuelve el resultado grabado sin tocar el anfitrión.",
  "verificacion": [
    "C60",
    "C61",
    "C62",
    "C63",
    "C64",
    "C65",
    "C66",
    "C67"
  ]
}
```

```caso
{
  "id": "C60",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\nRetornar inner.CrearDirectorio(\"n\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura\");\nreturn inner.createDirectory(\"n\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C61",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\nRetornar inner.Borrar(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura\");\nreturn inner.delete(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    }
  }
}
```

```caso
{
  "id": "C62",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\nRetornar inner.Renombrar(\"a\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura\");\nreturn inner.rename(\"a\", \"b\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    }
  }
}
```

```caso
{
  "id": "C63",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "permiso_denegado\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"escritura\");\nRetornar inner.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"escritura\");\nreturn inner.exists(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/a": "x"
    }
  }
}
```

```caso
{
  "id": "C64",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nRetornar inner.Existe(\"../a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura_escritura\");\nreturn inner.exists(\"../a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/b": "x",
      "a": "y"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C65",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nRetornar inner.Existe(\"/a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura_escritura\");\nreturn inner.exists(\"/a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/b": "x",
      "a": "y"
    }
  }
}
```

```caso
{
  "id": "C66",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ruta_invalida\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nRetornar inner.Renombrar(\"b\", \"../c\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine inner as DirCap <- propagate directory.subdirectory(\"d\", \"lectura_escritura\");\nreturn inner.rename(\"b\", \"../c\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "d/b": "x"
    }
  }
}
```

```caso
{
  "id": "C67",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "capacidad_cerrada\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDescartar directory.Cerrar();\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; SiNo Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<boolean, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndiscard directory.close();\nreturn directory.exists(\"a\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): if value then write 1; else write 0; endIf\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "a": "x"
    }
  }
}
```

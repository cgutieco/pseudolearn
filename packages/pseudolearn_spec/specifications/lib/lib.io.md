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
    "C17",
    "C77",
    "C78",
    "C79",
    "C80",
    "C81",
    "C82",
    "C83",
    "C84",
    "C85"
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
    "es": "SubProceso Probe() Como Resultado < Cadena, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\n  Retornar file.LeerTexto();\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < String, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define file As FileCap <- Propagate directory.open(\"a\", \"read\");\n  Return file.readText();\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir file Como ArchivoCap <- Propagar directory.Abrir(\"missing\", \"lectura\");\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define file As FileCap <- Propagate directory.open(\"missing\", \"read\");\n  Return Success (0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\n  Descartar file.Cerrar();\n  Definir content Como Bytes <- Propagar file.LeerBytes();\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define file As FileCap <- Propagate directory.open(\"a\", \"read\");\n  Discard file.close();\n  Define content As Bytes <- Propagate file.readBytes();\n  Return Success (0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\n  Definir content Como Bytes <- Propagar file.LeerBytes();\n  Escribir content.En(3);\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define file As FileCap <- Propagate directory.open(\"a\", \"read\");\n  Define content As Bytes <- Propagate file.readBytes();\n  Write content.at(3);\n  Return Success (0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
  "regla": "R3",
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
  "regla": "R3",
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
  "regla": "R3",
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
    "C29",
    "C86",
    "C87"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.EsDirectorio(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.EsDirectorio(\"d/a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.EsDirectorio(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Existe(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "C36",
    "C88"
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
    "es": "SubProceso Probe() Como Resultado < Vector < Cadena >, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Retornar directory.Listar(\"a\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (names): Escribir names.Longitud(), \":\", Unir(names, \",\");\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < vector < String >, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Return directory.list(\"a\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (names): Write names.length(), \":\", join(names, \",\");\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "C41",
    "C89"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Borrar(\"a\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Borrar(\"e\");\nRetornar directory.Existe(\"e\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Retornar directory.Borrar(\"d\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Return directory.delete(\"d\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Borrar(\"missing\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Borrar(\".\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "C48",
    "C90"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Renombrar(\"a\", \"b\");\nRetornar directory.Existe(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.Renombrar(\"d\", \"n\");\nRetornar directory.Existe(\"n/a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Retornar directory.Renombrar(\"a\", \"b\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Return directory.rename(\"a\", \"b\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"missing\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nDefinir step1 Como Logico <- Propagar inner.Renombrar(\"a\", \"b\");\nRetornar directory.Existe(\"d/b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.Renombrar(\"d\", \"d/n\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "C53",
    "C91"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir step1 Como Logico <- Propagar directory.CrearDirectorio(\"n\");\nRetornar directory.EsDirectorio(\"n\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.CrearDirectorio(\"d\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nRetornar directory.CrearDirectorio(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Retornar directory.CrearDirectorio(\"p/n\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Return directory.createDirectory(\"p/n\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "C59",
    "C92",
    "C93"
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
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\n  Retornar file.AgregarTexto(\"z\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define file As FileCap <- Propagate directory.open(\"a\", \"read\");\n  Return file.appendText(\"z\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\n  Retornar inner.CrearDirectorio(\"n\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define inner As DirCap <- Propagate directory.subdirectory(\"d\", \"lectura\");\n  Return inner.createDirectory(\"n\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\nRetornar inner.Borrar(\"a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura\");\nRetornar inner.Renombrar(\"a\", \"b\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"escritura\");\n  Retornar inner.Existe(\"a\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define inner As DirCap <- Propagate directory.subdirectory(\"d\", \"escritura\");\n  Return inner.exists(\"a\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Definir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\n  Retornar inner.Existe(\"../a\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Define inner As DirCap <- Propagate directory.subdirectory(\"d\", \"lectura_escritura\");\n  Return inner.exists(\"../a\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nRetornar inner.Existe(\"/a\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado<Logico, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir inner Como DirectorioCap <- Propagar directory.Subdirectorio(\"d\", \"lectura_escritura\");\nRetornar inner.Renombrar(\"b\", \"../c\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
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
    "es": "SubProceso Probe() Como Resultado < Logico, ErrorES >\n  Definir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\n  Descartar directory.Cerrar();\n  Retornar directory.Existe(\"a\");\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Si value Entonces Escribir 1; Sino Escribir 0; FinSi\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Boolean, IoError >\n  Define directory As DirCap <- Propagate requestDirectory(\"root\");\n  Discard directory.close();\n  Return directory.exists(\"a\");\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): If value Then Write 1; Else Write 0; EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
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
  "id": "R12",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Entorno es una capacidad de solo lectura que se solicita con SolicitarEntorno y tiene autoridad plena por omisión, sin concesiones. Obtener(nombre) devuelve Resultado<Opcional<Cadena>, ErrorES>: una variable ausente da Nada, una variable presente da Algo con su valor exacto, incluida la cadena vacía y el texto Unicode, y dos lecturas del mismo nombre son dos efectos independientes. La capacidad no enumera las demás variables ni ofrece escritura. Cuando el anfitrión distingue mayúsculas de minúsculas en los nombres, que es el caso de Unix, el nombre debe coincidir exactamente; el anfitrión decide, y en Windows no las distingue.",
  "verificacion": [
    "C68",
    "C94",
    "C95"
  ]
}
```

```caso
{
  "id": "C68",
  "regla": "R12",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "none\n[hola]\n[]\n[ñandú ✓]\n[hola]\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir env Como Entorno <- Propagar SolicitarEntorno();\nDefinir a Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_MISSING\");\nSegun a Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir b Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_PRESENT\");\nSegun b Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir c Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_EMPTY\");\nSegun c Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir d Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_UNICODE\");\nSegun d Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir e Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_PRESENT\");\nSegun e Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine env as Environment <- propagate requestEnvironment();\ndefine a as optional<string> <- propagate env.get(\"PL_MISSING\");\nswitch a do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine b as optional<string> <- propagate env.get(\"PL_PRESENT\");\nswitch b do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine c as optional<string> <- propagate env.get(\"PL_EMPTY\");\nswitch c do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine d as optional<string> <- propagate env.get(\"PL_UNICODE\");\nswitch d do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine e as optional<string> <- propagate env.get(\"PL_PRESENT\");\nswitch e do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "environment": {
      "PL_PRESENT": "hola",
      "PL_EMPTY": "",
      "PL_UNICODE": "ñandú ✓"
    }
  }
}
```

```regla
{
  "id": "R13",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un nombre vacío o que contiene el carácter = o el carácter nulo produce ErrorES.PeticionInvalida sin consultar al sistema. Un valor que no sea UTF-8 válido produce ErrorES.Utf8Invalido. En el navegador, donde no existe un entorno de proceso, la capacidad se solicita y Obtener produce un ErrorES tipado de plataforma.",
  "verificacion": [
    "C69"
  ]
}
```

```caso
{
  "id": "C69",
  "regla": "R13",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "peticion_invalida\npeticion_invalida\nok\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir env Como Entorno <- Propagar SolicitarEntorno();\n  Segun env.Obtener(\"\") Hacer\n    Exito (value): Escribir \"ok\";\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\n  Segun env.Obtener(\"A=B\") Hacer\n    Exito (value): Escribir \"ok\";\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\n  Segun env.Obtener(\"PL_PRESENT\") Hacer\n    Exito (value): Escribir \"ok\";\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define env As Environment <- Propagate requestEnvironment();\n  Switch env.get(\"\") Do\n    Success (value): Write \"ok\";\n    Failure (problem): Write problem.code;\n  EndSwitch\n  Switch env.get(\"A=B\") Do\n    Success (value): Write \"ok\";\n    Failure (problem): Write problem.code;\n  EndSwitch\n  Switch env.get(\"PL_PRESENT\") Do\n    Success (value): Write \"ok\";\n    Failure (problem): Write problem.code;\n  EndSwitch\n  Return Success (0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "environment": {
      "PL_PRESENT": "hola",
      "PL_EMPTY": "",
      "PL_UNICODE": "ñandú ✓"
    }
  }
}
```

```regla
{
  "id": "R14",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada solicitud y cada lectura de Entorno se graba en la cinta bajo capability_kind environment y la reproducción devuelve el valor grabado sin consultar al sistema. Una lectura cuyo nombre termina en token, key, secret o password, sin distinguir mayúsculas ASCII, se clasifica como secreta por su nombre: la entrada de la cinta lleva una referencia con key_id environment que solo depende del nombre, no se graba su valor, la cinta queda NonReproducibleRedacted y reproducirla se rechaza con replay_non_reproducible. Las lecturas con otros nombres no se redactan.",
  "verificacion": [
    "C70",
    "C71"
  ]
}
```

```caso
{
  "id": "C70",
  "regla": "R14",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "[hola]\nnone\n0\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "environment",
          "operation": "request_environment",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "environment",
          "operation": "environment_get",
          "outcome": "committed"
        },
        {
          "effect_seq": 4,
          "capability_kind": "environment",
          "operation": "environment_get",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir env Como Entorno <- Propagar SolicitarEntorno();\nDefinir a Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_PRESENT\");\nSegun a Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir b Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_MISSING\");\nSegun b Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine env as Environment <- propagate requestEnvironment();\ndefine a as optional<string> <- propagate env.get(\"PL_PRESENT\");\nswitch a do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine b as optional<string> <- propagate env.get(\"PL_MISSING\");\nswitch b do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "environment": {
      "PL_PRESENT": "hola",
      "PL_EMPTY": "",
      "PL_UNICODE": "ñandú ✓"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C71",
  "regla": "R14",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "[s3cr3t]\n[p4ss]\n[hola]\n0\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 4,
      "recursos_abiertos": 0,
      "estado_cinta": "non_reproducible_redacted",
      "reproduccion_fallo": "replay_non_reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "environment",
          "operation": "request_environment",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "environment",
          "operation": "environment_get",
          "outcome": "committed",
          "secret_key_id": "environment"
        },
        {
          "effect_seq": 4,
          "capability_kind": "environment",
          "operation": "environment_get",
          "outcome": "committed",
          "secret_key_id": "environment"
        },
        {
          "effect_seq": 6,
          "capability_kind": "environment",
          "operation": "environment_get",
          "outcome": "committed"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir env Como Entorno <- Propagar SolicitarEntorno();\nDefinir a Como Opcional<Cadena> <- Propagar env.Obtener(\"API_KEY\");\nSegun a Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir b Como Opcional<Cadena> <- Propagar env.Obtener(\"pl_Password\");\nSegun b Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nDefinir c Como Opcional<Cadena> <- Propagar env.Obtener(\"PL_PRESENT\");\nSegun c Hacer\nNada: Escribir \"none\";\nAlgo(text): Escribir \"[\", text, \"]\";\nFinSegun\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine env as Environment <- propagate requestEnvironment();\ndefine a as optional<string> <- propagate env.get(\"API_KEY\");\nswitch a do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine b as optional<string> <- propagate env.get(\"pl_Password\");\nswitch b do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\ndefine c as optional<string> <- propagate env.get(\"PL_PRESENT\");\nswitch c do\nnone: write \"none\";\nsome(text): write \"[\", text, \"]\";\nendSwitch\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "environment": {
      "API_KEY": "s3cr3t",
      "pl_Password": "p4ss",
      "PL_PRESENT": "hola"
    }
  }
}
```

```regla
{
  "id": "R15",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Consola.EstablecerCodigoSalida(n) devuelve Resultado<Entero, ErrorES> con el código establecido. Establece el código de salida del proceso que se aplica cuando el programa termina con normalidad: no termina el programa, no altera el flujo, Diferir ni las tareas, y si se establece más de una vez conserva el último. Vale 0 por omisión. Un n fuera de 0–255 produce ErrorES.PeticionInvalida sin cambiar el código vigente. Un programa que termina por fallo de ejecución, límite alcanzado o entrada agotada conserva el código de ese final y no el establecido. Se graba en la cinta bajo capability_kind console y la reproducción devuelve el valor grabado sin duplicar el efecto.",
  "verificacion": [
    "C72",
    "C73",
    "C74",
    "C96"
  ]
}
```

```caso
{
  "id": "C72",
  "regla": "R15",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n7\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir con Como Consola <- Propagar SolicitarConsola();\nDefinir c3 Como Entero <- Propagar con.EstablecerCodigoSalida(3);\nDefinir c7 Como Entero <- Propagar con.EstablecerCodigoSalida(7);\nEscribir c3;\nEscribir c7;\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine con as Console <- propagate requestConsole();\ndefine c3 as integer <- propagate con.setExitCode(3);\ndefine c7 as integer <- propagate con.setExitCode(7);\nwrite c3;\nwrite c7;\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C73",
  "regla": "R15",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n255\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir con Como Consola <- Propagar SolicitarConsola();\nDefinir c0 Como Entero <- Propagar con.EstablecerCodigoSalida(0);\nDefinir c255 Como Entero <- Propagar con.EstablecerCodigoSalida(255);\nEscribir c0;\nEscribir c255;\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine con as Console <- propagate requestConsole();\ndefine c0 as integer <- propagate con.setExitCode(0);\ndefine c255 as integer <- propagate con.setExitCode(255);\nwrite c0;\nwrite c255;\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C74",
  "regla": "R15",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "peticion_invalida\npeticion_invalida\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir con Como Consola <- Propagar SolicitarConsola();\n  Segun con.EstablecerCodigoSalida(256) Hacer\n    Exito (value): Escribir \"ok\";\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\n  Segun con.EstablecerCodigoSalida(-1) Hacer\n    Exito (value): Escribir \"ok\";\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define con As Console <- Propagate requestConsole();\n  Switch con.setExitCode(256) Do\n    Success (value): Write \"ok\";\n    Failure (problem): Write problem.code;\n  EndSwitch\n  Switch con.setExitCode(-1) Do\n    Success (value): Write \"ok\";\n    Failure (problem): Write problem.code;\n  EndSwitch\n  Return Success (0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```regla
{
  "id": "R16",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Consola.EscribirError(texto) devuelve Resultado<Entero, ErrorES> con la cantidad de bytes UTF-8 del texto, que queda escrito en el flujo de error del programa. La salida combinada del programa conserva el texto de ambos flujos en el orden en que se escribieron, y la respuesta de la API informa en error_ranges los tramos de bytes de esa salida que pertenecen al flujo de error. La CLI escribe esos tramos en la salida de error estándar y el resto en la salida estándar; la sesión de depuración los informa con la categoría de salida de error; los demás consumidores pueden mostrar la salida combinada. El texto vacío escribe cero bytes. Se graba en la cinta bajo capability_kind console.",
  "verificacion": [
    "C75",
    "C76",
    "C97"
  ]
}
```

```caso
{
  "id": "C75",
  "regla": "R16",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "a\nx\nb\n2\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir con Como Consola <- Propagar SolicitarConsola();\nEscribir \"a\";\nDefinir n Como Entero <- Propagar con.EscribirError(\"x\\n\");\nEscribir \"b\";\nEscribir n;\nRetornar Exito(0);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine con as Console <- propagate requestConsole();\nwrite \"a\";\ndefine n as integer <- propagate con.writeError(\"x\\n\");\nwrite \"b\";\nwrite n;\nreturn success(0);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  }
}
```

```caso
{
  "id": "C76",
  "regla": "R16",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "é0\n2\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado < Entero, ErrorES >\n  Definir con Como Consola <- Propagar SolicitarConsola();\n  Definir vacio Como Entero <- Propagar con.EscribirError(\"\");\n  Definir tilde Como Entero <- Propagar con.EscribirError(\"é\");\n  Escribir vacio;\n  Escribir tilde;\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo Main\n  Segun Probe() Hacer\n    Exito (value): Escribir value;\n    Error (problem): Escribir problem.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Probe() As Result < Integer, IoError >\n  Define con As Console <- Propagate requestConsole();\n  Define vacio As Integer <- Propagate con.writeError(\"\");\n  Define tilde As Integer <- Propagate con.writeError(\"é\");\n  Write vacio;\n  Write tilde;\n  Return Success (0);\nEndSubroutine\n\nAlgorithm Main\n  Switch Probe() Do\n    Success (value): Write value;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  }
}
```

```caso
{
  "id": "C77",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Total: 3\n255\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso LeerColores() Como Resultado < Bytes, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"colores.bin\", \"lectura\");\n  Retornar archivo.LeerBytes();\nFinSubProceso\n\nAlgoritmo MostrarBytes\n  Segun LeerColores() Hacer\n    Exito (datos):\n      Escribir \"Total: \", datos.Longitud();\n      Escribir datos.En(0);\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ReadColors() As Result < Bytes, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"colores.bin\", \"read\");\n  Return file.readBytes();\nEndSubroutine\n\nAlgorithm ShowBytes\n  Switch ReadColors() Do\n    Success (data):\n      Write \"Total: \", data.length();\n      Write data.at(0);\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "colores.bin": [
        255,
        0,
        128
      ]
    }
  }
}
```

```caso
{
  "id": "C78",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola, mundo\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso LeerSaludo() Como Resultado < Cadena, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"saludo.txt\", \"lectura\");\n  Retornar archivo.LeerTexto();\nFinSubProceso\n\nAlgoritmo MostrarSaludo\n  Segun LeerSaludo() Hacer\n    Exito (texto): Escribir texto;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ReadGreeting() As Result < String, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"saludo.txt\", \"read\");\n  Return file.readText();\nEndSubroutine\n\nAlgorithm ShowGreeting\n  Switch ReadGreeting() Do\n    Success (text): Write text;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "saludo.txt": "Hola, mundo"
    }
  }
}
```

```caso
{
  "id": "C79",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola\nOK\ncapacidad_cerrada\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso LeerDosVeces() Como Resultado < Cadena, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"saludo.txt\", \"lectura\");\n  Definir texto Como Cadena <- Propagar archivo.LeerTexto();\n  Escribir texto;\n  Definir cerrado Como Logico <- Propagar archivo.Cerrar();\n  Si cerrado Entonces\n    Escribir \"OK\";\n  FinSi\n  Retornar archivo.LeerTexto();\nFinSubProceso\n\nAlgoritmo CerrarArchivo\n  Segun LeerDosVeces() Hacer\n    Exito (texto): Escribir texto;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ReadTwice() As Result < String, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"saludo.txt\", \"read\");\n  Define text As String <- Propagate file.readText();\n  Write text;\n  Define closed As Boolean <- Propagate file.close();\n  If closed Then\n    Write \"OK\";\n  EndIf\n  Return file.readText();\nEndSubroutine\n\nAlgorithm CloseFile\n  Switch ReadTwice() Do\n    Success (text): Write text;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "saludo.txt": "Hola"
    }
  }
}
```

```caso
{
  "id": "C80",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Bytes: 11\nComprar pan\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso GuardarNota() Como Resultado < Cadena, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"nota.txt\", \"escritura\");\n  Definir cantidad Como Entero <- Propagar archivo.EscribirTexto(\"Comprar pan\");\n  Escribir \"Bytes: \", cantidad;\n  Definir lector Como ArchivoCap <- Propagar carpeta.Abrir(\"nota.txt\", \"lectura\");\n  Retornar lector.LeerTexto();\nFinSubProceso\n\nAlgoritmo Notas\n  Segun GuardarNota() Hacer\n    Exito (texto): Escribir texto;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SaveNote() As Result < String, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"nota.txt\", \"write\");\n  Define count As Integer <- Propagate file.writeText(\"Comprar pan\");\n  Write \"Bytes: \", count;\n  Define reader As FileCap <- Propagate folder.open(\"nota.txt\", \"read\");\n  Return reader.readText();\nEndSubroutine\n\nAlgorithm Notes\n  Switch SaveNote() Do\n    Success (text): Write text;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C81",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Bytes: 3\n83\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso GuardarBytes() Como Resultado < Bytes, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"copia.bin\", \"escritura\");\n  Definir datos Como Bytes <- BytesDesdeTexto(\"Sol\");\n  Definir cantidad Como Entero <- Propagar archivo.EscribirBytes(datos);\n  Escribir \"Bytes: \", cantidad;\n  Definir lector Como ArchivoCap <- Propagar carpeta.Abrir(\"copia.bin\", \"lectura\");\n  Retornar lector.LeerBytes();\nFinSubProceso\n\nAlgoritmo CopiarBytes\n  Segun GuardarBytes() Hacer\n    Exito (leidos): Escribir leidos.En(0);\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SaveBytes() As Result < Bytes, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"copia.bin\", \"write\");\n  Define data As Bytes <- bytesFromText(\"Sol\");\n  Define count As Integer <- Propagate file.writeBytes(data);\n  Write \"Bytes: \", count;\n  Define reader As FileCap <- Propagate folder.open(\"copia.bin\", \"read\");\n  Return reader.readBytes();\nEndSubroutine\n\nAlgorithm CopyBytes\n  Switch SaveBytes() Do\n    Success (loaded): Write loaded.at(0);\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C82",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola, Ana\nHola, Luis\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso LeerNombres() Como Resultado < Vector < Cadena >, ErrorES >\n  Definir argumentos Como Argumentos <- Propagar SolicitarArgumentos();\n  Retornar argumentos.Valores();\nFinSubProceso\n\nAlgoritmo Saludos\n  Segun LeerNombres() Hacer\n    Exito (nombres):\n      Para Cada nombre En nombres Hacer\n        Escribir \"Hola, \", nombre;\n      FinPara\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ReadNames() As Result < vector < String >, IoError >\n  Define arguments As Arguments <- Propagate requestArguments();\n  Return arguments.values();\nEndSubroutine\n\nAlgorithm Greetings\n  Switch ReadNames() Do\n    Success (names):\n      For each name in names Do\n        Write \"Hola, \", name;\n      EndFor\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "args": [
      "Ana",
      "Luis"
    ]
  }
}
```

```caso
{
  "id": "C83",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Inicio\nFalta un dato\nCódigo: 1\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Avisar() Como Resultado < Entero, ErrorES >\n  Definir consola Como Consola <- Propagar SolicitarConsola();\n  Descartar consola.EscribirError(\"Falta un dato\\n\");\n  Retornar consola.EstablecerCodigoSalida(1);\nFinSubProceso\n\nAlgoritmo Revisar\n  Escribir \"Inicio\";\n  Segun Avisar() Hacer\n    Exito (codigo): Escribir \"Código: \", codigo;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Warn() As Result < Integer, IoError >\n  Define console As Console <- Propagate requestConsole();\n  Discard console.writeError(\"Falta un dato\\n\");\n  Return console.setExitCode(1);\nEndSubroutine\n\nAlgorithm Check\n  Write \"Inicio\";\n  Switch Warn() Do\n    Success (exitCode): Write \"Código: \", exitCode;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C84",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "playa.jpg\nsol.jpg\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso VerFotos() Como Resultado < Vector < Cadena >, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir fotos Como DirectorioCap <- Propagar carpeta.Subdirectorio(\"fotos\", \"lectura\");\n  Retornar fotos.Listar(\".\");\nFinSubProceso\n\nAlgoritmo Album\n  Segun VerFotos() Hacer\n    Exito (nombres):\n      Para Cada nombre En nombres Hacer\n        Escribir nombre;\n      FinPara\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SeePhotos() As Result < vector < String >, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define photos As DirCap <- Propagate folder.subdirectory(\"fotos\", \"read\");\n  Return photos.list(\".\");\nEndSubroutine\n\nAlgorithm Album\n  Switch SeePhotos() Do\n    Success (names):\n      For each name in names Do\n        Write name;\n      EndFor\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "fotos/playa.jpg": "1",
      "fotos/sol.jpg": "2",
      "nota.txt": "3"
    }
  }
}
```

```caso
{
  "id": "C85",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Carpeta cerrada\ncapacidad_cerrada\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Revisar() Como Resultado < Logico, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir cerrada Como Logico <- Propagar carpeta.Cerrar();\n  Si cerrada Entonces\n    Escribir \"Carpeta cerrada\";\n  FinSi\n  Retornar carpeta.Existe(\"nota.txt\");\nFinSubProceso\n\nAlgoritmo CerrarCarpeta\n  Segun Revisar() Hacer\n    Exito (existe):\n      Si existe Entonces\n        Escribir \"1\";\n      FinSi\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Check() As Result < Boolean, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define closed As Boolean <- Propagate folder.close();\n  If closed Then\n    Write \"Carpeta cerrada\";\n  EndIf\n  Return folder.exists(\"nota.txt\");\nEndSubroutine\n\nAlgorithm CloseFolder\n  Switch Check() Do\n    Success (found):\n      If found Then\n        Write \"1\";\n      EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "nota.txt": "x"
    }
  }
}
```

```caso
{
  "id": "C86",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "tareas.txt: 1\ncompras.txt: 0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Buscar(nombre Como Cadena) Como Resultado < Logico, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Retornar carpeta.Existe(nombre);\nFinSubProceso\n\nSubProceso Informar(nombre Como Cadena)\n  Segun Buscar(nombre) Hacer\n    Exito (existe):\n      Si existe Entonces\n        Escribir nombre, \": 1\";\n      Sino\n        Escribir nombre, \": 0\";\n      FinSi\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nAlgoritmo BuscarArchivos\n  Informar(\"tareas.txt\");\n  Informar(\"compras.txt\");\nFinAlgoritmo\n",
    "en": "Subroutine Find(name As String) As Result < Boolean, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Return folder.exists(name);\nEndSubroutine\n\nSubroutine Report(name As String)\n  Switch Find(name) Do\n    Success (found):\n      If found Then\n        Write name, \": 1\";\n      Else\n        Write name, \": 0\";\n      EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nAlgorithm FindFiles\n  Report(\"tareas.txt\");\n  Report(\"compras.txt\");\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "tareas.txt": "x"
    }
  }
}
```

```caso
{
  "id": "C87",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "fotos: 1\nfotos/playa.jpg: 0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso EsCarpeta(ruta Como Cadena) Como Resultado < Logico, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Retornar carpeta.EsDirectorio(ruta);\nFinSubProceso\n\nSubProceso Informar(ruta Como Cadena)\n  Segun EsCarpeta(ruta) Hacer\n    Exito (esCarpeta):\n      Si esCarpeta Entonces\n        Escribir ruta, \": 1\";\n      Sino\n        Escribir ruta, \": 0\";\n      FinSi\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nAlgoritmo RevisarRutas\n  Informar(\"fotos\");\n  Informar(\"fotos/playa.jpg\");\nFinAlgoritmo\n",
    "en": "Subroutine IsFolder(path As String) As Result < Boolean, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Return folder.isDirectory(path);\nEndSubroutine\n\nSubroutine Report(path As String)\n  Switch IsFolder(path) Do\n    Success (isFolder):\n      If isFolder Then\n        Write path, \": 1\";\n      Else\n        Write path, \": 0\";\n      EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nAlgorithm CheckPaths\n  Report(\"fotos\");\n  Report(\"fotos/playa.jpg\");\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "fotos/playa.jpg": "x"
    }
  }
}
```

```caso
{
  "id": "C88",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "blues.mp3\njazz.mp3\nrock.mp3\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso VerCanciones() Como Resultado < Vector < Cadena >, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Retornar carpeta.Listar(\"musica\");\nFinSubProceso\n\nAlgoritmo Canciones\n  Segun VerCanciones() Hacer\n    Exito (nombres):\n      Para Cada nombre En nombres Hacer\n        Escribir nombre;\n      FinPara\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine SeeSongs() As Result < vector < String >, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Return folder.list(\"musica\");\nEndSubroutine\n\nAlgorithm Songs\n  Switch SeeSongs() Do\n    Success (names):\n      For each name in names Do\n        Write name;\n      EndFor\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "musica/rock.mp3": "1",
      "musica/jazz.mp3": "2",
      "musica/blues.mp3": "3"
    }
  }
}
```

```caso
{
  "id": "C89",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Borrado\n0\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso BorrarBorrador() Como Resultado < Logico, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir borrado Como Logico <- Propagar carpeta.Borrar(\"borrador.txt\");\n  Si borrado Entonces\n    Escribir \"Borrado\";\n  FinSi\n  Retornar carpeta.Existe(\"borrador.txt\");\nFinSubProceso\n\nAlgoritmo Limpiar\n  Segun BorrarBorrador() Hacer\n    Exito (existe):\n      Si existe Entonces\n        Escribir \"1\";\n      Sino\n        Escribir \"0\";\n      FinSi\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine DeleteDraft() As Result < Boolean, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define deleted As Boolean <- Propagate folder.delete(\"borrador.txt\");\n  If deleted Then\n    Write \"Borrado\";\n  EndIf\n  Return folder.exists(\"borrador.txt\");\nEndSubroutine\n\nAlgorithm CleanUp\n  Switch DeleteDraft() Do\n    Success (found):\n      If found Then\n        Write \"1\";\n      Else\n        Write \"0\";\n      EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "borrador.txt": "x"
    }
  }
}
```

```caso
{
  "id": "C90",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "OK\nArena y mar\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso CambiarNombre() Como Resultado < Cadena, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir movido Como Logico <- Propagar carpeta.Renombrar(\"foto1.jpg\", \"playa.jpg\");\n  Si movido Entonces\n    Escribir \"OK\";\n  FinSi\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"playa.jpg\", \"lectura\");\n  Retornar archivo.LeerTexto();\nFinSubProceso\n\nAlgoritmo Renombrar\n  Segun CambiarNombre() Hacer\n    Exito (texto): Escribir texto;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ChangeName() As Result < String, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define moved As Boolean <- Propagate folder.rename(\"foto1.jpg\", \"playa.jpg\");\n  If moved Then\n    Write \"OK\";\n  EndIf\n  Define file As FileCap <- Propagate folder.open(\"playa.jpg\", \"read\");\n  Return file.readText();\nEndSubroutine\n\nAlgorithm RenameFile\n  Switch ChangeName() Do\n    Success (text): Write text;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "files": {
      "foto1.jpg": "Arena y mar"
    }
  }
}
```

```caso
{
  "id": "C91",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "proyectos: OK\nya_existe\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Crear(nombre Como Cadena) Como Resultado < Logico, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Retornar carpeta.CrearDirectorio(nombre);\nFinSubProceso\n\nSubProceso Informar(nombre Como Cadena)\n  Segun Crear(nombre) Hacer\n    Exito (creada):\n      Si creada Entonces\n        Escribir nombre, \": OK\";\n      FinSi\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinSubProceso\n\nAlgoritmo NuevaCarpeta\n  Informar(\"proyectos\");\n  Informar(\"proyectos\");\nFinAlgoritmo\n",
    "en": "Subroutine Create(name As String) As Result < Boolean, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Return folder.createDirectory(name);\nEndSubroutine\n\nSubroutine Report(name As String)\n  Switch Create(name) Do\n    Success (created):\n      If created Then\n        Write name, \": OK\";\n      EndIf\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndSubroutine\n\nAlgorithm NewFolder\n  Report(\"proyectos\");\n  Report(\"proyectos\");\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C92",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Bytes: 10\npan, leche\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso HacerLista() Como Resultado < Cadena, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"lista.txt\", \"lectura_escritura\");\n  Definir primero Como Entero <- Propagar archivo.AgregarTexto(\"pan\");\n  Definir segundo Como Entero <- Propagar archivo.AgregarTexto(\", leche\");\n  Escribir \"Bytes: \", primero + segundo;\n  Retornar archivo.LeerTexto();\nFinSubProceso\n\nAlgoritmo ListaCompras\n  Segun HacerLista() Hacer\n    Exito (texto): Escribir texto;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine MakeList() As Result < String, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"lista.txt\", \"read_write\");\n  Define first As Integer <- Propagate file.appendText(\"pan\");\n  Define second As Integer <- Propagate file.appendText(\", leche\");\n  Write \"Bytes: \", first + second;\n  Return file.readText();\nEndSubroutine\n\nAlgorithm ShoppingList\n  Switch MakeList() Do\n    Success (text): Write text;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C93",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\nHola!\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Juntar() Como Resultado < Cadena, ErrorES >\n  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(\".\");\n  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir(\"datos.bin\", \"lectura_escritura\");\n  Definir primero Como Entero <- Propagar archivo.AgregarBytes(BytesDesdeTexto(\"Hola\"));\n  Definir segundo Como Entero <- Propagar archivo.AgregarBytes(BytesDesdeTexto(\"!\"));\n  Escribir primero + segundo;\n  Retornar archivo.LeerTexto();\nFinSubProceso\n\nAlgoritmo AgregarDatos\n  Segun Juntar() Hacer\n    Exito (texto): Escribir texto;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Combine() As Result < String, IoError >\n  Define folder As DirCap <- Propagate requestDirectory(\".\");\n  Define file As FileCap <- Propagate folder.open(\"datos.bin\", \"read_write\");\n  Define first As Integer <- Propagate file.appendBytes(bytesFromText(\"Hola\"));\n  Define second As Integer <- Propagate file.appendBytes(bytesFromText(\"!\"));\n  Write first + second;\n  Return file.readText();\nEndSubroutine\n\nAlgorithm AddData\n  Switch Combine() Do\n    Success (text): Write text;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C94",
  "regla": "R12",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola, Ana\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso LeerUsuario() Como Resultado < Opcional < Cadena >, ErrorES >\n  Definir entorno Como Entorno <- Propagar SolicitarEntorno();\n  Retornar entorno.Obtener(\"USUARIO\");\nFinSubProceso\n\nAlgoritmo Bienvenida\n  Segun LeerUsuario() Hacer\n    Exito (usuario):\n      Segun usuario Hacer\n        Algo (nombre): Escribir \"Hola, \", nombre;\n        Nada: Escribir \"Hola\";\n      FinSegun\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine ReadUser() As Result < Optional < String >, IoError >\n  Define environment As Environment <- Propagate requestEnvironment();\n  Return environment.get(\"USUARIO\");\nEndSubroutine\n\nAlgorithm Welcome\n  Switch ReadUser() Do\n    Success (user):\n      Switch user Do\n        Some (name): Write \"Hola, \", name;\n        None: Write \"Hola\";\n      EndSwitch\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {
    "environment": {
      "USUARIO": "Ana"
    }
  }
}
```

```caso
{
  "id": "C95",
  "regla": "R12",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "IDIOMA = es\nCOLOR no existe\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso VerVariable(nombre Como Cadena) Como Resultado < Entero, ErrorES >\n  Definir entorno Como Entorno <- Propagar SolicitarEntorno();\n  Definir valor Como Opcional < Cadena > <- Propagar entorno.Obtener(nombre);\n  Segun valor Hacer\n    Algo (texto): Escribir nombre, \" = \", texto;\n    Nada: Escribir nombre, \" no existe\";\n  FinSegun\n  Retornar Exito (0);\nFinSubProceso\n\nAlgoritmo VerVariables\n  Descartar VerVariable(\"IDIOMA\");\n  Descartar VerVariable(\"COLOR\");\nFinAlgoritmo\n",
    "en": "Subroutine ShowVariable(name As String) As Result < Integer, IoError >\n  Define environment As Environment <- Propagate requestEnvironment();\n  Define value As Optional < String > <- Propagate environment.get(name);\n  Switch value Do\n    Some (text): Write name, \" = \", text;\n    None: Write name, \" no existe\";\n  EndSwitch\n  Return Success (0);\nEndSubroutine\n\nAlgorithm SeeVariables\n  Discard ShowVariable(\"IDIOMA\");\n  Discard ShowVariable(\"COLOR\");\nEndAlgorithm\n"
  },
  "anfitrion": {
    "environment": {
      "IDIOMA": "es"
    }
  }
}
```

```caso
{
  "id": "C96",
  "regla": "R15",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Código: 3\nFin\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso MarcarFallo() Como Resultado < Entero, ErrorES >\n  Definir consola Como Consola <- Propagar SolicitarConsola();\n  Retornar consola.EstablecerCodigoSalida(3);\nFinSubProceso\n\nAlgoritmo CodigoDeSalida\n  Segun MarcarFallo() Hacer\n    Exito (codigo): Escribir \"Código: \", codigo;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\n  Escribir \"Fin\";\nFinAlgoritmo\n",
    "en": "Subroutine MarkFailure() As Result < Integer, IoError >\n  Define console As Console <- Propagate requestConsole();\n  Return console.setExitCode(3);\nEndSubroutine\n\nAlgorithm ExitCode\n  Switch MarkFailure() Do\n    Success (exitCode): Write \"Código: \", exitCode;\n    Failure (problem): Write problem.code;\n  EndSwitch\n  Write \"Fin\";\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

```caso
{
  "id": "C97",
  "regla": "R16",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Calculando\nSin datos\nBytes: 10\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Advertir() Como Resultado < Entero, ErrorES >\n  Definir consola Como Consola <- Propagar SolicitarConsola();\n  Retornar consola.EscribirError(\"Sin datos\\n\");\nFinSubProceso\n\nAlgoritmo Advertencia\n  Escribir \"Calculando\";\n  Segun Advertir() Hacer\n    Exito (bytes): Escribir \"Bytes: \", bytes;\n    Error (problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Subroutine Warn() As Result < Integer, IoError >\n  Define console As Console <- Propagate requestConsole();\n  Return console.writeError(\"Sin datos\\n\");\nEndSubroutine\n\nAlgorithm Warning\n  Write \"Calculando\";\n  Switch Warn() Do\n    Success (count): Write \"Bytes: \", count;\n    Failure (problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "anfitrion": {}
}
```

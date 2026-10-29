---
{
  "formato": "see/1",
  "id": "ENG.EFFECT.TAPE",
  "titulo": "Esquema versionado de cinta de efectos y reproducción aislada",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Esquema pseudolearn.tape/v1, identidad de ejecución, entradas encadenadas y rechazo sin anfitrión.",
  "titulo_en": "Versioned effect tape schema and isolated replay",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-COMMIT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Esquema versionado de cinta de efectos y reproducción aislada

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cinta de efectos utiliza el esquema versionado pseudolearn.tape/v1. Contiene la cabecera del esquema, la identidad inmutable de la ejecución y una secuencia monotónica de entradas de efecto TapeEntry serializadas de forma determinista.",
  "verificacion": [
    "C1",
    "C7"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "dato\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"escritura\");\nDescartar file.EscribirTexto(\"dato\");\nDescartar file.Cerrar();\nDefinir reader Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"lectura\");\nRetornar reader.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"write\");\ndiscard file.writeText(\"dato\");\ndiscard file.close();\ndefine reader as FileCap <- propagate directory.open(\"n\", \"read\");\nreturn reader.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "requested_permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "ExecutionIdentity resume de forma canónica la huella del programa: código fuente, grafo de dependencias, perfil, semilla, límites efectivos y permisos efectivos. Dos ejecuciones con idéntica ExecutionIdentity y entradas de cinta producen idéntica traza de estados y salidas.",
  "verificacion": [
    "C2"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "150\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDefinir instant Como Entero <- Propagar clock.Ahora();\nRetornar timer.Esperar(50);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\ndefine timer as Timer <- propagate requestTimer();\ndefine instant as integer <- propagate clock.now();\nreturn timer.wait(50);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "reloj",
      "temporizador"
    ],
    "requested_permissions": [
      "reloj",
      "temporizador"
    ],
    "clock": [
      100
    ],
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada TapeEntry registra effect_seq, task_id, source_node_id, capability_kind, operation, request_digest, secret_reference, outcome, payload_bytes y entry_hash. El campo entry_hash es un resumen SHA-256 encadenado criptográficamente con el entry_hash de la entrada previa, garantizando detección de adulteración. El campo capability_kind toma un valor del vocabulario cerrado console, arguments, filesystem, clock, timer y network, determinado por la operación y no por el tipo interno del anfitrión; una solicitud de capacidad se registra bajo la familia de la capacidad solicitada.",
  "verificacion": [
    "C3",
    "C15"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "holamundo\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir second Como ArchivoCap <- Propagar directory.Abrir(\"b\", \"lectura\");\nDefinir left Como Cadena <- Propagar file.LeerTexto();\nDefinir right Como Cadena <- Propagar second.LeerTexto();\nRetornar Exito(left + right);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine second as FileCap <- propagate directory.open(\"b\", \"read\");\ndefine left as string <- propagate file.readText();\ndefine right as string <- propagate second.readText();\nreturn success(left + right);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola",
      "b": "mundo"
    },
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda reproducción desde cinta valida identidad, secuencia y hashes encadenados. Ante discrepancia de identidad emite replay_identity_mismatch; ante efecto imprevisto emite replay_divergence; ante fin prematuro emite replay_truncated_tape; ante hash o payload adulterado emite replay_corrupted_tape; y ante cinta incompleta o incierta emite replay_non_reproducible. El motor jamás recurre al anfitrión vivo tras un fallo de reproducción.",
  "verificacion": [
    "C4",
    "C5",
    "C10",
    "C11",
    "C12"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "no_encontrado\ncierto\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo; Si problem.Incierto Entonces Escribir \"incierto\"; SiNo Escribir \"cierto\"; FinSi\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code; if problem.uncertain then write \"incierto\"; else write \"cierto\"; endIf\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    },
    "faults": [
      {
        "operation": "file_read_text",
        "code": "no_encontrado"
      }
    ],
    "grabar_y_reproducir": true
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir values Como Argumentos <- Propagar SolicitarArgumentos();\nDefinir list Como Vector<Cadena> <- Propagar values.Valores();\nRetornar Exito(list.Longitud());\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine values as Arguments <- propagate requestArguments();\ndefine list as vector<string> <- propagate values.values();\nreturn success(list.length());\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "argumentos"
    ],
    "requested_permissions": [
      "argumentos"
    ],
    "args": [
      "uno",
      "dos"
    ],
    "grabar_y_reproducir": true
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cinta protege la privacidad y los límites de memoria: los argumentos clasificados como secretos se redactan y sustituyen por SecretHandle { key_id, value_hmac } antes de la serialización, y el crecimiento de la cinta respeta el límite configurable max_tape_bytes. Si la cinta excede el presupuesto de bytes o contiene secretos sin almacén de resolución externo, se sella deterministamente como NonReproducibleTruncated o NonReproducibleRedacted. El límite es exacto: una entrada se admite si la cinta serializada resultante no supera max_tape_bytes, y se rechaza con un byte más. Agotar solo el presupuesto de la cinta no detiene la ejecución en vivo: el programa continúa y termina con normalidad, pero la cinta sellada no es reproducible y reproducirla se rechaza con replay_non_reproducible. La referencia a un secreto depende del valor y de la clave: cambiar cualquiera de los dos cambia value_hmac, y ni el valor ni la clave aparecen en la cinta bajo forma textual, escapada, decimal o hexadecimal.",
  "verificacion": [
    "C6",
    "C8",
    "C9"
  ]
}
```

```caso
{
  "id": "C6",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "6\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "non_reproducible_redacted",
      "reproduccion_fallo": "replay_non_reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "filesystem",
          "operation": "request_directory",
          "outcome": "committed"
        },
        {
          "effect_seq": 2,
          "capability_kind": "filesystem",
          "operation": "file_open",
          "outcome": "committed"
        },
        {
          "effect_seq": 3,
          "capability_kind": "filesystem",
          "operation": "file_write_text",
          "outcome": "committed",
          "secret_key_id": "k1"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"n\", \"escritura\");\nRetornar file.EscribirTexto(\"s3cr3t\");\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"n\", \"write\");\nreturn file.writeText(\"s3cr3t\");\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "requested_permissions": [
      "archivos_lectura",
      "archivos_escritura"
    ],
    "secrets": {
      "token": {
        "key_id": "k1",
        "value": "s3cr3t"
      }
    },
    "secret_keys": {
      "k1": "clave-privada"
    }
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 9,
      "recursos_abiertos": 0
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir values Como Argumentos <- Propagar SolicitarArgumentos();\nDefinir list Como Vector<Cadena> <- Propagar values.Valores();\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nDefinir instant Como Entero <- Propagar clock.Ahora();\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir content Como Cadena <- Propagar file.LeerTexto();\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDefinir waited Como Entero <- Propagar timer.Esperar(5);\nRetornar Exito(content);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine values as Arguments <- propagate requestArguments();\ndefine list as vector<string> <- propagate values.values();\ndefine clock as Clock <- propagate requestClock();\ndefine instant as integer <- propagate clock.now();\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine content as string <- propagate file.readText();\ndefine timer as Timer <- propagate requestTimer();\ndefine waited as integer <- propagate timer.wait(5);\nreturn success(content);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "argumentos",
      "reloj",
      "temporizador",
      "archivos_lectura"
    ],
    "requested_permissions": [
      "argumentos",
      "reloj",
      "temporizador",
      "archivos_lectura"
    ],
    "args": [
      "uno",
      "dos"
    ],
    "clock": [
      100
    ],
    "files": {
      "a": "hola"
    },
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 5,
      "recursos_abiertos": 0,
      "estado_cinta": "non_reproducible_truncated",
      "reproduccion_fallo": "replay_non_reproducible",
      "efectos": []
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir first Como Cadena <- Propagar file.LeerTexto();\nDefinir second Como Cadena <- Propagar file.LeerTexto();\nDefinir third Como Cadena <- Propagar file.LeerTexto();\nRetornar Exito(3);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine first as string <- propagate file.readText();\ndefine second as string <- propagate file.readText();\ndefine third as string <- propagate file.readText();\nreturn success(3);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    },
    "max_tape_bytes": 1
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "s3cr3t\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "estado_cinta": "non_reproducible_redacted",
      "reproduccion_fallo": "replay_non_reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "capability_kind": "console",
          "operation": "write",
          "outcome": "committed",
          "secret_key_id": "k1"
        }
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nEscribir \"s3cr3t\";\nFinAlgoritmo\n",
    "en": "algorithm Main\nwrite \"s3cr3t\";\nendAlgorithm\n"
  },
  "anfitrion": {
    "secrets": {
      "token": {
        "key_id": "k1",
        "value": "s3cr3t"
      }
    },
    "secret_keys": {
      "k1": "clave-privada"
    }
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "reproduccion_fallo": "replay_truncated_tape"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    },
    "alterar_cinta": "truncar_entrada"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "reproduccion_fallo": "replay_corrupted_tape"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    },
    "alterar_cinta": "corromper_hash"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "hola\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "reproduccion_fallo": "replay_identity_mismatch"
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Cadena, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nRetornar file.LeerTexto();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<string, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\nreturn file.readText();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "a": "hola"
    },
    "alterar_cinta": "cambiar_semilla"
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las entradas de la cinta registran la tarea que pidió el efecto en task_id, que vale 0 para la tarea raíz. effect_seq numera los efectos en orden de petición y delivery_seq indica la posición de entrega en la cinta; delivery_seq se omite cuando coincide con effect_seq, de modo que un programa sin efectos concurrentes graba la misma cinta que antes de existir las tareas. Un efecto cuya tarea se cancela mientras lo espera queda abandonado y se sella con el desenlace abandoned al terminar la ejecución; si la operación escribía, incluida network_send, la cinta pasa a UncertainExternalState. La reproducción entrega los resultados en el orden de la cinta y una entrega distinta de la grabada es replay_divergence.",
  "verificacion": [
    "C13",
    "C14",
    "C16"
  ]
}
```

```caso
{
  "id": "C13",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n2\n1\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 3,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 3,
          "task_id": 3,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 1
        },
        {
          "effect_seq": 2,
          "task_id": 2,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 3
        },
        {
          "effect_seq": 1,
          "task_id": 1,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "committed",
          "delivery_seq": 5
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Pause(label Como Entero)\nDescartar Aguardar SolicitarTemporizador();\nEscribir label;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Pause(1);\nLanzar Pause(2);\nLanzar Pause(3);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Pause(label as integer)\ndiscard await requestTimer();\nwrite label;\nendSubroutine\nalgorithm Main\ntasks\nspawn Pause(1);\nspawn Pause(2);\nspawn Pause(3);\nendTasks\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ],
    "grabar_y_reproducir": true,
    "orden_entrega": [
      3,
      2,
      1
    ]
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "done\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 0,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible",
      "efectos": [
        {
          "effect_seq": 1,
          "task_id": 1,
          "delivery_seq": 2,
          "capability_kind": "timer",
          "operation": "request_timer",
          "outcome": "abandoned"
        }
      ]
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Wait()\nDescartar Aguardar SolicitarTemporizador();\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nTareas failureReport\nLanzar Wait();\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nEscribir \"done\";\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait()\ndiscard await requestTimer();\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"problem\");\nendSubroutine\nalgorithm Main\ntasks failureReport\nspawn Wait();\nspawn Fail();\nendTasks\ndiscard failureReport;\nwrite \"done\";\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": [
      "temporizador"
    ],
    "requested_permissions": [
      "temporizador"
    ],
    "grabar_y_reproducir": true
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R3",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "200\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2,
      "estado_cinta": "reproducible",
      "efectos": [
        {"effect_seq": 1, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 2, "capability_kind": "network", "operation": "network_send", "outcome": "committed"}
      ]
    }
  },
  "programas": {
    "es": "Algoritmo Main\nDefinir net Como RedCap <- Propagar SolicitarRed();\nDefinir request Como PeticionHttp <- PeticionHttp(MetodoHttp.GET, \"https://fake.test/a\");\nDefinir response Como RespuestaHttp <- Propagar net.Enviar(request);\nEscribir response.Estado();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine net as NetworkCap <- propagate requestNetwork();\ndefine request as HttpRequest <- HttpRequest(HttpMethod.GET, \"https://fake.test/a\");\ndefine response as HttpResponse <- propagate net.send(request);\nwrite response.status();\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "grabar_y_reproducir": true,
    "http": {"GET https://fake.test/a": {"estado": 200}}
  }
}
```
```caso
{
  "id": "C16",
  "regla": "R6",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "done\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 1,
      "recursos_abiertos": 0,
      "estado_cinta": "uncertain_external_state",
      "efectos": [
        {"effect_seq": 1, "capability_kind": "network", "operation": "request_network", "outcome": "committed"},
        {"effect_seq": 2, "task_id": 1, "capability_kind": "network", "operation": "network_send", "outcome": "abandoned"}
      ]
    }
  },
  "programas": {
    "es": "SubProceso Suspendible Wait(net Como RedCap)\nDescartar Aguardar net.Enviar(PeticionHttp(MetodoHttp.POST, \"https://fake.test/abandoned-post\"));\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"problem\");\nFinSubProceso\nAlgoritmo Main\nDefinir net Como RedCap <- Propagar SolicitarRed();\nTareas failureReport\nLanzar Wait(net);\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nEscribir \"done\";\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait(net as NetworkCap)\ndiscard await net.send(HttpRequest(HttpMethod.POST, \"https://fake.test/abandoned-post\"));\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"problem\");\nendSubroutine\nalgorithm Main\ndefine net as NetworkCap <- propagate requestNetwork();\ntasks failureReport\nspawn Wait(net);\nspawn Fail();\nendTasks\ndiscard failureReport;\nwrite \"done\";\nendAlgorithm\n"
  },
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "grabar_y_reproducir": true
  }
}
```

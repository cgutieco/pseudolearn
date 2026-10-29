---
{
  "formato": "see/1",
  "id": "ENG.LIMITS",
  "titulo": "Límites de recursos del motor",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Límites deterministas de profundidad, sentencias, memoria y tiempo configurados por el anfitrión.",
  "depende_de": [
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.RECURSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "refina"
    },
    {
      "id": "LANG.ARRAY.DIMENSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "refina"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Engine resource limits"
}
---

# Límites de recursos del motor

```definicion
{
  "id": "D2",
  "termino": "límites externos y de JSON",
  "texto": "Los mínimos garantizados son max_http_body_bytes = 1048576 bytes decodificados, max_http_wire_bytes = 1048576 bytes en el cable, max_http_header_bytes = 16384, max_http_headers = 64, max_pending_network = 4, max_http_timeout_nanos = 30000000000 y max_json_depth = 64. La CLI fija respectivamente 8388608, 8388608, 16384, 64, 8, 30000000000 y 64; la app fija 1048576, 1048576, 16384, 64, 4, 15000000000 y 64. Los límites de red producen valores ErrorES y no terminaciones del programa. El transporte detiene la lectura al superar el límite efectivo más un byte."
}
```

```definicion
{
  "id": "D1",
  "termino": "unidades de recurso",
  "texto": "Profundidad: marcos activos, incluido el del algoritmo principal; cada llamada a un subprograma, método o constructor declarado añade un marco y las funciones incorporadas no lo hacen. Sentencias: entradas a sentencia ejecutadas, una por cada evento statement_entered. Celdas: suma sobre los valores alcanzables desde los marcos activos; un objeto ocupa una celda más una por campo, un arreglo una más una por elemento y una cadena creada en ejecución una más una por cada ocho puntos de código, redondeando hacia arriba. Los literales del programa, los escalares y el texto que Escribir produce como salida no ocupan celdas. Las raíces del conteo son las variables en ámbito de cada marco activo, incluidos parámetros y receptor, y los valores intermedios ya evaluados de la sentencia en curso. Una misma cadena creada en ejecución cuenta una sola vez mientras sea alcanzable aunque tenga varios alias; dos cadenas creadas por separado cuentan por separado aunque compartan bytes. Los temporales muertos no son raíces. Cinta: bytes serializados acumulados en EffectTape bajo el límite max_tape_bytes."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los límites son recursos del entorno que configura el anfitrión: profundidad, presupuesto de sentencias, celdas y guarda de tiempo. No forman parte del lenguaje ni requieren una edición nueva. Un programa que no alcanza ningún límite produce la misma salida, terminación y traza con cualquier configuración.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las tareas y los canales cuentan como celdas del montón: el almacenamiento de una tarea cuesta al menos una celda; un canal de capacidad c y ancho de elemento w, con w mínimo uno, cuesta 1 + c·w celdas; la continuación de una tarea suspendida cuesta una celda más sus ranuras, según ENG.TASK.MEMORY. Superar el límite de celdas al crearlos es un fallo del programa con cellLimitExceeded en el sitio de creación.",
  "verificacion": [
    "C20",
    "C21",
    "C22",
    "C23"
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
    "salida": "fin\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(1);\nEscribir \"fin\";\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "profundidad": 50,
    "sentencias": 100,
    "celdas": 64
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "fin\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(1);\nEscribir \"fin\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R11",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El anfitrión configura además el máximo de tareas vivas y el máximo de capacidad de un canal. Una tarea está viva desde su lanzamiento hasta que termina; la tarea raíz y las tareas terminadas no cuentan. Lanzar una tarea cuando ya hay tantas vivas como el máximo es un fallo del programa con taskLimitExceeded en el sitio del lanzamiento, sin efectos posteriores. Crear un canal cuya capacidad supera el máximo es un fallo del programa con channelCapacityExceeded; una capacidad igual al máximo se admite. Las omisiones son 4 096 tareas y 65 536 de capacidad.",
  "verificacion": [
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las unidades son deterministas e independientes de la plataforma y siguen la definición D1. La profundidad se comprueba al crear un marco; las sentencias, en cada entrada a sentencia; las celdas, en cada operación que crea un arreglo, un objeto o una cadena, contando también el valor nuevo.",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C17",
    "C18"
  ]
}
```

```caso
{
  "id": "C3",
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
    "salida": "fin\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(1);\nEscribir \"fin\";\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "profundidad": 3
  }
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "recursionDepthExceeded"
    }
  },
  "programa": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(1);\nEscribir \"fin\";\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "profundidad": 2
  }
}
```

```caso
{
  "id": "C5",
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
    "salida": "1\n2\n3\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "sentencias": 3
  }
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDimension a[10] Como Entero;\na[9] <- 1;\nEscribir a[9];\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 11
  }
}
```

```caso
{
  "id": "C7",
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
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "programa": "Algoritmo P\nDimension a[10] Como Entero;\na[9] <- 1;\nEscribir a[9];\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 10
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "abcd\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- \"ab\" + \"cd\";\nEscribir c;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 2
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "programa": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- \"ab\" + \"cd\";\nEscribir c;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 1
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La configuración por omisión de todo anfitrión admite al menos 1 000 marcos y 2²² celdas. No hay mínimo de sentencias: el presupuesto de sentencias es opcional. Un anfitrión puede configurar valores menores de forma explícita.",
  "verificacion": [
    "C10",
    "C11"
  ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "fin\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso f(n Como Entero)\nSi n > 0 Entonces\nf(n - 1);\nFinSi\nFinSubProceso\nAlgoritmo P\nf(998);\nEscribir \"fin\";\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```caso
{
  "id": "C11",
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
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDimension a[4194303] Como Entero;\na[0] <- 1;\nEscribir a[0];\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Agotar la profundidad o las celdas es un fallo del programa: la terminación es failed con recursionDepthExceeded o cellLimitExceeded. Agotar el presupuesto de sentencias o la guarda de tiempo es limit_reached, con el tipo de límite sentencias o tiempo; el presupuesto de sentencias emite además statementBudgetExhausted y la guarda de tiempo no emite diagnóstico. La guarda de tiempo se sondea en entradas a sentencia y evaluaciones de condición o prueba de bucle, incluidas las de bucles sin sentencias, sin efectos parciales del punto que la agota.",
  "verificacion": [
    "C12",
    "C13"
  ]
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
    "salida": "1\n2\n",
    "terminacion": "limit_reached",
    "limite": "sentencias",
    "diagnosticos": [
      {
        "codigo": "statementBudgetExhausted",
        "severidad": "info"
      }
    ]
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 2;\nEscribir 3;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "sentencias": 2
  }
}
```

```caso
{
  "id": "C13",
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
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "programa": "Algoritmo P\nDimension a[3, 3] Como Entero;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 9
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El límite se detecta exactamente en la entrada a sentencia, la llamada o la creación que lo supera, con el tramo que fija IR.SOURCE-MAP para esa sentencia, expresión de llamada u operación de creación, y ningún efecto posterior es visible.",
  "verificacion": [
    "C14"
  ]
}
```

```caso
{
  "id": "C14",
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
    "salida": "1\n",
    "fallo": {
      "codigo": "recursionDepthExceeded"
    },
    "diagnosticos": [
      {
        "codigo": "recursionDepthExceeded",
        "severidad": "error",
        "tramo": {
          "start": {
            "line": 2,
            "column": 1
          },
          "end": {
            "line": 2,
            "column": 4
          }
        },
        "argumentos": {
          "limit": 3
        }
      }
    ]
  },
  "programa": "SubProceso f()\nf();\nFinSubProceso\nAlgoritmo P\nEscribir 1;\nf();\nEscribir 2;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "profundidad": 3
  }
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La guarda de tiempo es la única terminación no determinista del contrato. Ningún caso la observa con un valor distinto de la ausencia de guarda.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El esquema de casos solo admite límites de profundidad, sentencias y celdas; ningún caso puede configurar una guarda de tiempo."
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ningún límite agota la pila del anfitrión ni produce DIAG.ENGINE.INTERNAL-FAULT, tampoco con recursión mutua ni sin configuración explícita.",
  "verificacion": [
    "C15",
    "C16"
  ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "recursionDepthExceeded"
    }
  },
  "programa": "SubProceso a()\nb();\nFinSubProceso\nSubProceso b()\na();\nFinSubProceso\nAlgoritmo P\na();\nFinAlgoritmo\n",
  "perfil_base": "es"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "recursionDepthExceeded"
    }
  },
  "programa": "SubProceso f()\nf();\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "profundidad": 1000
  }
}
```

```regla
{
  "id": "R8",
  "fuerza": "PUEDE",
  "clase": "semantica",
  "texto": "Los valores por omisión son informativos: la app usa 1 000 marcos; la CLI usa 100 000 marcos y ningún presupuesto de sentencias; la API usa los mínimos garantizados.",
  "verificacion": [
    "revision_humana"
  ],
  "justificacion": "Valores de producto de cada anfitrión; TOOL.CLI.RUN contiene casos que observan la profundidad por omisión de la CLI."
}
```

## Alcance

Este contrato cuantifica los recursos que LANG.SUBPROGRAM.RECURSION y LANG.ARRAY.DIMENSION delegan en el motor. Los casos fijan límites pequeños de forma explícita para observar los bordes: exactamente en el límite y uno por encima.

```caso
{
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
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable first Como Cadena <- \"\";\nDefinir Mutable second Como Cadena <- \"\";\nfirst <- \"a\" + \"b\";\nsecond <- first;\nfirst <- first + \"c\";\nEscribir first, \":\", second;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable first as string <- \"\";\ndefine mutable second as string <- \"\";\nfirst <- \"a\" + \"b\";\nsecond <- first;\nfirst <- first + \"c\";\nwrite first, \":\", second;\nendAlgorithm\n"
  },
  "espera": {
    "salida": "abc:ab\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 4
  },
  "id": "C17"
}
```

```caso
{
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
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable first Como Cadena <- \"\";\nDefinir Mutable second Como Cadena <- \"\";\nfirst <- \"a\" + \"b\";\nsecond <- first;\nfirst <- first + \"c\";\nEscribir first, \":\", second;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable first as string <- \"\";\ndefine mutable second as string <- \"\";\nfirst <- \"a\" + \"b\";\nsecond <- first;\nfirst <- first + \"c\";\nwrite first, \":\", second;\nendAlgorithm\n"
  },
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "limites": {
    "celdas": 3
  },
  "id": "C18"
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El presupuesto de la cinta de efectos (max_tape_bytes) no es una terminación del programa: agotarlo no cambia la salida ni la terminación, la ejecución en vivo continúa y solo la cinta se sella como no reproducible. Se mide en bytes serializados con corte exacto en max_tape_bytes.",
  "verificacion": [
    "C19"
  ]
}
```

```caso
{
  "id": "C19",
  "regla": "R9",
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
      "llamadas": 4,
      "recursos_abiertos": 0,
      "estado_cinta": "non_reproducible_truncated",
      "reproduccion_fallo": "replay_non_reproducible",
      "efectos": []
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir directory Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir file Como ArchivoCap <- Propagar directory.Abrir(\"a\", \"lectura\");\nDefinir first Como Cadena <- Propagar file.LeerTexto();\nDefinir second Como Cadena <- Propagar file.LeerTexto();\nRetornar Exito(2);\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine directory as DirCap <- propagate requestDirectory(\"root\");\ndefine file as FileCap <- propagate directory.open(\"a\", \"read\");\ndefine first as string <- propagate file.readText();\ndefine second as string <- propagate file.readText();\nreturn success(2);\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
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
  },
  "sujetos": [
    "engine",
    "aot"
  ]
}
```

## Colecciones e interfaces

Vector y Diccionario derivan sus límites del presupuesto cells existente: como máximo min(cells, u32 máximo menos dos) elementos y min(cells, u32 máximo) palabras de almacenamiento variable. Las palabras incluyen capacidad y metadatos variables, con ocho bytes por palabra. La cabecera fija no cuenta en ese almacenamiento variable. Una mutación comprueba límites, reservas y aritmética antes de publicar cambios. Vector consume una celda lógica más longitud por máximo entre uno y ancho; Diccionario consume una más longitud por uno más máximo entre uno y ancho de valor. Las referencias alcanzables se contabilizan sin doble conteo. Se conserva cellLimitExceeded para el presupuesto global y collectionLimitExceeded para el límite estructural.

```caso
{
  "id": "C20",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(5);\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<integer> <- channel(5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 6
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(5);\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<integer> <- channel(5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "limites": {
    "celdas": 5
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite \"w\";\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nspawn Work();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "w\nw\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 64
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R10",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite \"w\";\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nspawn Work();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "limites": {
    "celdas": 1
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nLanzar Work();\nFinTareas\nEscribir \"end\";\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite \"w\";\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nspawn Work();\nspawn Work();\nendTasks\nwrite \"end\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "w\nw\nw\nend\n",
    "terminacion": "completed"
  },
  "limites": {
    "tareas": 3
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nLanzar Work();\nLanzar Work();\nFinTareas\nEscribir \"end\";\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite \"w\";\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nspawn Work();\nspawn Work();\nspawn Work();\nendTasks\nwrite \"end\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "taskLimitExceeded"
    }
  },
  "limites": {
    "tareas": 3
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir \"w\";\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work();\nLanzar Work();\nFinTareas\nTareas\nLanzar Work();\nLanzar Work();\nFinTareas\nEscribir \"end\";\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite \"w\";\nendSubroutine\nalgorithm Main\ntasks\nspawn Work();\nspawn Work();\nendTasks\ntasks\nspawn Work();\nspawn Work();\nendTasks\nwrite \"end\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "w\nw\nw\nw\nend\n",
    "terminacion": "completed"
  },
  "limites": {
    "tareas": 2
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(8);\nEscribir \"ok\";\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<integer> <- channel(8);\nwrite \"ok\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ok\n",
    "terminacion": "completed"
  },
  "limites": {
    "capacidad_canal": 8
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(9);\nEscribir \"ok\";\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<integer> <- channel(9);\nwrite \"ok\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "channelCapacityExceeded"
    }
  },
  "limites": {
    "capacidad_canal": 8
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R11",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(65536);\nEscribir \"ok\";\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<integer> <- channel(65536);\nwrite \"ok\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ok\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 70000
  }
}
```

```regla
{
  "id": "R12",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "max_json_depth es un límite positivo configurable por el anfitrión. El valor predeterminado del motor y AOT es 64. Cada arreglo u objeto cuenta un nivel y el valor raíz contenedor cuenta como nivel uno; el límite se acepta y superarlo devuelve ProfundidadExcedida como resultado de AnalizarJson.",
  "verificacion": ["C35", "C36"]
}
```

```caso
{
  "id": "C35",
  "regla": "R12",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(\"[0]\");\nEscribir parsed.EsExito();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as Result<JsonValue, JsonError> <- parseJson(\"[0]\");\nwrite parsed.isSuccess();\nendAlgorithm\n"
  },
  "limites": {"max_json_depth": 1},
  "espera": {"salida": "Verdadero\n", "terminacion": "completed"}
}
```

```caso
{
  "id": "C36",
  "regla": "R12",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nDefinir parsed Como Resultado<ValorJson, ErrorJson> <- AnalizarJson(\"[[0]]\");\nEscribir parsed.EsExito();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parsed as Result<JsonValue, JsonError> <- parseJson(\"[[0]]\");\nwrite parsed.isSuccess();\nendAlgorithm\n"
  },
  "limites": {"max_json_depth": 1},
  "espera": {"salida": "Falso\n", "terminacion": "completed"}
}
```

```regla
{
  "id": "R13",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El anfitrión configura límites positivos de bytes HTTP, cabeceras, peticiones de red pendientes, tiempo externo y profundidad JSON según D2. El límite de profundidad JSON se aplica a cada arreglo y objeto con raíz en nivel uno. El exceso de bytes o de peticiones de red pendientes se entrega como LimiteExcedido; una petición que supera el máximo de pendientes no se envía al anfitrión. El agotamiento del plazo externo se entrega como TiempoAgotado; GET no es incierto y una mutación POST puede serlo después del envío. Estos errores son valores y mantienen la ejecución del programa. La profundidad excedida se representa como ProfundidadExcedida dentro del resultado de AnalizarJson.",
  "verificacion": ["C37"]
}
```

```caso
{
  "id": "C37",
  "regla": "R13",
  "perfiles": ["es", "en"],
  "rigor": ["estricto", "flexible"],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {"salida": "limite_excedido\ncontinuó\n", "terminacion": "completed"},
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir net Como RedCap <- Propagar SolicitarRed();\nSegun net.Enviar(PeticionHttp(MetodoHttp.GET, \"https://fake.test/limited\")) Hacer\nExito(response): Retornar Exito(0);\nError(problem): Retornar Error(problem);\nFinSegun\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir \"aceptada\";\nError(problem): Escribir problem.Codigo;\nFinSegun\nEscribir \"continuó\";\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine net as NetworkCap <- propagate requestNetwork();\nswitch net.send(HttpRequest(HttpMethod.GET, \"https://fake.test/limited\")) do\nsuccess(response): return success(0);\nfailure(problem): return failure(problem);\nendSwitch\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write \"accepted\";\nfailure(problem): write problem.code;\nendSwitch\nwrite \"continuó\";\nendAlgorithm\n"
  },
  "limites": {"max_http_body_bytes": 1},
  "anfitrion": {
    "permissions": ["red"],
    "requested_permissions": ["red"],
    "http": {"GET https://fake.test/limited": {"estado": 200, "cuerpo": "xy"}}
  }
}
```

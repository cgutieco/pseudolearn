---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.CLEANUP",
  "titulo": "Limpieza léxica diferida",
  "dominio": "lenguaje",
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
  "resumen": "Limpieza léxica diferida",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.GENERIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Limpieza léxica diferida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Diferir cuerpo FinDiferir registra limpieza del ámbito actual solo cuando se alcanza. Los nombres se resuelven al registrar y sus valores se leen al salir. No crea clausura. Cada limpieza alcanzada se ejecuta una sola vez y en orden inverso ante fin normal, Salir, Retornar o propagación fallida; cada iteración registra sus limpiezas propias. Los efectos no ocurren al registrar.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C8",
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDiferir\nEscribir 1;\nFinDiferir\nDiferir\nEscribir 2;\nFinDiferir\nEscribir 3;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefer\nwrite 1;\nendDefer\ndefer\nwrite 2;\nendDefer\nwrite 3;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n2\n1\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "Algoritmo Main\nDefinir Mutable value Como Entero <- 1;\nDiferir\nEscribir value;\nFinDiferir\nvalue <- 7;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine mutable value as integer <- 1;\ndefer\nwrite value;\nendDefer\nvalue <- 7;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nPara index <- 1 Hasta 2 Con Paso 1 Hacer\nDiferir\nEscribir index;\nFinDiferir\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\nfor index <- 1 to 2 step 1 do\ndefer\nwrite index;\nendDefer\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nSi Falso Entonces\nDiferir\nEscribir 9;\nFinDiferir\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm Main\nif false then\ndefer\nwrite 9;\nendDefer\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Retornar y Propagar evalúan y conservan su resultado antes de ejecutar limpiezas, incluidas cargas de referencia y variantes Resultado<T, ErrorES>, de modo que cerrar una capacidad con Diferir al retornar o propagar un ErrorES nunca oculta el error primario. Se rechazan Retornar, Salir, Propagar y otro Diferir dentro de una limpieza; una función literal interior posee contexto independiente. Una trampa del programa o de una limpieza termina inmediatamente sin ejecutar limpiezas pendientes. La cancelación cooperativa de tarea cancela y une primero a sus hijas y luego ejecuta las limpiezas pendientes en orden inverso. La cancelación del anfitrión detiene toda la ejecución sin ejecutar limpiezas.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C10",
    "C11",
    "C12",
    "C13"
  ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Wait() Como Resultado<Entero, Cadena>\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDiferir\nEscribir \"cleanup\";\nFinDiferir\nRetornar Exito(Propagar Aguardar timer.Esperar(100));\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo P\nTareas failure\nDefinir waiting Como Tarea<Entero> <- Lanzar Wait();\nDefinir failed Como Tarea<Entero> <- Lanzar Fail();\nFinTareas\nSegun failure Hacer\nNada: Escribir \"ok\";\nAlgo(problem): Escribir problem.Primero;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait() as result<integer, string>\ndefine timer as Timer <- propagate requestTimer();\ndefer\nwrite \"cleanup\";\nendDefer\nreturn success(propagate await timer.wait(100));\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nalgorithm P\ntasks failure\ndefine waiting as task<integer> <- spawn Wait();\ndefine failed as task<integer> <- spawn Fail();\nendTasks\nswitch failure do\nnone: write \"ok\";\nsome(problem): write problem.first;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "cleanup\nfailed\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "SubProceso value() Como Entero\nDefinir Mutable answer Como Entero <- 2;\nDiferir\nanswer <- 9;\nFinDiferir\nRetornar answer;\nFinSubProceso\nAlgoritmo Main\nEscribir value();\nFinAlgoritmo\n",
    "en": "subroutine value() as integer\ndefine mutable answer as integer <- 2;\ndefer\nanswer <- 9;\nendDefer\nreturn answer;\nendSubroutine\nalgorithm Main\nwrite value();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "SubProceso value() Como Entero\nDiferir\nRetornar 1;\nFinDiferir\nRetornar 2;\nFinSubProceso\nAlgoritmo Main\n\nFinAlgoritmo\n",
    "en": "subroutine value() as integer\ndefer\nreturn 1;\nendDefer\nreturn 2;\nendSubroutine\nalgorithm Main\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "controlTransferInsideCleanup",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "Algoritmo Main\nDiferir\nEscribir 1;\nFinDiferir\nEscribir 1 div 0;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefer\nwrite 1;\nendDefer\nwrite 1 div 0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "divisionByZero"
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nPara index <- 1 Hasta 3 Con Paso 1 Hacer\nDiferir\nEscribir index;\nFinDiferir\nSi index = 2 Entonces\nSalir;\nFinSi\nFinPara\nEscribir 9;\nFinAlgoritmo\n",
    "en": "algorithm Main\nfor index <- 1 to 3 step 1 do\ndefer\nwrite index;\nendDefer\nif index = 2 then\nbreak;\nendIf\nendFor\nwrite 9;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n2\n9\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDiferir\nEscribir 1;\nFinDiferir\nSi Verdadero Entonces\nDiferir\nEscribir 2;\nFinDiferir\nDiferir\nEscribir 3;\nFinDiferir\nFinSi\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefer\nwrite 1;\nendDefer\nif true then\ndefer\nwrite 2;\nendDefer\ndefer\nwrite 3;\nendDefer\nendIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n2\n1\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDiferir\nDiferir\nEscribir 1;\nFinDiferir\nFinDiferir\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefer\ndefer\nwrite 1;\nendDefer\nendDefer\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "controlTransferInsideCleanup",
        "severidad": "error"
      }
    ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso absent() Como Opcional<Entero>\nRetornar Nada;\nFinSubProceso\nSubProceso wrapped() Como Opcional<Cadena>\nDiferir\nEscribir 1;\nFinDiferir\nSi Verdadero Entonces\nDiferir\nEscribir 2;\nFinDiferir\nDefinir value Como Entero <- Propagar absent();\nEscribir value;\nFinSi\nRetornar Algo(\"unused\");\nFinSubProceso\nAlgoritmo Main\nDefinir outcome Como Opcional<Cadena> <- wrapped();\nSegun outcome Hacer\nAlgo(value): Escribir value;\nNada: Escribir \"empty\";\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine absent() as optional<integer>\nreturn none;\nendSubroutine\nsubroutine wrapped() as optional<string>\ndefer\nwrite 1;\nendDefer\nif true then\ndefer\nwrite 2;\nendDefer\ndefine value as integer <- propagate absent();\nwrite value;\nendIf\nreturn some(\"unused\");\nendSubroutine\nalgorithm Main\ndefine outcome as optional<string> <- wrapped();\nswitch outcome do\nsome(value): write value;\nnone: write \"empty\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n1\nempty\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso LeerConCierre() Como Resultado<Cadena, ErrorES>\nDefinir dir Como DirectorioCap <- Propagar SolicitarDirectorio(\"root\");\nDefinir f Como ArchivoCap <- Propagar dir.Abrir(\"malo.txt\", \"lectura\");\nDiferir\nDescartar f.Cerrar();\nDescartar dir.Cerrar();\nFinDiferir\nDefinir texto Como Cadena <- Propagar f.LeerTexto();\nRetornar Exito(texto);\nFinSubProceso\nAlgoritmo Main\nDefinir res Como Resultado<Cadena, ErrorES> <- LeerConCierre();\nSegun res Hacer\nExito(t): Escribir t;\nError(err): Escribir err.Codigo, \":\", err.Incierto;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine LeerConCierre() as result<string, IoError>\ndefine dir as DirCap <- propagate requestDirectory(\"root\");\ndefine f as FileCap <- propagate dir.open(\"malo.txt\", \"read\");\ndefer\ndiscard f.close();\ndiscard dir.close();\nendDefer\ndefine texto as string <- propagate f.readText();\nreturn success(texto);\nendSubroutine\nalgorithm Main\ndefine res as result<string, IoError> <- LeerConCierre();\nswitch res do\nsuccess(t): write t;\nfailure(err): write err.code, \":\", err.uncertain;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "anfitrion": {
    "permissions": [
      "archivos_lectura"
    ],
    "requested_permissions": [
      "archivos_lectura"
    ],
    "files": {
      "malo.txt": [255, 254]
    }
  },
  "espera": {
    "salida": "utf8_invalido:Falso\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 5,
      "recursos_abiertos": 0,
      "estado_cinta": "reproducible"
    }
  },
  "esperas": {
    "es": {
      "salida": "utf8_invalido:Falso\n",
      "terminacion": "completed",
      "anfitrion_observado": {
        "llamadas": 5,
        "recursos_abiertos": 0,
        "estado_cinta": "reproducible"
      }
    },
    "en": {
      "salida": "utf8_invalido:false\n",
      "terminacion": "completed",
      "anfitrion_observado": {
        "llamadas": 5,
        "recursos_abiertos": 0,
        "estado_cinta": "reproducible"
      }
    }
  }
}
```

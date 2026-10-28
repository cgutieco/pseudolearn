---
{
  "formato": "see/1",
  "id": "LANG.TASK.SCOPE",
  "titulo": "Ámbitos obligatorios de tareas",
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
  "resumen": "Ámbitos léxicos que poseen y unen a sus tareas hijas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TASK.SUSPENSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.CLEANUP",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "DIAG.CATALOG",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.BY-REFERENCE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EFFECT.TAPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ]
}
---

# Ámbitos obligatorios de tareas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Tareas [vínculo] … FinTareas abre un ámbito léxico, que puede estar vacío. Lanzar solo es válido en el cuerpo léxico directo del ámbito; una aparición fuera de él produce spawnOutsideTaskScope. Tareas o Lanzar dentro de Diferir producen taskScopeInsideDefer.",
  "verificacion": [
    "C1",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Lanzar nombra directamente una unidad suspendible y evalúa sus argumentos en el padre, de izquierda a derecha. Cada argumento debe ser transferible y no puede corresponder a un parámetro por referencia; las infracciones producen spawnTargetNotSuspendible, taskArgumentNotTransferable o taskByReferenceArgument. Lanzar crea una hija del ámbito actual sin ceder la ejecución del padre.",
  "verificacion": [
    "C1",
    "C8",
    "C9",
    "C10"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Lanzar una unidad que retorna T crea un asa local Tarea<T>; si retorna Resultado<T, E>, el asa contiene T y el ámbito conserva el error. Una unidad sin valor solo puede lanzarse como sentencia. La sentencia descarta el valor exitoso, nunca un error.",
  "verificacion": [
    "C1",
    "C2",
    "C11",
    "C17"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un asa solo se declara como vínculo inmutable Tarea<T> inicializado directamente por Lanzar dentro de su ámbito. Su único uso es Aguardar asa. Asignar, pasar, retornar, capturar, almacenar, comparar o escribir el asa produce taskHandleEscape. Aguardar el mismo asa más de una vez devuelve el mismo valor.",
  "verificacion": [
    "C11",
    "C12",
    "C13",
    "C14",
    "C17"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "FinTareas une a todas las hijas del ámbito. La tarea dueña espera si todavía hay hijas vivas y continúa sin suspender si ya terminaron. Ninguna hija sobrevive a su ámbito.",
  "verificacion": [
    "C1",
    "C3",
    "C4",
    "C18"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La cancelación cooperativa solo se solicita a una tarea que no está ejecutando y surte efecto al reanudarse, antes de otra sentencia fuera de Diferir. La tarea cancela y une primero a sus hijas vivas en orden de identidad; luego ejecuta sus limpiezas pendientes en orden inverso y termina cancelled. Un fallo de hermana solicita la misma cancelación y une el ámbito.",
  "verificacion": [
    "C15",
    "C16"
  ]
}
```

```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Dentro de una limpieza ejecutada por cancelación se permiten efectos sin Aguardar. Aguardar, Lanzar y Tareas siguen prohibidos estáticamente.",
  "verificacion": [
    "C6",
    "C7",
    "C15"
  ]
}
```

```regla
{
  "id": "R8",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Cancelar una tarea suspendida por un efecto concurrente la termina sin esperar al anfitrión y marca el efecto como abandoned. Si la respuesta llega después, se registra su entrega y se descarta; si la ejecución finaliza primero, la cinta sella abandoned. Una operación de escritura deja UncertainExternalState.",
  "verificacion": [
    "C19"
  ]
}
```

```regla
{
  "id": "R9",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La cancelación solicitada por el anfitrión conserva la semántica de ENG.EXEC.MODEL: detiene toda la ejecución de inmediato, no ejecuta limpiezas de tarea y sella la cinta como Incomplete.",
  "verificacion": [
    "C20"
  ]
}
```

```regla
{
  "id": "R10",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "Una trampa en cualquier tarea termina toda la ejecución como failed y no ejecuta limpiezas pendientes. La cancelación cooperativa de hermanos no convierte una trampa en un error de tarea recuperable.",
  "verificacion": [
    "C21"
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
    "es": "SubProceso Suspendible Print(value Como Entero)\nEscribir value;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Print(1);\nLanzar Print(2);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Print(value as integer)\nwrite value;\nendSubroutine\nalgorithm P\ntasks\nspawn Print(1);\nspawn Print(2);\nendTasks\nendAlgorithm\n"
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
    "es": "SubProceso Suspendible Crash()\nDiferir\nEscribir \"cleanup\";\nFinDiferir\nDefinir value Como Entero <- 1 / 0;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Crash();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Crash()\ndefer\nwrite \"cleanup\";\nendDefer\ndefine value as integer <- 1 / 0;\nendSubroutine\nalgorithm P\ntasks\nspawn Crash();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed"
  }
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite 1;\nendSubroutine\nalgorithm P\ntasks\nspawn Work();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nTareas\nTareas\nTareas\nLanzar Work();\nFinTareas\nFinTareas\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nwrite 1;\nendSubroutine\nalgorithm P\ntasks\ntasks\ntasks\nspawn Work();\nendTasks\nendTasks\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\nTareas\nFinTareas\nFinAlgoritmo\n",
    "en": "algorithm P\ntasks\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C5",
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
    "es": "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo P\nLanzar Work();\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nendSubroutine\nalgorithm P\nspawn Work();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "spawnOutsideTaskScope",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo P\nDiferir\nTareas\nLanzar Work();\nFinTareas\nFinDiferir\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nendSubroutine\nalgorithm P\ndefer\ntasks\nspawn Work();\nendTasks\nendDefer\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskScopeInsideDefer",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work()\nFinSubProceso\nAlgoritmo P\nTareas\nDiferir\nLanzar Work();\nFinDiferir\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work()\nendSubroutine\nalgorithm P\ntasks\ndefer\nspawn Work();\nendDefer\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskScopeInsideDefer",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso Suspendible Use(items Como Vector<Entero>)\nFinSubProceso\nAlgoritmo P\nDefinir items Como Vector<Entero> <- Vector<Entero>();\nTareas\nLanzar Use(items);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Use(items as vector<integer>)\nendSubroutine\nalgorithm P\ndefine items as vector<integer> <- vector<integer>();\ntasks\nspawn Use(items);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskArgumentNotTransferable",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso Suspendible Use(value Como Entero Por Referencia)\nFinSubProceso\nAlgoritmo P\nDefinir value Como Entero <- 1;\nTareas\nLanzar Use(value);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Use(value as integer by reference)\nendSubroutine\nalgorithm P\ndefine value as integer <- 1;\ntasks\nspawn Use(value);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskByReferenceArgument",
        "severidad": "error"
      }
    ]
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
    "es": "SubProceso Work()\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine Work()\nendSubroutine\nalgorithm P\ntasks\nspawn Work();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "spawnTargetNotSuspendible",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir t Como Tarea<Entero> <- Lanzar Work();\nDefinir other Como Tarea<Entero> <- Lanzar Work();\nt <- other;\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nalgorithm P\ntasks\ndefine t as task<integer> <- spawn Work();\ndefine other as task<integer> <- spawn Work();\nt <- other;\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskHandleEscape",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nSubProceso Leak() Como Tarea<Entero>\nTareas\nDefinir t Como Tarea<Entero> <- Lanzar Work();\nRetornar t;\nFinTareas\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Work();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nsubroutine Leak() as task<integer>\ntasks\ndefine t as task<integer> <- spawn Work();\nreturn t;\nendTasks\nendSubroutine\nalgorithm P\ntasks\nspawn Work();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskHandleEscape",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir t Como Tarea<Entero> <- Lanzar Work();\nDefinir closure Como SubProceso() <- SubProceso()\nDescartar t;\nFinSubProceso;\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nalgorithm P\ntasks\ndefine t as task<integer> <- spawn Work();\ndefine closure as subroutine() <- subroutine()\ndiscard t;\nendSubroutine;\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskHandleEscape",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Work() Como Entero\nRetornar 1;\nFinSubProceso\nSubProceso Consume(t Como Tarea<Entero>)\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir t Como Tarea<Entero> <- Lanzar Work();\nConsume(t);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work() as integer\nreturn 1;\nendSubroutine\nsubroutine Consume(t as task<integer>)\nendSubroutine\nalgorithm P\ntasks\ndefine t as task<integer> <- spawn Work();\nConsume(t);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskHandleEscape",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Wait() Como Entero\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDiferir\nEscribir \"cleanup\";\nFinDiferir\nRetornar Propagar Aguardar timer.Esperar(100);\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo P\nTareas failure\nDefinir waiting Como Tarea<Entero> <- Lanzar Wait();\nDefinir failed Como Tarea<Entero> <- Lanzar Fail();\nFinTareas\nSegun failure Hacer\nNada: Escribir \"ok\";\nAlgo(problem): Escribir problem.Primero;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait() as integer\ndefine timer as Timer <- propagate requestTimer();\ndefer\nwrite \"cleanup\";\nendDefer\nreturn propagate await timer.wait(100);\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nalgorithm P\ntasks failure\ndefine waiting as task<integer> <- spawn Wait();\ndefine failed as task<integer> <- spawn Fail();\nendTasks\nswitch failure do\nnone: write \"ok\";\nsome(problem): write problem.first;\nendSwitch\nendAlgorithm\n"
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
  "id": "C16",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Wait() Como Entero\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nDiferir\nEscribir \"grandchild\";\nFinDiferir\nRetornar Propagar Aguardar timer.Esperar(100);\nFinSubProceso\nSubProceso Suspendible Child()\nDiferir\nEscribir \"child\";\nFinDiferir\nTareas\nLanzar Wait();\nFinTareas\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo P\nTareas failure\nLanzar Child();\nLanzar Fail();\nFinTareas\nSegun failure Hacer\nNada: Escribir \"ok\";\nAlgo(problem): Escribir problem.Primero;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait() as integer\ndefine timer as Timer <- propagate requestTimer();\ndefer\nwrite \"grandchild\";\nendDefer\nreturn propagate await timer.wait(100);\nendSubroutine\nsubroutine suspendable Child()\ndefer\nwrite \"child\";\nendDefer\ntasks\nspawn Wait();\nendTasks\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nalgorithm P\ntasks failure\nspawn Child();\nspawn Fail();\nendTasks\nswitch failure do\nnone: write \"ok\";\nsome(problem): write problem.first;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "grandchild\nchild\nfailed\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Answer() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir answer Como Tarea<Entero> <- Lanzar Answer();\nEscribir Aguardar answer;\nEscribir Aguardar answer;\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Answer() as integer\nreturn 7;\nendSubroutine\nalgorithm P\ntasks\ndefine answer as task<integer> <- spawn Answer();\nwrite await answer;\nwrite await answer;\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Answer() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo P\nTareas\nDefinir answer Como Tarea<Entero> <- Lanzar Answer();\nEscribir Aguardar answer;\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Answer() as integer\nreturn 7;\nendSubroutine\nalgorithm P\ntasks\ndefine answer as task<integer> <- spawn Answer();\nwrite await answer;\nendTasks\nendAlgorithm\n"
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
  "id": "C19",
  "regla": "R8",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Wait() Como Entero\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nRetornar Propagar Aguardar timer.Esperar(100);\nFinSubProceso\nSubProceso Suspendible Fail() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Wait();\nLanzar Fail();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait() as integer\ndefine timer as Timer <- propagate requestTimer();\nreturn propagate await timer.wait(100);\nendSubroutine\nsubroutine suspendable Fail() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nalgorithm P\ntasks\nspawn Wait();\nspawn Fail();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed"
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R9",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso Suspendible Wait() Como Entero\nDiferir\nEscribir \"cleanup\";\nFinDiferir\nDefinir timer Como Temporizador <- Propagar SolicitarTemporizador();\nRetornar Propagar Aguardar timer.Esperar(100);\nFinSubProceso\nAlgoritmo P\nTareas\nLanzar Wait();\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Wait() as integer\ndefer\nwrite \"cleanup\";\nendDefer\ndefine timer as Timer <- propagate requestTimer();\nreturn propagate await timer.wait(100);\nendSubroutine\nalgorithm P\ntasks\nspawn Wait();\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "cancelacion": 3,
  "espera": {
    "salida": "",
    "terminacion": "cancelled"
  }
}
```

---
{
  "depende_de": [
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "tipo": "requiere",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "tipo": "requiere",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "LANG.CONTROL.CLEANUP",
      "tipo": "requiere",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "LANG.CAPABILITY.PURITY",
      "tipo": "requiere",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "DIAG.CATALOG",
      "tipo": "requiere",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "ENG.LIMITS",
      "tipo": "requiere",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "LIB.IO",
      "tipo": "usa",
      "version": ">=1.0.0, <2.0.0"
    },
    {
      "id": "LIB.TIME",
      "tipo": "usa",
      "version": ">=1.0.0, <2.0.0"
    }
  ],
  "dominio": "lenguaje",
  "duenos": [
    "responsable-especificaciones"
  ],
  "edicion": {
    "introducida_en": "2026"
  },
  "estado": "estable",
  "formato": "see/1",
  "id": "LANG.TASK.SUSPENSION",
  "resumen": "Identidad sintáctica y reglas estáticas de unidades suspendibles y espera explícita.",
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "titulo": "Funciones suspendibles y espera explícita",
  "titulo_en": "Suspendable subprograms and explicit await",
  "version": "1.0.0"
}
---

# Funciones suspendibles y espera explícita

La marca de suspensión es explícita en las unidades declaradas y contextual en la cabecera. El operador de espera es prefijo y está reservado. El análisis conserva todo el texto fuente y comprueba los contextos estáticos antes de permitir su uso.

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R1",
  "texto": "Una declaración SubProceso Suspendible declara una unidad que puede suspender. Proceso y Algoritmo son unidades raíz implícitamente suspendibles. La marca declara capacidad y no crea una tarea.",
  "verificacion": [
    "C1",
    "C2",
    "C11",
    "C13",
    "C15"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R2",
  "texto": "Una unidad suspendible no es un valor y no puede convertirse en valor de función. El modificador Suspendible no se admite en Funcion, métodos, constructores ni literales de función; estas posiciones producen suspendibleModifierNotAllowed. Usar una unidad suspendible en una posición de valor produce suspendibleAsValue.",
  "verificacion": [
    "C5",
    "C6"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R3",
  "texto": "Aguardar solo es válido dentro de una unidad suspendible o unidad raíz. Aguardar dentro de Diferir produce awaitInsideDefer y tiene precedencia sobre otros errores del mismo operando.",
  "verificacion": [
    "C7",
    "C8"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R4",
  "texto": "Aguardar acepta una llamada directa a una unidad suspendible o una operación de capacidad de LIB.IO o LIB.TIME. Cualquier otro operando produce awaitOperandInvalid.",
  "verificacion": [
    "C9"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R5",
  "texto": "Una llamada directa a una unidad suspendible debe estar cubierta inmediatamente por Aguardar; si no, produce suspendibleCallWithoutAwait. Aguardar una llamada ejecuta esa unidad en la tarea actual.",
  "verificacion": [
    "C10"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R6",
  "texto": "Aguardar puede ocupar cualquier posición de expresión. Las subexpresiones se evalúan de izquierda a derecha y los valores evaluados antes de la espera se conservan.",
  "verificacion": [
    "C3",
    "C4"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R7",
  "texto": "La profundidad de los marcos de unidades suspendibles se cuenta dentro de la tarea a la que pertenecen, según los límites de análisis y ejecución.",
  "verificacion": [
    "C12"
  ]
}
```

```regla
{
  "clase": "semantica",
  "fuerza": "DEBE",
  "id": "R8",
  "texto": "Aguardar un efecto ya resuelto entrega su valor y la ejecución puede terminar como completed sin producir awaiting_effect. Esta regla no exige una transición task_suspended.",
  "verificacion": [
    "C14"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C1",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nwrite 1;\nendSubroutine\nalgorithm P\nawait Worker();\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nAguardar Worker();\nFinAlgoritmo\n"
  },
  "regla": "R1",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C2",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable First()\nawait Second();\nendSubroutine\nsubroutine suspendable Second()\nawait Third();\nendSubroutine\nsubroutine suspendable Third()\nwrite 1;\nendSubroutine\nalgorithm P\nawait First();\nendAlgorithm\n",
    "es": "SubProceso Suspendible First()\nAguardar Second();\nFinSubProceso\nSubProceso Suspendible Second()\nAguardar Third();\nFinSubProceso\nSubProceso Suspendible Third()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nAguardar First();\nFinAlgoritmo\n"
  },
  "regla": "R1",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C3",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "algorithm P\ndefine clock as Clock <- propagate requestClock();\nwrite (propagate await clock.now()) + (propagate await clock.now());\nendAlgorithm\n",
    "es": "Algoritmo P\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nEscribir (Propagar Aguardar clock.Ahora()) + (Propagar Aguardar clock.Ahora());\nFinAlgoritmo\n"
  },
  "regla": "R6",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C4",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "function UseValue(value as integer) as integer\nreturn value;\nend function\nalgorithm P\ndefine clock as Clock <- propagate requestClock();\nwrite UseValue(propagate await clock.now());\nendAlgorithm\n",
    "es": "Funcion UseValue(value Como Entero) Como Entero\nRetornar value;\nFinFuncion\nAlgoritmo P\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nEscribir UseValue(Propagar Aguardar clock.Ahora());\nFinAlgoritmo\n"
  },
  "regla": "R6",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "suspendibleModifierNotAllowed",
        "severidad": "error"
      }
    ]
  },
  "id": "C5",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "function suspendable Calculate() as integer\nreturn 1;\nend function\nalgorithm P\nwrite Calculate();\nendAlgorithm\n",
    "es": "Funcion Suspendible Calculate() Como Entero\nRetornar 1;\nFinFuncion\nAlgoritmo P\nEscribir Calculate();\nFinAlgoritmo\n"
  },
  "regla": "R2",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "suspendibleAsValue",
        "severidad": "error"
      }
    ]
  },
  "id": "C6",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nendSubroutine\nalgorithm P\ndefine action as subroutine() <- Worker;\nwrite action;\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nFinSubProceso\nAlgoritmo P\nDefinir action Como SubProceso() <- Worker;\nEscribir action;\nFinAlgoritmo\n"
  },
  "regla": "R2",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "awaitOutsideSuspendible",
        "severidad": "error"
      }
    ]
  },
  "id": "C7",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nwrite 1;\nendSubroutine\nsubroutine Caller()\nawait Worker();\nendSubroutine\nalgorithm P\nCaller();\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nEscribir 1;\nFinSubProceso\nSubProceso Caller()\nAguardar Worker();\nFinSubProceso\nAlgoritmo P\nCaller();\nFinAlgoritmo\n"
  },
  "regla": "R3",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "awaitInsideDefer",
        "severidad": "error"
      }
    ]
  },
  "id": "C8",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nwrite 1;\nendSubroutine\nsubroutine suspendable Caller()\ndefer\nawait Worker();\nendDefer\nendSubroutine\nalgorithm P\nawait Caller();\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nEscribir 1;\nFinSubProceso\nSubProceso Suspendible Caller()\nDiferir\nAguardar Worker();\nFinDiferir\nFinSubProceso\nAlgoritmo P\nAguardar Caller();\nFinAlgoritmo\n"
  },
  "regla": "R3",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "awaitOperandInvalid",
        "severidad": "error"
      }
    ]
  },
  "id": "C9",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "algorithm P\nwrite await 1;\nendAlgorithm\n",
    "es": "Algoritmo P\nEscribir Aguardar 1;\nFinAlgoritmo\n"
  },
  "regla": "R4",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "suspendibleCallWithoutAwait",
        "severidad": "error"
      }
    ]
  },
  "id": "C10",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nendSubroutine\nalgorithm P\nWorker();\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nFinSubProceso\nAlgoritmo P\nWorker();\nFinAlgoritmo\n"
  },
  "regla": "R5",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C11",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nwrite 1;\nendSubroutine\nalgorithm P\nawait Worker();\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nAguardar Worker();\nFinAlgoritmo\n"
  },
  "regla": "R1",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C12",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Recurse(level as integer)\nif level > 0 then\nawait Recurse(level - 1);\nendIf\nwrite 0;\nendSubroutine\nalgorithm P\nawait Recurse(3);\nendAlgorithm\n",
    "es": "SubProceso Suspendible Recurse(level Como Entero)\nSi level > 0 Entonces\nAguardar Recurse(level - 1);\nFinSi\nEscribir 0;\nFinSubProceso\nAlgoritmo P\nAguardar Recurse(3);\nFinAlgoritmo\n"
  },
  "regla": "R7",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C13",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable A()\nwrite 1;\nendSubroutine\nalgorithm P\nawait A();\nendAlgorithm\n",
    "es": "SubProceso Suspendible A()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nAguardar A();\nFinAlgoritmo\n"
  },
  "regla": "R1",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```


```caso
{
  "anfitrion": {
    "clock": [
      100
    ],
    "grabar_y_reproducir": true,
    "permissions": [
      "reloj"
    ],
    "requested_permissions": [
      "reloj"
    ]
  },
  "espera": {
    "salida": "100\n",
    "terminacion": "completed"
  },
  "id": "C14",
  "operacion": "execute",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "algorithm Main\ndefine clock as Clock <- propagate requestClock();\nswitch await clock.now() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n",
    "es": "Algoritmo Main\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nSegun Aguardar clock.Ahora() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n"
  },
  "regla": "R8",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```caso
{
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "id": "C15",
  "operacion": "analyze",
  "origen": "derivado",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "en": "subroutine suspendable Worker()\nendSubroutine\nalgorithm P\ndefine suspendable as integer <- 1;\nwrite suspendable;\nendAlgorithm\n",
    "es": "SubProceso Suspendible Worker()\nFinSubProceso\nAlgoritmo P\nDefinir Suspendible Como Entero <- 1;\nEscribir Suspendible;\nFinAlgoritmo\n"
  },
  "regla": "R1",
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

---
{
  "formato": "see/1",
  "id": "LANG.TYPES.RELATIONS",
  "titulo": "Relaciones de tipos",
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
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Relaciones de tipos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.REAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.CLASS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Relaciones de tipos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Igualdad de tipos, asignabilidad y ampliación numérica son relaciones diferentes. Se admite entero a real por ampliación y subclase a superclase por nominalidad. No se convierten implícitamente real a entero, lógico a número, cadena a carácter ni primitivos a texto. Parámetros por referencia exigen coincidencia exacta de tipo.",
  "verificacion": [
    "C1",
    "C2"
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
  "programas": {
    "es": "Algoritmo P\nDefinir value Como Real <- 2;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as real <- 2;\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
  "programas": {
    "es": "Algoritmo P\nDefinir value Como Entero <- 2.5;\nEscribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as integer <- 2.5;\nwrite value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleTypesInAssignment",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Opcional<T> es una variante incorporada con alternativas Nada y Algo(valor). T es un tipo concreto admitido, incluido otro Opcional o Resultado. El contexto declarado fija el tipo de Nada y de los constructores anidados; Algo sin contexto puede inferir T desde su carga útil, pero un constructor ambiguo es ambiguousVariantType. La consulta se expresa mediante Segun con patrones; no hay extracción que atrape ni conversión implícita a T. Una referencia presente nunca usa el centinela de Nada; Opcional<Opcional<T>> distingue Nada de Algo(Nada).",
  "verificacion": [
    "C3",
    "C4",
    "C5",
    "C6",
    "C21"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Resultado<T,E> es una variante incorporada con alternativas Exito(valor) y Error(error). Sus argumentos son concretos y cada carga útil debe ser asignable al tipo declarado de su alternativa. La identidad depende de ambos argumentos, no de su disposición; tipos genéricos definidos por la persona quedan fuera de alcance. Los constructores necesitan un contexto que determine ambos argumentos. El valor no admite escritura, comparación, acceso a campos ni paso por referencia; se consulta mediante patrones.",
  "verificacion": [
    "C7",
    "C8",
    "C9",
    "C18",
    "C19",
    "C20"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Propagar expresión evalúa una variante una sola vez. En Opcional produce la carga útil de Algo o retorna Nada desde una función con retorno Opcional. En Resultado produce la carga útil de Exito o retorna Error desde una función con retorno Resultado y exactamente el mismo tipo E; no convierte el error ni lo descarta. Los tipos T de origen y retorno pueden ser distintos. El uso fuera de una función de retorno compatible es incompatiblePropagationType. La propagación fallida ejecuta las limpiezas de los ámbitos abandonados en orden inverso, conservando antes su carga útil y sin limpiar ante una trampa fatal.",
  "verificacion": [
    "C10",
    "C11",
    "C12",
    "C13"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un Resultado producido por una llamada en posición de sentencia, guardado en un vínculo sin tratar, sobrescrito antes de tratarlo o recibido como parámetro y abandonado es resultNotHandled. Se trata con Segun exhaustivo, Propagar, retorno o transferencia como argumento a un consumidor tipado. Descartar expresión evalúa exactamente un Resultado y expresa su descarte deliberado; no acepta otros tipos. Debe quedar tratado en todos los caminos que terminan normalmente o retornan desde la función. No se exige limpieza ante una trampa fatal.",
  "verificacion": [
    "C14",
    "C15",
    "C16",
    "C17"
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
  "programas": {
    "es": "Algoritmo Main\nDefinir value Como Opcional<Entero> <- Algo(7);\nSegun value Hacer\nAlgo(value): Escribir value;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine value as optional<integer> <- some(7);\nswitch value do\nsome(value): write value;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
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
  "programas": {
    "es": "Algoritmo Main\nDefinir value Como Opcional<Opcional<Entero>> <- Algo(Nada);\nSegun value Hacer\nAlgo(inner): Segun inner Hacer\nAlgo(value): Escribir value;\nNada: Escribir 2;\nFinSegun\nNada: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine value as optional<optional<integer>> <- some(none);\nswitch value do\nsome(inner): switch inner do\nsome(value): write value;\nnone: write 2;\nendSwitch\nnone: write 1;\nendSwitch\nendAlgorithm\n"
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
    "es": "Algoritmo Main\nDefinir value Como Opcional<Entero> <- Error(1);\nSegun value Hacer\nAlgo(payload): Escribir payload;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine value as optional<integer> <- failure(1);\nswitch value do\nsome(payload): write payload;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleVariantConstructor",
        "severidad": "error"
      }
    ]
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
    "es": "Clase Holder\nDefinir amount Como Entero;\nFinClase\nAlgoritmo Main\nDefinir holder Como Holder <- Nuevo Holder();\nholder.amount <- 9;\nDefinir value Como Opcional<Holder> <- Algo(holder);\nSegun value Hacer\nAlgo(found): Escribir found.amount;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "class Holder\ndefine amount as integer;\nendClass\nalgorithm Main\ndefine holder as Holder <- new Holder();\nholder.amount <- 9;\ndefine value as optional<Holder> <- some(holder);\nswitch value do\nsome(found): write found.amount;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
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
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Exito(4);\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<integer, string> <- success(4);\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Error(\"bad\");\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<integer, string> <- failure(\"bad\");\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "bad\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
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
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Exito(\"bad\");\nDescartar outcome;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<integer, string> <- success(\"bad\");\ndiscard outcome;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleArgumentType",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "SubProceso First() Como Resultado<Entero, Cadena>\nRetornar Error(\"failed\");\nFinSubProceso\nSubProceso Second() Como Resultado<Entero, Cadena>\nDefinir value Como Entero <- Propagar First();\nRetornar Exito(value + 1);\nFinSubProceso\nSubProceso Third() Como Resultado<Cadena, Cadena>\nDefinir value Como Entero <- Propagar Second();\nEscribir value;\nRetornar Exito(\"done\");\nFinSubProceso\nAlgoritmo Main\nDefinir outcome Como Resultado<Cadena, Cadena> <- Third();\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine First() as result<integer, string>\nreturn failure(\"failed\");\nendSubroutine\nsubroutine Second() as result<integer, string>\ndefine value as integer <- propagate First();\nreturn success(value + 1);\nendSubroutine\nsubroutine Third() as result<string, string>\ndefine value as integer <- propagate Second();\nwrite value;\nreturn success(\"done\");\nendSubroutine\nalgorithm Main\ndefine outcome as result<string, string> <- Third();\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "failed\n",
    "terminacion": "completed"
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
    "es": "SubProceso First() Como Opcional<Entero>\nRetornar Nada;\nFinSubProceso\nSubProceso Second() Como Opcional<Cadena>\nDefinir value Como Entero <- Propagar First();\nEscribir value;\nRetornar Algo(\"done\");\nFinSubProceso\nAlgoritmo Main\nDefinir outcome Como Opcional<Cadena> <- Second();\nSegun outcome Hacer\nAlgo(value): Escribir value;\nNada: Escribir \"empty\";\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine First() as optional<integer>\nreturn none;\nendSubroutine\nsubroutine Second() as optional<string>\ndefine value as integer <- propagate First();\nwrite value;\nreturn some(\"done\");\nendSubroutine\nalgorithm Main\ndefine outcome as optional<string> <- Second();\nswitch outcome do\nsome(value): write value;\nnone: write \"empty\";\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "empty\n",
    "terminacion": "completed"
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
    "es": "SubProceso First() Como Resultado<Entero, Entero>\nRetornar Error(4);\nFinSubProceso\nSubProceso Second() Como Resultado<Entero, Cadena>\nDefinir value Como Entero <- Propagar First();\nRetornar Exito(value);\nFinSubProceso\nAlgoritmo Main\nDescartar Second();\nFinAlgoritmo\n",
    "en": "subroutine First() as result<integer, integer>\nreturn failure(4);\nendSubroutine\nsubroutine Second() as result<integer, string>\ndefine value as integer <- propagate First();\nreturn success(value);\nendSubroutine\nalgorithm Main\ndiscard Second();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatiblePropagationType",
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
    "es": "SubProceso First() Como Resultado<Entero, Cadena>\nRetornar Exito(3);\nFinSubProceso\nSubProceso Second() Como Resultado<Entero, Cadena>\nDefinir value Como Entero <- Propagar First();\nRetornar Exito(value + 1);\nFinSubProceso\nSubProceso Third() Como Resultado<Cadena, Cadena>\nDefinir value Como Entero <- Propagar Second();\nEscribir value;\nRetornar Exito(\"done\");\nFinSubProceso\nAlgoritmo Main\nDescartar Third();\nFinAlgoritmo\n",
    "en": "subroutine First() as result<integer, string>\nreturn success(3);\nendSubroutine\nsubroutine Second() as result<integer, string>\ndefine value as integer <- propagate First();\nreturn success(value + 1);\nendSubroutine\nsubroutine Third() as result<string, string>\ndefine value as integer <- propagate Second();\nwrite value;\nreturn success(\"done\");\nendSubroutine\nalgorithm Main\ndiscard Third();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  }
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
  "programas": {
    "es": "SubProceso Produce() Como Resultado<Entero, Cadena>\nRetornar Exito(1);\nFinSubProceso\nAlgoritmo Main\nProduce();\nFinAlgoritmo\n",
    "en": "subroutine Produce() as result<integer, string>\nreturn success(1);\nendSubroutine\nalgorithm Main\nProduce();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "resultNotHandled",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C15",
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
    "es": "SubProceso Produce() Como Resultado<Entero, Cadena>\nRetornar Exito(1);\nFinSubProceso\nAlgoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Produce();\nFinAlgoritmo\n",
    "en": "subroutine Produce() as result<integer, string>\nreturn success(1);\nendSubroutine\nalgorithm Main\ndefine outcome as result<integer, string> <- Produce();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "resultNotHandled",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
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
    "es": "SubProceso Produce() Como Resultado<Entero, Cadena>\nRetornar Exito(1);\nFinSubProceso\nAlgoritmo Main\nDescartar Produce();\nFinAlgoritmo\n",
    "en": "subroutine Produce() as result<integer, string>\nreturn success(1);\nendSubroutine\nalgorithm Main\ndiscard Produce();\nendAlgorithm\n"
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
  "id": "C17",
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
    "es": "Algoritmo Main\nDescartar 1;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndiscard 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "discardRequiresResult",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C18",
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
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Real, Cadena> <- Exito(2.5);\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<real, string> <- success(2.5);\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.5\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Entero, Cadena> <- Exito((-9223372036854775807 - 1));\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<integer, string> <- success((-9223372036854775807 - 1));\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-9223372036854775808\n",
    "terminacion": "completed"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir outcome Como Resultado<Logico, Cadena> <- Exito(Falso);\nSegun outcome Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine outcome as result<boolean, string> <- success(false);\nswitch outcome do\nsuccess(value): write value;\nfailure(problem): write problem;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanFalse}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
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
    "es": "Clase Holder\nDefinir amount Como Entero;\nFinClase\nAlgoritmo Main\nDefinir value Como Opcional<Holder> <- Nada;\nSegun value Hacer\nAlgo(found): Escribir found.amount;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "class Holder\ndefine amount as integer;\nendClass\nalgorithm Main\ndefine value as optional<Holder> <- none;\nswitch value do\nsome(found): write found.amount;\nnone: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
}
```

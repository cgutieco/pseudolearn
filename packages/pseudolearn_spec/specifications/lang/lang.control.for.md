---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.FOR",
  "titulo": "Bucle contado",
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
  "resumen": "Bucle contado.",
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "edicion": {
    "introducida_en": "2026"
  }
}
---

# Bucle contado

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Inicial, final y paso se evalúan una sola vez antes de la primera prueba, en ese orden.",
  "verificacion": [
    "C1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Paso cero impide ejecutar el cuerpo y termina con zeroStepInCountedLoop.",
  "verificacion": [
    "C3",
    "C4"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La prueba precede al cuerpo y es inclusiva; la dirección depende solo del signo del paso.",
  "verificacion": [
    "C4",
    "C5",
    "C6",
    "C7",
    "C16",
    "C17"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La cabecera introduce un control entero local al bucle después de evaluar inicial, final y paso. Al salir termina su ámbito; no modifica un vínculo exterior homónimo. El sombreado produce bindingShadowsOuter. Usarlo fuera sin vínculo exterior produce bindingOutsideScope. Excepción: si el bloque inmediato de la sentencia contiene una variable homónima de tipo Entero declarada con Definir, que no es parámetro, no tiene valor y no se ha leído ni escrito, salvo como control de otro Para de ese mismo bloque, la cabecera la reutiliza como control: no se produce bindingShadowsOuter y la declaración no produce variableDeclaredNeverUsed. El control sigue siendo local al bucle, de modo que esa variable continúa sin valor después de él. En cualquier otro caso se aplica el sombreado.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Modificar la variable de control en el cuerpo se rechaza con controlVariableModified como error.",
  "verificacion": [
    "C8",
    "C9",
    "C14",
    "C15"
  ]
}
```

```error
{
  "id": "E1",
  "situacion": "paso cero",
  "clase": "ejecucion",
  "codigo": "zeroStepInCountedLoop",
  "severidad": "A"
}
```

```error
{
  "id": "E2",
  "situacion": "modificación del control",
  "clase": "semantica",
  "codigo": "controlVariableModified",
  "severidad": "A"
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
    "es": "Algoritmo P\n  Definir bound Como Entero <- 0;\n  bound <- 3;\n  Para counter <- 1 Hasta bound Con Paso 1 Hacer\n    bound <- 10;\n    Escribir counter Sin Saltar;\n  FinPara\n  Escribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\n  define bound as integer <- 0;\n  bound <- 3;\n  for counter <- 1 to bound step 1 do\n    bound <- 10;\n    write counter without newline;\n  endFor\n  write \"\";\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "123\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 1 Hasta 3 Hacer\n    Escribir counter Sin Saltar;\n  FinPara\n  Escribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 1 to 3 do\n    write counter without newline;\n  endFor\n  write \"\";\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "123\n",
    "terminacion": "completed"
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 1 Hasta 3 Con Paso 0 Hacer\n    Escribir counter;\n  FinPara\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 1 to 3 step 0 do\n    write counter;\n  endFor\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "zeroStepInCountedLoop"
    },
    "diagnosticos": [
      {
        "codigo": "zeroStepInCountedLoop",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "produce": [
    "E1"
  ]
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 1 Hasta 3 Con Paso 1 Hacer\n    Escribir counter Sin Saltar;\n  FinPara\n  Escribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 1 to 3 step 1 do\n    write counter without newline;\n  endFor\n  write \"\";\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "123\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "evita": [
    "E1"
  ]
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 10 Hasta 0 Con Paso 1 Hacer\n    Escribir counter;\n  FinPara\n  Escribir counter;\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 10 to 0 step 1 do\n    write counter;\n  endFor\n  write counter;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingOutsideScope",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 10 Hasta 0 Con Paso -4 Hacer\n    Escribir counter, \" \" Sin Saltar;\n  FinPara\n  Escribir \"/\", counter;\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 10 to 0 step -4 do\n    write counter, \" \" without newline;\n  endFor\n  write \"/\", counter;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingOutsideScope",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 3 Hasta 3 Con Paso 1 Hacer\n    Escribir counter;\n  FinPara\n  Escribir counter;\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 3 to 3 step 1 do\n    write counter;\n  endFor\n  write counter;\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingOutsideScope",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 1 Hasta 3 Con Paso 1 Hacer\n    counter <- counter + 1;\n  FinPara\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 1 to 3 step 1 do\n    counter <- counter + 1;\n  endFor\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "diagnosticos": [
      {
        "codigo": "controlVariableModified",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "produce": [
    "E2"
  ]
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
  "programas": {
    "es": "Algoritmo P\n  Para counter <- 1 Hasta 3 Con Paso 1 Hacer\n    Escribir counter;\n  FinPara\nFinAlgoritmo\n",
    "en": "algorithm P\n  for counter <- 1 to 3 step 1 do\n    write counter;\n  endFor\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "evita": [
    "E2"
  ]
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El control es un identificador entero; límites y paso son enteros. La cláusula Con Paso es opcional: su ausencia equivale a Con Paso 1, también cuando el valor inicial supera al final, en cuyo caso el cuerpo no se ejecuta. El incremento usa aritmética entera comprobada, también tras la última iteración válida. El cuerpo vacío es admisible.",
  "verificacion": [
    "C2",
    "C10",
    "C11",
    "C12",
    "C13",
    "C18",
    "C19",
    "C20",
    "C21"
  ]
}
```

```caso
{
  "id": "C10",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara counter <- 1 Hasta 0 Con Paso 1 Hacer\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor counter <- 1 to 0 step 1 do\nendFor\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "completed"
  },
  "origen": "derivado"
}
```

```caso
{
  "id": "C11",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara counter <- 1 Hasta 2 Hacer\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor counter <- 1 to 2 do\nendFor\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "origen": "derivado"
}
```

```caso
{
  "id": "C12",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara counter <- 1 Hasta 2.5 Con Paso 1 Hacer\nEscribir counter;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor counter <- 1 to 2.5 step 1 do\nwrite counter;\nendFor\nendAlgorithm\n"
  },
  "operacion": "analyze",
  "espera": {
    "diagnosticos": [
      {
        "codigo": "nonIntegerForBound",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado"
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
  "programas": {
    "es": "Algoritmo P\nPara counter <- 9223372036854775807 Hasta 9223372036854775807 Con Paso 1 Hacer\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor counter <- 9223372036854775807 to 9223372036854775807 step 1 do\nendFor\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "integerOverflow"
    }
  },
  "origen": "derivado"
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
  "programas": {
    "es": "Algoritmo P\nPara index <- 1 Hasta 1 Con Paso 1 Hacer\nLeer index;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor index <- 1 to 1 step 1 do\nread index;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "controlVariableModified",
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
  "programas": {
    "es": "SubProceso touch(value Como Entero Por Referencia)\nvalue <- 2;\nFinSubProceso\nAlgoritmo P\nPara index <- 1 Hasta 1 Con Paso 1 Hacer\ntouch(index);\nFinPara\nFinAlgoritmo\n",
    "en": "subroutine touch(value as integer by reference)\nvalue <- 2;\nendSubroutine\nalgorithm P\nfor index <- 1 to 1 step 1 do\ntouch(index);\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "controlVariableModified",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara index <- 10 Hasta 0 Con Paso -4 Hacer\nEscribir index;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor index <- 10 to 0 step -4 do\nwrite index;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "10\n6\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara index <- 3 Hasta 3 Con Paso 1 Hacer\nEscribir index;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor index <- 3 to 3 step 1 do\nwrite index;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara i <- 1 Hasta 3 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\nfor i <- 1 to 3 do\nwrite i without newline;\nendFor\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "123\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara i <- 3 Hasta 1 Hacer\nEscribir i;\nFinPara\nEscribir \"fin\";\nFinAlgoritmo\n",
    "en": "algorithm P\nfor i <- 3 to 1 do\nwrite i;\nendFor\nwrite \"fin\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "fin\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara i <- 1 Hasta 1 Hacer\nEscribir i;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\nfor i <- 1 to 1 do\nwrite i;\nendFor\nendAlgorithm\n"
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
  "id": "C21",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nPara i <- 3 Hasta 1 Con Paso -1 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\nfor i <- 3 to 1 step -1 do\nwrite i without newline;\nendFor\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "321\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir i Como Entero;\nPara i <- 1 Hasta 3 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine i as integer;\nfor i <- 1 to 3 do\nwrite i without newline;\nendFor\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "123\n",
    "terminacion": "completed",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir i, n Como Entero;\nn <- 2;\nPara i <- 1 Hasta n Hacer\nEscribir i Sin Saltar;\nFinPara\nPara i <- n Hasta 1 Con Paso -1 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine i, n as integer;\nn <- 2;\nfor i <- 1 to n do\nwrite i without newline;\nendFor\nfor i <- n to 1 step -1 do\nwrite i without newline;\nendFor\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir i Como Real;\nPara i <- 1 Hasta 3 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine i as real;\nfor i <- 1 to 3 do\nwrite i without newline;\nendFor\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableDeclaredNeverUsed",
        "severidad": "advertencia"
      },
      {
        "codigo": "bindingShadowsOuter",
        "severidad": "advertencia"
      }
    ]
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir i Como Entero <- 0;\nPara i <- 1 Hasta 3 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine i as integer <- 0;\nfor i <- 1 to 3 do\nwrite i without newline;\nendFor\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableDeclaredNeverUsed",
        "severidad": "advertencia"
      },
      {
        "codigo": "bindingShadowsOuter",
        "severidad": "advertencia"
      }
    ]
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir i Como Entero;\nPara i <- 1 Hasta 3 Hacer\nEscribir i Sin Saltar;\nFinPara\nEscribir i;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine i as integer;\nfor i <- 1 to 3 do\nwrite i without newline;\nendFor\nwrite i;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableUsedUninitialized",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir i Como Entero;\nSi Verdadero Entonces\nPara i <- 1 Hasta 3 Hacer\nEscribir i Sin Saltar;\nFinPara\nFinSi\nEscribir \"\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine i as integer;\nif true then\nfor i <- 1 to 3 do\nwrite i without newline;\nendFor\nendIf\nwrite \"\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "variableDeclaredNeverUsed",
        "severidad": "advertencia"
      },
      {
        "codigo": "bindingShadowsOuter",
        "severidad": "advertencia"
      }
    ]
  }
}
```

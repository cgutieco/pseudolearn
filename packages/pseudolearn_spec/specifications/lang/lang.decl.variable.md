---
{
  "formato": "see/1",
  "id": "LANG.DECL.VARIABLE",
  "titulo": "Declaración de variables",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Declaración de variables.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de variables

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Definir n₁, …, nₖ Como tipo declara k variables locales sin valor, en el orden escrito. Con un único nombre se admite un valor inicial <- expresión, que comprueba el tipo y no puede leer la variable que declara (bindingReadsOwnInitializer); con varios nombres el valor inicial es initializerWithMultipleNames, error. Toda variable declarada con Definir y todo parámetro por valor se puede reasignar, usar como destino de Leer y pasar por referencia; no hay forma de declararla constante con Definir. Siguen sin poder reasignarse la variable de control de Para (controlVariableModified) y los vínculos que introducen Para Cada, los patrones de variante y las tareas (immutableBindingAssignment). Mutable no es palabra reservada: es un identificador ordinario. Los campos, parámetros y arreglos conservan sus contratos específicos. Un nombre de un carácter es válido; repetir un nombre en la lista o en el mismo ámbito es duplicateVariableDeclaration. La mutación de un objeto no reasigna su vínculo; escribir un campo de registro por valor modifica la variable.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13"
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
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nDefinir value Como Entero <- 2;\nEscribir x, value;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\ndefine value as integer <- 2;\nwrite x, value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "12\n",
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
  "programas": {
    "es": "Algoritmo P\nDefinir Como Entero;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine as integer;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedIdentifierInDeclaration",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nwrite x;\nendAlgorithm\n"
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nx <- 2;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nx <- 2;\nwrite x;\nendAlgorithm\n"
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
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable x Como Entero <- 1;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable x as integer <- 1;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedTypeConnector",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- x;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "bindingReadsOwnInitializer",
        "severidad": "error"
      }
    ]
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
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable Como Entero <- 1;\nEscribir Mutable;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable as integer <- 1;\nwrite mutable;\nendAlgorithm\n"
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
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir x Como Entero <- 1;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine x as integer <- 1;\nread x;\nwrite x;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  },
  "entradas": [
    "7"
  ]
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
  "programas": {
    "es": "Algoritmo P\nDefinir a, b, c Como Entero;\na <- 1;\nb <- 2;\nc <- a + b;\nEscribir a, b, c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine a, b, c as integer;\na <- 1;\nb <- 2;\nc <- a + b;\nwrite a, b, c;\nendAlgorithm\n"
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
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir a, b Como Entero <- 1;\nEscribir a;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine a, b as integer <- 1;\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "initializerWithMultipleNames",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir a, a Como Entero;\na <- 1;\nEscribir a;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine a, a as integer;\na <- 1;\nwrite a;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateVariableDeclaration",
        "severidad": "error",
        "argumentos": {
          "lexeme": "a"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Definir n Como Entero <- 1;\n  Definir n Como Entero;\n  Escribir n;\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Define n As Integer <- 1;\n  Define n As Integer;\n  Write n;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateVariableDeclaration",
        "severidad": "error",
        "argumentos": {
          "lexeme": "n"
        }
      }
    ]
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Datos\n  Definir nombre Como Cadena;\n  Definir edad Como Entero;\n  Definir altura Como Real <- 1.62;\n  nombre <- \"Ana\";\n  edad <- 15;\n  Escribir nombre, \" \", edad;\n  Escribir altura;\nFinAlgoritmo\n",
    "en": "Algorithm Profile\n  Define name As String;\n  Define age As Integer;\n  Define height As Real <- 1.62;\n  name <- \"Ana\";\n  age <- 15;\n  Write name, \" \", age;\n  Write height;\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Ana 15\n1.62\n",
    "terminacion": "completed"
  }
}
```

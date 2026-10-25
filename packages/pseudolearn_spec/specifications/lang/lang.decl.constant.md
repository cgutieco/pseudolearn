---
{
  "formato": "see/1",
  "id": "LANG.DECL.CONSTANT",
  "titulo": "Declaración de constantes",
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
  "resumen": "Constantes de módulo y locales con valor calculado al analizar.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.OPS.ARITHMETIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de constantes

Una constante fija un valor que no cambia y que el motor conoce antes de ejecutar.

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Constante nombre Como tipo <- expresión declara un valor fijo, en el módulo o dentro del cuerpo de un algoritmo, subproceso o método. El tipo es entero, real, lógico, carácter, cadena o un enumerado, y el inicializador es obligatorio con las conversiones de la asignación. El nombre no se repite entre constantes y variables de su ámbito; la constante no admite asignación. Una constante de módulo es privada del módulo y visible en todo él; una local es visible desde su declaración hasta el cierre de su ámbito léxico, como los demás vínculos. Usar una constante equivale a escribir su valor y no ocupa variable en ejecución.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El inicializador se calcula al analizar el programa con el mismo resultado que en ejecución. Admite literales, otras constantes, miembros de enumerado, agrupación, los signos unarios, NO, las operaciones + - * / div mod, las comparaciones, Y, O y la concatenación de cadenas y caracteres; no admite variables, llamadas, potencia ni construcciones de objeto o registro. El cálculo entero se comprueba en 64 bits: el desbordamiento es constantArithmeticOverflow y todo divisor cero es constantDivisionByZero. Lo que no pertenece al subconjunto es constantNotEvaluable.",
  "verificacion": [
    "C7",
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
  "texto": "Una constante que depende de sí misma, directa o indirectamente, es circularConstantDefinition con un solo diagnóstico por ciclo. El cálculo tiene un presupuesto de 10000 pasos y de 65536 bytes por valor de texto; superarlo es constantBudgetExceeded. Un valor de exactamente 65536 bytes cabe en el presupuesto.",
  "verificacion": [
    "C11",
    "C12",
    "C13",
    "C16"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una constante sin inicializador es expectedConstantInitializer y sin nombre es expectedConstantName; el tipo del valor se comprueba como en una asignación.",
  "verificacion": [
    "C14",
    "C15"
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
    "es": "Constante A Como Entero <- 2;\nConstante B Como Entero <- A * 3 + 1;\nAlgoritmo P\nEscribir A, B;\nFinAlgoritmo\n",
    "en": "constant A as integer <- 2;\nconstant B as integer <- A * 3 + 1;\nalgorithm P\nwrite A, B;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "27\n",
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
    "es": "Algoritmo P\nConstante R Como Real <- 0.1 + 0.2;\nEscribir R, 0.1 + 0.2;\nFinAlgoritmo\n",
    "en": "algorithm P\nconstant R as real <- 0.1 + 0.2;\nwrite R, 0.1 + 0.2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.300000000000000040.30000000000000004\n",
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante T Como Cadena <- \"ab\" + \"c\";\nConstante V Como Logico <- 3 > 2 Y NO Falso;\nConstante Q Como Real <- 2;\nAlgoritmo P\nEscribir T, V, Q;\nFinAlgoritmo\n",
    "en": "constant T as string <- \"ab\" + \"c\";\nconstant V as boolean <- 3 > 2 and not false;\nconstant Q as real <- 2;\nalgorithm P\nwrite T, V, Q;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "abc{{lexema:booleanTrue}}2.0\n",
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante A Como Entero <- 1;\nAlgoritmo P\nA <- 2;\nFinAlgoritmo\n",
    "en": "constant A as integer <- 1;\nalgorithm P\nA <- 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constantReassigned",
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

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante A Como Entero <- 1;\nConstante A Como Entero <- 2;\nAlgoritmo P\nEscribir A;\nFinAlgoritmo\n",
    "en": "constant A as integer <- 1;\nconstant A as integer <- 2;\nalgorithm P\nwrite A;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateVariableDeclaration",
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

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nConstante A Como Entero <- 1;\nDefinir A Como Entero <- 0;\nEscribir A;\nFinAlgoritmo\n",
    "en": "algorithm P\nconstant A as integer <- 1;\ndefine A as integer <- 0;\nwrite A;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateVariableDeclaration",
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

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante M Como Entero <- 9223372036854775807 + 1;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant M as integer <- 9223372036854775807 + 1;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constantArithmeticOverflow",
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

```caso
{
  "id": "C8",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante Z Como Entero <- 1 div 0;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant Z as integer <- 1 div 0;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constantDivisionByZero",
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

```caso
{
  "id": "C9",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante Z Como Real <- 1 / 0;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant Z as real <- 1 / 0;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constantDivisionByZero",
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

```caso
{
  "id": "C10",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante C Como Entero <- 2 ^ 3;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant C as integer <- 2 ^ 3;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constantNotEvaluable",
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

```caso
{
  "id": "C11",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante A Como Entero <- A;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant A as integer <- A;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "circularConstantDefinition",
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

```caso
{
  "id": "C12",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante A Como Entero <- B;\nConstante B Como Entero <- A;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant A as integer <- B;\nconstant B as integer <- A;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "circularConstantDefinition",
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

```caso
{
  "id": "C13",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante S1 Como Cadena <- \"ab\";\nConstante S2 Como Cadena <- S1 + S1;\nConstante S3 Como Cadena <- S2 + S2;\nConstante S4 Como Cadena <- S3 + S3;\nConstante S5 Como Cadena <- S4 + S4;\nConstante S6 Como Cadena <- S5 + S5;\nConstante S7 Como Cadena <- S6 + S6;\nConstante S8 Como Cadena <- S7 + S7;\nConstante S9 Como Cadena <- S8 + S8;\nConstante S10 Como Cadena <- S9 + S9;\nConstante S11 Como Cadena <- S10 + S10;\nConstante S12 Como Cadena <- S11 + S11;\nConstante S13 Como Cadena <- S12 + S12;\nConstante S14 Como Cadena <- S13 + S13;\nConstante S15 Como Cadena <- S14 + S14;\nConstante S16 Como Cadena <- S15 + S15;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant S1 as string <- \"ab\";\nconstant S2 as string <- S1 + S1;\nconstant S3 as string <- S2 + S2;\nconstant S4 as string <- S3 + S3;\nconstant S5 as string <- S4 + S4;\nconstant S6 as string <- S5 + S5;\nconstant S7 as string <- S6 + S6;\nconstant S8 as string <- S7 + S7;\nconstant S9 as string <- S8 + S8;\nconstant S10 as string <- S9 + S9;\nconstant S11 as string <- S10 + S10;\nconstant S12 as string <- S11 + S11;\nconstant S13 as string <- S12 + S12;\nconstant S14 as string <- S13 + S13;\nconstant S15 as string <- S14 + S14;\nconstant S16 as string <- S15 + S15;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
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
    "es": "Constante S1 Como Cadena <- \"ab\";\nConstante S2 Como Cadena <- S1 + S1;\nConstante S3 Como Cadena <- S2 + S2;\nConstante S4 Como Cadena <- S3 + S3;\nConstante S5 Como Cadena <- S4 + S4;\nConstante S6 Como Cadena <- S5 + S5;\nConstante S7 Como Cadena <- S6 + S6;\nConstante S8 Como Cadena <- S7 + S7;\nConstante S9 Como Cadena <- S8 + S8;\nConstante S10 Como Cadena <- S9 + S9;\nConstante S11 Como Cadena <- S10 + S10;\nConstante S12 Como Cadena <- S11 + S11;\nConstante S13 Como Cadena <- S12 + S12;\nConstante S14 Como Cadena <- S13 + S13;\nConstante S15 Como Cadena <- S14 + S14;\nConstante S16 Como Cadena <- S15 + S15;\nConstante S17 Como Cadena <- S16 + S16;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant S1 as string <- \"ab\";\nconstant S2 as string <- S1 + S1;\nconstant S3 as string <- S2 + S2;\nconstant S4 as string <- S3 + S3;\nconstant S5 as string <- S4 + S4;\nconstant S6 as string <- S5 + S5;\nconstant S7 as string <- S6 + S6;\nconstant S8 as string <- S7 + S7;\nconstant S9 as string <- S8 + S8;\nconstant S10 as string <- S9 + S9;\nconstant S11 as string <- S10 + S10;\nconstant S12 as string <- S11 + S11;\nconstant S13 as string <- S12 + S12;\nconstant S14 as string <- S13 + S13;\nconstant S15 as string <- S14 + S14;\nconstant S16 as string <- S15 + S15;\nconstant S17 as string <- S16 + S16;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "constantBudgetExceeded",
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

```caso
{
  "id": "C14",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante A Como Entero;\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant A as integer;\nalgorithm P\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedConstantInitializer",
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

```caso
{
  "id": "C15",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Constante A Como Entero <- \"x\";\nAlgoritmo P\nFinAlgoritmo\n",
    "en": "constant A as integer <- \"x\";\nalgorithm P\nendAlgorithm\n"
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

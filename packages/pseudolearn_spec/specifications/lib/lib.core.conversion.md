---
{
  "formato": "see/1",
  "id": "LIB.CORE.CONVERSION",
  "titulo": "Conversiones explícitas",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Conversiones explícitas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.IO.VALUE-FORMAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Conversiones explícitas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "ATexto acepta cualquier primitivo y usa exactamente formato de salida. AEntero y AReal aceptan cadena decimal y producen entero en rango o real finito. Texto inválido produce stringToNumberConversionFailed; no devuelve cero. No convierte implícitamente objetos/arreglos, ni modifica la cadena original.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
    "es": "Algoritmo P\nEscribir ATexto(2), \":\", AEntero(\"12\"), \":\", AReal(\"2.5\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toText(2), \":\", toInteger(\"12\"), \":\", toReal(\"2.5\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:12:2.5\n",
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
    "es": "Algoritmo P\nEscribir AEntero(\"no\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toInteger(\"no\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringToNumberConversionFailed"
    }
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
    "es": "Algoritmo P\nEscribir AReal(\"no\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toReal(\"no\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringToNumberConversionFailed"
    }
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
    "es": "Algoritmo P\nEscribir AEntero(2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toInteger(2);\nendAlgorithm\n"
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

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Decimales(valor, cantidad) devuelve la cadena del valor con exactamente cantidad decimales fijos, con cantidad entre 0 y 100. Calcula sobre la expansión decimal exacta del número binario64 y redondea los empates alejándolos de cero; con cantidad 0 omite el punto decimal. Acepta un real o un entero, que se amplía a real, y conserva el signo: el cero negativo y un negativo que redondea a cero se muestran con signo. No usa separadores de miles ni configuración regional. Una cantidad negativa o mayor que 100 produce decimalPlacesOutOfRange. Un real no finito se muestra con su forma de salida habitual. La cadena devuelta cuenta celdas como cualquier cadena. Un primer argumento que no es numérico, una cantidad que no es entera o una aridad distinta de dos se rechaza antes de la ejecución.",
  "verificacion": [
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15"
  ]
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
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(2.5, 0);\nEscribir Decimales(-2.5, 0);\nEscribir Decimales(0.125, 2);\nEscribir Decimales(7, 2);\nEscribir Decimales(1.005, 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(2.5, 0);\nwrite decimals(-2.5, 0);\nwrite decimals(0.125, 2);\nwrite decimals(7, 2);\nwrite decimals(1.005, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n-3\n0.13\n7.00\n1.00\n",
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
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(0.1, 20);\nEscribir Decimales(10000000000.0 * 1000000000000.0, 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(0.1, 20);\nwrite decimals(10000000000.0 * 1000000000000.0, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.10000000000000000555\n10000000000000000000000.00\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "Algoritmo P\nDefinir z Como Real <- 0.0;\nEscribir Decimales(-z, 2);\nEscribir Decimales(z, 2);\nEscribir Decimales(-0.001, 2);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine z as real <- 0.0;\nwrite decimals(-z, 2);\nwrite decimals(z, 2);\nwrite decimals(-0.001, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-0.00\n0.00\n-0.00\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(AReal(\"5e-324\"), 3);\nEscribir Decimales(1, 100);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(toReal(\"5e-324\"), 3);\nwrite decimals(1, 100);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.000\n1.0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000\n",
    "terminacion": "completed"
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
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(1.0, 101);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(1.0, 101);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "decimalPlacesOutOfRange"
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
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(1.0, -1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(1.0, -1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "decimalPlacesOutOfRange"
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
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(\"a\", 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(\"a\", 2);\nendAlgorithm\n"
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
  "id": "C12",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(1.5, 2.5);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(1.5, 2.5);\nendAlgorithm\n"
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
  "id": "C13",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Decimales(1.5);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite decimals(1.5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "argumentCountMismatch",
        "severidad": "error"
      }
    ]
  }
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
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- Decimales(1.5, 1);\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- decimals(1.5, 1);\nwrite c;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1.5\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 2
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- Decimales(1.5, 1);\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- decimals(1.5, 1);\nwrite c;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "limites": {
    "celdas": 1
  }
}
```

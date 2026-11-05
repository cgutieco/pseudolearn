---
{
  "formato": "see/1",
  "id": "LIB.CORE.TEXT",
  "titulo": "Funciones de texto y carácter",
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
  "resumen": "Funciones de texto y carácter.",
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
      "id": "LANG.TYPES.CHARACTER",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Funciones de texto y carácter

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Longitud cuenta puntos de código de cadena, también vacía. CaracterEn(cadena, índice) devuelve carácter cero basado o stringPositionOutOfRange. CodigoDe(caracter) devuelve su escalar Unicode. CaracterDesde(entero) exige [0,1114111] excluyendo [55296,57343] y falla con invalidCharacterCode fuera de ese dominio. No normalizan contenido.",
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
    "es": "Algoritmo P\nEscribir Longitud(\"😀a\"), \":\", CaracterEn(\"😀a\", 0), \":\", CodigoDe(\"😀\"), \":\", CaracterDesde(128512);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite length(\"😀a\"), \":\", charAt(\"😀a\", 0), \":\", charCode(\"😀\"), \":\", charFromCode(128512);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:😀:128512:😀\n",
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
    "es": "Algoritmo P\nEscribir CaracterEn(\"ab\", 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charAt(\"ab\", 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringPositionOutOfRange"
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
    "es": "Algoritmo P\nEscribir CaracterDesde(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "invalidCharacterCode"
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
    "es": "Algoritmo P\nEscribir CaracterDesde(1114112);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(1114112);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "invalidCharacterCode"
    }
  }
}
```

```regla
{
  "id": "T1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Subcadena, Concatenar, Contiene, PosicionDe, EmpiezaCon, TerminaCon, Reemplazar, Dividir, Unir y Recortar son funciones puras sobre Cadena. Operan por puntos de código, no normalizan ni dependen de configuración regional y no modifican sus argumentos.",
  "verificacion": [
    "C5",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C15",
    "C16",
    "C44"
  ]
}
```

```regla
{
  "id": "T2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Subcadena(c, desde, hasta) usa posiciones desde cero e incluye ambas: es válida si 0 ≤ desde ≤ hasta + 1 ≤ Longitud(c), desde igual a hasta + 1 da la cadena vacía y en otro caso produce stringPositionOutOfRange. Concatenar(a, b) devuelve los puntos de código de a seguidos de los de b, igual que a + b. Contiene de la cadena vacía devuelve Verdadero; PosicionDe devuelve la primera coincidencia y Algo(0) para la parte vacía. EmpiezaCon y TerminaCon aceptan una parte vacía. Reemplazar sustituye todas las coincidencias sin solaparse y deja la cadena intacta si se busca la cadena vacía. Dividir con separador vacío produce emptySeparator y dividir la cadena vacía devuelve un vector con una cadena vacía. Unir un vector vacío devuelve la cadena vacía. Recortar solo quita U+0020, U+0009, U+000A y U+000D de los extremos.",
  "verificacion": [
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C16",
    "C44",
    "C45",
    "C46",
    "C47",
    "C48",
    "C49",
    "C50"
  ]
}
```

```regla
{
  "id": "T3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cada cadena creada por estas funciones cuenta las celdas de ejecución con la misma regla que cualquier otra cadena creada en ejecución.",
  "verificacion": [
    "C5",
    "C6",
    "C8",
    "C11",
    "C12",
    "C15",
    "C17",
    "C18"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "T1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"a😀b\", 1, 1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"a😀b\", 1, 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "😀\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir \"<\", Subcadena(\"ab\", 2, 1), \">\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"<\", substring(\"ab\", 2, 1), \">\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "<>\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"abc\", 2, 3);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"abc\", 2, 3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C8",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Contiene(\"abc\", \"\"), \":\", Contiene(\"abc\", \"b\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite contains(\"abc\", \"\"), \":\", contains(\"abc\", \"b\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}:{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir found Como Opcional<Entero> <- PosicionDe(\"abcabc\", \"bc\");\nSegun found Hacer\nNada: Escribir -1;\nAlgo(position): Escribir position;\nFinSegun\nDefinir empty Como Opcional<Entero> <- PosicionDe(\"abc\", \"\");\nSegun empty Hacer\nNada: Escribir -1;\nAlgo(position): Escribir position;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine found as optional<integer> <- indexOf(\"abcabc\", \"bc\");\nswitch found do\nnone: write -1;\nsome(position): write position;\nendSwitch\ndefine empty as optional<integer> <- indexOf(\"abc\", \"\");\nswitch empty do\nnone: write -1;\nsome(position): write position;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir EmpiezaCon(\"abc\", \"\"), \":\", TerminaCon(\"abc\", \"\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite startsWith(\"abc\", \"\"), \":\", endsWith(\"abc\", \"\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}:{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Reemplazar(\"aaaa\", \"aa\", \"x\"), \":\", Reemplazar(\"abc\", \"\", \"x\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite replace(\"aaaa\", \"aa\", \"x\"), \":\", replace(\"abc\", \"\", \"x\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "xx:abc\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parts Como Vector<Cadena> <- Dividir(\"a,,b\", \",\");\nEscribir Unir(parts, \"|\");\nDefinir empty Como Vector<Cadena> <- Dividir(\"\", \",\");\nEscribir empty.Longitud(), \":\", Unir(empty, \",\");\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parts as vector<string> <- split(\"a,,b\", \",\");\nwrite join(parts, \"|\");\ndefine empty as vector<string> <- split(\"\", \",\");\nwrite empty.length(), \":\", join(empty, \",\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "a||b\n1:\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDividir(\"abc\", \"\");\nFinAlgoritmo\n",
    "en": "algorithm P\nsplit(\"abc\", \"\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "emptySeparator"
    }
  }
}
```

```caso
{
  "id": "C14",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir parts Como Vector<Cadena> <- Vector();\nEscribir \"<\", Unir(parts, \",\"), \">\";\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine parts as vector<string> <- vector();\nwrite \"<\", join(parts, \",\"), \">\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "<>\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Recortar(\" \\t\\r\\nx \\r\\n\\t\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite trim(\" \\t\\r\\nx \\r\\n\\t\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "x\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "T1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Recortar(\" x \");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite trim(\" x \");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": " x \n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C17",
  "regla": "T3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- Recortar(\" x \");\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- trim(\" x \");\nwrite c;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "x\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 2
  }
}
```

```caso
{
  "id": "C18",
  "regla": "T3",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- Recortar(\" x \");\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- trim(\" x \");\nwrite c;\nendAlgorithm\n"
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

```regla
{
  "id": "T4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "AMayusculas y AMinusculas convierten una cadena con las correspondencias Unicode completas de mayúsculas y minúsculas, independientes de la configuración regional y de la plataforma, en la versión de Unicode que el README del motor declara. Una letra puede producir varias (ß produce SS al pasar a mayúsculas), U+0130 produce i seguida de U+0307 al pasar a minúsculas y Σ produce ς al final de palabra y σ en el resto. No normalizan, dejan intactos los puntos de código sin correspondencia, no modifican su argumento y la cadena devuelta cuenta celdas como T3. Un argumento que no es cadena o una aridad distinta de uno se rechaza antes de la ejecución. Mayusculas y Minusculas son alias en español de AMayusculas y AMinusculas con la misma identidad y semántica.",
  "verificacion": [
    "C19",
    "C20",
    "C21",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "C30",
    "C51"
  ]
}
```

```caso
{
  "id": "C19",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMayusculas(\"Hola 42\");\nEscribir AMinusculas(\"Hola 42\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toUpper(\"Hola 42\");\nwrite toLower(\"Hola 42\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "HOLA 42\nhola 42\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C20",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMayusculas(\"\");\nEscribir AMinusculas(\"\");\nEscribir AMayusculas(\"ABC\");\nEscribir AMinusculas(\"abc\");\nEscribir AMayusculas(\"a\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toUpper(\"\");\nwrite toLower(\"\");\nwrite toUpper(\"ABC\");\nwrite toLower(\"abc\");\nwrite toUpper(\"a\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "\n\nABC\nabc\nA\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C21",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMayusculas(\"é\");\nEscribir AMinusculas(\"É\");\nEscribir AMayusculas(\"ǆ\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toUpper(\"é\");\nwrite toLower(\"É\");\nwrite toUpper(\"ǆ\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "É\né\nǄ\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C22",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMayusculas(\"straße\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toUpper(\"straße\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "STRASSE\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMinusculas(\"İ\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toLower(\"İ\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "i̇\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMinusculas(\"ΑΣ\");\nEscribir AMinusculas(\"ΑΣΑ\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toLower(\"ΑΣ\");\nwrite toLower(\"ΑΣΑ\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ας\nασα\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMayusculas(\"é😀\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toUpper(\"é😀\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "É😀\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C26",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir texto Como Cadena <- \"abc\";\nDefinir mayus Como Cadena <- AMayusculas(texto);\nEscribir texto, mayus;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine texto as string <- \"abc\";\ndefine mayus as string <- toUpper(texto);\nwrite texto, mayus;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "abcABC\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C27",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMayusculas(1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toUpper(1);\nendAlgorithm\n"
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
  "id": "C28",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir AMinusculas();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite toLower();\nendAlgorithm\n"
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
  "id": "C29",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- AMayusculas(\"ab\");\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- toUpper(\"ab\");\nwrite c;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "AB\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 2
  }
}
```

```caso
{
  "id": "C30",
  "regla": "T4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- AMayusculas(\"ab\");\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- toUpper(\"ab\");\nwrite c;\nendAlgorithm\n"
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

```regla
{
  "id": "T5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "RellenarIzquierda(texto, ancho, relleno) y RellenarDerecha(texto, ancho, relleno) devuelven el texto precedido o seguido de copias de relleno hasta que la cadena tenga ancho puntos de código. El relleno es textual: no trata el signo de forma especial. Un texto que ya alcanza o supera el ancho se devuelve sin recortar. El relleno, Cadena o Caracter, debe tener exactamente un punto de código; en otro caso se produce invalidPaddingText. Un ancho negativo produce paddingWidthOutOfRange y un ancho mayor que 16777216 produce cellLimitExceeded sin construir la cadena. El resultado cuenta celdas como T3. Un argumento de tipo distinto o una aridad distinta de tres se rechaza antes de la ejecución.",
  "verificacion": [
    "C31",
    "C32",
    "C33",
    "C34",
    "C35",
    "C36",
    "C37",
    "C38",
    "C39",
    "C40",
    "C41",
    "C42",
    "C43"
  ]
}
```

```caso
{
  "id": "C31",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"7\", 3, \"0\");\nEscribir RellenarDerecha(\"7\", 3, \".\");\nEscribir RellenarIzquierda(\"-5\", 4, \"0\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"7\", 3, \"0\");\nwrite padRight(\"7\", 3, \".\");\nwrite padLeft(\"-5\", 4, \"0\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "007\n7..\n00-5\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C32",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"abcd\", 2, \"0\");\nEscribir RellenarDerecha(\"\", 0, \"x\");\nEscribir RellenarIzquierda(\"\", 2, \"x\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"abcd\", 2, \"0\");\nwrite padRight(\"\", 0, \"x\");\nwrite padLeft(\"\", 2, \"x\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "abcd\n\nxx\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C33",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"é😀\", 4, \"-\");\nEscribir RellenarDerecha(\"a\", 2, \"😀\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"é😀\", 4, \"-\");\nwrite padRight(\"a\", 2, \"😀\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "--é😀\na😀\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C34",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"7\", 3, CaracterDesde(48));\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"7\", 3, charFromCode(48));\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "007\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C35",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"a\", 3, \"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"a\", 3, \"ab\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "invalidPaddingText"
    }
  }
}
```

```caso
{
  "id": "C36",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarDerecha(\"a\", 3, \"\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padRight(\"a\", 3, \"\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "invalidPaddingText"
    }
  }
}
```

```caso
{
  "id": "C37",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"a\", -1, \"0\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"a\", -1, \"0\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "paddingWidthOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C38",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarDerecha(\"a\", 16777217, \"0\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padRight(\"a\", 16777217, \"0\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  }
}
```

```caso
{
  "id": "C39",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"a\", \"3\", \"0\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"a\", \"3\", \"0\");\nendAlgorithm\n"
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
  "id": "C40",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"a\", 3);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"a\", 3);\nendAlgorithm\n"
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
  "id": "C41",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- RellenarIzquierda(\"a\", 3, \"0\");\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- padLeft(\"a\", 3, \"0\");\nwrite c;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "00a\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 7
  }
}
```

```caso
{
  "id": "C42",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir Mutable c Como Cadena <- \"\";\nc <- RellenarIzquierda(\"a\", 3, \"0\");\nEscribir c;\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine mutable c as string <- \"\";\nc <- padLeft(\"a\", 3, \"0\");\nwrite c;\nendAlgorithm\n"
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
    "celdas": 2
  }
}
```

```caso
{
  "id": "C43",
  "regla": "T5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir RellenarIzquierda(\"x\", 3, \"é\");\nEscribir RellenarDerecha(\"x\", 3, \"é\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite padLeft(\"x\", 3, \"é\");\nwrite padRight(\"x\", 3, \"é\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ééx\nxéé\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C44",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Concatenar(\"a\", \"\"), Concatenar(\"\", \"b\"), Concatenar(\"ho\", \"la\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite concat(\"a\", \"\"), concat(\"\", \"b\"), concat(\"ho\", \"la\");\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "abhola\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C45",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"hola\", 0, 1);\nEscribir \"<\", Subcadena(\"hola\", 2, 1), \">\";\nEscribir \"<\", Subcadena(\"\", 0, -1), \">\";\nEscribir Subcadena(\"hola\", 3, 3);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"hola\", 0, 1);\nwrite \"<\", substring(\"hola\", 2, 1), \">\";\nwrite \"<\", substring(\"\", 0, -1), \">\";\nwrite substring(\"hola\", 3, 3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ho\n<>\n<>\na\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C46",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"hola\", 0, 4);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"hola\", 0, 4);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C47",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"hola\", -1, 0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"hola\", -1, 0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C48",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"hola\", 3, 1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"hola\", 3, 1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C49",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Concatenar(\"a\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite concat(\"a\");\nendAlgorithm\n"
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
  "id": "C50",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Concatenar(\"a\", 1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite concat(\"a\", 1);\nendAlgorithm\n"
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
  "id": "C51",
  "regla": "T4",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Mayusculas(\"ñandú\");\nEscribir Minusculas(\"ÑANDÚ\");\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ÑANDÚ\nñandú\n",
    "terminacion": "completed"
  }
}
```

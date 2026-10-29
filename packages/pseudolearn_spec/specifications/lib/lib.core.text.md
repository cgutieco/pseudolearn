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
    "es": "Algoritmo P\nEscribir CaracterEn(\"ab\", 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charAt(\"ab\", 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
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
    "es": "Algoritmo P\nEscribir CaracterDesde(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "invalidCharacterCode"
    }
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
    "es": "Algoritmo P\nEscribir CaracterDesde(1114112);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite charFromCode(1114112);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "invalidCharacterCode"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

```regla
{
  "id": "T1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Subcadena, Contiene, PosicionDe, EmpiezaCon, TerminaCon, Reemplazar, Dividir, Unir y Recortar son funciones puras sobre Cadena. Operan por puntos de código, no normalizan ni dependen de configuración regional y no modifican sus argumentos.",
  "verificacion": [
    "C5",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C15",
    "C16"
  ]
}
```

```regla
{
  "id": "T2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Subcadena usa inicio desde cero y cantidad; un intervalo fuera de rango produce stringPositionOutOfRange. Contiene de la cadena vacía devuelve Verdadero; PosicionDe devuelve la primera coincidencia y Algo(0) para la parte vacía. EmpiezaCon y TerminaCon aceptan una parte vacía. Reemplazar sustituye todas las coincidencias sin solaparse y deja la cadena intacta si se busca la cadena vacía. Dividir con separador vacío produce emptySeparator y dividir la cadena vacía devuelve un vector con una cadena vacía. Unir un vector vacío devuelve la cadena vacía. Recortar solo quita U+0020, U+0009, U+000A y U+000D de los extremos.",
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
    "C16"
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
    "C15"
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
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir \"<\", Subcadena(\"ab\", 2, 0), \">\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"<\", substring(\"ab\", 2, 0), \">\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "<>\n",
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
  "id": "C7",
  "regla": "T2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir Subcadena(\"abc\", 2, 2);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite substring(\"abc\", 2, 2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "stringPositionOutOfRange"
    }
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

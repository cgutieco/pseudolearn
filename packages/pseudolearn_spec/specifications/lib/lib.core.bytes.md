---
formato: see/1
id: LIB.CORE.BYTES
titulo: Secuencias binarias inmutables
dominio: biblioteca
estado: estable
version: "1.0.0"
duenos:
- responsable-lenguaje
sujetos:
- engine
- aot
resumen: Conversión UTF-8 y operaciones puras sobre bytes.
titulo_en: Immutable byte sequences
edicion:
  introducida_en: "2027"
depende_de:
- id: LIB.MODEL
  version: ">=1.0.0, <2.0.0"
  tipo: requiere
- id: LANG.TASK.ISOLATION
  version: ">=1.0.0, <2.0.0"
  tipo: usa
revisado_por:
- César Antonio Gutiérrez Contreras
---

# Secuencias binarias inmutables

```regla
{
  "id": "B1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Bytes es inmutable y transferible. BytesDesdeTexto codifica los puntos de código como UTF-8 sin BOM. Segmento y Unir devuelven secuencias nuevas. Segmento fuera de rango atrapa con bytesRangeOutOfBounds en el sitio de la llamada. En(i) devuelve como Entero entre 0 y 255 el octeto de la posición i, contada desde cero; un índice negativo o mayor o igual que la longitud atrapa con arrayIndexOutOfRange en el sitio de la llamada, con el índice pedido como argumento index y la longitud como argumento size.",
  "verificacion": [
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
    "C13",
    "C14"
  ]
}
```

```regla
{
  "id": "B2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Bytes() y Segmento(0, 0) producen una secuencia vacía. La longitud de Bytes() es cero. Un segmento de inicio cero y cantidad igual a la longitud devuelve todos los octetos en el mismo orden.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "B2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir empty Como Bytes <- Bytes();\nDefinir zero Como Bytes <- empty.Segmento(0, 0);\nEscribir empty.Longitud(), \":\", zero.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine empty as Bytes <- Bytes();\ndefine zero as Bytes <- empty.segment(0, 0);\nwrite empty.length(), \":\", zero.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "B2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir source Como Bytes <- BytesDesdeTexto(\"ab\");\nDefinir all Como Bytes <- source.Segmento(0, source.Longitud());\nEscribir all.Longitud(), \":\", all.En(0), \":\", all.En(1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine source as Bytes <- bytesFromText(\"ab\");\ndefine all as Bytes <- source.segment(0, source.length());\nwrite all.length(), \":\", all.at(0), \":\", all.at(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:97:98\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\n  Definir source Como Bytes <- BytesDesdeTexto(\"a\");\n  source.Segmento(1, 1);\nFinAlgoritmo\n",
    "en": "Algorithm P\n  Define source As Bytes <- bytesFromText(\"a\");\n  source.segment(1, 1);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "bytesRangeOutOfBounds"
    }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir source Como Bytes <- BytesDesdeTexto(\"ab\");\nDefinir left Como Bytes <- Bytes();\nDefinir first Como Bytes <- left.Unir(source);\nDefinir second Como Bytes <- source.Unir(left);\nEscribir first.Longitud(), \":\", first.En(0), \":\", first.En(1);\nEscribir second.Longitud(), \":\", second.En(0), \":\", second.En(1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine source as Bytes <- bytesFromText(\"ab\");\ndefine left as Bytes <- Bytes();\ndefine first as Bytes <- left.join(source);\ndefine second as Bytes <- source.join(left);\nwrite first.length(), \":\", first.at(0), \":\", first.at(1);\nwrite second.length(), \":\", second.at(0), \":\", second.at(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2:97:98\n2:97:98\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C5",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir value Como Bytes <- BytesDesdeTexto(\"😀\");\nEscribir value.Longitud(), \":\", value.En(0), \":\", value.En(1), \":\", value.En(2), \":\", value.En(3);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine value as Bytes <- bytesFromText(\"😀\");\nwrite value.length(), \":\", value.at(0), \":\", value.at(1), \":\", value.at(2), \":\", value.at(3);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4:240:159:152:128\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo TextoABytes\n  Definir datos Como Bytes <- BytesDesdeTexto(\"Hola\");\n  Escribir datos.Longitud();\n  Escribir datos.En(0);\nFinAlgoritmo\n",
    "en": "Algorithm TextToBytes\n  Define data As Bytes <- bytesFromText(\"Hola\");\n  Write data.length();\n  Write data.at(0);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n72\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C7",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo PedazoDeBytes\n  Definir datos Como Bytes <- BytesDesdeTexto(\"Hola\");\n  Definir parte Como Bytes <- datos.Segmento(1, 2);\n  Escribir parte.Longitud();\n  Escribir parte.En(0);\n  Escribir parte.En(1);\nFinAlgoritmo\n",
    "en": "Algorithm PieceOfBytes\n  Define data As Bytes <- bytesFromText(\"Hola\");\n  Define piece As Bytes <- data.segment(1, 2);\n  Write piece.length();\n  Write piece.at(0);\n  Write piece.at(1);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n111\n108\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C8",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo JuntarBytes\n  Definir primero Como Bytes <- BytesDesdeTexto(\"Ho\");\n  Definir juntos Como Bytes <- primero.Unir(BytesDesdeTexto(\"la\"));\n  Escribir primero.Longitud();\n  Escribir juntos.Longitud();\nFinAlgoritmo\n",
    "en": "Algorithm JoinBytes\n  Define first As Bytes <- bytesFromText(\"Ho\");\n  Define together As Bytes <- first.join(bytesFromText(\"la\"));\n  Write first.length();\n  Write together.length();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n4\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo BytesVacios\n  Definir vacio Como Bytes <- Bytes();\n  Escribir vacio.Longitud();\nFinAlgoritmo\n",
    "en": "Algorithm EmptyBytes\n  Define empty As Bytes <- Bytes();\n  Write empty.length();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C10",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo ContarBytes\n  Definir palabra Como Cadena;\n  palabra <- \"año\";\n  Escribir Longitud(palabra);\n  Escribir BytesDesdeTexto(\"ñ\").Longitud();\nFinAlgoritmo\n",
    "en": "Algorithm CountBytes\n  Define word As String;\n  word <- \"año\";\n  Write length(word);\n  Write bytesFromText(\"ñ\").length();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo LeerCadaByte\n  Definir datos Como Bytes <- BytesDesdeTexto(\"abc\");\n  Escribir datos.En(0);\n  Escribir datos.En(1);\n  Escribir datos.En(2);\nFinAlgoritmo\n",
    "en": "Algorithm ReadEachByte\n  Define data As Bytes <- bytesFromText(\"abc\");\n  Write data.at(0);\n  Write data.at(1);\n  Write data.at(2);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "97\n98\n99\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C12",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo BytesATexto\n  Definir datos Como Bytes <- BytesDesdeTexto(\"Hola\");\n  Segun datos.Segmento(1, 2).TextoUtf8() Hacer\n    Exito(texto): Escribir texto;\n    Error(problema): Escribir problema.Codigo;\n  FinSegun\nFinAlgoritmo\n",
    "en": "Algorithm BytesToText\n  Define data As Bytes <- bytesFromText(\"Hola\");\n  Switch data.segment(1, 2).utf8Text() Do\n    Success(text): Write text;\n    Failure(problem): Write problem.code;\n  EndSwitch\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ol\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir datos Como Bytes <- BytesDesdeTexto(\"ab\");\nEscribir datos.En(1);\nEscribir datos.En(2);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine data as Bytes <- bytesFromText(\"ab\");\nwrite data.at(1);\nwrite data.at(2);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    },
    "diagnosticos": [
      {
        "codigo": "arrayIndexOutOfRange",
        "severidad": "error",
        "argumentos": {
          "index": 2,
          "size": 2
        }
      }
    ],
    "salida": "98\n"
  }
}
```

```caso
{
  "id": "C14",
  "regla": "B1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir vacio Como Bytes <- Bytes();\nEscribir vacio.En(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine empty as Bytes <- Bytes();\nwrite empty.at(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    },
    "diagnosticos": [
      {
        "codigo": "arrayIndexOutOfRange",
        "severidad": "error",
        "argumentos": {
          "index": -1,
          "size": 0
        }
      }
    ],
    "salida": ""
  }
}
```

---
{
  "formato": "see/1",
  "id": "LANG.TYPES.DICTIONARY",
  "titulo": "Diccionarios tipados con orden de inserción",
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
  "resumen": "Diccionarios tipados con orden de inserción",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.GENERIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Diccionarios tipados con orden de inserción

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Diccionario<K,V> es una referencia compartida; Diccionario() vacío necesita contexto. K solo admite entero, carácter, cadena, lógico o enumerado. Las cadenas comparan contenido UTF-8 exacto sin normalización NFC. Longitud() devuelve Entero. d[k] lee V y una clave ausente produce missingDictionaryKey. d[k] <- valor inserta o reemplaza; reemplazar conserva posición y versión.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C10",
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
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Cadena, Entero> <- Diccionario();\nvalues[\"aa\"] <- 2;\nvalues[\"aa\"] <- 7;\nEscribir values.Longitud(), values[\"aa\"];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<string, integer> <- dictionary();\nvalues[\"aa\"] <- 2;\nvalues[\"aa\"] <- 7;\nwrite values.length(), values[\"aa\"];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "17\n",
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
    "es": "Algoritmo Main\n  Definir values Como Diccionario<Cadena, Entero> <- Diccionario();\n  Escribir values[\"absent\"];\nFinAlgoritmo\n",
    "en": "Algorithm Main\n  Define values As Dictionary<String, Integer> <- dictionary();\n  Write values[\"absent\"];\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "missingDictionaryKey"
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
    "es": "Algoritmo Main\n  Definir values Como Diccionario<Real, Entero> <- Diccionario();\nFinAlgoritmo\n",
    "en": "Algorithm Main\n  Define values As Dictionary<Real, Integer> <- dictionary();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "invalidDictionaryKeyType",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Cadena, Entero> <- Diccionario();\nvalues[\"éx\"] <- 1;\nvalues[\"éx\"] <- 2;\nEscribir values.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<string, integer> <- dictionary();\nvalues[\"éx\"] <- 1;\nvalues[\"éx\"] <- 2;\nwrite values.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Buscar(k) y Eliminar(k) devuelven Opcional<V>; Nada indica ausencia. Borrar una clave ausente no modifica nada. Una nueva inserción o borrado exitoso incrementa versión, sin envolver u32; una reinserción tras borrado queda al final. El índice abierto guarda posiciones u32 y las entradas conservan orden. El hash FNV-1a de 64 bits usa codificación canónica de claves y siempre confirma igualdad completa. El índice crece antes de superar tres cuartos de ocupación y compacta establemente cuando los huecos superan un cuarto de posiciones usadas.",
  "verificacion": [
    "C5",
    "C6",
    "C7"
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
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Cadena, Entero> <- Diccionario();\nvalues[\"aa\"] <- 1;\nvalues[\"bb\"] <- 2;\nDefinir removed Como Opcional<Entero> <- values.Eliminar(\"aa\");\nvalues[\"aa\"] <- 3;\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<string, integer> <- dictionary();\nvalues[\"aa\"] <- 1;\nvalues[\"bb\"] <- 2;\ndefine removed as optional<integer> <- values.remove(\"aa\");\nvalues[\"aa\"] <- 3;\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{\"bb\": 2, \"aa\": 3}\n",
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
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Cadena, Entero> <- Diccionario();\nSegun values.Buscar(\"xx\") Hacer\nNada:\nEscribir 0;\nAlgo(value):\nEscribir value;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<string, integer> <- dictionary();\nswitch values.find(\"xx\") do\nnone:\nwrite 0;\nsome(value):\nwrite value;\nendSwitch\nendAlgorithm\n"
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
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Entero, Entero> <- Diccionario();\nDefinir absent Como Opcional<Entero> <- values.Eliminar(1);\nEscribir values.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<integer, integer> <- dictionary();\ndefine absent as optional<integer> <- values.remove(1);\nwrite values.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los límites físicos, la atomicidad y el agotamiento de versión son los mismos del Vector, incluyendo índice, hashes y ocupación en el almacenamiento variable. El costo lógico es una celda más entradas por uno más el máximo entre uno y ancho de valor; referencias alcanzables se cuentan una vez. Escribir muestra pares clave: valor entre llaves en orden de inserción, separados por coma y espacio, solo si los valores son imprimibles. No se usa HashMap ni su orden de recorrido.",
  "verificacion": [
    "C8",
    "C9"
  ]
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
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Entero, Entero> <- Diccionario();\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<integer, integer> <- dictionary();\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{}\n",
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
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Entero, Entero> <- Diccionario();\nvalues[2] <- 7;\nvalues[1] <- 8;\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<integer, integer> <- dictionary();\nvalues[2] <- 7;\nvalues[1] <- 8;\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{2: 7, 1: 8}\n",
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
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Entero, Entero> <- Diccionario();\nPara Cada key, value En values Hacer\nEscribir key, value;\nFinPara\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<integer, integer> <- dictionary();\nfor each key, value in values do\nwrite key, value;\nendFor\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{}\n",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Claves()/keys() devuelve una copia Vector<K> con las claves actuales en orden de inserción; borrar y reinsertar ubica la clave al final. La copia cuenta celdas y no modifica el diccionario. Una vista inmutable devuelve claves con el aislamiento de lectura existente.",
  "verificacion": [
    "C11",
    "C12",
    "C13",
    "C14",
    "C16"
  ]
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
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Diccionario<Cadena,Entero> <- Diccionario();\nvalues[\"bb\"] <- 1; values[\"aa\"] <- 2;\nDefinir names Como Vector<Cadena> <- values.Claves();\nEscribir names[0], \":\", names[1];\nDefinir removed Como Opcional<Entero> <- values.Eliminar(\"bb\");\nvalues[\"bb\"] <- 3; names[0] <- \"zz\";\nDefinir reordered Como Vector<Cadena> <- values.Claves();\nEscribir names[0], \":\", names[1], \":\", reordered[0], \":\", reordered[1];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as dictionary<string,integer> <- dictionary();\nvalues[\"bb\"] <- 1; values[\"aa\"] <- 2;\ndefine names as vector<string> <- values.keys();\nwrite names[0], \":\", names[1];\ndefine removed as optional<integer> <- values.remove(\"bb\");\nvalues[\"bb\"] <- 3; names[0] <- \"zz\";\ndefine reordered as vector<string> <- values.keys();\nwrite names[0], \":\", names[1], \":\", reordered[0], \":\", reordered[1];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "bb:aa\nzz:aa:aa:bb\n",
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
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Diccionario<Entero,Entero> <- Diccionario();\nEscribir values.Claves().Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as dictionary<integer,integer> <- dictionary();\nwrite values.keys().length();\nendAlgorithm\n"
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
  "id": "C13",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Diccionario<Entero,Entero> <- Diccionario();\nDefinir names Como Vector<Entero> <- values.Claves();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as dictionary<integer,integer> <- dictionary();\ndefine names as vector<integer> <- values.keys();\nendAlgorithm\n"
  },
  "limites": {
    "celdas": 1
  },
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
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
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Diccionario<Entero,Entero> <- Diccionario();\nvalues[7] <- 1;\nDefinir frozen Como Inmutable<Diccionario<Entero,Entero>> <- Instantanea(values);\nDefinir names Como Inmutable<Vector<Entero>> <- frozen.Claves();\nEscribir names[0];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as dictionary<integer,integer> <- dictionary();\nvalues[7] <- 1;\ndefine frozen as immutable<dictionary<integer,integer>> <- snapshot(values);\ndefine names as immutable<vector<integer>> <- frozen.keys();\nwrite names[0];\nendAlgorithm\n"
  },
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Edades\n  Definir edades Como Diccionario<Cadena, Entero> <- Diccionario();\n  edades[\"Ana\"] <- 15;\n  edades[\"Luis\"] <- 17;\n  edades[\"Ana\"] <- 16;\n  Escribir edades[\"Ana\"];\n  Escribir edades.Longitud();\nFinAlgoritmo\n",
    "en": "Algorithm Ages\n  Define ages As Dictionary<String, Integer> <- dictionary();\n  ages[\"Ana\"] <- 15;\n  ages[\"Luis\"] <- 17;\n  ages[\"Ana\"] <- 16;\n  Write ages[\"Ana\"];\n  Write ages.length();\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "16\n2\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo Lista\n  Definir edades Como Diccionario<Cadena, Entero> <- Diccionario();\n  edades[\"Luis\"] <- 17;\n  edades[\"Ana\"] <- 15;\n  Para Cada nombre En edades.Claves() Hacer\n    Escribir nombre;\n  FinPara\nFinAlgoritmo\n",
    "en": "Algorithm Roster\n  Define ages As Dictionary<String, Integer> <- dictionary();\n  ages[\"Luis\"] <- 17;\n  ages[\"Ana\"] <- 15;\n  For Each name In ages.keys() Do\n    Write name;\n  EndFor\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Luis\nAna\n",
    "terminacion": "completed"
  }
}
```

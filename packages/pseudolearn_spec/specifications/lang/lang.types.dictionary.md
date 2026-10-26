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
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Diccionarios tipados con orden de inserción",
  "edicion": {
    "introducida_en": "2026"
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
    "C10"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Cadena, Entero> <- Diccionario();\nEscribir values[\"absent\"];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<string, integer> <- dictionary();\nwrite values[\"absent\"];\nendAlgorithm\n"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Real, Entero> <- Diccionario();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<real, integer> <- dictionary();\nendAlgorithm\n"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
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
  "rigor": [
    "estricto",
    "flexible"
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

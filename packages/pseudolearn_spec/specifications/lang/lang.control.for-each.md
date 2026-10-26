---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.FOR-EACH",
  "titulo": "Iteración tipada sobre colecciones y arreglos",
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
  "resumen": "Iteración tipada sobre colecciones y arreglos",
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

# Iteración tipada sobre colecciones y arreglos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Para Cada elemento En secuencia Hacer cuerpo FinPara recorre Vector o arreglo unidimensional. Diccionario exige dos vínculos clave, valor. La secuencia se evalúa una vez antes de introducir vínculos inmutables por valor, visibles solo en el cuerpo. El orden es ascendente para secuencias y de inserción para diccionarios. Una colección vacía no ejecuta el cuerpo.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C7"
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
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(4);\nvalues.Agregar(7);\nPara Cada value En values Hacer\nEscribir value;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(4);\nvalues.append(7);\nfor each value in values do\nwrite value;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n7\n",
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
    "es": "Algoritmo Main\nDefinir values Como Diccionario<Entero, Entero> <- Diccionario();\nvalues[2] <- 8;\nPara Cada key, value En values Hacer\nEscribir key, value;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as dictionary<integer, integer> <- dictionary();\nvalues[2] <- 8;\nfor each key, value in values do\nwrite key, value;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "28\n",
    "terminacion": "completed"
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
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nPara Cada value En values Hacer\nEscribir value;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nfor each value in values do\nwrite value;\nendFor\nendAlgorithm\n"
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
    "es": "Algoritmo Main\nDimension values[1, 1] Como Entero;\nPara Cada value En values Hacer\nEscribir value;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndimension values[1, 1] as integer;\nfor each value in values do\nwrite value;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "invalidForEachCollection",
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
  "texto": "La iteración captura la versión inicial y la comprueba antes de cada avance, incluso antes de comprobar el final. Cualquier modificación estructural por alias produce collectionModifiedDuringIteration con sitio en el bucle. Reemplazar elementos o valores existentes no invalida. El arreglo no cambia estructura.",
  "verificacion": [
    "C5",
    "C6",
    "C8",
    "C9"
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
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(1);\nPara Cada value En values Hacer\nvalues.Agregar(value);\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(1);\nfor each value in values do\nvalues.append(value);\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "collectionModifiedDuringIteration"
    }
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
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(1);\nPara Cada value En values Hacer\nvalues[0] <- 7;\nFinPara\nEscribir values[0];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(1);\nfor each value in values do\nvalues[0] <- 7;\nendFor\nwrite values[0];\nendAlgorithm\n"
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
  "id": "C7",
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
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nPara Cada item En values Hacer\nEscribir item;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nfor each item in values do\nwrite item;\nendFor\nendAlgorithm\n"
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
  "id": "C8",
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
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(1);\nDefinir alias Como Vector<Entero> <- values;\nPara Cada item En values Hacer\nalias.Agregar(2);\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(1);\ndefine alias as vector<integer> <- values;\nfor each item in values do\nalias.append(2);\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "collectionModifiedDuringIteration"
    }
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(1);\nvalues.Agregar(2);\nPara Cada item En values Hacer\nvalues[1] <- 8;\nEscribir item;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(1);\nvalues.append(2);\nfor each item in values do\nvalues[1] <- 8;\nwrite item;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n8\n",
    "terminacion": "completed"
  }
}
```

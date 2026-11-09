---
{
  "formato": "see/1",
  "id": "LIB.CORE.ROUNDING",
  "titulo": "Truncamiento y redondeo",
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
  "resumen": "Truncamiento y redondeo.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Truncamiento y redondeo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "trunc acepta real y trunca hacia cero. redon acepta real y redondea al entero más cercano; empates se alejan de cero. Ambas devuelven entero de 64 bits y fallan con integerOverflow si el resultado sale de rango. Se admite ampliación de argumento entero a real según firma.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C6",
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
  "programas": {
    "es": "Algoritmo P\nEscribir trunc(-2.9), \":\", redon(2.5), \":\", redon(-2.5);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite trunc(-2.9), \":\", round(2.5), \":\", round(-2.5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-2:3:-3\n",
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
    "es": "Algoritmo P\nEscribir trunc(100000000000000000000.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite trunc(100000000000000000000.0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "integerOverflow"
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
    "es": "Algoritmo P\nEscribir redon(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite round(\"ab\");\nendAlgorithm\n"
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
  "texto": "piso/floor y techo/ceil aceptan un número ampliado a real y devuelven respectivamente el mayor entero no superior y el menor entero no inferior. El resultado es Entero de 64 bits; fuera de rango produce integerOverflow. Ambos ceros producen el entero cero.",
  "verificacion": [
    "C4",
    "C5",
    "C8",
    "C9"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir piso(-0.5), \":\", techo(-0.5), \":\", piso(2), \":\", techo(2.1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite floor(-0.5), \":\", ceil(-0.5), \":\", floor(2), \":\", ceil(2.1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-1:0:2:3\n",
    "terminacion": "completed"
  }
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
    "es": "Algoritmo P\nEscribir piso(9300000000000000000.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite floor(9300000000000000000.0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "integerOverflow"
    }
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
    "es": "Algoritmo RedondearPrecio\n  Definir precio Como Real;\n  precio <- 7.6;\n  Escribir trunc(precio);\n  Escribir redon(precio);\nFinAlgoritmo\n",
    "en": "Algorithm RoundPrice\n  Define price As Real;\n  price <- 7.6;\n  Write trunc(price);\n  Write round(price);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n8\n",
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
  "programas": {
    "es": "Algoritmo RedondearNegativos\n  Definir temperatura Como Real;\n  temperatura <- -2.5;\n  Escribir trunc(temperatura);\n  Escribir redon(temperatura);\n  Escribir redon(2.5);\nFinAlgoritmo\n",
    "en": "Algorithm RoundNegatives\n  Define temperature As Real;\n  temperature <- -2.5;\n  Write trunc(temperature);\n  Write round(temperature);\n  Write round(2.5);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-2\n-3\n3\n",
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
    "es": "Algoritmo EdadCumplida\n  Definir edadExacta Como Real;\n  edadExacta <- 15.9;\n  Escribir piso(edadExacta);\n  Escribir piso(-3.2);\nFinAlgoritmo\n",
    "en": "Algorithm CompletedAge\n  Define exactAge As Real;\n  exactAge <- 15.9;\n  Write floor(exactAge);\n  Write floor(-3.2);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "15\n-4\n",
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
    "es": "Algoritmo AutosNecesarios\n  Definir alumnos Como Entero;\n  alumnos <- 23;\n  Escribir alumnos / 5;\n  Escribir techo(alumnos / 5);\nFinAlgoritmo\n",
    "en": "Algorithm CarsNeeded\n  Define students As Integer;\n  students <- 23;\n  Write students / 5;\n  Write ceil(students / 5);\nEndAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4.6\n5\n",
    "terminacion": "completed"
  }
}
```

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
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-r9"
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
    "C3"
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
    "C5"
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

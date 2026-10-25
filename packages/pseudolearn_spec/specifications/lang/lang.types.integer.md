---
{
  "formato": "see/1",
  "id": "LANG.TYPES.INTEGER",
  "titulo": "Tipo entero",
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
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Tipo entero.",
  "depende_de": [],
  "edicion": {
    "introducida_en": "2026"
  }
}
---

# Tipo entero

```definicion
{
  "id": "D1",
  "termino": "rango del entero",
  "texto": "Intervalo cerrado [-9223372036854775808, 9223372036854775807]."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los valores enteros pertenecen al intervalo de D1; los extremos y cero se imprimen en decimal exacto.",
  "verificacion": [
    "C1",
    "C2",
    "C3"
  ],
  "referencias": [
    "D1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una suma que sale del intervalo de D1 termina con integerOverflow sin producir valor ni salida.",
  "verificacion": [
    "C4",
    "C5",
    "C6"
  ],
  "referencias": [
    "D1"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La suma de enteros dentro de D1 produce el resultado matemático exacto.",
  "verificacion": [
    "C7",
    "C8"
  ],
  "referencias": [
    "D1"
  ]
}
```

```error
{
  "id": "E1",
  "situacion": "suma fuera de rango",
  "clase": "ejecucion",
  "codigo": "integerOverflow",
  "severidad": "A"
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
    "es": "Algoritmo P\n  Definir value Como Entero <- 0;\n  Escribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\n  define value as integer <- 0;\n  write value;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "evita": [
    "E1"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Definir value Como Entero <- 9223372036854775807;\n  Escribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\n  define value as integer <- 9223372036854775807;\n  write value;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "9223372036854775807\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "evita": [
    "E1"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Definir value Como Entero <- -9223372036854775807 - 1;\n  Escribir value;\nFinAlgoritmo\n",
    "en": "algorithm P\n  define value as integer <- -9223372036854775807 - 1;\n  write value;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "-9223372036854775808\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "evita": [
    "E1"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo P\n  Escribir 9223372036854775807 + 1;\nFinAlgoritmo\n",
    "en": "algorithm P\n  write 9223372036854775807 + 1;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    },
    "diagnosticos": [
      {
        "codigo": "integerOverflow",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "produce": [
    "E1"
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
    "es": "Algoritmo P\n  Escribir (-9223372036854775807 - 1) + (-1);\nFinAlgoritmo\n",
    "en": "algorithm P\n  write (-9223372036854775807 - 1) + (-1);\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "integerOverflow"
    },
    "diagnosticos": [
      {
        "codigo": "integerOverflow",
        "severidad": "error"
      }
    ]
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "produce": [
    "E1"
  ]
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
    "es": "Algoritmo P\n  Escribir 9223372036854775807 + 0;\nFinAlgoritmo\n",
    "en": "algorithm P\n  write 9223372036854775807 + 0;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "9223372036854775807\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ],
  "evita": [
    "E1"
  ]
}
```

```caso
{
  "id": "C7",
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
    "es": "Algoritmo P\n  Escribir -3 + 5;\nFinAlgoritmo\n",
    "en": "algorithm P\n  write -3 + 5;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
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
    "es": "Algoritmo P\n  Escribir (-9223372036854775807 - 1) + 9223372036854775807;\nFinAlgoritmo\n",
    "en": "algorithm P\n  write (-9223372036854775807 - 1) + 9223372036854775807;\nendAlgorithm\n"
  },
  "operacion": "execute",
  "espera": {
    "salida": "-1\n",
    "terminacion": "completed",
    "diagnosticos": []
  },
  "origen": "derivado",
  "etiquetas": [
    "limite"
  ]
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

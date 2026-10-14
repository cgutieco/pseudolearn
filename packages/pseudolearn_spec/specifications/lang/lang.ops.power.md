---
{
  "formato": "see/1",
  "id": "LANG.OPS.POWER",
  "titulo": "Potencia",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Potencia.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.REAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Potencia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La potencia asocia a derecha. Dos enteros exigen exponente no negativo y producen entero comprobado; exponente negativo produce negativeIntegerExponent. Con operando real se produce real finito. La potencia cero devuelve uno, incluido cero elevado a cero; desbordamiento y resultados no finitos tienen diagnósticos.",
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
    "es": "Algoritmo P\nEscribir 0 ^ 0, \":\", 2 ^ 0, \":\", 2 ^ 3;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 0 ^ 0, \":\", 2 ^ 0, \":\", 2 ^ 3;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1:1:8\n",
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
    "es": "Algoritmo P\nEscribir 2 ^ -1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2 ^ -1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "negativeIntegerExponent"
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
    "es": "Algoritmo P\nEscribir 2 ^ 63;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2 ^ 63;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "integerOverflow"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

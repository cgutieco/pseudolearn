---
{
  "formato": "see/1",
  "id": "LANG.OPS.POWER",
  "titulo": "Potencia",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
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
  ],
  "cambio": {
    "clase": "aclaracion",
    "impacto_usuarios": "Precisa redondeo, formato o recursos sin añadir construcciones.",
    "impacto_implementaciones": "Actualiza contratos y casos derivados para ejecución portable y verificable.",
    "justificacion": "Eliminar ambigüedades antes de implementar la ejecución determinista.",
    "revisado_por": "autorización de la fase R5 en la conversación"
  }
}
---

# Potencia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La potencia asocia a derecha. Dos enteros exigen exponente no negativo y producen entero comprobado; exponente negativo produce negativeIntegerExponent. Con operando real se produce real finito. La potencia cero devuelve uno, incluido cero elevado a cero; desbordamiento y resultados no finitos tienen diagnósticos. La potencia real se redondea al binario64 más cercano al valor matemático exacto, con empates al significando par, independientemente del anfitrión.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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

```caso
{
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nEscribir 2.0 ^ 0.5, \":\", 0.0 ^ 0.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2.0 ^ 0.5, \":\", 0.0 ^ 0.0;\nendAlgorithm\n"
  },
  "espera": {
    "salida": "1.4142135623730951:1.0\n",
    "terminacion": "completed"
  },
  "id": "C4"
}
```

```caso
{
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nEscribir (-2.0) ^ 0.5;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite (-2.0) ^ 0.5;\nendAlgorithm\n"
  },
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
    }
  },
  "id": "C5"
}
```

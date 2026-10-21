---
{
  "formato": "see/1",
  "id": "LANG.TYPES.REAL",
  "titulo": "Tipo real",
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
  "resumen": "Tipo real.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.LEXICAL.NUMBER-LITERAL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Tipo real

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Real es IEEE 754 binario64 finito. Operaciones reales redondean a ese formato; infinitos y NaN producen nonFiniteRealResult. Los dos rigores e idiomas usan el mismo dominio. La salida usa notación posicional y al menos un decimal, sin exponente. El redondeo es al valor representable más cercano, con empates al significando par, incluidas las funciones matemáticas y la potencia real. Los subnormales y los ceros con signo pertenecen al dominio finito.",
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
    "es": "Algoritmo P\nEscribir 2.0, \":\", 0.0, \":\", -1.5;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2.0, \":\", 0.0, \":\", -1.5;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0:0.0:-1.5\n",
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
    "es": "Algoritmo P\nEscribir exp(1000);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite exp(1000);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
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
    "es": "Algoritmo P\nEscribir 0.1 + 0.2, \":\", -0.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 0.1 + 0.2, \":\", -0.0;\nendAlgorithm\n"
  },
  "espera": {
    "salida": "0.30000000000000004:-0.0\n",
    "terminacion": "completed"
  },
  "id": "C3"
}
```

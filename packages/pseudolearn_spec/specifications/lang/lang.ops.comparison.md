---
{
  "formato": "see/1",
  "id": "LANG.OPS.COMPARISON",
  "titulo": "Comparaciones",
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
  "resumen": "Comparaciones.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Comparaciones

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Orden e igualdad numéricos amplían entero a real si hace falta. Textos y caracteres admiten comparación compatible; lógicos solo igualdad. Objetos admiten igualdad por identidad. Los arreglos no se comparan. Igualdad entre reales produce advertencia realEqualityComparison en ambos rigores, sin cambiar el valor.",
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
    "es": "Algoritmo P\nEscribir 2 < 3, 2 = 2, \"ab\" < \"cd\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2 < 3, 2 = 2, \"ab\" < \"cd\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "{{lexema:booleanTrue}}{{lexema:booleanTrue}}{{lexema:booleanTrue}}\n",
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
    "es": "Algoritmo P\nEscribir Verdadero < Falso;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite true < false;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "noOrderBetweenBooleans",
        "severidad": "error"
      }
    ]
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
    "es": "Algoritmo P\nEscribir 2.0 = 2.0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2.0 = 2.0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "realEqualityComparison",
        "severidad": "warning"
      }
    ]
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

---
{
  "formato": "see/1",
  "id": "LIB.CORE.ROUNDING",
  "titulo": "Truncamiento y redondeo",
  "dominio": "biblioteca",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Truncamiento y redondeo.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Sin cambios en el lenguaje ni en el código admitido.",
    "impacto_implementaciones": "Activa el sujeto engine en R4 manteniendo reference.",
    "justificacion": "Habilitar la verificación de conformidad estática del nuevo motor en Rust.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
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
    "es": "Algoritmo P\nEscribir trunc(100000000000000000000.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite trunc(100000000000000000000.0);\nendAlgorithm\n"
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
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

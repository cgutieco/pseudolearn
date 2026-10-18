---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.REPEAT",
  "titulo": "Bucle posterior",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine",
    "aot"
  ],
  "resumen": "Bucle posterior.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.BOOLEAN",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Bucle posterior

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Repetir ejecuta el cuerpo al menos una vez y termina cuando la condición de Hasta Que es verdadera. La condición se evalúa después del cuerpo y debe ser lógica. Hasta Que cierra el bloque; no hay cierre adicional. El cuerpo vacío comprueba la condición una vez.",
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
    "es": "Algoritmo P\nRepetir\nEscribir 1;\nHasta Que Verdadero\nFinAlgoritmo\n",
    "en": "algorithm P\nrepeat\nwrite 1;\nuntil true\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
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
    "es": "Algoritmo P\nRepetir\nHasta Que Verdadero\nFinAlgoritmo\n",
    "en": "algorithm P\nrepeat\nuntil true\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nRepetir\nHasta Que 1\nFinAlgoritmo\n",
    "en": "algorithm P\nrepeat\nuntil 1\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "nonBooleanCondition",
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

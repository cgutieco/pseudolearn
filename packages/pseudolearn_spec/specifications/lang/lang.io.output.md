---
{
  "formato": "see/1",
  "id": "LANG.IO.OUTPUT",
  "titulo": "Salida",
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
  "resumen": "Salida.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
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

# Salida

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Escribir evalúa cero o más expresiones separadas por coma, izquierda a derecha y una vez. Concatena representaciones sin separador. Sin Saltar solo aparece una vez al final; ausente agrega salto de línea. La salida vacía agrega una línea; vacía sin salto no emite nada.",
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
    "es": "Algoritmo P\nEscribir;\nEscribir Sin Saltar;\nEscribir 1, 2 Sin Saltar;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite;\nwrite without newline;\nwrite 1, 2 without newline;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "\n12",
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
    "es": "Algoritmo P\nEscribir Sin Saltar \"ab\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite without newline \"ab\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unexpectedModifierPosition",
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
    "es": "Algoritmo P\nEscribir 1 Sin Saltar Sin Saltar;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 without newline without newline;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateModifier",
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

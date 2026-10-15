---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.TEXT-LITERAL",
  "titulo": "Literales de texto",
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
  "resumen": "Literales de texto.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
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

# Literales de texto

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Comillas simples o dobles delimitan literales. Un literal vacío o con más de un punto de código es cadena; exactamente uno es carácter. Se admiten escapes n, t, r, barra invertida y ambas comillas. El contenido conserva sus puntos de código, sin NFC. Escape desconocido y literal sin cierre tienen diagnósticos específicos; la recuperación no absorbe la siguiente sentencia.",
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
    "es": "Algoritmo P\nEscribir \"\", \"ab\", \"\\n\", \"é\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"\", \"ab\", \"\\n\", \"é\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ab\né\n",
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
    "es": "Algoritmo P\nEscribir \"abc;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"abc;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unterminatedString",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
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
    "es": "Algoritmo P\nEscribir \"\\q\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"\\q\";\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "invalidEscapeSequence",
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

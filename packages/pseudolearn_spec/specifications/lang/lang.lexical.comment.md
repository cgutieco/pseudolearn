---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.COMMENT",
  "titulo": "Comentarios y conservación",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "0.2.0",
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
  "resumen": "Comentarios y conservación.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Comentarios y conservación

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El marcador // abre un comentario hasta el fin de línea, fuera de literales. Su contenido no se tokeniza ni ejecuta. Se conserva el texto original para consumidores que reimprimen; el fin de archivo cierra el comentario sin exigir salto final.",
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
    "es": "Algoritmo P\n// @ literal ignorado\nEscribir \"//\"; // comentario\nFinAlgoritmo\n",
    "en": "algorithm P\n// @ literal ignorado\nwrite \"//\"; // comentario\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "//\n",
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
    "es": "Algoritmo P\n\nFinAlgoritmo\n// eof",
    "en": "algorithm P\n\nendAlgorithm\n// eof"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
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
    "es": "Algoritmo P\nEscribir @;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite @;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "unrecognizedCharacter",
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

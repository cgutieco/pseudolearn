---
{
  "formato": "see/1",
  "id": "LANG.PROFILE.STRICTNESS",
  "titulo": "Reglas de la edición",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Reglas comunes de la edición 2027.",
  "edicion": {
    "introducida_en": "2027"
  },
  "depende_de": [
    {
      "id": "LANG.PROFILE.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Reglas de la edición

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La edición 2027 aplica una sola gramática y una sola política semántica. Toda sentencia simple termina en punto y coma, cada bucle Para declara Con Paso, cada parámetro declara su tipo y las etiquetas de Según tienen tipo entero o enumerado. La base de índices, la sensibilidad de nombres y el significado de operadores son reglas comunes.",
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
    "es": "Algoritmo P\nEscribir 1\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "missingStatementTerminator",
        "severidad": "error"
      }
    ]
  }
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
    "es": "Algoritmo P\nEscribir 1\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "terminacion": "failed",
    "diagnosticos": [
      {
        "codigo": "missingStatementTerminator",
        "severidad": "error"
      }
    ]
  }
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
    "es": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

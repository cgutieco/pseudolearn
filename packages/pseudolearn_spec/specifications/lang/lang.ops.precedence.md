---
{
  "formato": "see/1",
  "id": "LANG.OPS.PRECEDENCE",
  "titulo": "Precedencia y asociatividad",
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
  "resumen": "Precedencia y asociatividad.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Precedencia y asociatividad

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "De mayor a menor: postfijos; unarios + - NO; potencia; * / div mod; + - concatenación; < <= > >=; = <>; Y; O. Unarios y potencia asocian a derecha; los demás a izquierda. Los paréntesis alteran agrupación. La negación lógica liga más que los relacionales y el signo más que la potencia.",
  "verificacion": [
    "C1",
    "C2"
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
    "es": "Algoritmo P\nEscribir 2 ^ 3 ^ 2, \":\", -2 ^ 2, \":\", 10 - 3 - 2;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 2 ^ 3 ^ 2, \":\", -2 ^ 2, \":\", 10 - 3 - 2;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "512:4:5\n",
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
    "es": "Algoritmo P\nEscribir ();\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "emptyParentheses",
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

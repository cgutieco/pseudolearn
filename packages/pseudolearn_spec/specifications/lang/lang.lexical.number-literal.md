---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.NUMBER-LITERAL",
  "titulo": "Literales numéricos",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.3.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Literales numéricos.",
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
    "clase": "aclaracion",
    "impacto_usuarios": "Un literal fuera de rango produce un único diagnóstico principal, con cualquier signo precedente.",
    "impacto_implementaciones": "Suprimir expectedExpression derivado del mismo literal inválido.",
    "justificacion": "La regla define el signo separado y el rango del literal; DIAG.CLASSES y la recuperación prohíben duplicar el fallo por sincronización.",
    "revisado_por": "autorización de la remediación de R5; derivación de la regla"
  }
}
---

# Literales numéricos

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un literal entero es una secuencia decimal de dígitos. Un real contiene punto y al menos un dígito a cada lado; no hay notación exponencial. El signo es un operador separado. Los enteros deben ser representables en 64 bits con signo; un literal positivo que excede el máximo produce integerLiteralOutOfRange aunque esté precedido por menos.",
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
    "es": "Algoritmo P\nEscribir 0, \":\", -1, \":\", 2.5;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 0, \":\", -1, \":\", 2.5;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0:-1:2.5\n",
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
    "es": "Algoritmo P\nEscribir 9223372036854775808;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 9223372036854775808;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "integerLiteralOutOfRange",
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
    "es": "Algoritmo P\nEscribir -9223372036854775808;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite -9223372036854775808;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "integerLiteralOutOfRange",
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

---
{
  "formato": "see/1",
  "id": "LANG.LEXICAL.NUMBER-LITERAL",
  "titulo": "Literales numéricos",
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
  "resumen": "Literales numéricos.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SOURCE.ENCODING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
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

```definicion
{
  "id": "D1",
  "termino": "textmateNumber",
  "texto": "Patrones declarativos de los literales decimales enteros y reales; el consumidor solo resalta candidatos.",
  "valor": {
    "integer": "[0-9]+",
    "real": "[0-9]+\\.[0-9]+"
  }
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

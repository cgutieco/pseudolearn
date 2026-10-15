---
{
  "formato": "see/1",
  "id": "LIB.CORE.MATH",
  "titulo": "Funciones matemáticas",
  "dominio": "biblioteca",
  "estado": "experimental",
  "version": "0.3.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference",
    "engine"
  ],
  "resumen": "Funciones matemáticas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LIB.MODEL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Funciones matemáticas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "rc, abs, ln, exp, sen, cos y atan aceptan un número y devuelven real finito. rc es raíz cuadrada no negativa, ln logaritmo natural, exp exponencial base e; funciones trigonométricas usan radianes. Dominio inválido, infinito o NaN produce nonFiniteRealResult. Se aplica ampliación entero a real; nunca se consulta entorno. El resultado de cada función es el binario64 más cercano al valor matemático exacto, con empates al significando par; esta regla incluye subnormales y ceros con signo y es independiente de la biblioteca matemática del anfitrión.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5"
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
    "es": "Algoritmo P\nEscribir rc(4), \":\", abs(-3), \":\", ln(1), \":\", exp(0), \":\", sen(0), \":\", cos(0), \":\", atan(0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(4), \":\", abs(-3), \":\", ln(1), \":\", exp(0), \":\", sin(0), \":\", cos(0), \":\", atan(0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2.0:3.0:0.0:1.0:0.0:1.0:0.0\n",
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
    "es": "Algoritmo P\nEscribir rc(-1);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(-1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
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
    "es": "Algoritmo P\nEscribir ln(0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite ln(0);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "nonFiniteRealResult"
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
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nEscribir rc(\"ab\");\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(\"ab\");\nendAlgorithm\n"
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

```caso
{
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo P\nEscribir rc(2.0), \":\", ln(2.0), \":\", exp(1.0), \":\", sen(1.0), \":\", cos(1.0), \":\", atan(1.0);\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite sqrt(2.0), \":\", ln(2.0), \":\", exp(1.0), \":\", sin(1.0), \":\", cos(1.0), \":\", atan(1.0);\nendAlgorithm\n"
  },
  "espera": {
    "salida": "1.4142135623730951:0.6931471805599453:2.718281828459045:0.8414709848078965:0.5403023058681398:0.7853981633974483\n",
    "terminacion": "completed"
  },
  "id": "C5"
}
```

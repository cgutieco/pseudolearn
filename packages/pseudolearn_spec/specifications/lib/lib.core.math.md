---
{
  "formato": "see/1",
  "id": "LIB.CORE.MATH",
  "titulo": "Funciones matemáticas",
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

# Funciones matemáticas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "rc, abs, ln, exp, sen, cos y atan aceptan un número y devuelven real finito. rc es raíz cuadrada no negativa, ln logaritmo natural, exp exponencial base e; funciones trigonométricas usan radianes. Dominio inválido, infinito o NaN produce nonFiniteRealResult. Se aplica ampliación entero a real; nunca se consulta entorno.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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

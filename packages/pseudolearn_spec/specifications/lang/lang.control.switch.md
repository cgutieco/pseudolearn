---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.SWITCH",
  "titulo": "Selección múltiple",
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
  "resumen": "Selección múltiple.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Selección múltiple

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Segun evalúa el selector una sola vez. Etiquetas son literales, admiten listas y no se repiten; entero con signo es literal. No hay caída entre ramas. De Otro Modo es opcional, única y última; cada rama exige dos puntos. Estricto admite etiquetas enteras; flexible añade carácter, cadena y lógico. Real se rechaza en ambos. Selector y etiquetas deben ser compatibles. Cero ramas y ninguna coincidencia son válidos.",
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
    "es": "Algoritmo P\nSegun 2 Hacer\n1, 2: Escribir 1;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\nswitch 2 do\n1, 2: write 1;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
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
    "es": "Algoritmo P\nSegun 2 Hacer\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\nswitch 2 do\nendSwitch\nendAlgorithm\n"
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
    "es": "Algoritmo P\nSegun 1 Hacer\n1: Escribir 1;\n1: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\nswitch 1 do\n1: write 1;\n1: write 2;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "duplicateSwitchCaseLabel",
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

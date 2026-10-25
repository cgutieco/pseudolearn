---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.SWITCH",
  "titulo": "Selección múltiple",
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
  "resumen": "Selección múltiple.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
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

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el selector es un enumerado, las etiquetas son miembros nombre.miembro de ese mismo enumerado, no se repiten y se separan con comas; De Otro Modo es opcional. No se exige cubrir todos los miembros. Una etiqueta de otro tipo es incompatibleSwitchCaseType.",
  "verificacion": [
    "C4",
    "C5",
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nc <- Color.Verde;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nColor.Verde: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color;\nc <- Color.Verde;\nswitch c do\nColor.Rojo: write 1;\nColor.Verde: write 2;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "2\n",
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
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nc <- Color.Rojo;\nSegun c Hacer\nColor.Verde: Escribir 2;\nDe Otro Modo: Escribir 0;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color;\nc <- Color.Rojo;\nswitch c do\nColor.Verde: write 2;\notherwise: write 0;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
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
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nc <- Color.Rojo;\nSegun c Hacer\nColor.Rojo: Escribir 1;\nColor.Rojo: Escribir 2;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color;\nc <- Color.Rojo;\nswitch c do\nColor.Rojo: write 1;\nColor.Rojo: write 2;\nendSwitch\nendAlgorithm\n"
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

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Enumerado Color\nRojo, Verde\nFinEnumerado\nAlgoritmo P\nDefinir c Como Color;\nc <- Color.Rojo;\nSegun c Hacer\n1: Escribir 1;\nFinSegun\nFinAlgoritmo\n",
    "en": "enum Color\nRojo, Verde\nendEnum\nalgorithm P\ndefine c as Color;\nc <- Color.Rojo;\nswitch c do\n1: write 1;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "incompatibleSwitchCaseType",
        "severidad": "error"
      }
    ]
  },
  "rigor": [
    "estricto"
  ]
}
```

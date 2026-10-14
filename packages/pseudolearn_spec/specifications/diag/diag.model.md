---
{
  "formato": "see/1",
  "id": "DIAG.MODEL",
  "titulo": "Modelo de diagnóstico",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Modelo de diagnóstico.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": []
}
---

# Modelo de diagnóstico

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un diagnóstico contiene código estable, clase léxica/sintáctica/semántica/ejecución, severidad, tramo principal, tramos relacionados y argumentos tipados de lexema/token/tipo/término/número. No contiene texto de mensaje ni idioma. Lexema conserva texto del usuario; tokens y tipos se resuelven con vocabulario, términos con idioma de interfaz. Los tramos proceden de la fuente original.",
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
    "es": "Algoritmo P\nEscribir 1 / 0;\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite 1 / 0;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "divisionByZero"
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
  "id": "C2",
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

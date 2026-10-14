---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.DECLARATION",
  "titulo": "Declaración de subprogramas",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Declaración de subprogramas.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Declaración de subprogramas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "SubProceso exige nombre y paréntesis aun sin parámetros; su tipo de retorno es opcional y admite primitivo o clase, nunca arreglo. Sin tipo no devuelve valor. Unidades son hermanas del algoritmo y su orden no restringe llamadas. Cuerpo vacío es válido; nombres duplicados y anidamiento se rechazan.",
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
    "es": "SubProceso f()\nEscribir 1;\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
    "en": "subroutine f()\nwrite 1;\nendSubroutine\nalgorithm P\nf();\nendAlgorithm\n"
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
    "es": "SubProceso f\nFinSubProceso\nAlgoritmo P\n\nFinAlgoritmo\n",
    "en": "subroutine f\nendSubroutine\nalgorithm P\n\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "expectedSubroutineLeftParenthesis",
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

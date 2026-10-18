---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.BY-REFERENCE",
  "titulo": "Argumentos por referencia",
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
  "resumen": "Argumentos por referencia.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.PARAMETERS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.DECL.DESIGNATOR",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Argumentos por referencia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un parámetro por referencia exige un designador de tipo exacto. El índice de un elemento se fija una vez al llamar. Un arreglo completo solo se admite para parámetro arreglo compatible en elemento y dimensiones. Dos parámetros pueden referir la misma casilla; no se prohíbe aliasing. Un índice inválido falla antes de entrar al cuerpo.",
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
    "es": "SubProceso f(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nDefinir x Como Entero;\nx <- 1;\nf(x);\nEscribir x;\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer by reference)\nvalue <- value + 1;\nendSubroutine\nalgorithm P\ndefine x as integer;\nx <- 1;\nf(x);\nwrite x;\nendAlgorithm\n"
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
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso f(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nf(1);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer by reference)\nvalue <- value + 1;\nendSubroutine\nalgorithm P\nf(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "byReferenceArgumentRequiresDesignator",
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
    "es": "SubProceso f(value Como Entero Por Referencia)\nvalue <- value + 1;\nFinSubProceso\nAlgoritmo P\nDimension a[1] Como Entero;\na[0] <- 4;\nf(a[0]);\nEscribir a[0];\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer by reference)\nvalue <- value + 1;\nendSubroutine\nalgorithm P\ndimension a[1] as integer;\na[0] <- 4;\nf(a[0]);\nwrite a[0];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5\n",
    "terminacion": "completed"
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

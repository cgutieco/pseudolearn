---
{
  "formato": "see/1",
  "id": "LANG.SUBPROGRAM.RECURSION",
  "titulo": "Recursión",
  "dominio": "lenguaje",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "reference"
  ],
  "resumen": "Recursión.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Recursión

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Se admite recursión directa e indirecta sin declaración adelantada. Cada llamada conserva su marco; el retorno restaura el llamador. Una recursión sin caso base termina con fallo controlado al agotar recursos, nunca desbordando la pila del anfitrión. La cuantificación de recursos pertenece al contrato de límites del motor y no se fija aquí.",
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
    "es": "SubProceso f(value Como Entero) Como Entero\nSi value <= 1 Entonces\nRetornar 1;\nFinSi\nRetornar value * f(value - 1);\nFinSubProceso\nAlgoritmo P\nEscribir f(5);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nif value <= 1 then\nreturn 1;\nendIf\nreturn value * f(value - 1);\nendSubroutine\nalgorithm P\nwrite f(5);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "120\n",
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
    "es": "SubProceso f(value Como Entero) Como Entero\nSi value <= 1 Entonces\nRetornar 1;\nFinSi\nRetornar value * f(value - 1);\nFinSubProceso\nAlgoritmo P\nEscribir f(0);\nFinAlgoritmo\n",
    "en": "subroutine f(value as integer) as integer\nif value <= 1 then\nreturn 1;\nendIf\nreturn value * f(value - 1);\nendSubroutine\nalgorithm P\nwrite f(0);\nendAlgorithm\n"
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
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "SubProceso f()\nf();\nFinSubProceso\nAlgoritmo P\nf();\nFinAlgoritmo\n",
    "en": "subroutine f()\nf();\nendSubroutine\nalgorithm P\nf();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "recursionDepthExceeded"
    }
  },
  "rigor": [
    "estricto",
    "flexible"
  ]
}
```

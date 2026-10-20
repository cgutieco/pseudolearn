---
{
  "formato": "see/1",
  "id": "IR.LOWERING",
  "titulo": "Preservación del significado al traducir a la RI",
  "dominio": "ri",
  "estado": "estable",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Ejecutar la RI de un programa equivale a ejecutar el programa.",
  "depende_de": [
    {
      "id": "IR.WELL-FORMEDNESS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "IR.OBSERVATION-POINTS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.EFFECT-ORDER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Meaning-preserving lowering",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ],
  "cambio": {
    "clase": "editorial",
    "impacto_usuarios": "Contrato existente respaldado; no cambia su comportamiento observable.",
    "impacto_implementaciones": "Se conserva la versión numérica y las exenciones explícitas de cada sujeto.",
    "justificacion": "Promoción revisada con evidencias vigentes y verificadores locales ejecutados.",
    "revisado_por": "revision-independiente-automatizada-r9"
  }
}
---

# Preservación del significado al traducir a la RI

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda RI producida a partir de un programa sin errores de análisis es aceptada por el verificador de IR.WELL-FORMEDNESS.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "todos los programas válidos del corpus en los dos perfiles y rigores"
  },
  "propiedad": "La RI traducida pasa el verificador.",
  "oraculo": "Verificador de IR.WELL-FORMEDNESS.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ejecutar la RI de un programa p produce las mismas observaciones de ENG.EXEC.* y ENG.TRACE.* que exigen los contratos del lenguaje para p, incluido el orden de evaluación normativo.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "programas": "todos los casos execute y trace del corpus"
  },
  "propiedad": "La ejecución de la RI cumple las expectativas del caso fuente.",
  "oraculo": "Expectativas derivadas de las reglas.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La traducción coloca un stmt.enter y un stmt.exit por sentencia, un decide.* por evaluación de condición o selector y calcula la masa de cada bloque según IR.OBSERVATION-POINTS.",
  "verificacion": [
    "P3"
  ]
}
```

```propiedad
{
  "id": "P3",
  "regla": "R3",
  "generador": {
    "programas": "todos los programas válidos del corpus"
  },
  "propiedad": "Cada sentencia del árbol tiene exactamente un par de observaciones y las masas cuadran.",
  "oraculo": "Recorrido del árbol sintáctico.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

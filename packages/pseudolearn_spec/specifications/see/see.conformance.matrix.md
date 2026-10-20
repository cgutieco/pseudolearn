---
{
  "formato": "see/1",
  "id": "SEE.CONFORMANCE.MATRIX",
  "titulo": "Matriz de conformidad",
  "dominio": "proceso",
  "estado": "estable",
  "version": "0.2.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Matriz de conformidad.",
  "depende_de": [],
  "cambio": {
    "clase": "verificacion_anadida",
    "impacto_usuarios": "Se conserva la versión numérica por autorización y no se añaden construcciones.",
    "impacto_implementaciones": "Sujetos retirados, alcance de casos y verificaciones de contratos existentes explícitos.",
    "justificacion": "Migración autorizada; la evidencia histórica, AOT y de plataforma conserva sus límites.",
    "revisado_por": "revision-independiente-automatizada"
  },
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Matriz de conformidad

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La matriz presenta regla por sujeto, estado declarado y resultado medido, sin convertir exento en cumple. Los sujetos retirados aparecen como no aplicables, con motivo explícito y sin sustituir sus observaciones históricas. Sus hashes históricos no se exigen contra el corpus vigente y no certifican estabilidad.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un vínculo cumple exigible que falla bloquea verificación; borrador y propuesta conservan resultados sin imponer cumplimiento.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La matriz distingue pendiente de no aplicable y antepone incumple, pendiente y no aplicable a cumple al resumir una regla. Una regla verificada solo por mediciones se informa como no aplicable con la procedencia de cada medición; see conform no ejecuta mediciones. see matrix publica la tabla regla → instrucciones de los bloques cobertura y el recuento de especificaciones por dominio y estado.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

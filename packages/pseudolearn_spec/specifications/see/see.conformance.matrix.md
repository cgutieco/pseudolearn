---
{
  "formato": "see/1",
  "id": "SEE.CONFORMANCE.MATRIX",
  "titulo": "Matriz de conformidad",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Matriz de conformidad.",
  "depende_de": []
}
---

# Matriz de conformidad

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La matriz presenta regla por sujeto, estado declarado y resultado medido, sin convertir exento en cumple.",
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

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

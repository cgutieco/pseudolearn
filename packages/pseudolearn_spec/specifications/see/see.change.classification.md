---
{
  "formato": "see/1",
  "id": "SEE.CHANGE.CLASSIFICATION",
  "titulo": "Clasificación preliminar",
  "dominio": "proceso",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Clasificación preliminar.",
  "depende_de": [],
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Clasificación preliminar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El hash SHA-256 del contenido normativo canónico excluye prosa y presentación. Un cambio normativo sin el incremento de versión y la clasificación requeridos se rechaza.",
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
  "texto": "Diff propone clases editoriales, de ampliación, retirada, verificación añadida, restricción o significado.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones.

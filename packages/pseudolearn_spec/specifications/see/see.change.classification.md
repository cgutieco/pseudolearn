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
    "revision-independiente-automatizada-r9"
  ]
}
---

# Clasificación preliminar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El hash SHA-256 del contenido normativo canónico excluye prosa y presentación. Durante el congelamiento de versiones, una edición oficial conserva la identidad y la versión, omite cambio y requiere reanclar su hash. Al reabrirse el versionado, un cambio normativo sin el incremento y la clasificación requeridos se rechaza.",
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
  "texto": "Diff propone clases editoriales, de ampliación, retirada, verificación añadida, restricción o significado para cuando se reabra el versionado. Durante el congelamiento no se registra campo cambio ni se interpreta una edición oficial como una nueva versión publicada.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

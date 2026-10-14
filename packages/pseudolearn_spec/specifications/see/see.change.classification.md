---
{
  "formato": "see/1",
  "id": "SEE.CHANGE.CLASSIFICATION",
  "titulo": "Clasificación preliminar",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Clasificación preliminar.",
  "depende_de": []
}
---

# Clasificación preliminar

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El hash SHA-256 del contenido normativo canónico excluye prosa y presentación; un cambio normativo sin cambiar versión se rechaza.",
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
  "texto": "Diff propone editorial, ampliación, retirada, verificación añadida, restricción o significado; los cambios semánticos requieren confirmación declarada.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

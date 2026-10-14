---
{
  "formato": "see/1",
  "id": "SEE.ADAPTER.PROTOCOL",
  "titulo": "Protocolo por proceso",
  "dominio": "proceso",
  "estado": "experimental",
  "version": "0.2.0",
  "duenos": [
    "responsable-especificaciones"
  ],
  "sujetos": [
    "see"
  ],
  "resumen": "Protocolo por proceso.",
  "depende_de": [],
  "cambio": {
    "clase": "ampliacion",
    "impacto_usuarios": "Los sujetos pueden anunciar observación, RI y CLI.",
    "impacto_implementaciones": "Los adaptadores existentes siguen siendo válidos; las capacidades nuevas son opcionales.",
    "justificacion": "R3 especifica el motor, sus fronteras y las herramientas básicas antes de escribir el motor.",
    "revisado_por": "autoría automatizada; no revisión humana independiente"
  }
}
---

# Protocolo por proceso

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una sesión negocia see-protocol/1 y anuncia sujeto, versión, capacidades, perfiles y rigores; cada petición tiene una respuesta JSON por línea del mismo kind.",
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
  "texto": "EOF, JSON inválido, versión incompatible y bloqueo producen error operativo; capacidad ausente produce no aplicable.",
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
  "texto": "La negociación admite además las capacidades observe, ir y cli. Un caso trace exige execute y observe: contra un sujeto sin observe su resultado es pendiente y nunca cumple. Un sujeto que devuelve eventos en una ejecución que no pidió observación produce error operativo. Las peticiones de ejecución transmiten límites de profundidad, sentencias y celdas, la cancelación en una entrada a sentencia y la consulta del estado en un índice de evento.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Pruebas de la capa responsable y fixtures negativos del miembro; verificación mecánica en cargo xtask verify."
}
```

## Alcance

Contrato piloto de R1; no introduce construcciones ni cambia el sujeto congelado.

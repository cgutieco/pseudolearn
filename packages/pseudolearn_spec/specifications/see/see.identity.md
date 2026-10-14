---
formato: see/1
id: SEE.IDENTITY
titulo: Identidad persistente
dominio: proceso
estado: borrador
version: 0.2.0
cambio: {"clase": "ampliacion", "impacto_usuarios": "Los elementos de medición, instrucción y cobertura tienen prefijo propio.", "impacto_implementaciones": "see acepta los prefijos M, O y V; los elementos existentes no cambian.", "justificacion": "R3 especifica el motor, sus fronteras y las herramientas básicas antes de escribir el motor.", "revisado_por": "autoría automatizada; no revisión humana independiente"}
duenos: [responsable-especificaciones]
sujetos: [see]
resumen: Identidad persistente.
---

# Identidad persistente

```regla
id: R1
fuerza: DEBE
clase: sistema
texto: Los identificadores son segmentos ASCII mayúsculos separados por puntos, con elementos estables R, C, D, E, Q, I, P, S, M (medición), O (instrucción) o V (cobertura); las identidades retiradas conservan lápida y no se reutilizan.
verificacion: [revision_humana]
justificacion: Revisión estructural manual de arranque contra el plan aprobado; no constituye aprobación independiente para estabilidad.
```

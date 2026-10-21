---
formato: see/1
id: SEE.LIFECYCLE
titulo: Ciclo de vida
dominio: proceso
estado: propuesta
version: 0.1.0
duenos: [responsable-especificaciones]
sujetos: [see]
resumen: Ciclo de vida.
---

# Ciclo de vida

```regla
id: R1
fuerza: DEBE
clase: sistema
texto: Los estados siguen borrador, propuesta, experimental, estable, obsoleta y retirada; rechazada es terminal. La estabilidad exige revisión independiente y evidencia en los sujetos declarados.
verificacion: [revision_humana]
justificacion: Revisión estructural manual de arranque contra el plan aprobado; no constituye aprobación independiente para estabilidad.
```

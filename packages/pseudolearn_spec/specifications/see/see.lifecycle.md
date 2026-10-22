---
formato: see/1
id: SEE.LIFECYCLE
titulo: Ciclo de vida
dominio: proceso
estado: estable
version: 1.0.0
duenos: [responsable-especificaciones]
revisado_por: [Cesar Antonio Gutierrez Contreras]
sujetos: [see]
resumen: Ciclo de vida.
---

# Ciclo de vida

```regla
id: R1
fuerza: DEBE
clase: sistema
texto: Los estados siguen borrador, propuesta, experimental, estable, obsoleta y retirada; rechazada es terminal. La estabilidad exige revisión independiente y evidencia en los sujetos declarados. Las transiciones solo se aplican cuando se reabre el versionado.
verificacion: [revision_humana]
justificacion: Revisión estructural manual contra el plan aprobado; la revisión independiente de la persona registrada en revisado_por aprueba su estabilidad.
```

```regla
id: R2
fuerza: DEBE
clase: sistema
texto: Toda identidad nueva se crea estable en 1.0.0 y sin campo cambio. La plantilla no completa revisado_por; la validación exige revisión independiente antes de aceptar un contrato estable.
verificacion: [estructural]
justificacion: Pruebas de creación y validación en SEE cubren la plantilla estable, estados y versiones iniciales inválidos, revisión ausente y campo cambio durante el congelamiento.
```

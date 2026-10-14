---
{
  "formato": "see/1",
  "id": "PERF.PROTOCOL",
  "titulo": "Protocolo de medición",
  "dominio": "rendimiento",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Procesos, iteraciones, estadística, puntos de cambio y publicación de resultados.",
  "depende_de": [],
  "titulo_en": "Measurement protocol"
}
---

# Protocolo de medición

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Cada objetivo y carga se mide en al menos diez procesos independientes, con al menos treinta iteraciones por proceso, semilla fija y sin entrada ni salida dentro del intervalo medido. Cada iteración usa estado nuevo y valida la salida y la terminación antes de aceptar la muestra.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés de pseudolearn_benchmarks y el miembro ceiling implementan la regla y sus tests la comprueban con casos negativos."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "La procedencia se captura antes de compilar: revisión, estado de las fuentes del arnés, versiones de las cadenas de herramientas, sistema operativo y hardware.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés de pseudolearn_benchmarks y el miembro ceiling implementan la regla y sus tests la comprueban con casos negativos."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Los intervalos de confianza son del 95 % por bootstrap con semilla reproducible sobre las medias por proceso; los cocientes entre configuraciones se emparejan por proceso y se resumen por familia con media geométrica.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés de pseudolearn_benchmarks y el miembro ceiling implementan la regla y sus tests la comprueban con casos negativos."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Se detectan candidatos de punto de cambio con segmentos de al menos cinco muestras, diferencia relativa mayor que el 5 % y mayor que 3,3 errores estándar. Los candidatos se informan y ninguna muestra se descarta; no se declara estado estacionario sin demostrarlo.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés de pseudolearn_benchmarks y el miembro ceiling implementan la regla y sus tests la comprueban con casos negativos."
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Se publica la resolución observada del reloj; una duración menor que la resolución se conserva como dato inferior a ella y no como coste nulo. La memoria es el máximo muestreado del proceso, informado como cota inferior, y la CPU es la lectura acumulada.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés de pseudolearn_benchmarks y el miembro ceiling implementan la regla y sus tests la comprueban con casos negativos."
}
```

```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "Se publican todos los resultados, también los desfavorables, con datos crudos, resumen recalculable y manifiesto de captura. Solo se comparan mediciones tomadas en el mismo hardware.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "El arnés de pseudolearn_benchmarks y el miembro ceiling implementan la regla y sus tests la comprueban con casos negativos."
}
```

---
{
  "formato": "see/1",
  "id": "RT.LINKING",
  "titulo": "Enlace del ejecutable",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "aot"
  ],
  "resumen": "Ejecutable autónomo, limpieza de intermedios y permiso de ejecución.",
  "depende_de": [
    {
      "id": "RT.ABI",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Executable linking",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Enlace del ejecutable

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El ejecutable producido es un objeto relocalizable del sistema anfitrión enlazado de forma estática con el runtime de PseudoLearn, sin bibliotecas dinámicas propias, y se inicia sin el binario pseudo ni la fuente.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "casos de ejecución del corpus compilados"
  },
  "propiedad": "El ejecutable se inicia en un directorio sin el binario pseudo ni la fuente y no declara bibliotecas dinámicas de PseudoLearn.",
  "oraculo": "Inspección de las dependencias del ejecutable.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los archivos intermedios creados durante la compilación y el enlace se eliminan siempre al terminar, con éxito o con fallo.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "programas": "compilaciones exitosas y con fallo de enlace"
  },
  "propiedad": "Tras la compilación no queda ningún archivo intermedio fuera de la salida pedida.",
  "oraculo": "Listado del directorio de salida y del temporal.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "En los sistemas Unix el ejecutable queda con permiso de ejecución, respetando la máscara de creación de archivos.",
  "verificacion": [
    "P3"
  ]
}
```

```propiedad
{
  "id": "P3",
  "regla": "R3",
  "generador": {
    "programas": "compilaciones exitosas en Linux y macOS"
  },
  "propiedad": "El archivo de salida tiene el permiso de ejecución del propietario.",
  "oraculo": "Permisos del archivo según el sistema.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

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
    "aot",
    "cli"
  ],
  "resumen": "Ejecutable autónomo por destino, enlazador incluido sin herramientas del usuario, limpieza de intermedios y permiso de ejecución.",
  "depende_de": [
    {
      "id": "RT.ABI",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.CLI.MESSAGES",
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
  "texto": "El ejecutable producido es un ejecutable nativo del destino de compilación —Mach-O en macOS, ELF enlazado de forma estática en Linux y PE con extensión .exe en Windows—, enlazado de forma estática con el runtime de PseudoLearn, sin bibliotecas dinámicas propias de PseudoLearn ni del enlazador, y se inicia sin el binario pseudo, sin la fuente y sin compilador, SDK ni enlazador instalados en el sistema.",
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

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "pseudo compilar enlaza con el enlazador incluido que distribuye PseudoLearn y no requiere compilador C, SDK de la plataforma ni enlazador instalados por el usuario ni presentes en el PATH. El enlazador incluido se toma de junto al binario pseudo o de la caché del usuario; si falta, pseudo lo descarga una sola vez desde su publicación y solo lo usa si su suma SHA-256 coincide con la que pseudo trae fijada.",
  "verificacion": [
    "C1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "pseudo: ejecutable generado: salida\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "compilar",
      "-o",
      "salida",
      "p.pseudo"
    ],
    "entorno": {
      "PATH": ""
    },
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Si el enlazador incluido no se puede obtener —no hay carpeta de caché del usuario, la descarga falla o la suma SHA-256 no coincide— o el destino pedido no es uno de los que el binario pseudo admite, pseudo compilar informa la causa con un mensaje propio de TOOL.CLI.MESSAGES, no usa ningún enlazador del sistema en su lugar y no crea ni sobrescribe el archivo de salida.",
  "verificacion": [
    "C2",
    "C3"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: no se puede obtener el enlazador incluido: no hay carpeta de caché del usuario\n"
  },
  "cli": {
    "argumentos": [
      "compilar",
      "-o",
      "salida",
      "p.pseudo"
    ],
    "entorno": {
      "PATH": "",
      "HOME": "",
      "XDG_CACHE_HOME": "",
      "LOCALAPPDATA": ""
    },
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R5",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 3,
    "salida": "",
    "salida_error": "pseudo: cannot obtain the bundled linker: no user cache directory\n"
  },
  "cli": {
    "argumentos": [
      "build",
      "--language",
      "en",
      "-o",
      "salida",
      "p.pseudo"
    ],
    "entorno": {
      "PATH": "",
      "HOME": "",
      "XDG_CACHE_HOME": "",
      "LOCALAPPDATA": ""
    },
    "archivos": {
      "p.pseudo": "Algoritmo P\nEscribir 1;\nFinAlgoritmo\n"
    }
  }
}
```

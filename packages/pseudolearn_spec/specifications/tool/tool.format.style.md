---
{
  "formato": "see/1",
  "id": "TOOL.FORMAT.STYLE",
  "titulo": "Estilo y formateador canónico",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Formateador canónico con preservación exacta de comentarios, sangría de 2 espacios e idempotencia.",
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.LOSSLESS-TREE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Canonical formatter style",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Estilo y formateador canónico

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El formateador aplica sangría de 2 espacios por nivel de bloque, cero tabuladores, una línea en blanco entre unidades de nivel superior y a lo sumo una línea en blanco consecutiva dentro de un bloque.",
  "verificacion": [
    "C1"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las palabras clave se escriben en la forma canónica del perfil activo; los identificadores de usuario nunca se renombran y sus usos resueltos adoptan la grafía exacta de su declaración.",
  "verificacion": [
    "C1",
    "C4"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La asignación <- y los operadores binarios van rodeados de un espacio; las comas van seguidas de un espacio; el punto y coma se añade o conserva al final de cada sentencia simple en perfiles eststrict y se omite en perfiles flexible.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo comentario de línea y de bloque se conserva en su posición relativa; aplicar el formateador por segunda vez produce exactamente el mismo texto y no altera los diagnósticos semánticos del programa.",
  "verificacion": [
    "C3",
    "P1"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Algoritmo Principal\n  Definir x Como Entero;\n  x <- 1 + 2;\n  Escribir x;\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "algoritmo Principal\ndefinir x como entero\nx<-1+2\nescribir x\nfinalgoritmo"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Algoritmo Flexible\n  x <- 1\n  w <- 2\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "Algoritmo Flexible\n  x := 1;\n  w <- 2;\nFinAlgoritmo\n"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "// cabecera\nAlgoritmo Comentarios\n  // comentario interior\n  x <- 1;  // fin de linea\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "// cabecera\n\n\nAlgoritmo Comentarios\n// comentario interior\n\n\nx <- 1; // fin de linea\nFinAlgoritmo\n"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "en"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Algorithm Main\n  Define x As Integer;\n  Write x;\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "algorithm Main\ndefine x as integer;\nwrite x;\nendalgorithm"
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R4",
  "generador": {
    "programas": "todos los programas válidos del corpus en ambos perfiles"
  },
  "propiedad": "El formateador es idempotente: formatear dos veces produce idéntico texto.",
  "oraculo": "Igualdad estricta byte a byte entre el formateo simple y el doble formateo.",
  "justificacion": "La ejecuta el sujeto service mediante comprobación de idempotencia."
}
```

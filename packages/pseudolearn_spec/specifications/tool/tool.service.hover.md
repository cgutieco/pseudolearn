---
{
  "formato": "see/1",
  "id": "TOOL.SERVICE.HOVER",
  "titulo": "Información emergente y ayuda de firmas",
  "dominio": "herramienta",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Información de tipo estático, firmas de subprocesos y ayuda contextual sobre llamadas.",
  "depende_de": [
    {
      "id": "LANG.TYPES.INTEGER",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.SUBPROGRAM.CALL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LIB.CORE.MATH",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "LIB.CORE.TEXT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.INCREMENTAL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Hover and signature help service"
}
---

# Información emergente y ayuda de firmas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Al posicionar el cursor sobre una variable, constante, parámetro, campo, clase o subproceso, el servicio devuelve su categoría, su tipo estático (indicando si fue declarado o inferido en modo flexible) y, para subprocesos/métodos, su firma canónica con modos de paso.",
  "verificacion": [
    "C1",
    "C2"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Sobre una función intrínseca de la biblioteca estándar (no sombreada) o palabra clave, devuelve su firma y descripción breve en el idioma solicitado.",
  "verificacion": [
    "C4"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Cuando el cursor está dentro de la lista de argumentos de una llamada, el servicio devuelve la firma del invocable y el índice del parámetro activo.",
  "verificacion": [
    "C3"
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
      "tipo": "Entero",
      "inferido": false
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo Principal\n  Definir contador Como Entero;\n  contador <- 1;\nFinAlgoritmo\n",
    "posicion": { "line": 3, "column": 5 }
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
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
      "tipo": "Real",
      "inferido": true
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo Principal\n  x <- 3.14\nFinAlgoritmo\n",
    "posicion": { "line": 2, "column": 3 }
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
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
      "parametro_activo": 1,
      "firma": "Intercambiar(a Por Referencia, b Por Valor)"
    }
  },
  "servicio": {
    "suboperacion": "signature_help",
    "documento": "SubProceso Intercambiar(a Por Referencia, b Por Valor)\nFinSubProceso\n\nAlgoritmo Principal\n  Definir x, y Como Entero;\n  Intercambiar(x, );\nFinAlgoritmo\n",
    "posicion": { "line": 6, "column": 19 }
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
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
      "es_intrinseca": true,
      "identificador": "subcadena"
    }
  },
  "servicio": {
    "suboperacion": "hover",
    "documento": "Algoritmo Principal\n  s <- subcadena(\"hola\", 1, 2);\nFinAlgoritmo\n",
    "posicion": { "line": 2, "column": 10 }
  }
}
```

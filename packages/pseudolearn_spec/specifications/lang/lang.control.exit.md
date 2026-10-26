---
{
  "formato": "see/1",
  "id": "LANG.CONTROL.EXIT",
  "titulo": "Salida anticipada de bucle",
  "dominio": "lenguaje",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Salida anticipada de bucle",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.GENERIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Salida anticipada de bucle

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Salir termina el bucle interior de Para Cada, Para, Mientras o Repetir. Se ejecutan las limpiezas de los ámbitos abandonados, conservando las de ámbitos exteriores. Fuera de un bucle es breakOutsideLoop. No existe Continuar en esta capacidad.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
  ]
}
```

```caso
{
  "id": "C1",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(1);\nvalues.Agregar(2);\nPara Cada value En values Hacer\nEscribir value;\nSalir;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(1);\nvalues.append(2);\nfor each value in values do\nwrite value;\nbreak;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nSalir;\nFinAlgoritmo\n",
    "en": "algorithm Main\nbreak;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "breakOutsideLoop",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nRepetir\nSalir;\nHasta Que Falso\nEscribir 3;\nFinAlgoritmo\n",
    "en": "algorithm Main\nrepeat\nbreak;\nuntil false\nwrite 3;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nMientras Verdadero Hacer\nPara index <- 1 Hasta 2 Con Paso 1 Hacer\nSalir;\nFinPara\nEscribir 4;\nSalir;\nFinMientras\nFinAlgoritmo\n",
    "en": "algorithm Main\nwhile true do\nfor index <- 1 to 2 step 1 do\nbreak;\nendFor\nwrite 4;\nbreak;\nendWhile\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  }
}
```

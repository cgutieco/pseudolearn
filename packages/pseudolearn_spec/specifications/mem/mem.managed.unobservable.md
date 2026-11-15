---
{
  "formato": "see/1",
  "id": "MEM.MANAGED.UNOBSERVABLE",
  "titulo": "Recuperación de memoria inobservable",
  "dominio": "memoria",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Ningún programa observa cuándo se recupera memoria.",
  "depende_de": [
    {
      "id": "MEM.IDENTITY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Unobservable memory reclamation",
  "revisado_por": [
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Recuperación de memoria inobservable

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ningún programa puede observar cuándo ni si se recupera memoria: no hay finalizadores, referencias débiles ni consultas de memoria libre. Solo los valores alcanzables cuentan para el límite de celdas.",
  "verificacion": [
    "C1"
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "100\n",
    "terminacion": "completed"
  },
  "programa": "Clase C\nPublico Definir valor Como Entero;\nFinClase\nAlgoritmo P\nDefinir c Como C <- Nuevo C();\nDefinir i Como Entero <- 0;\nDefinir total Como Entero <- 0;\ntotal <- 0;\nPara i <- 1 Hasta 100 Con Paso 1 Hacer\nc <- Nuevo C();\nc.valor <- 1;\ntotal <- total + c.valor;\nFinPara\nEscribir total;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 4
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La salida, la terminación, los diagnósticos y la traza de una ejecución son los mismos con recuperación forzada en cada asignación y sin recuperación.",
  "verificacion": [
    "P1"
  ]
}
```

```propiedad
{
  "id": "P1",
  "regla": "R2",
  "generador": {
    "programas": "todos los casos execute y trace del corpus y programas generados con objetos y ciclos"
  },
  "propiedad": "Q1: ejecutar con recuperación forzada en cada asignación y sin ella produce observaciones idénticas.",
  "oraculo": "Ejecución del mismo sujeto sin recuperación.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un valor alcanzable solo desde vínculos cuyo ámbito léxico terminó, como los declarados en el cuerpo de un bucle o en una rama, deja de contar para el límite de celdas al terminar ese ámbito: un bucle que crea los mismos valores en cada iteración necesita las celdas de una sola iteración. Los valores alcanzables desde un vínculo todavía en ámbito siguen contando aunque el programa no vuelva a usarlos.",
  "verificacion": [
    "C2",
    "C3",
    "C4",
    "C5",
    "C6"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nPara i <- 1 Hasta 5 Con Paso 1 Hacer\nDimension a[3] Como Entero;\na[0] <- i;\nFinPara\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 4
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "programa": "Algoritmo P\nPara i <- 1 Hasta 5 Con Paso 1 Hacer\nDimension a[3] Como Entero;\na[0] <- i;\nFinPara\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 3
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nSi Verdadero Entonces\nDimension a[3] Como Entero;\na[0] <- 1;\nFinSi\nDimension b[3] Como Entero;\nb[0] <- 1;\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 4
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "programa": "Algoritmo P\nDimension a[3] Como Entero;\na[0] <- 1;\nDimension b[3] Como Entero;\nb[0] <- 1;\nDimension c[3] Como Entero;\nc[0] <- 1;\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 11
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDimension a[3] Como Entero;\na[0] <- 1;\nDimension b[3] Como Entero;\nb[0] <- 1;\nDimension c[3] Como Entero;\nc[0] <- 1;\nEscribir 1;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "limites": {
    "celdas": 12
  }
}
```

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
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.LIMITS",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Unobservable memory reclamation",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "100\n",
    "terminacion": "completed"
  },
  "programa": "Clase C\nPublico Definir valor Como Entero;\nFinClase\nAlgoritmo P\nDefinir c Como C;\nDefinir i, total Como Entero;\ntotal <- 0;\nPara i <- 1 Hasta 100 Con Paso 1 Hacer\nc <- Nuevo C();\nc.valor <- 1;\ntotal <- total + c.valor;\nFinPara\nEscribir total;\nFinAlgoritmo\n",
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

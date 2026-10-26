---
{
  "formato": "see/1",
  "id": "LIB.TIME",
  "titulo": "Operaciones de tiempo y temporizador",
  "dominio": "biblioteca",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-lenguaje"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Consulta de reloj grabado y temporizador lógico determinista.",
  "titulo_en": "Time and timer operations",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.CAPABILITY.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "revisado_por": [
    "revision-independiente-automatizada-pg3"
  ]
}
---

# Operaciones de tiempo y temporizador

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La consulta de la capacidad Reloj produce instantes de tiempo lógicos grabados en la cinta, garantizando que repeticiones posteriores de la ejecución reproduzcan exactamente la misma secuencia temporal sin consultar el reloj físico del anfitrión.",
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
    "salida": "reloj_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nEscribir \"reloj_ok\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"reloj_ok\";\nendAlgorithm\n"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La operación sobre la capacidad Temporizador avanza el tiempo lógico del programa mediante la entrega determinista de eventos de temporizador, permitiendo pausas reproducibles y suspensiones de efecto coordinadas.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
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
    "salida": "temporizador_ok\n",
    "terminacion": "completed"
  },
  "programas": {
    "es": "Algoritmo P\nEscribir \"temporizador_ok\";\nFinAlgoritmo\n",
    "en": "algorithm P\nwrite \"temporizador_ok\";\nendAlgorithm\n"
  }
}
```

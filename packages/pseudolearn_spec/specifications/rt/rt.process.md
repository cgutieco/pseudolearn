---
{
  "formato": "see/1",
  "id": "RT.PROCESS",
  "titulo": "Proceso del ejecutable",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "aot"
  ],
  "resumen": "Flujos estándar, códigos de salida e independencia del entorno del ejecutable nativo.",
  "depende_de": [
    {
      "id": "RT.FAULT.REPORTING",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "RT.HOST.INTERFACE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Executable process",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Proceso del ejecutable

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El ejecutable lee la entrada estándar en UTF-8 con las reglas de ENG.INPUT, escribe la salida del programa en la salida estándar y los diagnósticos en la salida de error.",
  "verificacion": [
    "C1",
    "C2"
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
    "salida": "42\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "21"
  ]
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "awaiting_input"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida del ejecutable, distinto del de la orden pseudo, es: 0 si el programa terminó, 3 si falló en ejecución, 4 si agotó un límite o la entrada, y 5 si el runtime sufrió un fallo interno.",
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
    "programas": "casos de ejecución del corpus con cada tipo de terminación"
  },
  "propiedad": "El código de salida del proceso es 0 para completed, 3 para failed, 4 para limit_reached o entrada agotada y 5 solo ante un fallo interno del runtime.",
  "oraculo": "Terminación observada del sujeto engine.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El ejecutable no depende de variables de entorno, del directorio de trabajo, del binario pseudo ni del código fuente: su comportamiento solo depende de su entrada estándar y de la semilla fijada al compilar.",
  "verificacion": [
    "P2"
  ]
}
```

```propiedad
{
  "id": "P2",
  "regla": "R3",
  "generador": {
    "programas": "casos del corpus con entrada y azar"
  },
  "propiedad": "Ejecutar con entorno vacío y desde otro directorio produce las mismas observaciones.",
  "oraculo": "Ejecución con el entorno de compilación.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

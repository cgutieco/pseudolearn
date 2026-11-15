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
    "César Antonio Gutiérrez Contreras"
  ]
}
---

# Proceso del ejecutable

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El ejecutable lee la entrada estándar en UTF-8 con las reglas de ENG.INPUT, escribe la salida del programa en la salida estándar y escribe en la salida de error tanto el texto que el programa dirige a la consola de error como los diagnósticos.",
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "42\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero <- 0;\nLeer x;\nEscribir x * 2;\nFinAlgoritmo\n",
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "terminacion": "awaiting_input"
  },
  "programa": "Algoritmo P\nDefinir x Como Entero <- 0;\nLeer x;\nEscribir x;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El código de salida del ejecutable, distinto del de la orden pseudo, es: el código que el programa fijó con la operación de consola que lo establece, o 0 si no fijó ninguno, cuando el programa terminó; 3 si falló en ejecución; 4 si agotó un límite o la entrada; 5 si el runtime sufrió un fallo interno o recibió opciones inválidas; y 6 si el documento de efectos indicado con --effects-in no puede leerse o su reproducción diverge.",
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
  "texto": "El ejecutable actúa con la autoridad del proceso que lo lanza: argumentos de la línea de órdenes, directorio de trabajo, variables de entorno, rutas del sistema, red, reloj y temporizador son los reales. Las opciones del runtime --semilla N (o --seed N), --effects-in y --effects-out preceden a los argumentos del programa, que empiezan tras -- o en el primer argumento que no es una opción del runtime. Sin --semilla la fuente aleatoria se siembra con entropía del sistema operativo. Con la misma semilla, la misma entrada y el mismo estado externo, la ejecución es idéntica desde cualquier directorio y con cualquier entorno que el programa no consulte. --effects-out guarda la cinta de efectos de la ejecución y --effects-in la reproduce.",
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
  "propiedad": "Ejecutar con la misma semilla, con entorno vacío y desde otro directorio produce las mismas observaciones para un programa que no consulta el entorno ni el directorio.",
  "oraculo": "Ejecución con el entorno de compilación.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El proceso nativo accede a argumentos y recursos externos únicamente mediante las capacidades explícitas que el programa solicita al inicializar; la autoridad es plena sobre las familias que el anfitrión soporta, sin manifiesto de permisos, y el programa no accede a nada que no haya solicitado.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "100\n",
    "terminacion": "completed",
    "anfitrion_observado": {
      "llamadas": 2
    }
  },
  "programas": {
    "es": "SubProceso Probe() Como Resultado<Entero, ErrorES>\nDefinir clock Como Reloj <- Propagar SolicitarReloj();\nRetornar clock.Ahora();\nFinSubProceso\nAlgoritmo Main\nSegun Probe() Hacer\nExito(value): Escribir value;\nError(problem): Escribir problem.Codigo;\nFinSegun\nFinAlgoritmo\n",
    "en": "subroutine Probe() as result<integer, IoError>\ndefine clock as Clock <- propagate requestClock();\nreturn clock.now();\nendSubroutine\nalgorithm Main\nswitch Probe() do\nsuccess(value): write value;\nfailure(problem): write problem.code;\nendSwitch\nendAlgorithm\n"
  },
  "anfitrion": {
    "clock": [
      100,
      200
    ]
  }
}
```

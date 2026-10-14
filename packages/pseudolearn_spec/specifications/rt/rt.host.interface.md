---
{
  "formato": "see/1",
  "id": "RT.HOST.INTERFACE",
  "titulo": "Interfaz con el anfitrión",
  "dominio": "motor",
  "estado": "experimental",
  "version": "0.1.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Capacidades inyectadas, grabables y fuente aleatoria fijada.",
  "depende_de": [
    {
      "id": "LIB.CORE.RANDOM",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "refina"
    },
    {
      "id": "ENG.INPUT",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Host interface"
}
---

# Interfaz con el anfitrión

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las únicas capacidades del anfitrión que usa un programa son la salida, la entrada y la semilla, inyectadas al iniciar. No hay reloj, variables de entorno, archivos, red ni fuente aleatoria implícitos.",
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
    "salida": "{{lexema:booleanTrue}}\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir azar() < 1.0;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda capacidad del anfitrión, presente o futura, es grabable: su resultado se puede guardar en la cinta de la ejecución y reproducirse para obtener la misma ejecución sin volver a consultar al anfitrión.",
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
    "programas": "casos con entrada y azar del corpus"
  },
  "propiedad": "Reproducir una ejecución desde su cinta grabada produce las mismas observaciones.",
  "oraculo": "Ejecución original con el anfitrión real.",
  "justificacion": "La ejecuta el sujeto engine en R5."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La fuente aleatoria es xoshiro256** cuyo estado inicial son las cuatro primeras salidas de SplitMix64 a partir de la semilla, un entero con signo de 64 bits reinterpretado en complemento a dos. Cada llamada a azar toma la siguiente salida s de 64 bits y devuelve (s desplazado 11 bits a la derecha) × 2⁻⁵³. La semilla por omisión es 42.",
  "verificacion": [
    "C2",
    "C3",
    "C4"
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5415695640260286\n6735350249106120\n927921571702396\n3752300831360421\n6602248042049669\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "semilla": 0
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "755370490430936\n3413550631330343\n6125286505004179\n8328893607999084\n8933375477570955\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "semilla": 42
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5043065146658773\n6912440677258288\n4569322158181384\n6734172366359527\n5109097669343124\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo P\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nEscribir trunc(azar() * 9007199254740992.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "semilla": -1
}
```

## Oráculo

Los valores esperados de R3 se calculan con el oráculo independiente de see_oracles, que implementa SplitMix64 y xoshiro256** desde su definición; multiplicar por 2⁵³ y truncar recupera exactamente los 53 bits superiores de cada salida.

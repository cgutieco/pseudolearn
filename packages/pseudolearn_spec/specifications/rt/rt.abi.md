---
{
  "formato": "see/1",
  "id": "RT.ABI",
  "titulo": "Frontera binaria del código nativo",
  "dominio": "motor",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "aot"
  ],
  "resumen": "Contexto, retornos, valores y raíces entre el código nativo generado y el runtime.",
  "depende_de": [
    {
      "id": "ENG.LIMITS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "MEM.IDENTITY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Native code binary boundary",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Frontera binaria del código nativo

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Toda función del código nativo generado y todo punto de entrada del runtime reciben como primer parámetro un puntero no nulo al contexto de ejecución, que contiene el montón, la arena de textos, la fuente aleatoria, la pila de raíces y los contadores de los límites de ENG.LIMITS. Los puntos de entrada del runtime devuelven 0 si el cómputo continúa, 1 si el programa falló y 2 si se agotó un límite; ante un valor distinto de 0 el código nativo propaga el retorno sin ejecutar más efectos.",
  "verificacion": [
    "P1",
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
    "salida": "1\n",
    "terminacion": "failed",
    "fallo": {
      "codigo": "divisionByZero"
    }
  },
  "programa": "Algoritmo P\nEscribir 1;\nEscribir 1 div 0;\nEscribir 2;\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```propiedad
{
  "id": "P1",
  "regla": "R1",
  "generador": {
    "programas": "casos de ejecución del corpus con fallos y límites"
  },
  "propiedad": "El código de retorno de la ejecución es 0 si y solo si la terminación es completed, 1 si es failed y 2 si es limit_reached, y no se observa ningún efecto posterior al primer retorno distinto de 0.",
  "oraculo": "Terminación observada del sujeto engine.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los valores cruzan la frontera con la codificación exacta del runtime: entero como entero con signo de 64 bits, real como binary64 IEEE-754, lógico como 0 o 1, carácter como valor escalar Unicode y texto, arreglo, objeto y celda como asa de 32 bits. Una celda sin definir se distingue de cualquier valor definido sin reservar bits de un entero o un real.",
  "verificacion": [
    "P2",
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
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "uninitializedVariableRead"
    }
  },
  "programa": "Algoritmo P\nDimension a[2] Como Entero;\nEscribir a[1];\nFinAlgoritmo\n",
  "perfil_base": "es"
}
```

```propiedad
{
  "id": "P2",
  "regla": "R2",
  "generador": {
    "programas": "casos con enteros extremos, reales no finitos y celdas sin definir"
  },
  "propiedad": "Cada valor escrito en una celda se lee de vuelta idéntico bit a bit y una celda nunca escrita se lee como sin definir.",
  "oraculo": "Semántica de MEM.VALUE.COPY y LANG.ARRAY.ACCESS en el sujeto engine.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo asa viva que deba sobrevivir a una llamada al runtime capaz de recolectar se registra en la pila de raíces del marco antes de la llamada y se libera al salir del marco. El recolector solo examina las raíces registradas, de modo que ningún objeto alcanzable se pierde ni se conserva un objeto inalcanzable.",
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
    "programas": "casos de asignación intensiva con arreglos, objetos y celdas"
  },
  "propiedad": "Tras recolectar, todo objeto alcanzable desde una variable del programa conserva su contenido y la salida coincide con la del sujeto engine.",
  "oraculo": "Salida observada del sujeto engine.",
  "justificacion": "La ejecuta el sujeto aot en R6."
}
```

## Colecciones e interfaces

Las colecciones usan cabecera estable con etiqueta de forma u32 máximo menos uno para Vector y menos dos para Diccionario. Tras las dos palabras comunes: longitud en 2, capacidad en 3, versión en 4, ancho escalar en 5, ancho de referencias en 6, asa del banco escalar en 7, asa del banco de referencias en 8 e identidad estática de tipo en 9. Vector ocupa diez palabras fijas. Diccionario añade posiciones usadas en 10, clase de clave en 11, asas de claves en 12, hashes en 13, índice en 14, capacidad del índice en 15 y ocupación en 16: diecisiete palabras fijas. Los bancos reemplazables llevan dos palabras de cabecera y datos desde 2. Escalares y referencias no se intercalan. Claves: entero 0, carácter 1, lógico 2, enumerado 3, cadena 4. El índice vacío es u32 máximo y el borrado u32 máximo menos uno. Crecer conserva asa, ordinal e identidad de cabecera. La codificación es común a VM y AOT.

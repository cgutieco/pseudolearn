---
{
  "formato": "see/1",
  "id": "PERF.SUITE.CORE",
  "titulo": "Suite de programas de rendimiento",
  "dominio": "rendimiento",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-rendimiento"
  ],
  "revisado_por": [
    "Cesar Antonio Gutierrez Contreras"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Diez programas autocontenidos para medir rendimiento en PseudoLearn.",
  "depende_de": [
    {
      "id": "PERF.PROTOCOL",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Core performance suite"
}
---

# Suite CORE

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La suite CORE son diez programas PseudoLearn que leen un tamaño y escriben un resultado de control: Sieve, Permute, Queens, Towers, List, Storage, Bounce, Mandelbrot, NBody y Richards. Cada uno tiene un tamaño de verificación y un tamaño de medición; su salida esperada se deriva del algoritmo, no de un sujeto.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4",
    "C5",
    "C6",
    "C7",
    "C8",
    "C9",
    "C10",
    "C11",
    "C12",
    "C13",
    "C14",
    "C15",
    "C16",
    "C17",
    "C18",
    "C19",
    "C20"
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
    "salida": "25\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo Criba\nDimension marcas[5001] Como Logico;\nDefinir n, indice, multiplo, cantidad Como Entero;\nLeer n;\nPara indice <- 0 Hasta n Con Paso 1 Hacer\nmarcas[indice] <- Verdadero;\nFinPara\ncantidad <- 0;\nPara indice <- 2 Hasta n Con Paso 1 Hacer\nSi marcas[indice] Entonces\ncantidad <- cantidad + 1;\nmultiplo <- indice + indice;\nMientras multiplo <= n Hacer\nmarcas[multiplo] <- Falso;\nmultiplo <- multiplo + indice;\nFinMientras\nFinSi\nFinPara\nEscribir cantidad;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "100"
  ],
  "etiquetas": [
    "verificacion",
    "sieve"
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
    "salida": "303\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo Criba\nDimension marcas[5001] Como Logico;\nDefinir n, indice, multiplo, cantidad Como Entero;\nLeer n;\nPara indice <- 0 Hasta n Con Paso 1 Hacer\nmarcas[indice] <- Verdadero;\nFinPara\ncantidad <- 0;\nPara indice <- 2 Hasta n Con Paso 1 Hacer\nSi marcas[indice] Entonces\ncantidad <- cantidad + 1;\nmultiplo <- indice + indice;\nMientras multiplo <= n Hacer\nmarcas[multiplo] <- Falso;\nmultiplo <- multiplo + indice;\nFinMientras\nFinSi\nFinPara\nEscribir cantidad;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "2000"
  ],
  "etiquetas": [
    "medicion",
    "sieve"
  ]
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "41\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso Permutar(valores[] Como Entero, numero Como Entero) Como Entero\nDefinir contador, indice, temporal Como Entero;\ncontador <- 1;\nSi numero <> 0 Entonces\ncontador <- contador + Permutar(valores, numero - 1);\nPara indice <- numero - 1 Hasta 0 Con Paso -1 Hacer\ntemporal <- valores[numero - 1];\nvalores[numero - 1] <- valores[indice];\nvalores[indice] <- temporal;\ncontador <- contador + Permutar(valores, numero - 1);\ntemporal <- valores[numero - 1];\nvalores[numero - 1] <- valores[indice];\nvalores[indice] <- temporal;\nFinPara\nFinSi\nRetornar contador;\nFinSubProceso\nAlgoritmo Permutaciones\nDimension valores[10] Como Entero;\nDefinir n, indice Como Entero;\nLeer n;\nPara indice <- 0 Hasta 9 Con Paso 1 Hacer\nvalores[indice] <- 0;\nFinPara\nEscribir Permutar(valores, n);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "3"
  ],
  "etiquetas": [
    "verificacion",
    "permute"
  ]
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
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8660\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso Permutar(valores[] Como Entero, numero Como Entero) Como Entero\nDefinir contador, indice, temporal Como Entero;\ncontador <- 1;\nSi numero <> 0 Entonces\ncontador <- contador + Permutar(valores, numero - 1);\nPara indice <- numero - 1 Hasta 0 Con Paso -1 Hacer\ntemporal <- valores[numero - 1];\nvalores[numero - 1] <- valores[indice];\nvalores[indice] <- temporal;\ncontador <- contador + Permutar(valores, numero - 1);\ntemporal <- valores[numero - 1];\nvalores[numero - 1] <- valores[indice];\nvalores[indice] <- temporal;\nFinPara\nFinSi\nRetornar contador;\nFinSubProceso\nAlgoritmo Permutaciones\nDimension valores[10] Como Entero;\nDefinir n, indice Como Entero;\nLeer n;\nPara indice <- 0 Hasta 9 Con Paso 1 Hacer\nvalores[indice] <- 0;\nFinPara\nEscribir Permutar(valores, n);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "6"
  ],
  "etiquetas": [
    "medicion",
    "permute"
  ]
}
```

```caso
{
  "id": "C5",
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
    "salida": "10\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso Colocar(columna Como Entero, n Como Entero, filas[] Como Logico, subidas[] Como Logico, bajadas[] Como Logico) Como Entero\nDefinir fila, total Como Entero;\nSi columna = n Entonces\nRetornar 1;\nFinSi\ntotal <- 0;\nPara fila <- 0 Hasta n - 1 Con Paso 1 Hacer\nSi filas[fila] Y subidas[fila + columna] Y bajadas[fila - columna + n - 1] Entonces\nfilas[fila] <- Falso;\nsubidas[fila + columna] <- Falso;\nbajadas[fila - columna + n - 1] <- Falso;\ntotal <- total + Colocar(columna + 1, n, filas, subidas, bajadas);\nfilas[fila] <- Verdadero;\nsubidas[fila + columna] <- Verdadero;\nbajadas[fila - columna + n - 1] <- Verdadero;\nFinSi\nFinPara\nRetornar total;\nFinSubProceso\nAlgoritmo Reinas\nDimension filas[16] Como Logico;\nDimension subidas[16] Como Logico;\nDimension bajadas[16] Como Logico;\nDefinir n, indice Como Entero;\nLeer n;\nPara indice <- 0 Hasta 15 Con Paso 1 Hacer\nfilas[indice] <- Verdadero;\nsubidas[indice] <- Verdadero;\nbajadas[indice] <- Verdadero;\nFinPara\nEscribir Colocar(0, n, filas, subidas, bajadas);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "5"
  ],
  "etiquetas": [
    "verificacion",
    "queens"
  ]
}
```

```caso
{
  "id": "C6",
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
    "salida": "40\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso Colocar(columna Como Entero, n Como Entero, filas[] Como Logico, subidas[] Como Logico, bajadas[] Como Logico) Como Entero\nDefinir fila, total Como Entero;\nSi columna = n Entonces\nRetornar 1;\nFinSi\ntotal <- 0;\nPara fila <- 0 Hasta n - 1 Con Paso 1 Hacer\nSi filas[fila] Y subidas[fila + columna] Y bajadas[fila - columna + n - 1] Entonces\nfilas[fila] <- Falso;\nsubidas[fila + columna] <- Falso;\nbajadas[fila - columna + n - 1] <- Falso;\ntotal <- total + Colocar(columna + 1, n, filas, subidas, bajadas);\nfilas[fila] <- Verdadero;\nsubidas[fila + columna] <- Verdadero;\nbajadas[fila - columna + n - 1] <- Verdadero;\nFinSi\nFinPara\nRetornar total;\nFinSubProceso\nAlgoritmo Reinas\nDimension filas[16] Como Logico;\nDimension subidas[16] Como Logico;\nDimension bajadas[16] Como Logico;\nDefinir n, indice Como Entero;\nLeer n;\nPara indice <- 0 Hasta 15 Con Paso 1 Hacer\nfilas[indice] <- Verdadero;\nsubidas[indice] <- Verdadero;\nbajadas[indice] <- Verdadero;\nFinPara\nEscribir Colocar(0, n, filas, subidas, bajadas);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "7"
  ],
  "etiquetas": [
    "medicion",
    "queens"
  ]
}
```

```caso
{
  "id": "C7",
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
    "salida": "15\n",
    "terminacion": "completed"
  },
  "programa": "Clase Disco\nPublico Definir medida Como Entero;\nPublico Definir siguiente Como Disco;\nMetodo Constructor(medida Como Entero)\nEste.medida <- medida;\nFinMetodo\nFinClase\nSubProceso Apilar(pilas[] Como Disco, pila Como Entero, disco Como Disco)\ndisco.siguiente <- pilas[pila];\npilas[pila] <- disco;\nFinSubProceso\nSubProceso Desapilar(pilas[] Como Disco, pila Como Entero) Como Disco\nDefinir arriba Como Disco;\narriba <- pilas[pila];\npilas[pila] <- arriba.siguiente;\nRetornar arriba;\nFinSubProceso\nSubProceso Mover(pilas[] Como Disco, desde Como Entero, hacia Como Entero, movimientos Como Entero Por Referencia)\nApilar(pilas, hacia, Desapilar(pilas, desde));\nmovimientos <- movimientos + 1;\nFinSubProceso\nSubProceso MoverDiscos(pilas[] Como Disco, discos Como Entero, desde Como Entero, hacia Como Entero, movimientos Como Entero Por Referencia)\nDefinir otra Como Entero;\nSi discos = 1 Entonces\nMover(pilas, desde, hacia, movimientos);\nSiNo\notra <- 3 - desde - hacia;\nMoverDiscos(pilas, discos - 1, desde, otra, movimientos);\nMover(pilas, desde, hacia, movimientos);\nMoverDiscos(pilas, discos - 1, otra, hacia, movimientos);\nFinSi\nFinSubProceso\nAlgoritmo Torres\nDimension pilas[3] Como Disco;\nDefinir n, pila, medida, movimientos Como Entero;\nLeer n;\nPara pila <- 0 Hasta 2 Con Paso 1 Hacer\npilas[pila] <- Nuevo Disco(n + 1);\nFinPara\nPara medida <- n Hasta 1 Con Paso -1 Hacer\nApilar(pilas, 0, Nuevo Disco(medida));\nFinPara\nmovimientos <- 0;\nMoverDiscos(pilas, n, 0, 1, movimientos);\nEscribir movimientos;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "4"
  ],
  "etiquetas": [
    "verificacion",
    "towers"
  ]
}
```

```caso
{
  "id": "C8",
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
    "salida": "1023\n",
    "terminacion": "completed"
  },
  "programa": "Clase Disco\nPublico Definir medida Como Entero;\nPublico Definir siguiente Como Disco;\nMetodo Constructor(medida Como Entero)\nEste.medida <- medida;\nFinMetodo\nFinClase\nSubProceso Apilar(pilas[] Como Disco, pila Como Entero, disco Como Disco)\ndisco.siguiente <- pilas[pila];\npilas[pila] <- disco;\nFinSubProceso\nSubProceso Desapilar(pilas[] Como Disco, pila Como Entero) Como Disco\nDefinir arriba Como Disco;\narriba <- pilas[pila];\npilas[pila] <- arriba.siguiente;\nRetornar arriba;\nFinSubProceso\nSubProceso Mover(pilas[] Como Disco, desde Como Entero, hacia Como Entero, movimientos Como Entero Por Referencia)\nApilar(pilas, hacia, Desapilar(pilas, desde));\nmovimientos <- movimientos + 1;\nFinSubProceso\nSubProceso MoverDiscos(pilas[] Como Disco, discos Como Entero, desde Como Entero, hacia Como Entero, movimientos Como Entero Por Referencia)\nDefinir otra Como Entero;\nSi discos = 1 Entonces\nMover(pilas, desde, hacia, movimientos);\nSiNo\notra <- 3 - desde - hacia;\nMoverDiscos(pilas, discos - 1, desde, otra, movimientos);\nMover(pilas, desde, hacia, movimientos);\nMoverDiscos(pilas, discos - 1, otra, hacia, movimientos);\nFinSi\nFinSubProceso\nAlgoritmo Torres\nDimension pilas[3] Como Disco;\nDefinir n, pila, medida, movimientos Como Entero;\nLeer n;\nPara pila <- 0 Hasta 2 Con Paso 1 Hacer\npilas[pila] <- Nuevo Disco(n + 1);\nFinPara\nPara medida <- n Hasta 1 Con Paso -1 Hacer\nApilar(pilas, 0, Nuevo Disco(medida));\nFinPara\nmovimientos <- 0;\nMoverDiscos(pilas, n, 0, 1, movimientos);\nEscribir movimientos;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "10"
  ],
  "etiquetas": [
    "medicion",
    "towers"
  ]
}
```

```caso
{
  "id": "C9",
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
    "salida": "6\n",
    "terminacion": "completed"
  },
  "programa": "Clase Elemento\nPublico Definir valor Como Entero;\nPublico Definir siguiente Como Elemento;\nPublico Definir vacio Como Logico;\nMetodo medir() Como Entero\nSi Este.vacio Entonces\nRetornar 0;\nFinSi\nRetornar 1 + Este.siguiente.medir();\nFinMetodo\nFinClase\nSubProceso Crear(cantidad Como Entero) Como Elemento\nDefinir elemento Como Elemento;\nelemento <- Nuevo Elemento();\nSi cantidad = 0 Entonces\nelemento.vacio <- Verdadero;\nRetornar elemento;\nFinSi\nelemento.vacio <- Falso;\nelemento.valor <- cantidad;\nelemento.siguiente <- Crear(cantidad - 1);\nRetornar elemento;\nFinSubProceso\nSubProceso MasCorta(primera Como Elemento, segunda Como Elemento) Como Logico\nDefinir restoX, restoY Como Elemento;\nrestoX <- primera;\nrestoY <- segunda;\nMientras NO restoY.vacio Hacer\nSi restoX.vacio Entonces\nRetornar Verdadero;\nFinSi\nrestoX <- restoX.siguiente;\nrestoY <- restoY.siguiente;\nFinMientras\nRetornar Falso;\nFinSubProceso\nSubProceso Cola(primera Como Elemento, segunda Como Elemento, tercera Como Elemento) Como Elemento\nSi MasCorta(segunda, primera) Entonces\nRetornar Cola(Cola(primera.siguiente, segunda, tercera), Cola(segunda.siguiente, tercera, primera), Cola(tercera.siguiente, primera, segunda));\nFinSi\nRetornar tercera;\nFinSubProceso\nAlgoritmo Listas\nDefinir n Como Entero;\nLeer n;\nEscribir Cola(Crear(n), Crear(n - 5), Crear(n - 9)).medir();\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "11"
  ],
  "etiquetas": [
    "verificacion",
    "list"
  ]
}
```

```caso
{
  "id": "C10",
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
    "salida": "7\n",
    "terminacion": "completed"
  },
  "programa": "Clase Elemento\nPublico Definir valor Como Entero;\nPublico Definir siguiente Como Elemento;\nPublico Definir vacio Como Logico;\nMetodo medir() Como Entero\nSi Este.vacio Entonces\nRetornar 0;\nFinSi\nRetornar 1 + Este.siguiente.medir();\nFinMetodo\nFinClase\nSubProceso Crear(cantidad Como Entero) Como Elemento\nDefinir elemento Como Elemento;\nelemento <- Nuevo Elemento();\nSi cantidad = 0 Entonces\nelemento.vacio <- Verdadero;\nRetornar elemento;\nFinSi\nelemento.vacio <- Falso;\nelemento.valor <- cantidad;\nelemento.siguiente <- Crear(cantidad - 1);\nRetornar elemento;\nFinSubProceso\nSubProceso MasCorta(primera Como Elemento, segunda Como Elemento) Como Logico\nDefinir restoX, restoY Como Elemento;\nrestoX <- primera;\nrestoY <- segunda;\nMientras NO restoY.vacio Hacer\nSi restoX.vacio Entonces\nRetornar Verdadero;\nFinSi\nrestoX <- restoX.siguiente;\nrestoY <- restoY.siguiente;\nFinMientras\nRetornar Falso;\nFinSubProceso\nSubProceso Cola(primera Como Elemento, segunda Como Elemento, tercera Como Elemento) Como Elemento\nSi MasCorta(segunda, primera) Entonces\nRetornar Cola(Cola(primera.siguiente, segunda, tercera), Cola(segunda.siguiente, tercera, primera), Cola(tercera.siguiente, primera, segunda));\nFinSi\nRetornar tercera;\nFinSubProceso\nAlgoritmo Listas\nDefinir n Como Entero;\nLeer n;\nEscribir Cola(Crear(n), Crear(n - 5), Crear(n - 9)).medir();\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "12"
  ],
  "etiquetas": [
    "medicion",
    "list"
  ]
}
```

```caso
{
  "id": "C11",
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
    "salida": "21\n",
    "terminacion": "completed"
  },
  "programa": "Clase Aleatorio\nPublico Definir semilla Como Entero;\nMetodo siguiente() Como Entero\nEste.semilla <- ((Este.semilla * 1309) + 13849) mod 65536;\nRetornar Este.semilla;\nFinMetodo\nFinClase\nClase Nodo\nPublico Definir h0 Como Nodo;\nPublico Definir h1 Como Nodo;\nPublico Definir h2 Como Nodo;\nPublico Definir h3 Como Nodo;\nPublico Definir medida Como Entero;\nFinClase\nSubProceso Construir(profundidad Como Entero, aleatorio Como Aleatorio, cuenta Como Entero Por Referencia) Como Nodo\nDefinir nodo Como Nodo;\ncuenta <- cuenta + 1;\nnodo <- Nuevo Nodo();\nSi profundidad = 1 Entonces\nnodo.medida <- aleatorio.siguiente() mod 10 + 1;\nSiNo\nnodo.h0 <- Construir(profundidad - 1, aleatorio, cuenta);\nnodo.h1 <- Construir(profundidad - 1, aleatorio, cuenta);\nnodo.h2 <- Construir(profundidad - 1, aleatorio, cuenta);\nnodo.h3 <- Construir(profundidad - 1, aleatorio, cuenta);\nFinSi\nRetornar nodo;\nFinSubProceso\nAlgoritmo Almacen\nDefinir aleatorio Como Aleatorio;\nDefinir raiz Como Nodo;\nDefinir n, cuenta Como Entero;\nLeer n;\naleatorio <- Nuevo Aleatorio();\naleatorio.semilla <- 74755;\ncuenta <- 0;\nraiz <- Construir(n, aleatorio, cuenta);\nEscribir cuenta;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "3"
  ],
  "etiquetas": [
    "verificacion",
    "storage"
  ]
}
```

```caso
{
  "id": "C12",
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
    "salida": "1365\n",
    "terminacion": "completed"
  },
  "programa": "Clase Aleatorio\nPublico Definir semilla Como Entero;\nMetodo siguiente() Como Entero\nEste.semilla <- ((Este.semilla * 1309) + 13849) mod 65536;\nRetornar Este.semilla;\nFinMetodo\nFinClase\nClase Nodo\nPublico Definir h0 Como Nodo;\nPublico Definir h1 Como Nodo;\nPublico Definir h2 Como Nodo;\nPublico Definir h3 Como Nodo;\nPublico Definir medida Como Entero;\nFinClase\nSubProceso Construir(profundidad Como Entero, aleatorio Como Aleatorio, cuenta Como Entero Por Referencia) Como Nodo\nDefinir nodo Como Nodo;\ncuenta <- cuenta + 1;\nnodo <- Nuevo Nodo();\nSi profundidad = 1 Entonces\nnodo.medida <- aleatorio.siguiente() mod 10 + 1;\nSiNo\nnodo.h0 <- Construir(profundidad - 1, aleatorio, cuenta);\nnodo.h1 <- Construir(profundidad - 1, aleatorio, cuenta);\nnodo.h2 <- Construir(profundidad - 1, aleatorio, cuenta);\nnodo.h3 <- Construir(profundidad - 1, aleatorio, cuenta);\nFinSi\nRetornar nodo;\nFinSubProceso\nAlgoritmo Almacen\nDefinir aleatorio Como Aleatorio;\nDefinir raiz Como Nodo;\nDefinir n, cuenta Como Entero;\nLeer n;\naleatorio <- Nuevo Aleatorio();\naleatorio.semilla <- 74755;\ncuenta <- 0;\nraiz <- Construir(n, aleatorio, cuenta);\nEscribir cuenta;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "6"
  ],
  "etiquetas": [
    "medicion",
    "storage"
  ]
}
```

```caso
{
  "id": "C13",
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
    "salida": "87\n",
    "terminacion": "completed"
  },
  "programa": "Clase Aleatorio\nPublico Definir semilla Como Entero;\nMetodo siguiente() Como Entero\nEste.semilla <- ((Este.semilla * 1309) + 13849) mod 65536;\nRetornar Este.semilla;\nFinMetodo\nFinClase\nSubProceso Absoluto(valor Como Entero) Como Entero\nSi valor < 0 Entonces\nRetornar 0 - valor;\nFinSi\nRetornar valor;\nFinSubProceso\nClase Pelota\nPublico Definir posX Como Entero;\nPublico Definir posY Como Entero;\nPublico Definir vx Como Entero;\nPublico Definir vy Como Entero;\nMetodo iniciar(aleatorio Como Aleatorio) Como Pelota\nEste.posX <- aleatorio.siguiente() mod 500;\nEste.posY <- aleatorio.siguiente() mod 500;\nEste.vx <- (aleatorio.siguiente() mod 300) - 150;\nEste.vy <- (aleatorio.siguiente() mod 300) - 150;\nRetornar Este;\nFinMetodo\nMetodo rebotar() Como Logico\nDefinir rebote Como Logico;\nrebote <- Falso;\nEste.posX <- Este.posX + Este.vx;\nEste.posY <- Este.posY + Este.vy;\nSi Este.posX > 500 Entonces\nEste.posX <- 500;\nEste.vx <- 0 - Absoluto(Este.vx);\nrebote <- Verdadero;\nFinSi\nSi Este.posX < 0 Entonces\nEste.posX <- 0;\nEste.vx <- Absoluto(Este.vx);\nrebote <- Verdadero;\nFinSi\nSi Este.posY > 500 Entonces\nEste.posY <- 500;\nEste.vy <- 0 - Absoluto(Este.vy);\nrebote <- Verdadero;\nFinSi\nSi Este.posY < 0 Entonces\nEste.posY <- 0;\nEste.vy <- Absoluto(Este.vy);\nrebote <- Verdadero;\nFinSi\nRetornar rebote;\nFinMetodo\nFinClase\nAlgoritmo Rebotes\nDimension pelotas[100] Como Pelota;\nDefinir aleatorio Como Aleatorio;\nDefinir n, ronda, indice, rebotes Como Entero;\nLeer n;\naleatorio <- Nuevo Aleatorio();\naleatorio.semilla <- 74755;\nPara indice <- 0 Hasta 99 Con Paso 1 Hacer\npelotas[indice] <- Nuevo Pelota().iniciar(aleatorio);\nFinPara\nrebotes <- 0;\nPara ronda <- 1 Hasta n Con Paso 1 Hacer\nPara indice <- 0 Hasta 99 Con Paso 1 Hacer\nSi pelotas[indice].rebotar() Entonces\nrebotes <- rebotes + 1;\nFinSi\nFinPara\nFinPara\nEscribir rebotes;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "3"
  ],
  "etiquetas": [
    "verificacion",
    "bounce"
  ]
}
```

```caso
{
  "id": "C14",
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
    "salida": "1331\n",
    "terminacion": "completed"
  },
  "programa": "Clase Aleatorio\nPublico Definir semilla Como Entero;\nMetodo siguiente() Como Entero\nEste.semilla <- ((Este.semilla * 1309) + 13849) mod 65536;\nRetornar Este.semilla;\nFinMetodo\nFinClase\nSubProceso Absoluto(valor Como Entero) Como Entero\nSi valor < 0 Entonces\nRetornar 0 - valor;\nFinSi\nRetornar valor;\nFinSubProceso\nClase Pelota\nPublico Definir posX Como Entero;\nPublico Definir posY Como Entero;\nPublico Definir vx Como Entero;\nPublico Definir vy Como Entero;\nMetodo iniciar(aleatorio Como Aleatorio) Como Pelota\nEste.posX <- aleatorio.siguiente() mod 500;\nEste.posY <- aleatorio.siguiente() mod 500;\nEste.vx <- (aleatorio.siguiente() mod 300) - 150;\nEste.vy <- (aleatorio.siguiente() mod 300) - 150;\nRetornar Este;\nFinMetodo\nMetodo rebotar() Como Logico\nDefinir rebote Como Logico;\nrebote <- Falso;\nEste.posX <- Este.posX + Este.vx;\nEste.posY <- Este.posY + Este.vy;\nSi Este.posX > 500 Entonces\nEste.posX <- 500;\nEste.vx <- 0 - Absoluto(Este.vx);\nrebote <- Verdadero;\nFinSi\nSi Este.posX < 0 Entonces\nEste.posX <- 0;\nEste.vx <- Absoluto(Este.vx);\nrebote <- Verdadero;\nFinSi\nSi Este.posY > 500 Entonces\nEste.posY <- 500;\nEste.vy <- 0 - Absoluto(Este.vy);\nrebote <- Verdadero;\nFinSi\nSi Este.posY < 0 Entonces\nEste.posY <- 0;\nEste.vy <- Absoluto(Este.vy);\nrebote <- Verdadero;\nFinSi\nRetornar rebote;\nFinMetodo\nFinClase\nAlgoritmo Rebotes\nDimension pelotas[100] Como Pelota;\nDefinir aleatorio Como Aleatorio;\nDefinir n, ronda, indice, rebotes Como Entero;\nLeer n;\naleatorio <- Nuevo Aleatorio();\naleatorio.semilla <- 74755;\nPara indice <- 0 Hasta 99 Con Paso 1 Hacer\npelotas[indice] <- Nuevo Pelota().iniciar(aleatorio);\nFinPara\nrebotes <- 0;\nPara ronda <- 1 Hasta n Con Paso 1 Hacer\nPara indice <- 0 Hasta 99 Con Paso 1 Hacer\nSi pelotas[indice].rebotar() Entonces\nrebotes <- rebotes + 1;\nFinSi\nFinPara\nFinPara\nEscribir rebotes;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "50"
  ],
  "etiquetas": [
    "medicion",
    "bounce"
  ]
}
```

```caso
{
  "id": "C15",
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
    "salida": "253\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso OExclusivo(primero Como Entero, segundo Como Entero) Como Entero\nDefinir a, b, resultado, peso Como Entero;\na <- primero;\nb <- segundo;\nresultado <- 0;\npeso <- 1;\nMientras a > 0 O b > 0 Hacer\nSi (a mod 2) <> (b mod 2) Entonces\nresultado <- resultado + peso;\nFinSi\na <- a div 2;\nb <- b div 2;\npeso <- peso * 2;\nFinMientras\nRetornar resultado;\nFinSubProceso\nAlgoritmo Mandelbrot\nDefinir n, suma, acumulado, bits, columna, fila, iteracion, escape Como Entero;\nDefinir zr, zi, zrzr, zizi, cr, ci Como Real;\nDefinir activo Como Logico;\nLeer n;\nsuma <- 0;\nacumulado <- 0;\nbits <- 0;\nfila <- 0;\nMientras fila < n Hacer\nci <- (2.0 * fila / n) - 1.0;\ncolumna <- 0;\nMientras columna < n Hacer\nzrzr <- 0.0;\nzi <- 0.0;\nzizi <- 0.0;\ncr <- (2.0 * columna / n) - 1.5;\niteracion <- 0;\nactivo <- Verdadero;\nescape <- 0;\nMientras activo Y iteracion < 50 Hacer\nzr <- zrzr - zizi + cr;\nzi <- 2.0 * zr * zi + ci;\nzrzr <- zr * zr;\nzizi <- zi * zi;\nSi zrzr + zizi > 4.0 Entonces\nactivo <- Falso;\nescape <- 1;\nFinSi\niteracion <- iteracion + 1;\nFinMientras\nacumulado <- acumulado * 2 + escape;\nbits <- bits + 1;\nSi bits = 8 Entonces\nsuma <- OExclusivo(suma, acumulado);\nacumulado <- 0;\nbits <- 0;\nSiNo\nSi columna = n - 1 Entonces\nacumulado <- acumulado * (2 ^ (8 - bits));\nsuma <- OExclusivo(suma, acumulado);\nacumulado <- 0;\nbits <- 0;\nFinSi\nFinSi\ncolumna <- columna + 1;\nFinMientras\nfila <- fila + 1;\nFinMientras\nEscribir suma;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "8"
  ],
  "etiquetas": [
    "verificacion",
    "mandelbrot"
  ]
}
```

```caso
{
  "id": "C16",
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
    "salida": "31\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso OExclusivo(primero Como Entero, segundo Como Entero) Como Entero\nDefinir a, b, resultado, peso Como Entero;\na <- primero;\nb <- segundo;\nresultado <- 0;\npeso <- 1;\nMientras a > 0 O b > 0 Hacer\nSi (a mod 2) <> (b mod 2) Entonces\nresultado <- resultado + peso;\nFinSi\na <- a div 2;\nb <- b div 2;\npeso <- peso * 2;\nFinMientras\nRetornar resultado;\nFinSubProceso\nAlgoritmo Mandelbrot\nDefinir n, suma, acumulado, bits, columna, fila, iteracion, escape Como Entero;\nDefinir zr, zi, zrzr, zizi, cr, ci Como Real;\nDefinir activo Como Logico;\nLeer n;\nsuma <- 0;\nacumulado <- 0;\nbits <- 0;\nfila <- 0;\nMientras fila < n Hacer\nci <- (2.0 * fila / n) - 1.0;\ncolumna <- 0;\nMientras columna < n Hacer\nzrzr <- 0.0;\nzi <- 0.0;\nzizi <- 0.0;\ncr <- (2.0 * columna / n) - 1.5;\niteracion <- 0;\nactivo <- Verdadero;\nescape <- 0;\nMientras activo Y iteracion < 50 Hacer\nzr <- zrzr - zizi + cr;\nzi <- 2.0 * zr * zi + ci;\nzrzr <- zr * zr;\nzizi <- zi * zi;\nSi zrzr + zizi > 4.0 Entonces\nactivo <- Falso;\nescape <- 1;\nFinSi\niteracion <- iteracion + 1;\nFinMientras\nacumulado <- acumulado * 2 + escape;\nbits <- bits + 1;\nSi bits = 8 Entonces\nsuma <- OExclusivo(suma, acumulado);\nacumulado <- 0;\nbits <- 0;\nSiNo\nSi columna = n - 1 Entonces\nacumulado <- acumulado * (2 ^ (8 - bits));\nsuma <- OExclusivo(suma, acumulado);\nacumulado <- 0;\nbits <- 0;\nFinSi\nFinSi\ncolumna <- columna + 1;\nFinMientras\nfila <- fila + 1;\nFinMientras\nEscribir suma;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "30"
  ],
  "etiquetas": [
    "medicion",
    "mandelbrot"
  ]
}
```

```caso
{
  "id": "C17",
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
    "salida": "-169074954025067\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo NCuerpos\nDimension px[5] Como Real;\nDimension py[5] Como Real;\nDimension pz[5] Como Real;\nDimension vx[5] Como Real;\nDimension vy[5] Como Real;\nDimension vz[5] Como Real;\nDimension masa[5] Como Real;\nDefinir pi, solar, dias, mx, my, mz, dx, dy, dz, cuadrado, distancia, magnitud, energia Como Real;\nDefinir n, ronda, i, j Como Entero;\nLeer n;\npi <- 3.141592653589793;\nsolar <- 4.0 * pi * pi;\ndias <- 365.24;\npx[0] <- 0.0;\npy[0] <- 0.0;\npz[0] <- 0.0;\nvx[0] <- 0.0;\nvy[0] <- 0.0;\nvz[0] <- 0.0;\nmasa[0] <- solar;\npx[1] <- 4.84143144246472090;\npy[1] <- -1.16032004402742839;\npz[1] <- -0.103622044471123109;\nvx[1] <- 0.00166007664274403694 * dias;\nvy[1] <- 0.00769901118419740425 * dias;\nvz[1] <- -0.0000690460016972063023 * dias;\nmasa[1] <- 0.000954791938424326609 * solar;\npx[2] <- 8.34336671824457987;\npy[2] <- 4.12479856412430479;\npz[2] <- -0.403523417114321381;\nvx[2] <- -0.00276742510726862411 * dias;\nvy[2] <- 0.00499852801234917238 * dias;\nvz[2] <- 0.0000230417297573763929 * dias;\nmasa[2] <- 0.000285885980666130812 * solar;\npx[3] <- 12.8943695621391310;\npy[3] <- -15.1111514016986312;\npz[3] <- -0.223307578892655734;\nvx[3] <- 0.00296460137564761618 * dias;\nvy[3] <- 0.00237847173959480950 * dias;\nvz[3] <- -0.0000296589568540237556 * dias;\nmasa[3] <- 0.0000436624404335156298 * solar;\npx[4] <- 15.3796971148509165;\npy[4] <- -25.9193146099879641;\npz[4] <- 0.179258772950371181;\nvx[4] <- 0.00268067772490389322 * dias;\nvy[4] <- 0.00162824170038242295 * dias;\nvz[4] <- -0.0000951592254519715870 * dias;\nmasa[4] <- 0.0000515138902046611451 * solar;\nmx <- 0.0;\nmy <- 0.0;\nmz <- 0.0;\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\nmx <- mx + vx[i] * masa[i];\nmy <- my + vy[i] * masa[i];\nmz <- mz + vz[i] * masa[i];\nFinPara\nvx[0] <- 0.0 - (mx / solar);\nvy[0] <- 0.0 - (my / solar);\nvz[0] <- 0.0 - (mz / solar);\nPara ronda <- 1 Hasta n Con Paso 1 Hacer\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\nPara j <- i + 1 Hasta 4 Con Paso 1 Hacer\ndx <- px[i] - px[j];\ndy <- py[i] - py[j];\ndz <- pz[i] - pz[j];\ncuadrado <- dx * dx + dy * dy + dz * dz;\ndistancia <- rc(cuadrado);\nmagnitud <- 0.01 / (cuadrado * distancia);\nvx[i] <- vx[i] - dx * masa[j] * magnitud;\nvy[i] <- vy[i] - dy * masa[j] * magnitud;\nvz[i] <- vz[i] - dz * masa[j] * magnitud;\nvx[j] <- vx[j] + dx * masa[i] * magnitud;\nvy[j] <- vy[j] + dy * masa[i] * magnitud;\nvz[j] <- vz[j] + dz * masa[i] * magnitud;\nFinPara\nFinPara\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\npx[i] <- px[i] + 0.01 * vx[i];\npy[i] <- py[i] + 0.01 * vy[i];\npz[i] <- pz[i] + 0.01 * vz[i];\nFinPara\nFinPara\nenergia <- 0.0;\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\nenergia <- energia + 0.5 * masa[i] * (vx[i] * vx[i] + vy[i] * vy[i] + vz[i] * vz[i]);\nPara j <- i + 1 Hasta 4 Con Paso 1 Hacer\ndx <- px[i] - px[j];\ndy <- py[i] - py[j];\ndz <- pz[i] - pz[j];\ndistancia <- rc(dx * dx + dy * dy + dz * dz);\nenergia <- energia - (masa[i] * masa[j]) / distancia;\nFinPara\nFinPara\nEscribir trunc(energia * 1000000000000000.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "1"
  ],
  "etiquetas": [
    "verificacion",
    "nbody"
  ]
}
```

```caso
{
  "id": "C18",
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
    "salida": "-169050762382409\n",
    "terminacion": "completed"
  },
  "programa": "Algoritmo NCuerpos\nDimension px[5] Como Real;\nDimension py[5] Como Real;\nDimension pz[5] Como Real;\nDimension vx[5] Como Real;\nDimension vy[5] Como Real;\nDimension vz[5] Como Real;\nDimension masa[5] Como Real;\nDefinir pi, solar, dias, mx, my, mz, dx, dy, dz, cuadrado, distancia, magnitud, energia Como Real;\nDefinir n, ronda, i, j Como Entero;\nLeer n;\npi <- 3.141592653589793;\nsolar <- 4.0 * pi * pi;\ndias <- 365.24;\npx[0] <- 0.0;\npy[0] <- 0.0;\npz[0] <- 0.0;\nvx[0] <- 0.0;\nvy[0] <- 0.0;\nvz[0] <- 0.0;\nmasa[0] <- solar;\npx[1] <- 4.84143144246472090;\npy[1] <- -1.16032004402742839;\npz[1] <- -0.103622044471123109;\nvx[1] <- 0.00166007664274403694 * dias;\nvy[1] <- 0.00769901118419740425 * dias;\nvz[1] <- -0.0000690460016972063023 * dias;\nmasa[1] <- 0.000954791938424326609 * solar;\npx[2] <- 8.34336671824457987;\npy[2] <- 4.12479856412430479;\npz[2] <- -0.403523417114321381;\nvx[2] <- -0.00276742510726862411 * dias;\nvy[2] <- 0.00499852801234917238 * dias;\nvz[2] <- 0.0000230417297573763929 * dias;\nmasa[2] <- 0.000285885980666130812 * solar;\npx[3] <- 12.8943695621391310;\npy[3] <- -15.1111514016986312;\npz[3] <- -0.223307578892655734;\nvx[3] <- 0.00296460137564761618 * dias;\nvy[3] <- 0.00237847173959480950 * dias;\nvz[3] <- -0.0000296589568540237556 * dias;\nmasa[3] <- 0.0000436624404335156298 * solar;\npx[4] <- 15.3796971148509165;\npy[4] <- -25.9193146099879641;\npz[4] <- 0.179258772950371181;\nvx[4] <- 0.00268067772490389322 * dias;\nvy[4] <- 0.00162824170038242295 * dias;\nvz[4] <- -0.0000951592254519715870 * dias;\nmasa[4] <- 0.0000515138902046611451 * solar;\nmx <- 0.0;\nmy <- 0.0;\nmz <- 0.0;\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\nmx <- mx + vx[i] * masa[i];\nmy <- my + vy[i] * masa[i];\nmz <- mz + vz[i] * masa[i];\nFinPara\nvx[0] <- 0.0 - (mx / solar);\nvy[0] <- 0.0 - (my / solar);\nvz[0] <- 0.0 - (mz / solar);\nPara ronda <- 1 Hasta n Con Paso 1 Hacer\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\nPara j <- i + 1 Hasta 4 Con Paso 1 Hacer\ndx <- px[i] - px[j];\ndy <- py[i] - py[j];\ndz <- pz[i] - pz[j];\ncuadrado <- dx * dx + dy * dy + dz * dz;\ndistancia <- rc(cuadrado);\nmagnitud <- 0.01 / (cuadrado * distancia);\nvx[i] <- vx[i] - dx * masa[j] * magnitud;\nvy[i] <- vy[i] - dy * masa[j] * magnitud;\nvz[i] <- vz[i] - dz * masa[j] * magnitud;\nvx[j] <- vx[j] + dx * masa[i] * magnitud;\nvy[j] <- vy[j] + dy * masa[i] * magnitud;\nvz[j] <- vz[j] + dz * masa[i] * magnitud;\nFinPara\nFinPara\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\npx[i] <- px[i] + 0.01 * vx[i];\npy[i] <- py[i] + 0.01 * vy[i];\npz[i] <- pz[i] + 0.01 * vz[i];\nFinPara\nFinPara\nenergia <- 0.0;\nPara i <- 0 Hasta 4 Con Paso 1 Hacer\nenergia <- energia + 0.5 * masa[i] * (vx[i] * vx[i] + vy[i] * vy[i] + vz[i] * vz[i]);\nPara j <- i + 1 Hasta 4 Con Paso 1 Hacer\ndx <- px[i] - px[j];\ndy <- py[i] - py[j];\ndz <- pz[i] - pz[j];\ndistancia <- rc(dx * dx + dy * dy + dz * dz);\nenergia <- energia - (masa[i] * masa[j]) / distancia;\nFinPara\nFinPara\nEscribir trunc(energia * 1000000000000000.0);\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "100"
  ],
  "etiquetas": [
    "medicion",
    "nbody"
  ]
}
```

```caso
{
  "id": "C19",
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
    "salida": "120 47\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso OExclusivo(primero Como Entero, segundo Como Entero) Como Entero\nDefinir a, b, resultado, peso Como Entero;\na <- primero;\nb <- segundo;\nresultado <- 0;\npeso <- 1;\nMientras a > 0 O b > 0 Hacer\nSi (a mod 2) <> (b mod 2) Entonces\nresultado <- resultado + peso;\nFinSi\na <- a div 2;\nb <- b div 2;\npeso <- peso * 2;\nFinMientras\nRetornar resultado;\nFinSubProceso\nClase Paquete\nPublico Definir enlace Como Paquete;\nPublico Definir identidad Como Entero;\nPublico Definir especie Como Entero;\nPublico Definir dato Como Entero;\nPublico Definir d0 Como Entero;\nPublico Definir d1 Como Entero;\nPublico Definir d2 Como Entero;\nPublico Definir d3 Como Entero;\nMetodo iniciar(enlace Como Paquete, identidad Como Entero, especie Como Entero) Como Paquete\nEste.enlace <- enlace;\nEste.identidad <- identidad;\nEste.especie <- especie;\nEste.dato <- 0;\nEste.d0 <- 0;\nEste.d1 <- 0;\nEste.d2 <- 0;\nEste.d3 <- 0;\nRetornar Este;\nFinMetodo\nMetodo consultar(posicion Como Entero) Como Entero\nSegun posicion Hacer\n0: Retornar Este.d0;\n1: Retornar Este.d1;\n2: Retornar Este.d2;\nFinSegun\nRetornar Este.d3;\nFinMetodo\nMetodo guardar(posicion Como Entero, valor Como Entero)\nSegun posicion Hacer\n0: Este.d0 <- valor;\n1: Este.d1 <- valor;\n2: Este.d2 <- valor;\nDe Otro Modo: Este.d3 <- valor;\nFinSegun\nFinMetodo\nMetodo anexarA(lista Como Paquete, vacio Como Paquete) Como Paquete\nDefinir actual Como Paquete;\nEste.enlace <- vacio;\nSi lista = vacio Entonces\nRetornar Este;\nFinSi\nactual <- lista;\nMientras actual.enlace <> vacio Hacer\nactual <- actual.enlace;\nFinMientras\nactual.enlace <- Este;\nRetornar lista;\nFinMetodo\nFinClase\nClase Area\nPublico Definir lista Como Tarea;\nPublico Definir nula Como Tarea;\nPublico Definir vacio Como Paquete;\nPublico Definir t1 Como Tarea;\nPublico Definir t2 Como Tarea;\nPublico Definir t3 Como Tarea;\nPublico Definir t4 Como Tarea;\nPublico Definir t5 Como Tarea;\nPublico Definir t6 Como Tarea;\nPublico Definir retenciones Como Entero;\nPublico Definir encolados Como Entero;\nMetodo registrar(identidad Como Entero, tarea Como Tarea)\nSegun identidad Hacer\n1: Este.t1 <- tarea;\n2: Este.t2 <- tarea;\n3: Este.t3 <- tarea;\n4: Este.t4 <- tarea;\n5: Este.t5 <- tarea;\nDe Otro Modo: Este.t6 <- tarea;\nFinSegun\nFinMetodo\nMetodo buscar(identidad Como Entero) Como Tarea\nSegun identidad Hacer\n1: Retornar Este.t1;\n2: Retornar Este.t2;\n3: Retornar Este.t3;\n4: Retornar Este.t4;\n5: Retornar Este.t5;\nFinSegun\nRetornar Este.t6;\nFinMetodo\nFinClase\nClase Tarea\nPublico Definir enlace Como Tarea;\nPublico Definir identidad Como Entero;\nPublico Definir prioridad Como Entero;\nPublico Definir entrada Como Paquete;\nPublico Definir pendiente Como Logico;\nPublico Definir esperando Como Logico;\nPublico Definir reteniendo Como Logico;\nPublico Definir area Como Area;\nMetodo iniciar(area Como Area, identidad Como Entero, prioridad Como Entero, entrada Como Paquete, pendiente Como Logico, esperando Como Logico)\nEste.area <- area;\nEste.enlace <- area.lista;\nEste.identidad <- identidad;\nEste.prioridad <- prioridad;\nEste.entrada <- entrada;\nEste.pendiente <- pendiente;\nEste.esperando <- esperando;\nEste.reteniendo <- Falso;\narea.lista <- Este;\narea.registrar(identidad, Este);\nFinMetodo\nMetodo procesar(paquete Como Paquete) Como Tarea\nRetornar Este;\nFinMetodo\nMetodo agregarPaquete(paquete Como Paquete, anterior Como Tarea) Como Tarea\nSi Este.entrada = Este.area.vacio Entonces\nEste.entrada <- paquete;\nEste.pendiente <- Verdadero;\nSi Este.prioridad > anterior.prioridad Entonces\nRetornar Este;\nFinSi\nSiNo\nEste.entrada <- paquete.anexarA(Este.entrada, Este.area.vacio);\nFinSi\nRetornar anterior;\nFinMetodo\nMetodo correr() Como Tarea\nDefinir mensaje Como Paquete;\nSi Este.pendiente Y Este.esperando Y NO Este.reteniendo Entonces\nmensaje <- Este.entrada;\nEste.entrada <- mensaje.enlace;\nSi Este.entrada = Este.area.vacio Entonces\nEste.pendiente <- Falso;\nSiNo\nEste.pendiente <- Verdadero;\nFinSi\nEste.esperando <- Falso;\nEste.reteniendo <- Falso;\nSiNo\nmensaje <- Este.area.vacio;\nFinSi\nRetornar Este.procesar(mensaje);\nFinMetodo\nMetodo esperar() Como Tarea\nEste.esperando <- Verdadero;\nRetornar Este;\nFinMetodo\nMetodo retener() Como Tarea\nEste.area.retenciones <- Este.area.retenciones + 1;\nEste.reteniendo <- Verdadero;\nRetornar Este.enlace;\nFinMetodo\nMetodo liberar(identidad Como Entero) Como Tarea\nDefinir tarea Como Tarea;\ntarea <- Este.area.buscar(identidad);\ntarea.reteniendo <- Falso;\nSi tarea.prioridad > Este.prioridad Entonces\nRetornar tarea;\nFinSi\nRetornar Este;\nFinMetodo\nMetodo encolar(paquete Como Paquete) Como Tarea\nDefinir destino Como Tarea;\ndestino <- Este.area.buscar(paquete.identidad);\nEste.area.encolados <- Este.area.encolados + 1;\npaquete.enlace <- Este.area.vacio;\npaquete.identidad <- Este.identidad;\nRetornar destino.agregarPaquete(paquete, Este);\nFinMetodo\nFinClase\nClase TareaDispositivo Hereda De Tarea\nPublico Definir retenido Como Paquete;\nMetodo procesar(paquete Como Paquete) Como Tarea\nDefinir actual Como Paquete;\nSi paquete = Este.area.vacio Entonces\nactual <- Este.retenido;\nSi actual = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\nEste.retenido <- Este.area.vacio;\nRetornar Este.encolar(actual);\nFinSi\nEste.retenido <- paquete;\nRetornar Este.retener();\nFinMetodo\nFinClase\nClase TareaManejador Hereda De Tarea\nPublico Definir trabajo Como Paquete;\nPublico Definir dispositivo Como Paquete;\nMetodo procesar(paquete Como Paquete) Como Tarea\nDefinir trabajoActual, dispositivoActual Como Paquete;\nDefinir cuenta Como Entero;\nSi paquete <> Este.area.vacio Entonces\nSi paquete.especie = 1001 Entonces\nEste.trabajo <- paquete.anexarA(Este.trabajo, Este.area.vacio);\nSiNo\nEste.dispositivo <- paquete.anexarA(Este.dispositivo, Este.area.vacio);\nFinSi\nFinSi\ntrabajoActual <- Este.trabajo;\nSi trabajoActual = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\ncuenta <- trabajoActual.dato;\nSi cuenta >= 4 Entonces\nEste.trabajo <- trabajoActual.enlace;\nRetornar Este.encolar(trabajoActual);\nFinSi\ndispositivoActual <- Este.dispositivo;\nSi dispositivoActual = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\nEste.dispositivo <- dispositivoActual.enlace;\ndispositivoActual.dato <- trabajoActual.consultar(cuenta);\ntrabajoActual.dato <- cuenta + 1;\nRetornar Este.encolar(dispositivoActual);\nFinMetodo\nFinClase\nClase TareaOciosa Hereda De Tarea\nPublico Definir control Como Entero;\nPublico Definir cuenta Como Entero;\nMetodo procesar(paquete Como Paquete) Como Tarea\nEste.cuenta <- Este.cuenta - 1;\nSi Este.cuenta = 0 Entonces\nRetornar Este.retener();\nFinSi\nSi Este.control mod 2 = 0 Entonces\nEste.control <- Este.control div 2;\nRetornar Este.liberar(5);\nFinSi\nEste.control <- OExclusivo(Este.control div 2, 53256);\nRetornar Este.liberar(6);\nFinMetodo\nFinClase\nClase TareaTrabajo Hereda De Tarea\nPublico Definir destino Como Entero;\nPublico Definir cuenta Como Entero;\nMetodo procesar(paquete Como Paquete) Como Tarea\nDefinir posicion Como Entero;\nSi paquete = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\nSi Este.destino = 3 Entonces\nEste.destino <- 4;\nSiNo\nEste.destino <- 3;\nFinSi\npaquete.identidad <- Este.destino;\npaquete.dato <- 0;\nPara posicion <- 0 Hasta 3 Con Paso 1 Hacer\nEste.cuenta <- Este.cuenta + 1;\nSi Este.cuenta > 26 Entonces\nEste.cuenta <- 1;\nFinSi\npaquete.guardar(posicion, 65 + Este.cuenta - 1);\nFinPara\nRetornar Este.encolar(paquete);\nFinMetodo\nFinClase\nAlgoritmo Richards\nDefinir area Como Area;\nDefinir vacio, cola Como Paquete;\nDefinir nula, actual Como Tarea;\nDefinir ociosa Como TareaOciosa;\nDefinir trabajo Como TareaTrabajo;\nDefinir manejadorA, manejadorB Como TareaManejador;\nDefinir dispositivoA, dispositivoB Como TareaDispositivo;\nDefinir ciclos Como Entero;\nLeer ciclos;\narea <- Nuevo Area();\nvacio <- Nuevo Paquete();\nvacio.enlace <- vacio;\nnula <- Nuevo Tarea();\narea.vacio <- vacio;\narea.nula <- nula;\narea.lista <- nula;\narea.retenciones <- 0;\narea.encolados <- 0;\nociosa <- Nuevo TareaOciosa();\nociosa.control <- 1;\nociosa.cuenta <- ciclos;\nociosa.iniciar(area, 1, 1, vacio, Falso, Falso);\ncola <- Nuevo Paquete().iniciar(vacio, 0, 1001);\ncola <- Nuevo Paquete().iniciar(cola, 0, 1001);\ntrabajo <- Nuevo TareaTrabajo();\ntrabajo.destino <- 3;\ntrabajo.cuenta <- 0;\ntrabajo.iniciar(area, 2, 1000, cola, Verdadero, Verdadero);\ncola <- Nuevo Paquete().iniciar(vacio, 5, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 5, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 5, 1000);\nmanejadorA <- Nuevo TareaManejador();\nmanejadorA.trabajo <- vacio;\nmanejadorA.dispositivo <- vacio;\nmanejadorA.iniciar(area, 3, 2000, cola, Verdadero, Verdadero);\ncola <- Nuevo Paquete().iniciar(vacio, 6, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 6, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 6, 1000);\nmanejadorB <- Nuevo TareaManejador();\nmanejadorB.trabajo <- vacio;\nmanejadorB.dispositivo <- vacio;\nmanejadorB.iniciar(area, 4, 3000, cola, Verdadero, Verdadero);\ndispositivoA <- Nuevo TareaDispositivo();\ndispositivoA.retenido <- vacio;\ndispositivoA.iniciar(area, 5, 4000, vacio, Falso, Verdadero);\ndispositivoB <- Nuevo TareaDispositivo();\ndispositivoB.retenido <- vacio;\ndispositivoB.iniciar(area, 6, 5000, vacio, Falso, Verdadero);\nactual <- area.lista;\nMientras actual <> nula Hacer\nSi actual.reteniendo O (NO actual.pendiente Y actual.esperando) Entonces\nactual <- actual.enlace;\nSiNo\nactual <- actual.correr();\nFinSi\nFinMientras\nEscribir area.encolados, \" \", area.retenciones;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "50"
  ],
  "etiquetas": [
    "verificacion",
    "richards"
  ]
}
```

```caso
{
  "id": "C20",
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
    "salida": "2322 928\n",
    "terminacion": "completed"
  },
  "programa": "SubProceso OExclusivo(primero Como Entero, segundo Como Entero) Como Entero\nDefinir a, b, resultado, peso Como Entero;\na <- primero;\nb <- segundo;\nresultado <- 0;\npeso <- 1;\nMientras a > 0 O b > 0 Hacer\nSi (a mod 2) <> (b mod 2) Entonces\nresultado <- resultado + peso;\nFinSi\na <- a div 2;\nb <- b div 2;\npeso <- peso * 2;\nFinMientras\nRetornar resultado;\nFinSubProceso\nClase Paquete\nPublico Definir enlace Como Paquete;\nPublico Definir identidad Como Entero;\nPublico Definir especie Como Entero;\nPublico Definir dato Como Entero;\nPublico Definir d0 Como Entero;\nPublico Definir d1 Como Entero;\nPublico Definir d2 Como Entero;\nPublico Definir d3 Como Entero;\nMetodo iniciar(enlace Como Paquete, identidad Como Entero, especie Como Entero) Como Paquete\nEste.enlace <- enlace;\nEste.identidad <- identidad;\nEste.especie <- especie;\nEste.dato <- 0;\nEste.d0 <- 0;\nEste.d1 <- 0;\nEste.d2 <- 0;\nEste.d3 <- 0;\nRetornar Este;\nFinMetodo\nMetodo consultar(posicion Como Entero) Como Entero\nSegun posicion Hacer\n0: Retornar Este.d0;\n1: Retornar Este.d1;\n2: Retornar Este.d2;\nFinSegun\nRetornar Este.d3;\nFinMetodo\nMetodo guardar(posicion Como Entero, valor Como Entero)\nSegun posicion Hacer\n0: Este.d0 <- valor;\n1: Este.d1 <- valor;\n2: Este.d2 <- valor;\nDe Otro Modo: Este.d3 <- valor;\nFinSegun\nFinMetodo\nMetodo anexarA(lista Como Paquete, vacio Como Paquete) Como Paquete\nDefinir actual Como Paquete;\nEste.enlace <- vacio;\nSi lista = vacio Entonces\nRetornar Este;\nFinSi\nactual <- lista;\nMientras actual.enlace <> vacio Hacer\nactual <- actual.enlace;\nFinMientras\nactual.enlace <- Este;\nRetornar lista;\nFinMetodo\nFinClase\nClase Area\nPublico Definir lista Como Tarea;\nPublico Definir nula Como Tarea;\nPublico Definir vacio Como Paquete;\nPublico Definir t1 Como Tarea;\nPublico Definir t2 Como Tarea;\nPublico Definir t3 Como Tarea;\nPublico Definir t4 Como Tarea;\nPublico Definir t5 Como Tarea;\nPublico Definir t6 Como Tarea;\nPublico Definir retenciones Como Entero;\nPublico Definir encolados Como Entero;\nMetodo registrar(identidad Como Entero, tarea Como Tarea)\nSegun identidad Hacer\n1: Este.t1 <- tarea;\n2: Este.t2 <- tarea;\n3: Este.t3 <- tarea;\n4: Este.t4 <- tarea;\n5: Este.t5 <- tarea;\nDe Otro Modo: Este.t6 <- tarea;\nFinSegun\nFinMetodo\nMetodo buscar(identidad Como Entero) Como Tarea\nSegun identidad Hacer\n1: Retornar Este.t1;\n2: Retornar Este.t2;\n3: Retornar Este.t3;\n4: Retornar Este.t4;\n5: Retornar Este.t5;\nFinSegun\nRetornar Este.t6;\nFinMetodo\nFinClase\nClase Tarea\nPublico Definir enlace Como Tarea;\nPublico Definir identidad Como Entero;\nPublico Definir prioridad Como Entero;\nPublico Definir entrada Como Paquete;\nPublico Definir pendiente Como Logico;\nPublico Definir esperando Como Logico;\nPublico Definir reteniendo Como Logico;\nPublico Definir area Como Area;\nMetodo iniciar(area Como Area, identidad Como Entero, prioridad Como Entero, entrada Como Paquete, pendiente Como Logico, esperando Como Logico)\nEste.area <- area;\nEste.enlace <- area.lista;\nEste.identidad <- identidad;\nEste.prioridad <- prioridad;\nEste.entrada <- entrada;\nEste.pendiente <- pendiente;\nEste.esperando <- esperando;\nEste.reteniendo <- Falso;\narea.lista <- Este;\narea.registrar(identidad, Este);\nFinMetodo\nMetodo procesar(paquete Como Paquete) Como Tarea\nRetornar Este;\nFinMetodo\nMetodo agregarPaquete(paquete Como Paquete, anterior Como Tarea) Como Tarea\nSi Este.entrada = Este.area.vacio Entonces\nEste.entrada <- paquete;\nEste.pendiente <- Verdadero;\nSi Este.prioridad > anterior.prioridad Entonces\nRetornar Este;\nFinSi\nSiNo\nEste.entrada <- paquete.anexarA(Este.entrada, Este.area.vacio);\nFinSi\nRetornar anterior;\nFinMetodo\nMetodo correr() Como Tarea\nDefinir mensaje Como Paquete;\nSi Este.pendiente Y Este.esperando Y NO Este.reteniendo Entonces\nmensaje <- Este.entrada;\nEste.entrada <- mensaje.enlace;\nSi Este.entrada = Este.area.vacio Entonces\nEste.pendiente <- Falso;\nSiNo\nEste.pendiente <- Verdadero;\nFinSi\nEste.esperando <- Falso;\nEste.reteniendo <- Falso;\nSiNo\nmensaje <- Este.area.vacio;\nFinSi\nRetornar Este.procesar(mensaje);\nFinMetodo\nMetodo esperar() Como Tarea\nEste.esperando <- Verdadero;\nRetornar Este;\nFinMetodo\nMetodo retener() Como Tarea\nEste.area.retenciones <- Este.area.retenciones + 1;\nEste.reteniendo <- Verdadero;\nRetornar Este.enlace;\nFinMetodo\nMetodo liberar(identidad Como Entero) Como Tarea\nDefinir tarea Como Tarea;\ntarea <- Este.area.buscar(identidad);\ntarea.reteniendo <- Falso;\nSi tarea.prioridad > Este.prioridad Entonces\nRetornar tarea;\nFinSi\nRetornar Este;\nFinMetodo\nMetodo encolar(paquete Como Paquete) Como Tarea\nDefinir destino Como Tarea;\ndestino <- Este.area.buscar(paquete.identidad);\nEste.area.encolados <- Este.area.encolados + 1;\npaquete.enlace <- Este.area.vacio;\npaquete.identidad <- Este.identidad;\nRetornar destino.agregarPaquete(paquete, Este);\nFinMetodo\nFinClase\nClase TareaDispositivo Hereda De Tarea\nPublico Definir retenido Como Paquete;\nMetodo procesar(paquete Como Paquete) Como Tarea\nDefinir actual Como Paquete;\nSi paquete = Este.area.vacio Entonces\nactual <- Este.retenido;\nSi actual = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\nEste.retenido <- Este.area.vacio;\nRetornar Este.encolar(actual);\nFinSi\nEste.retenido <- paquete;\nRetornar Este.retener();\nFinMetodo\nFinClase\nClase TareaManejador Hereda De Tarea\nPublico Definir trabajo Como Paquete;\nPublico Definir dispositivo Como Paquete;\nMetodo procesar(paquete Como Paquete) Como Tarea\nDefinir trabajoActual, dispositivoActual Como Paquete;\nDefinir cuenta Como Entero;\nSi paquete <> Este.area.vacio Entonces\nSi paquete.especie = 1001 Entonces\nEste.trabajo <- paquete.anexarA(Este.trabajo, Este.area.vacio);\nSiNo\nEste.dispositivo <- paquete.anexarA(Este.dispositivo, Este.area.vacio);\nFinSi\nFinSi\ntrabajoActual <- Este.trabajo;\nSi trabajoActual = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\ncuenta <- trabajoActual.dato;\nSi cuenta >= 4 Entonces\nEste.trabajo <- trabajoActual.enlace;\nRetornar Este.encolar(trabajoActual);\nFinSi\ndispositivoActual <- Este.dispositivo;\nSi dispositivoActual = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\nEste.dispositivo <- dispositivoActual.enlace;\ndispositivoActual.dato <- trabajoActual.consultar(cuenta);\ntrabajoActual.dato <- cuenta + 1;\nRetornar Este.encolar(dispositivoActual);\nFinMetodo\nFinClase\nClase TareaOciosa Hereda De Tarea\nPublico Definir control Como Entero;\nPublico Definir cuenta Como Entero;\nMetodo procesar(paquete Como Paquete) Como Tarea\nEste.cuenta <- Este.cuenta - 1;\nSi Este.cuenta = 0 Entonces\nRetornar Este.retener();\nFinSi\nSi Este.control mod 2 = 0 Entonces\nEste.control <- Este.control div 2;\nRetornar Este.liberar(5);\nFinSi\nEste.control <- OExclusivo(Este.control div 2, 53256);\nRetornar Este.liberar(6);\nFinMetodo\nFinClase\nClase TareaTrabajo Hereda De Tarea\nPublico Definir destino Como Entero;\nPublico Definir cuenta Como Entero;\nMetodo procesar(paquete Como Paquete) Como Tarea\nDefinir posicion Como Entero;\nSi paquete = Este.area.vacio Entonces\nRetornar Este.esperar();\nFinSi\nSi Este.destino = 3 Entonces\nEste.destino <- 4;\nSiNo\nEste.destino <- 3;\nFinSi\npaquete.identidad <- Este.destino;\npaquete.dato <- 0;\nPara posicion <- 0 Hasta 3 Con Paso 1 Hacer\nEste.cuenta <- Este.cuenta + 1;\nSi Este.cuenta > 26 Entonces\nEste.cuenta <- 1;\nFinSi\npaquete.guardar(posicion, 65 + Este.cuenta - 1);\nFinPara\nRetornar Este.encolar(paquete);\nFinMetodo\nFinClase\nAlgoritmo Richards\nDefinir area Como Area;\nDefinir vacio, cola Como Paquete;\nDefinir nula, actual Como Tarea;\nDefinir ociosa Como TareaOciosa;\nDefinir trabajo Como TareaTrabajo;\nDefinir manejadorA, manejadorB Como TareaManejador;\nDefinir dispositivoA, dispositivoB Como TareaDispositivo;\nDefinir ciclos Como Entero;\nLeer ciclos;\narea <- Nuevo Area();\nvacio <- Nuevo Paquete();\nvacio.enlace <- vacio;\nnula <- Nuevo Tarea();\narea.vacio <- vacio;\narea.nula <- nula;\narea.lista <- nula;\narea.retenciones <- 0;\narea.encolados <- 0;\nociosa <- Nuevo TareaOciosa();\nociosa.control <- 1;\nociosa.cuenta <- ciclos;\nociosa.iniciar(area, 1, 1, vacio, Falso, Falso);\ncola <- Nuevo Paquete().iniciar(vacio, 0, 1001);\ncola <- Nuevo Paquete().iniciar(cola, 0, 1001);\ntrabajo <- Nuevo TareaTrabajo();\ntrabajo.destino <- 3;\ntrabajo.cuenta <- 0;\ntrabajo.iniciar(area, 2, 1000, cola, Verdadero, Verdadero);\ncola <- Nuevo Paquete().iniciar(vacio, 5, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 5, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 5, 1000);\nmanejadorA <- Nuevo TareaManejador();\nmanejadorA.trabajo <- vacio;\nmanejadorA.dispositivo <- vacio;\nmanejadorA.iniciar(area, 3, 2000, cola, Verdadero, Verdadero);\ncola <- Nuevo Paquete().iniciar(vacio, 6, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 6, 1000);\ncola <- Nuevo Paquete().iniciar(cola, 6, 1000);\nmanejadorB <- Nuevo TareaManejador();\nmanejadorB.trabajo <- vacio;\nmanejadorB.dispositivo <- vacio;\nmanejadorB.iniciar(area, 4, 3000, cola, Verdadero, Verdadero);\ndispositivoA <- Nuevo TareaDispositivo();\ndispositivoA.retenido <- vacio;\ndispositivoA.iniciar(area, 5, 4000, vacio, Falso, Verdadero);\ndispositivoB <- Nuevo TareaDispositivo();\ndispositivoB.retenido <- vacio;\ndispositivoB.iniciar(area, 6, 5000, vacio, Falso, Verdadero);\nactual <- area.lista;\nMientras actual <> nula Hacer\nSi actual.reteniendo O (NO actual.pendiente Y actual.esperando) Entonces\nactual <- actual.enlace;\nSiNo\nactual <- actual.correr();\nFinSi\nFinMientras\nEscribir area.encolados, \" \", area.retenciones;\nFinAlgoritmo\n",
  "perfil_base": "es",
  "entradas": [
    "1000"
  ],
  "etiquetas": [
    "medicion",
    "richards"
  ]
}
```

## Programas y tamaños

| Programa | Familia | Tamaño de verificación | Tamaño de medición |
|---|---|---|---|
| Sieve | arreglos | 100 | 2000 |
| Permute | recursión | 3 | 6 |
| Queens | arreglos | 5 | 7 |
| Towers | objetos | 4 | 10 |
| List | objetos | 11 | 12 |
| Storage | objetos | 3 | 6 |
| Bounce | objetos | 3 | 50 |
| Mandelbrot | numérica | 8 | 30 |
| NBody | numérica | 1 | 100 |
| Richards | objetos | 50 | 1000 |

Los programas especifican sus propios algoritmos, entradas, tamaños y salidas esperadas. Las referencias ausentes son objetos centinela, la disyunción exclusiva se calcula con div y mod, Storage representa los arreglos de hijos con objetos de cuatro campos y las hojas guardan su tamaño, Queens cuenta todas las soluciones y NBody escribe trunc(energía × 10¹⁵). Los oráculos independientes derivan de esas definiciones; los tamaños y controles de medición constan en esta misma especificación.

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "sistema",
  "texto": "V1F conserva su variante histórica y su representación sin modificaciones. V1F-S es una variante adicional experimental con los mismos algoritmos comprobados y marcos, rastreo explícito de definición de elementos y campos, recolección no móvil desde raíces de marcos y límite por celdas vivas alcanzables. Ambos techos conservan los diez programas, tamaños y controles; no se reemplazan resultados históricos.",
  "verificacion": [
    "estructural"
  ],
  "justificacion": "Los tests de ceiling contrastan controles independientes, indefinidos, raíces, ciclos, recuperación de basura y límite vivo."
}
```

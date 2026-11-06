---
{
  "formato": "see/1",
  "id": "LANG.PROGRAM.CLASSIC",
  "titulo": "Programas de pseudocódigo clásico",
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
    "reference",
    "engine",
    "aot",
    "cli",
    "service"
  ],
  "resumen": "Programas de pseudocódigo clásico que se ejecutan sin retoques.",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.DECL.VARIABLE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.DECL.UNINITIALIZED",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.IO.INPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.IO.OUTPUT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.IF",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.SWITCH",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.WHILE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.REPEAT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.CONTROL.FOR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.ARRAY.DIMENSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.DECLARATION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.RETURN",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.SUBPROGRAM.BY-REFERENCE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LANG.TYPES.RELATIONS",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LIB.CORE.TEXT",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    },
    {
      "id": "LIB.CORE.CONVERSION",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Programas de pseudocódigo clásico

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un programa formado solo por Algoritmo o Proceso, Definir con lista de nombres, Leer, Escribir, Si, Segun, Mientras, Repetir, Para sin paso, Dimension en dos pasos, Funcion con variable de retorno, SubProceso con parámetros por referencia de salida y las funciones clásicas de la biblioteca se analiza sin diagnósticos y se ejecuta con la salida que derivan las reglas de cada construcción, sin retoques: con punto y coma, índices desde cero y sin valores iniciales ficticios.",
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
    "C20",
    "C21",
    "C22",
    "C23",
    "C24",
    "C25",
    "C26",
    "C27",
    "C28",
    "C29",
    "C30",
    "C31",
    "C32",
    "C33",
    "C34",
    "C35",
    "C36",
    "C37",
    "C38",
    "C39",
    "C40"
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
  "programas": {
    "es": "Algoritmo Saludo\nDefinir nombre Como Cadena;\nEscribir \"Ingrese su nombre:\";\nLeer nombre;\nEscribir \"Hola \", nombre;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Ingrese su nombre:\nHola Ana\n",
    "terminacion": "completed"
  },
  "entradas": [
    "Ana"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
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
  "programas": {
    "es": "Algoritmo Saludo\nDefinir nombre Como Cadena;\nEscribir \"Ingrese su nombre:\";\nLeer nombre;\nEscribir \"Hola \", nombre;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo SumaNumeros\nDefinir n, i, x, suma Como Entero;\nLeer n;\nsuma <- 0;\ni <- 0;\nMientras i < n Hacer\nLeer x;\nsuma <- suma + x;\ni <- i + 1;\nFinMientras\nEscribir \"Suma: \", suma;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Suma: 15\n",
    "terminacion": "completed"
  },
  "entradas": [
    "3",
    "4",
    "5",
    "6"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo SumaNumeros\nDefinir n, i, x, suma Como Entero;\nLeer n;\nsuma <- 0;\ni <- 0;\nMientras i < n Hacer\nLeer x;\nsuma <- suma + x;\ni <- i + 1;\nFinMientras\nEscribir \"Suma: \", suma;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo MayorDeTres\nDefinir a, b, c, mayor Como Entero;\nLeer a, b, c;\nSi a > b Entonces\nSi a > c Entonces\nmayor <- a;\nSiNo\nmayor <- c;\nFinSi\nSiNo\nSi b > c Entonces\nmayor <- b;\nSiNo\nmayor <- c;\nFinSi\nFinSi\nEscribir \"Mayor: \", mayor;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Mayor: 9\n",
    "terminacion": "completed"
  },
  "entradas": [
    "4",
    "9",
    "2"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo MayorDeTres\nDefinir a, b, c, mayor Como Entero;\nLeer a, b, c;\nSi a > b Entonces\nSi a > c Entonces\nmayor <- a;\nSiNo\nmayor <- c;\nFinSi\nSiNo\nSi b > c Entonces\nmayor <- b;\nSiNo\nmayor <- c;\nFinSi\nFinSi\nEscribir \"Mayor: \", mayor;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Menu\nDefinir opcion Como Entero;\nDefinir resp, mensaje Como Cadena;\nLeer opcion;\nSegun opcion Hacer\n1: mensaje <- \"Sumar\";\n2: mensaje <- \"Restar\";\nDe Otro Modo: mensaje <- \"Salir\";\nFinSegun\nEscribir \"Eligio \", mensaje;\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Confirmado\";\nSiNo\nEscribir \"Cancelado\";\nFinSi\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Eligio Restar\nConfirmado\n",
    "terminacion": "completed"
  },
  "entradas": [
    "2",
    "s"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C8",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Menu\nDefinir opcion Como Entero;\nDefinir resp, mensaje Como Cadena;\nLeer opcion;\nSegun opcion Hacer\n1: mensaje <- \"Sumar\";\n2: mensaje <- \"Restar\";\nDe Otro Modo: mensaje <- \"Salir\";\nFinSegun\nEscribir \"Eligio \", mensaje;\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Confirmado\";\nSiNo\nEscribir \"Cancelado\";\nFinSi\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Factorial\nDefinir n, i, f Como Entero;\nLeer n;\nf <- 1;\ni <- 1;\nRepetir\nf <- f * i;\ni <- i + 1;\nHasta Que i > n\nEscribir n, \"! = \", f;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "5! = 120\n",
    "terminacion": "completed"
  },
  "entradas": [
    "5"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Factorial\nDefinir n, i, f Como Entero;\nLeer n;\nf <- 1;\ni <- 1;\nRepetir\nf <- f * i;\ni <- i + 1;\nHasta Que i > n\nEscribir n, \"! = \", f;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Tabla\nDefinir n Como Entero;\nLeer n;\nPara i <- 1 Hasta 10 Hacer\nEscribir n, \" x \", i, \" = \", n * i;\nFinPara\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3 x 1 = 3\n3 x 2 = 6\n3 x 3 = 9\n3 x 4 = 12\n3 x 5 = 15\n3 x 6 = 18\n3 x 7 = 21\n3 x 8 = 24\n3 x 9 = 27\n3 x 10 = 30\n",
    "terminacion": "completed"
  },
  "entradas": [
    "3"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C12",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Tabla\nDefinir n Como Entero;\nLeer n;\nPara i <- 1 Hasta 10 Hacer\nEscribir n, \" x \", i, \" = \", n * i;\nFinPara\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Promedio\nDefinir notas Como Real;\nDefinir suma Como Real;\nDimension notas[5];\nsuma <- 0;\nPara i <- 0 Hasta 4 Hacer\nLeer notas[i];\nsuma <- suma + notas[i];\nFinPara\nEscribir \"Promedio: \", suma / 5;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Promedio: 8.2\n",
    "terminacion": "completed"
  },
  "entradas": [
    "10",
    "8",
    "9",
    "7",
    "7"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C14",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Algoritmo Promedio\nDefinir notas Como Real;\nDefinir suma Como Real;\nDimension notas[5];\nsuma <- 0;\nPara i <- 0 Hasta 4 Hacer\nLeer notas[i];\nsuma <- suma + notas[i];\nFinPara\nEscribir \"Promedio: \", suma / 5;\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo UsaMayor\nDefinir p, q Como Entero;\nLeer p, q;\nEscribir \"Mayor: \", Mayor(p, q);\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Mayor: 12\n",
    "terminacion": "completed"
  },
  "entradas": [
    "7",
    "12"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo UsaMayor\nDefinir p, q Como Entero;\nLeer p, q;\nEscribir \"Mayor: \", Mayor(p, q);\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "SubProceso LeerPositivo(n Como Entero Por Referencia)\nRepetir\nLeer n;\nHasta Que n > 0\nFinSubProceso\nProceso Positivos\nDefinir valor Como Entero;\nLeerPositivo(valor);\nEscribir \"Valor: \", valor;\nFinProceso\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Valor: 8\n",
    "terminacion": "completed"
  },
  "entradas": [
    "-3",
    "0",
    "8"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "SubProceso LeerPositivo(n Como Entero Por Referencia)\nRepetir\nLeer n;\nHasta Que n > 0\nFinSubProceso\nProceso Positivos\nDefinir valor Como Entero;\nLeerPositivo(valor);\nEscribir \"Valor: \", valor;\nFinProceso\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Funcion r <- Mayor(a Como Real, b Como Real)\nDefinir r Como Real;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo Integrador\nDefinir nombre, resp, dato Como Cadena;\nDefinir cantidad, i, opcion Como Entero;\nDefinir notas Como Real;\nDefinir suma, mejor Como Real;\nDimension notas[3];\nLeer nombre;\nEscribir Concatenar(\"Hola, \", Mayusculas(nombre));\nEscribir \"Letras: \", Longitud(nombre), \" Inicio: \", Subcadena(nombre, 0, 2);\ncantidad <- 3;\nsuma <- 0;\ni <- 0;\nMientras i < cantidad Hacer\nLeer dato;\nnotas[i] <- ConvertirANumero(dato);\nsuma <- suma + notas[i];\ni <- i + 1;\nFinMientras\nmejor <- notas[0];\nPara k <- 1 Hasta 2 Hacer\nmejor <- Mayor(mejor, notas[k]);\nFinPara\nEscribir \"Promedio: \", suma / cantidad, \" Mejor: \", mejor;\nLeer opcion;\nSegun opcion Hacer\n1: Escribir \"Aprobado\";\n2: Escribir \"Revisar\";\nDe Otro Modo: Escribir \"Sin opcion\";\nFinSegun\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Fin\";\nSiNo\nEscribir \"Continuar\";\nFinSi\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Hola, LUCIA\nLetras: 5 Inicio: Luc\nPromedio: 7.5 Mejor: 9.0\nRevisar\nFin\n",
    "terminacion": "completed"
  },
  "entradas": [
    "Lucia",
    "7.5",
    "9",
    "6",
    "2",
    "s"
  ],
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "programas": {
    "es": "Funcion r <- Mayor(a Como Real, b Como Real)\nDefinir r Como Real;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo Integrador\nDefinir nombre, resp, dato Como Cadena;\nDefinir cantidad, i, opcion Como Entero;\nDefinir notas Como Real;\nDefinir suma, mejor Como Real;\nDimension notas[3];\nLeer nombre;\nEscribir Concatenar(\"Hola, \", Mayusculas(nombre));\nEscribir \"Letras: \", Longitud(nombre), \" Inicio: \", Subcadena(nombre, 0, 2);\ncantidad <- 3;\nsuma <- 0;\ni <- 0;\nMientras i < cantidad Hacer\nLeer dato;\nnotas[i] <- ConvertirANumero(dato);\nsuma <- suma + notas[i];\ni <- i + 1;\nFinMientras\nmejor <- notas[0];\nPara k <- 1 Hasta 2 Hacer\nmejor <- Mayor(mejor, notas[k]);\nFinPara\nEscribir \"Promedio: \", suma / cantidad, \" Mejor: \", mejor;\nLeer opcion;\nSegun opcion Hacer\n1: Escribir \"Aprobado\";\n2: Escribir \"Revisar\";\nDe Otro Modo: Escribir \"Sin opcion\";\nFinSegun\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Fin\";\nSiNo\nEscribir \"Continuar\";\nFinSi\nFinAlgoritmo\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Ingrese su nombre:\nHola Ana\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Saludo\nDefinir nombre Como Cadena;\nEscribir \"Ingrese su nombre:\";\nLeer nombre;\nEscribir \"Hola \", nombre;\nFinAlgoritmo\n"
    },
    "entrada": "Ana\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Suma: 15\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo SumaNumeros\nDefinir n, i, x, suma Como Entero;\nLeer n;\nsuma <- 0;\ni <- 0;\nMientras i < n Hacer\nLeer x;\nsuma <- suma + x;\ni <- i + 1;\nFinMientras\nEscribir \"Suma: \", suma;\nFinAlgoritmo\n"
    },
    "entrada": "3\n4\n5\n6\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Mayor: 9\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo MayorDeTres\nDefinir a, b, c, mayor Como Entero;\nLeer a, b, c;\nSi a > b Entonces\nSi a > c Entonces\nmayor <- a;\nSiNo\nmayor <- c;\nFinSi\nSiNo\nSi b > c Entonces\nmayor <- b;\nSiNo\nmayor <- c;\nFinSi\nFinSi\nEscribir \"Mayor: \", mayor;\nFinAlgoritmo\n"
    },
    "entrada": "4\n9\n2\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Eligio Restar\nConfirmado\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Menu\nDefinir opcion Como Entero;\nDefinir resp, mensaje Como Cadena;\nLeer opcion;\nSegun opcion Hacer\n1: mensaje <- \"Sumar\";\n2: mensaje <- \"Restar\";\nDe Otro Modo: mensaje <- \"Salir\";\nFinSegun\nEscribir \"Eligio \", mensaje;\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Confirmado\";\nSiNo\nEscribir \"Cancelado\";\nFinSi\nFinAlgoritmo\n"
    },
    "entrada": "2\ns\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "5! = 120\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Factorial\nDefinir n, i, f Como Entero;\nLeer n;\nf <- 1;\ni <- 1;\nRepetir\nf <- f * i;\ni <- i + 1;\nHasta Que i > n\nEscribir n, \"! = \", f;\nFinAlgoritmo\n"
    },
    "entrada": "5\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "3 x 1 = 3\n3 x 2 = 6\n3 x 3 = 9\n3 x 4 = 12\n3 x 5 = 15\n3 x 6 = 18\n3 x 7 = 21\n3 x 8 = 24\n3 x 9 = 27\n3 x 10 = 30\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Tabla\nDefinir n Como Entero;\nLeer n;\nPara i <- 1 Hasta 10 Hacer\nEscribir n, \" x \", i, \" = \", n * i;\nFinPara\nFinAlgoritmo\n"
    },
    "entrada": "3\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Promedio: 8.2\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Algoritmo Promedio\nDefinir notas Como Real;\nDefinir suma Como Real;\nDimension notas[5];\nsuma <- 0;\nPara i <- 0 Hasta 4 Hacer\nLeer notas[i];\nsuma <- suma + notas[i];\nFinPara\nEscribir \"Promedio: \", suma / 5;\nFinAlgoritmo\n"
    },
    "entrada": "10\n8\n9\n7\n7\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Mayor: 12\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo UsaMayor\nDefinir p, q Como Entero;\nLeer p, q;\nEscribir \"Mayor: \", Mayor(p, q);\nFinAlgoritmo\n"
    },
    "entrada": "7\n12\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Valor: 8\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "SubProceso LeerPositivo(n Como Entero Por Referencia)\nRepetir\nLeer n;\nHasta Que n > 0\nFinSubProceso\nProceso Positivos\nDefinir valor Como Entero;\nLeerPositivo(valor);\nEscribir \"Valor: \", valor;\nFinProceso\n"
    },
    "entrada": "-3\n0\n8\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C30",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "cli",
  "espera": {
    "codigo_salida": 0,
    "salida": "Hola, LUCIA\nLetras: 5 Inicio: Luc\nPromedio: 7.5 Mejor: 9.0\nRevisar\nFin\n",
    "salida_error": ""
  },
  "cli": {
    "argumentos": [
      "ejecutar",
      "p.pseudo"
    ],
    "entorno": {},
    "archivos": {
      "p.pseudo": "Funcion r <- Mayor(a Como Real, b Como Real)\nDefinir r Como Real;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo Integrador\nDefinir nombre, resp, dato Como Cadena;\nDefinir cantidad, i, opcion Como Entero;\nDefinir notas Como Real;\nDefinir suma, mejor Como Real;\nDimension notas[3];\nLeer nombre;\nEscribir Concatenar(\"Hola, \", Mayusculas(nombre));\nEscribir \"Letras: \", Longitud(nombre), \" Inicio: \", Subcadena(nombre, 0, 2);\ncantidad <- 3;\nsuma <- 0;\ni <- 0;\nMientras i < cantidad Hacer\nLeer dato;\nnotas[i] <- ConvertirANumero(dato);\nsuma <- suma + notas[i];\ni <- i + 1;\nFinMientras\nmejor <- notas[0];\nPara k <- 1 Hasta 2 Hacer\nmejor <- Mayor(mejor, notas[k]);\nFinPara\nEscribir \"Promedio: \", suma / cantidad, \" Mejor: \", mejor;\nLeer opcion;\nSegun opcion Hacer\n1: Escribir \"Aprobado\";\n2: Escribir \"Revisar\";\nDe Otro Modo: Escribir \"Sin opcion\";\nFinSegun\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Fin\";\nSiNo\nEscribir \"Continuar\";\nFinSi\nFinAlgoritmo\n"
    },
    "entrada": "Lucia\n7.5\n9\n6\n2\ns\n"
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C31",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo Saludo\nDefinir nombre Como Cadena;\nEscribir \"Ingrese su nombre:\";\nLeer nombre;\nEscribir \"Hola \", nombre;\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo Saludo\nDefinir nombre Como Cadena;\nEscribir \"Ingrese su nombre:\";\nLeer nombre;\nEscribir \"Hola \", nombre;\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C32",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo SumaNumeros\nDefinir n, i, x, suma Como Entero;\nLeer n;\nsuma <- 0;\ni <- 0;\nMientras i < n Hacer\nLeer x;\nsuma <- suma + x;\ni <- i + 1;\nFinMientras\nEscribir \"Suma: \", suma;\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo SumaNumeros\nDefinir n, i, x, suma Como Entero;\nLeer n;\nsuma <- 0;\ni <- 0;\nMientras i < n Hacer\nLeer x;\nsuma <- suma + x;\ni <- i + 1;\nFinMientras\nEscribir \"Suma: \", suma;\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C33",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo MayorDeTres\nDefinir a, b, c, mayor Como Entero;\nLeer a, b, c;\nSi a > b Entonces\nSi a > c Entonces\nmayor <- a;\nSiNo\nmayor <- c;\nFinSi\nSiNo\nSi b > c Entonces\nmayor <- b;\nSiNo\nmayor <- c;\nFinSi\nFinSi\nEscribir \"Mayor: \", mayor;\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo MayorDeTres\nDefinir a, b, c, mayor Como Entero;\nLeer a, b, c;\nSi a > b Entonces\nSi a > c Entonces\nmayor <- a;\nSiNo\nmayor <- c;\nFinSi\nSiNo\nSi b > c Entonces\nmayor <- b;\nSiNo\nmayor <- c;\nFinSi\nFinSi\nEscribir \"Mayor: \", mayor;\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C34",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo Menu\nDefinir opcion Como Entero;\nDefinir resp, mensaje Como Cadena;\nLeer opcion;\nSegun opcion Hacer\n1: mensaje <- \"Sumar\";\n2: mensaje <- \"Restar\";\nDe Otro Modo: mensaje <- \"Salir\";\nFinSegun\nEscribir \"Eligio \", mensaje;\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Confirmado\";\nSiNo\nEscribir \"Cancelado\";\nFinSi\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo Menu\nDefinir opcion Como Entero;\nDefinir resp, mensaje Como Cadena;\nLeer opcion;\nSegun opcion Hacer\n1: mensaje <- \"Sumar\";\n2: mensaje <- \"Restar\";\nDe Otro Modo: mensaje <- \"Salir\";\nFinSegun\nEscribir \"Eligio \", mensaje;\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Confirmado\";\nSiNo\nEscribir \"Cancelado\";\nFinSi\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C35",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo Factorial\nDefinir n, i, f Como Entero;\nLeer n;\nf <- 1;\ni <- 1;\nRepetir\nf <- f * i;\ni <- i + 1;\nHasta Que i > n\nEscribir n, \"! = \", f;\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo Factorial\nDefinir n, i, f Como Entero;\nLeer n;\nf <- 1;\ni <- 1;\nRepetir\nf <- f * i;\ni <- i + 1;\nHasta Que i > n\nEscribir n, \"! = \", f;\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C36",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo Tabla\nDefinir n Como Entero;\nLeer n;\nPara i <- 1 Hasta 10 Hacer\nEscribir n, \" x \", i, \" = \", n * i;\nFinPara\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo Tabla\nDefinir n Como Entero;\nLeer n;\nPara i <- 1 Hasta 10 Hacer\nEscribir n, \" x \", i, \" = \", n * i;\nFinPara\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C37",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Algoritmo Promedio\nDefinir notas Como Real;\nDefinir suma Como Real;\nDimension notas[5];\nsuma <- 0;\nPara i <- 0 Hasta 4 Hacer\nLeer notas[i];\nsuma <- suma + notas[i];\nFinPara\nEscribir \"Promedio: \", suma / 5;\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Algoritmo Promedio\nDefinir notas Como Real;\nDefinir suma Como Real;\nDimension notas[5];\nsuma <- 0;\nPara i <- 0 Hasta 4 Hacer\nLeer notas[i];\nsuma <- suma + notas[i];\nFinPara\nEscribir \"Promedio: \", suma / 5;\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C38",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo UsaMayor\nDefinir p, q Como Entero;\nLeer p, q;\nEscribir \"Mayor: \", Mayor(p, q);\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Funcion r <- Mayor(a Como Entero, b Como Entero)\nDefinir r Como Entero;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo UsaMayor\nDefinir p, q Como Entero;\nLeer p, q;\nEscribir \"Mayor: \", Mayor(p, q);\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C39",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "SubProceso LeerPositivo(n Como Entero Por Referencia)\nRepetir\nLeer n;\nHasta Que n > 0\nFinSubProceso\nProceso Positivos\nDefinir valor Como Entero;\nLeerPositivo(valor);\nEscribir \"Valor: \", valor;\nFinProceso\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "SubProceso LeerPositivo(n Como Entero Por Referencia)\nRepetir\nLeer n;\nHasta Que n > 0\nFinSubProceso\nProceso Positivos\nDefinir valor Como Entero;\nLeerPositivo(valor);\nEscribir \"Valor: \", valor;\nFinProceso\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

```caso
{
  "id": "C40",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "coincide_con_frio": true,
      "diagnostics": [],
      "errores": []
    }
  },
  "servicio": {
    "suboperacion": "workspace",
    "campos": [
      "coincide_con_frio",
      "diagnostics",
      "errores"
    ],
    "workspace": {
      "project": {
        "project_id": "1",
        "revision_id": "1",
        "packages": [
          {
            "name": "app",
            "root": "app",
            "kind": "application",
            "entries": [
              "app/main"
            ],
            "dependencies": {}
          }
        ],
        "files": [
          {
            "path": "app/main",
            "source_id": 1,
            "text": "Funcion r <- Mayor(a Como Real, b Como Real)\nDefinir r Como Real;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo Integrador\nDefinir nombre, resp, dato Como Cadena;\nDefinir cantidad, i, opcion Como Entero;\nDefinir notas Como Real;\nDefinir suma, mejor Como Real;\nDimension notas[3];\nLeer nombre;\nEscribir Concatenar(\"Hola, \", Mayusculas(nombre));\nEscribir \"Letras: \", Longitud(nombre), \" Inicio: \", Subcadena(nombre, 0, 2);\ncantidad <- 3;\nsuma <- 0;\ni <- 0;\nMientras i < cantidad Hacer\nLeer dato;\nnotas[i] <- ConvertirANumero(dato);\nsuma <- suma + notas[i];\ni <- i + 1;\nFinMientras\nmejor <- notas[0];\nPara k <- 1 Hasta 2 Hacer\nmejor <- Mayor(mejor, notas[k]);\nFinPara\nEscribir \"Promedio: \", suma / cantidad, \" Mejor: \", mejor;\nLeer opcion;\nSegun opcion Hacer\n1: Escribir \"Aprobado\";\n2: Escribir \"Revisar\";\nDe Otro Modo: Escribir \"Sin opcion\";\nFinSegun\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Fin\";\nSiNo\nEscribir \"Continuar\";\nFinSi\nFinAlgoritmo\n"
          }
        ]
      },
      "options": {
        "profile": "es"
      }
    },
    "actions": [
      {
        "operation": "open",
        "path": "app/main",
        "version": 1,
        "text": "Funcion r <- Mayor(a Como Real, b Como Real)\nDefinir r Como Real;\nSi a > b Entonces\nr <- a;\nSiNo\nr <- b;\nFinSi\nFinFuncion\nAlgoritmo Integrador\nDefinir nombre, resp, dato Como Cadena;\nDefinir cantidad, i, opcion Como Entero;\nDefinir notas Como Real;\nDefinir suma, mejor Como Real;\nDimension notas[3];\nLeer nombre;\nEscribir Concatenar(\"Hola, \", Mayusculas(nombre));\nEscribir \"Letras: \", Longitud(nombre), \" Inicio: \", Subcadena(nombre, 0, 2);\ncantidad <- 3;\nsuma <- 0;\ni <- 0;\nMientras i < cantidad Hacer\nLeer dato;\nnotas[i] <- ConvertirANumero(dato);\nsuma <- suma + notas[i];\ni <- i + 1;\nFinMientras\nmejor <- notas[0];\nPara k <- 1 Hasta 2 Hacer\nmejor <- Mayor(mejor, notas[k]);\nFinPara\nEscribir \"Promedio: \", suma / cantidad, \" Mejor: \", mejor;\nLeer opcion;\nSegun opcion Hacer\n1: Escribir \"Aprobado\";\n2: Escribir \"Revisar\";\nDe Otro Modo: Escribir \"Sin opcion\";\nFinSegun\nLeer resp;\nSi resp = \"s\" Entonces\nEscribir \"Fin\";\nSiNo\nEscribir \"Continuar\";\nFinSi\nFinAlgoritmo\n"
      }
    ]
  },
  "exclusiones": {
    "en": "El pseudocódigo clásico que se copia sin retoques está escrito en español; el perfil en de cada construcción se verifica en su propia regla."
  }
}
```

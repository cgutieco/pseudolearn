---
{
  "formato": "see/1",
  "id": "TOOL.FORMAT.STYLE",
  "titulo": "Estilo y formateador canónico",
  "dominio": "herramienta",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-herramientas"
  ],
  "sujetos": [
    "service"
  ],
  "resumen": "Formateador canónico con preservación exacta de comentarios, sangría de 2 espacios e idempotencia.",
  "depende_de": [
    {
      "id": "LANG.SYNTAX.GRAMMAR",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "LANG.PROFILE.VOCABULARY",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    },
    {
      "id": "TOOL.SERVICE.LOSSLESS-TREE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Canonical formatter style",
  "revisado_por": [
    "revision-independiente-automatizada-r9",
    "Cesar Antonio Gutierrez Contreras"
  ]
}
---

# Estilo y formateador canónico

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El formateador aplica sangría de 2 espacios por nivel de bloque, cero tabuladores, una línea en blanco entre unidades de nivel superior y a lo sumo una línea en blanco consecutiva dentro de un bloque. Abre un nivel cada construcción con cierre propio, según la gramática: algoritmo, subprograma, función anónima, clase, método, constructor, registro, enumerado, interfaz, variante, condicional, bucles, Segun, Elegir, Tareas y Diferir; su cierre vuelve al nivel de la apertura. Sino vuelve al nivel de su Si, y las ramas de Segun y de Elegir se sangran un nivel dentro de la construcción y su cuerpo otro más.",
  "verificacion": [
    "C1",
    "C5",
    "C7"
  ]
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Las palabras clave se escriben en la forma canónica del perfil activo: en español, el lexema del vocabulario tal como está declarado (por ejemplo div, mod y Sino), salvo la apertura y el cierre del algoritmo, que se escriben Algoritmo y FinAlgoritmo; en inglés, el lexema con mayúscula inicial en cada palabra (Define, EndAlgorithm, Div). Las palabras contextuales en posición de palabra clave o de tipo siguen la misma regla; tras un punto o ante el paréntesis de una llamada conservan su lexema. Los identificadores de usuario nunca se renombran y sus usos resueltos adoptan la grafía exacta de su declaración.",
  "verificacion": [
    "C1",
    "C4",
    "C5",
    "C6"
  ]
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "La asignación se escribe siempre <- (su alias := se reescribe a la forma canónica) y, igual que los operadores binarios, va rodeada de un espacio; las comas van seguidas de un espacio; el punto y coma obligatorio se conserva al final de cada sentencia simple y no se añade a una línea que abre un bloque, a los miembros de un enumerado, a las alternativas de una variante ni a un cierre. Los ángulos de los tipos genéricos no llevan espacios dentro ni alrededor (Vector<Entero>, Nuevo Caja<Entero>(7)), y el paréntesis va pegado a Algo, Exito, Error y a SubProceso en tipos y funciones anónimas.",
  "verificacion": [
    "C1",
    "C2",
    "C5",
    "C6"
  ]
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Todo comentario de línea y de bloque se conserva en su posición relativa; aplicar el formateador por segunda vez produce exactamente el mismo texto y no altera los diagnósticos semánticos del programa.",
  "verificacion": [
    "C3",
    "P1"
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
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Algoritmo Principal\n  Definir x Como Entero <- 0;\n  x <- 1 + 2;\n  Escribir x;\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "algoritmo Principal\ndefinir x como entero<-0;\nx<-1+2;\nescribir x;\nfinalgoritmo"
  }
}
```

```caso
{
  "id": "C2",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Algoritmo Minimo\n  x <- 1;\n  w <- 2;\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "Algoritmo Minimo\n  x := 1;\n  w <- 2;\nFinAlgoritmo\n"
  }
}
```

```caso
{
  "id": "C3",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "// cabecera\nAlgoritmo Comentarios\n  // comentario interior\n  x <- 1;  // fin de linea\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "// cabecera\n\n\nAlgoritmo Comentarios\n// comentario interior\n\n\nx <- 1; // fin de linea\nFinAlgoritmo\n"
  }
}
```

```caso
{
  "id": "C4",
  "regla": "R2",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "revisado_por": "Cesar Antonio Gutierrez Contreras",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Algorithm Main\n  Define x As Integer <- 0;\n  Write x;\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "algorithm Main\ndefine x as integer <- 0;\nwrite x;\nendalgorithm"
  }
}
```

```propiedad
{
  "id": "P1",
  "regla": "R4",
  "generador": {
    "programas": "todos los programas válidos del corpus en ambos perfiles"
  },
  "propiedad": "El formateador es idempotente: formatear dos veces produce idéntico texto.",
  "oraculo": "Igualdad estricta byte a byte entre el formateo simple y el doble formateo.",
  "justificacion": "La ejecuta el sujeto service mediante comprobación de idempotencia."
}
```

```caso
{
  "id": "C5",
  "regla": "R1",
  "perfiles": [
    "es"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Registro Jugador\n  Definir puntos Como Entero;\n  Definir nombre Como Cadena;\nFinRegistro\n\nEnumerado Talla\n  S, M, L\nFinEnumerado\n\nVariante Forma\n  Alternativa Circulo(radio Como Entero)\n  Alternativa Punto\nFinVariante\n\nClase Caja<T>\n  Publico Definir valor Como T;\n  Metodo Constructor(v Como T)\n    Este.valor <- v;\n  FinMetodo\nFinClase\n\nSubProceso Suspendible Contar(n Como Entero)\n  Escribir n;\nFinSubProceso\n\nSubProceso Probe() Como Resultado<Entero, ErrorES>\n  Retornar Exito(1);\nFinSubProceso\n\nAlgoritmo P\n  Definir v Como Vector<Entero> <- Vector();\n  Definir c Como Caja<Entero> <- Nuevo Caja<Entero>(7);\n  Definir op Como Opcional<Opcional<Entero>> <- Algo(Algo(3));\n  Definir f Como SubProceso() Como Entero <- SubProceso() Como Entero\n    Retornar 7 div 2 + 7 mod 2;\n  FinSubProceso;\n  Escribir f(), v.Longitud() < 3, 1 > 0;\n  Si NO Verdadero Entonces\n    Escribir 1;\n  Sino\n    Escribir 2;\n  FinSi\n  Tareas\n    Lanzar Contar(1);\n    Lanzar Contar(2);\n  FinTareas\n  Repetir\n    Escribir 3;\n  Hasta Que Verdadero\n  Segun op Hacer\n    Algo(x): Escribir 1;\n    Nada: Escribir 0;\n  FinSegun\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "Registro Jugador\nDefinir puntos Como Entero;\nDefinir nombre Como Cadena;\nFinRegistro\nEnumerado Talla\nS, M, L\nFinEnumerado\nVariante Forma\nAlternativa Circulo(radio Como Entero)\nAlternativa Punto\nFinVariante\nClase Caja<T>\nPublico Definir valor Como T;\nMetodo Constructor(v Como T)\nEste.valor <- v;\nFinMetodo\nFinClase\nSubProceso Suspendible Contar(n Como Entero)\nEscribir n;\nFinSubProceso\nSubProceso Probe() Como Resultado < Entero, ErrorES >\nRetornar Exito (1);\nFinSubProceso\nAlgoritmo P\nDefinir v Como Vector < Entero > <- Vector();\nDefinir c Como Caja<Entero> <- Nuevo Caja < Entero > (7);\nDefinir op Como Opcional<Opcional<Entero>> <- Algo (Algo(3));\nDefinir f Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar 7 Div 2 + 7 Mod 2;\nFinSubProceso;\nEscribir f(), v.Longitud() < 3, 1 > 0;\nSi NO Verdadero Entonces\nEscribir 1;\nSiNo\nEscribir 2;\nFinSi\nTareas\nLanzar Contar(1);\nLanzar Contar(2);\nFinTareas\nRepetir\nEscribir 3;\nHasta Que Verdadero\nSegun op Hacer\nAlgo (x): Escribir 1;\nNada: Escribir 0;\nFinSegun\nFinAlgoritmo\n"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "en"
  ],
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "Interface Shape\n  Method area() As Real;\nEndInterface\n\nVariant Kind\n  Case Dot\n  Case Ring(size As Integer)\nEndVariant\n\nClass Square Implements Shape\n  Method area() As Real\n    Return 1.0;\n  EndMethod\nEndClass\n\nSubroutine Suspendable Count(n As Integer)\n  Write n;\nEndSubroutine\n\nAlgorithm P\n  Define v As Vector<Integer> <- vector();\n  For Each item In v Do\n    Write item;\n  EndFor\n  Defer\n    Write 9;\n  EndDefer\n  Write 7 Div 2, 7 Mod 2, Not True And False;\nEndAlgorithm\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "interface Shape\nmethod area() as real;\nendInterface\nvariant Kind\ncase Dot\ncase Ring(size as integer)\nendVariant\nclass Square implements Shape\nmethod area() as real\nreturn 1.0;\nendMethod\nendClass\nsubroutine suspendable Count(n as integer)\nwrite n;\nendSubroutine\nalgorithm P\ndefine v as vector<integer> <- vector();\nfor each item in v do\nwrite item;\nendFor\ndefer\nwrite 9;\nendDefer\nwrite 7 div 2, 7 mod 2, not true and false;\nendAlgorithm\n"
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
  "origen": "derivado",
  "operacion": "service",
  "espera": {
    "servicio": {
      "formateado": "SubProceso Suspendible Tomar(c Como Canal<Entero>)\n  Elegir\n    Recibir x Desde c:\n      Escribir x;\n    Recibir z Desde c:\n      Escribir z;\n  FinElegir\nFinSubProceso\n\nAlgoritmo P\n  Definir base Como Vector<Entero> <- Vector();\n  Definir datos Como Inmutable<Vector<Entero>> <- Instantanea(base);\n  Para Cada d En datos Hacer\n    Escribir d;\n  FinPara\nFinAlgoritmo\n"
    }
  },
  "servicio": {
    "suboperacion": "format",
    "documento": "SubProceso Suspendible Tomar(c Como Canal<Entero>)\nElegir\nRecibir x Desde c:\nEscribir x;\nRecibir z Desde c:\nEscribir z;\nFinElegir\nFinSubProceso\nAlgoritmo P\nDefinir base Como Vector<Entero> <- Vector();\nDefinir datos Como Inmutable<Vector<Entero>> <- Instantanea(base);\nPara Cada d En datos Hacer\nEscribir d;\nFinPara\nFinAlgoritmo\n"
  }
}
```

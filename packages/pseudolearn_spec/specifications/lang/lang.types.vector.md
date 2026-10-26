---
{
  "formato": "see/1",
  "id": "LANG.TYPES.VECTOR",
  "titulo": "Vectores dinámicos tipados",
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
    "engine",
    "aot"
  ],
  "resumen": "Vectores dinámicos tipados",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "LANG.TYPES.GENERIC",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Vectores dinámicos tipados

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Vector<T> es una referencia compartida de elementos homogéneos; Vector() vacío necesita contexto de tipo. Los registros se copian por valor y las referencias, incluidas clausuras y colecciones, se comparten. Longitud() devuelve Entero; el acceso v[i] usa índices desde cero y atrapa fuera de rango. Reemplazar un elemento existente no modifica la versión estructural.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C4"
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
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nEscribir values.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nwrite values.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
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
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(4);\nvalues[0] <- 8;\nEscribir values[0];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(4);\nvalues[0] <- 8;\nwrite values[0];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "8\n",
    "terminacion": "completed"
  }
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
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nEscribir values[0];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nwrite values[0];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  }
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
  "programas": {
    "es": "Registro Box\nDefinir value Como Entero;\nFinRegistro\nAlgoritmo Main\nDefinir values Como Vector<Box> <- Vector();\nvalues.Agregar(Box(4));\nDefinir Mutable copy Como Box <- values[0];\ncopy.value <- 9;\nEscribir values[0].value;\nFinAlgoritmo\n",
    "en": "record Box\ndefine value as integer;\nendRecord\nalgorithm Main\ndefine values as vector<Box> <- vector();\nvalues.append(Box(4));\ndefine mutable copy as Box <- values[0];\ncopy.value <- 9;\nwrite values[0].value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "4\n",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Agregar(x), Insertar(i,x) y Eliminar(i) no retornan valor. Insertar permite 0 hasta longitud inclusive; Eliminar requiere un índice existente. Conservan orden, comprueban tamaño antes de modificar y solo un cambio estructural exitoso incrementa una versión u32; su agotamiento atrapa antes de modificar. La capacidad parte de cero, crece a uno y luego se duplica con aritmética comprobada y recorte al límite.",
  "verificacion": [
    "C5",
    "C6",
    "C7"
  ]
}
```

```caso
{
  "id": "C5",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(2);\nvalues.Insertar(0, 1);\nvalues.Agregar(3);\nvalues.Eliminar(1);\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(2);\nvalues.insert(0, 1);\nvalues.append(3);\nvalues.remove(1);\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "[1, 3]\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C6",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Insertar(1, 7);\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.insert(1, 7);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "",
    "fallo": {
      "codigo": "arrayIndexOutOfRange"
    }
  }
}
```

```caso
{
  "id": "C7",
  "regla": "R2",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nDefinir alias Como Vector<Entero> <- values;\nalias.Agregar(5);\nEscribir values.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\ndefine alias as vector<integer> <- values;\nalias.append(5);\nwrite values.length();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El límite por colección deriva del presupuesto cells del anfitrión: min(cells, u32 máximo menos dos) elementos y min(cells, u32 máximo) palabras de almacenamiento variable, ocho bytes por palabra. El almacenamiento variable incluye capacidad y metadatos; la cabecera fija queda fuera. Un vector cuenta globalmente una celda más longitud por máximo entre uno y ancho de elemento, además de referencias alcanzables sin doble conteo. El límite estructural produce collectionLimitExceeded y el global conserva cellLimitExceeded. Escribir muestra elementos separados por coma y espacio entre corchetes si todos son imprimibles; las cadenas y caracteres internos se delimitan y escapan. Los tipos sin representación de salida se rechazan estáticamente.",
  "verificacion": [
    "C8",
    "C9",
    "C10",
    "C11"
  ]
}
```

```caso
{
  "id": "C8",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Cadena> <- Vector();\nvalues.Agregar(\"ab\");\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<string> <- vector();\nvalues.append(\"ab\");\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "[\"ab\"]\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C9",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Registro Box\nDefinir value Como Entero;\nFinRegistro\nAlgoritmo Main\nDefinir values Como Vector<Box> <- Vector();\nEscribir values;\nFinAlgoritmo\n",
    "en": "record Box\ndefine value as integer;\nendRecord\nalgorithm Main\ndefine values as vector<Box> <- vector();\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "collectionCannotBeWritten",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C10",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nEscribir values;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nwrite values;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "[]\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C11",
  "regla": "R3",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "SubProceso make(value Como Entero) Como SubProceso() Como Entero\nDefinir captured Como Entero <- value;\nRetornar SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nFinSubProceso\nAlgoritmo Main\nDefinir callbacks Como Vector<SubProceso() Como Entero> <- Vector();\ncallbacks.Agregar(make(7));\nEscribir callbacks[0]();\nFinAlgoritmo\n",
    "en": "subroutine make(value as integer) as subroutine() as integer\ndefine captured as integer <- value;\nreturn subroutine() as integer\nreturn captured;\nendSubroutine;\nendSubroutine\nalgorithm Main\ndefine callbacks as vector<subroutine() as integer> <- vector();\ncallbacks.append(make(7));\nwrite callbacks[0]();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```

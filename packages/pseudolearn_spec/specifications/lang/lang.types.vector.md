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
  "programas": {
    "es": "Registro Box\nDefinir value Como Entero;\nFinRegistro\nAlgoritmo Main\nDefinir values Como Vector<Box> <- Vector();\nvalues.Agregar(Box(4));\nDefinir copy Como Box <- values[0];\ncopy.value <- 9;\nEscribir values[0].value;\nFinAlgoritmo\n",
    "en": "record Box\ndefine value as integer;\nendRecord\nalgorithm Main\ndefine values as vector<Box> <- vector();\nvalues.append(Box(4));\ndefine copy as Box <- values[0];\ncopy.value <- 9;\nwrite values[0].value;\nendAlgorithm\n"
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

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Ordenar()/sort() e Invertir()/reverse() mutan el vector y aumentan su versión estructural incluso vacío o unitario. El orden natural admite Entero, Real, Caracter, Cadena y Logico (Falso antes de Verdadero); las cadenas se ordenan por puntos de código sin normalización; los ceros reales son iguales. Ordenar(comparador) admite un SubProceso(T,T) Como Entero síncrono por valor: negativo, cero o positivo. El orden es estable y conserva el multiconjunto. La mezcla termina con comparadores inconsistentes. La ordenación trabaja en copias O(n) contabilizadas en celdas y no confirma parcialmente el reordenamiento ante fallo del comparador, combustible o memoria. Rechaza cualquier escritura al receptor por alias durante el comparador, incluido reemplazar un elemento, así como una ordenación anidada sobre el mismo receptor con collectionModifiedDuringIteration; los efectos propios del comparador no se revierten. Un recorrido activo detecta la nueva versión. La mezcla interna no introduce pasos visibles; el cuerpo de usuario del comparador conserva sus observaciones.",
  "verificacion": [
    "C12",
    "C13",
    "C14",
    "C17",
    "C18",
    "C19",
    "C20",
    "C21",
    "C22",
    "C23",
    "C25",
    "C27"
  ]
}
```

```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "PosicionDe(x)/indexOf(x) devuelve Opcional<Entero> con la primera posición desde cero o Nada; Contiene(x)/contains(x) devuelve Logico. Admiten solo elementos primitivos y usan igualdad de valor, incluyendo igualdad entre ceros reales y contenido Unicode exacto. No mutan el receptor y pueden consultar vistas inmutables.",
  "verificacion": [
    "C15",
    "C16",
    "C24",
    "C26"
  ]
}
```

```caso
{
  "id": "C12",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(3); values.Agregar(-1); values.Agregar(3);\nvalues.Ordenar(); Escribir values[0], \":\", values[1], \":\", values[2];\nvalues.Invertir(); Escribir values[0], \":\", values[2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(3); values.append(-1); values.append(3);\nvalues.sort(); write values[0], \":\", values[1], \":\", values[2];\nvalues.reverse(); write values[0], \":\", values[2];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "-1:3:3\n3:-1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C13",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector(); values.Ordenar(); values.Invertir();\nEscribir values.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector(); values.sort(); values.reverse();\nwrite values.length();\nendAlgorithm\n"
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
  "id": "C14",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector(); values.Agregar(1);\nPara Cada element En values Hacer\nvalues.Ordenar();\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector(); values.append(1);\nfor each element in values do\nvalues.sort();\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "collectionModifiedDuringIteration"
    }
  }
}
```

```caso
{
  "id": "C15",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector(); values.Agregar(7); values.Agregar(7);\nEscribir values.Contiene(7), \":\", values.Contiene(8);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector(); values.append(7); values.append(7);\nwrite values.contains(7), \":\", values.contains(8);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Verdadero:Falso\n",
    "terminacion": "completed"
  },
  "esperas": {
    "es": {
      "salida": "Verdadero:Falso\n",
      "terminacion": "completed"
    },
    "en": {
      "salida": "true:false\n",
      "terminacion": "completed"
    }
  }
}
```

```caso
{
  "id": "C16",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector(); Escribir values.Contiene(1);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector(); write values.contains(1);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "Falso\n",
    "terminacion": "completed"
  },
  "esperas": {
    "es": {
      "salida": "Falso\n",
      "terminacion": "completed"
    },
    "en": {
      "salida": "false\n",
      "terminacion": "completed"
    }
  }
}
```

```caso
{
  "id": "C17",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(32);\nvalues.Agregar(21);\nvalues.Agregar(12);\nvalues.Agregar(11);\nvalues.Ordenar(SubProceso(left Como Entero, right Como Entero) Como Entero\nRetornar left MOD 10 - right MOD 10;\nFinSubProceso);\nEscribir values[0], \":\", values[1], \":\", values[2], \":\", values[3];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(32);\nvalues.append(21);\nvalues.append(12);\nvalues.append(11);\nvalues.sort(subroutine(left as integer, right as integer) as integer\nreturn left mod 10 - right mod 10;\nendSubroutine);\nwrite values[0], \":\", values[1], \":\", values[2], \":\", values[3];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "21:11:32:12\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C18",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(32);\nvalues.Agregar(21);\nvalues.Agregar(12);\nvalues.Agregar(11);\nvalues.Ordenar(SubProceso(left Como Entero, right Como Entero) Como Entero\nRetornar 0;\nFinSubProceso);\nEscribir values[0], \":\", values[1], \":\", values[2], \":\", values[3];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(32);\nvalues.append(21);\nvalues.append(12);\nvalues.append(11);\nvalues.sort(subroutine(left as integer, right as integer) as integer\nreturn 0;\nendSubroutine);\nwrite values[0], \":\", values[1], \":\", values[2], \":\", values[3];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "32:21:12:11\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C19",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(32);\nvalues.Agregar(21);\nvalues.Agregar(12);\nvalues.Agregar(11);\nvalues.Ordenar(SubProceso(left Como Entero, right Como Entero) Como Entero\nRetornar -1;\nFinSubProceso);\nEscribir values[0], \":\", values[1], \":\", values[2], \":\", values[3];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(32);\nvalues.append(21);\nvalues.append(12);\nvalues.append(11);\nvalues.sort(subroutine(left as integer, right as integer) as integer\nreturn -1;\nendSubroutine);\nwrite values[0], \":\", values[1], \":\", values[2], \":\", values[3];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "32:21:12:11\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C20",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(2);\nvalues.Agregar(1);\nvalues.Ordenar(SubProceso(left Como Entero, right Como Entero) Como Entero\nRetornar left DIV (right - right);\nFinSubProceso);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(2);\nvalues.append(1);\nvalues.sort(subroutine(left as integer, right as integer) as integer\nreturn left div (right - right);\nendSubroutine);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "divisionByZero"
    }
  }
}
```

```caso
{
  "id": "C21",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(2);\nvalues.Agregar(1);\nvalues.Ordenar(SubProceso(left Como Entero, right Como Entero) Como Entero\nvalues.Agregar(9);\nRetornar left - right;\nFinSubProceso);\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(2);\nvalues.append(1);\nvalues.sort(subroutine(left as integer, right as integer) as integer\nvalues.append(9);\nreturn left - right;\nendSubroutine);\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "fallo": {
      "codigo": "collectionModifiedDuringIteration"
    }
  }
}
```

```caso
{
  "id": "C22",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Real> <- Vector();\nvalues.Agregar(0.0);\nvalues.Agregar(-0.0);\nvalues.Agregar(1.0);\nvalues.Ordenar(); Escribir values[0], \":\", values[1], \":\", values[2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<real> <- vector();\nvalues.append(0.0);\nvalues.append(-0.0);\nvalues.append(1.0);\nvalues.sort(); write values[0], \":\", values[1], \":\", values[2];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0.0:-0.0:1.0\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C23",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Cadena> <- Vector();\nvalues.Agregar(\"éé\");\nvalues.Agregar(\"ZZ\");\nvalues.Agregar(\"aa\");\nvalues.Ordenar(); Escribir values[0], \":\", values[1], \":\", values[2];\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<string> <- vector();\nvalues.append(\"éé\");\nvalues.append(\"ZZ\");\nvalues.append(\"aa\");\nvalues.sort(); write values[0], \":\", values[1], \":\", values[2];\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ZZ:aa:éé\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C24",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nvalues.Agregar(8);\nvalues.Agregar(7);\nSegun values.PosicionDe(7) Hacer\nAlgo(found): Escribir found;\nNada: Escribir -1;\nFinSegun\nSegun values.PosicionDe(9) Hacer\nAlgo(found): Escribir found;\nNada: Escribir -1;\nFinSegun\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<integer> <- vector();\nvalues.append(7);\nvalues.append(8);\nvalues.append(7);\nswitch values.indexOf(7) do\nsome(found): write found;\nnone: write -1;\nendSwitch\nswitch values.indexOf(9) do\nsome(found): write found;\nnone: write -1;\nendSwitch\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "0\n-1\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C25",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Vector<Entero>> <- Vector(); values.Ordenar();\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<vector<integer>> <- vector(); values.sort();\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "elementTypeNotOrderable",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C26",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Vector<Entero>> <- Vector(); Escribir values.Contiene(Vector());\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<vector<integer>> <- vector(); write values.contains(vector());\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "analyze",
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "elementTypeNotComparable",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R4",
  "perfiles": [
    "es",
    "en"
  ],
  "programas": {
    "es": "Algoritmo P\nDefinir values Como Vector<Logico> <- Vector(); values.Agregar(Verdadero); values.Agregar(Falso); values.Ordenar(); Si values[0] = Falso Entonces Escribir 1; FinSi\nFinAlgoritmo\n",
    "en": "algorithm P\ndefine values as vector<boolean> <- vector(); values.append(true); values.append(false); values.sort(); if values[0] = false then write 1; endIf\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "1\n",
    "terminacion": "completed"
  }
}
```

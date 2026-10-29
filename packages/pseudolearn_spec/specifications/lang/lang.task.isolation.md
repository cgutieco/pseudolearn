---
{
  "formato": "see/1",
  "id": "LANG.TASK.ISOLATION",
  "titulo": "Aislamiento transitivo entre tareas",
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
  "resumen": "Aislamiento transitivo entre tareas",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {"id": "LIB.JSON", "version": ">=1.0.0, <2.0.0", "tipo": "requiere"},
    {
      "id": "LANG.TASK.SCOPE",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Aislamiento transitivo entre tareas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Son transferibles los escalares, cadenas, enumerados, registros de campos transferibles, Opcional y Resultado de componentes transferibles, Canal de elemento transferible, FalloTareas de error transferible, Inmutable y capacidades. Bytes, ValorJson, PeticionHttp y RespuestaHttp son transferibles porque sus interfaces no exponen mutación. MetodoHttp es un enumerado transferible. Los argumentos de Lanzar, elementos de Canal y errores de tareas usan el mismo predicado estructural.",
  "verificacion": [
    "C1",
    "C2",
    "C3",
    "C26"
  ]
}
```
```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "No son transferibles vectores, diccionarios, arreglos, objetos de clase, tipos función aunque solo capturen escalares, asas Tarea ni compuestos que los contengan. El diagnóstico informa el tipo y la ruta hasta el primer componente no transferible; los ciclos de tipos se recorren una sola vez.",
  "verificacion": [
    "C4",
    "C5",
    "C6",
    "C7",
    "C14",
    "C15",
    "C16"
  ]
}
```
```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un parámetro de tipo opaco en un cuerpo genérico no es transferible. Los parámetros por referencia no cruzan una frontera de tarea. El resultado de una tarea terminada se mueve al padre y no requiere transferibilidad.",
  "verificacion": [
    "C11",
    "C13",
    "C17",
    "C18",
    "C19"
  ]
}
```
```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Instantanea(x) devuelve Inmutable<S>. Acepta escalares, cadenas, enumerados, registros, variantes, vectores, diccionarios y arreglos. Copia profundamente conservando alias internos y ciclos; canales y capacidades se comparten. Las celdas copiadas se cobran como creación y pueden fallar con cellLimitExceeded.",
  "verificacion": [
    "C20",
    "C22",
    "C23"
  ]
}
```
```regla
{
  "id": "R7",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Instantanea de un objeto de clase o de una función, directa o contenida en el grafo, produce snapshotNotSupported con la ruta hasta el primer componente rechazado.",
  "verificacion": [
    "C24",
    "C27"
  ]
}
```
```regla
{
  "id": "R5",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Inmutable<S> admite lecturas; el resultado referencial no transferible de una lectura conserva Inmutable. No permite escritura ni métodos mutadores: immutableValueWrite. No hay conversión implícita a S ni desde S. Instantanea de Inmutable conserva el aislamiento.",
  "verificacion": [
    "C12",
    "C21",
    "C29"
  ]
}
```
```regla
{
  "id": "R6",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Copiar conserva su copia superficial previa y no crea aislamiento transitivo.",
  "verificacion": [
    "C28"
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
  "programas": {
    "es": "SubProceso Suspendible Work(value Como Entero)\nEscribir value;\nFinSubProceso\nAlgoritmo Main\nTareas\nLanzar Work(7);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(value as integer)\nwrite value;\nendSubroutine\nalgorithm Main\ntasks\nspawn Work(7);\nendTasks\nendAlgorithm\n"
  },
  "espera": {
    "salida": "7\n",
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
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Opcional<Entero>> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<optional<integer>> <- channel(1);\nstream.close();\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
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
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Bytes> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<Bytes> <- channel(1);\nstream.close();\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": []
  }
}
```
```caso
{
  "id": "C4",
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
  "operacion": "analyze",
  "programas": {
    "es": "SubProceso Suspendible Work(value Como Vector<Entero>)\nFinSubProceso\nAlgoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nTareas\nLanzar Work(values);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(value as vector<integer>)\nendSubroutine\nalgorithm Main\ndefine values as vector<integer> <- vector();\ntasks\nspawn Work(values);\nendTasks\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskArgumentNotTransferable",
        "severidad": "error"
      }
    ]
  }
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
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Clase Customer\nFinClase\nRegistro Request\nDefinir customer Como Customer;\nFinRegistro\nAlgoritmo Main\nDefinir stream Como Canal<Request> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "class Customer\nendClass\nrecord Request\ndefine customer as Customer;\nendRecord\nalgorithm Main\ndefine stream as channel<Request> <- channel(1);\nstream.close();\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelElementNotTransferable",
        "severidad": "error"
      }
    ]
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
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Clase Customer\nFinClase\nAlgoritmo Main\nDefinir stream Como Canal<Opcional<Customer>> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "class Customer\nendClass\nalgorithm Main\ndefine stream as channel<optional<Customer>> <- channel(1);\nstream.close();\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelElementNotTransferable",
        "severidad": "error"
      }
    ]
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
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Algoritmo Main\nDefinir stream Como Canal<Vector<Entero>> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine stream as channel<vector<integer>> <- channel(1);\nstream.close();\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelElementNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```
```cobertura
{
  "id": "V1",
  "regla": "LANG.TASK.ISOLATION#R1",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```cobertura
{
  "id": "V2",
  "regla": "LANG.TASK.ISOLATION#R2",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```cobertura
{
  "id": "V3",
  "regla": "LANG.TASK.ISOLATION#R3",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```cobertura
{
  "id": "V4",
  "regla": "LANG.TASK.ISOLATION#R4",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```cobertura
{
  "id": "V5",
  "regla": "LANG.TASK.ISOLATION#R5",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```cobertura
{
  "id": "V6",
  "regla": "LANG.TASK.ISOLATION#R6",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```cobertura
{
  "id": "V7",
  "regla": "LANG.TASK.ISOLATION#R7",
  "sin_ri": "El predicado y la restricción de escritura se verifican estáticamente; la copia usa las disposiciones gestionadas del runtime."
}
```
```caso
{
  "id": "C11",
  "regla": "R4",
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
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nvalues[0] <- 9;\nEscribir frozen[0];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(7);\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\nvalues[0] <- 9;\nwrite frozen[0];\nendAlgorithm\n"
  },
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  }
}
```
```caso
{
  "id": "C12",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nfrozen[0] <- 9;\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(7);\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\nfrozen[0] <- 9;\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "immutableValueWrite",
        "severidad": "error"
      }
    ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nEscribir frozen.Longitud();\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\nwrite frozen.length();\nendAlgorithm\n"
  },
  "espera": {
    "salida": "0\n",
    "terminacion": "completed"
  }
}
```
```caso
{
  "id": "C14",
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
  "operacion": "analyze",
  "programas": {
    "es": "Clase Customer\nFinClase\nSubProceso Suspendible Work(callback Como SubProceso() Como Customer)\nFinSubProceso\nAlgoritmo Main\nDefinir captured Como Customer <- Nuevo Customer();\nDefinir callback Como SubProceso() Como Customer <- SubProceso() Como Customer\nRetornar captured;\nFinSubProceso;\nTareas\nLanzar Work(callback);\nFinTareas\nFinAlgoritmo\n",
    "en": "class Customer\nendClass\nsubroutine suspendable Work(callback as subroutine() as Customer)\nendSubroutine\nalgorithm Main\ndefine captured as Customer <- new Customer();\ndefine callback as subroutine() as Customer <- subroutine() as Customer\nreturn captured;\nendSubroutine;\ntasks\nspawn Work(callback);\nendTasks\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskArgumentNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```
```caso
{
  "id": "C15",
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
  "operacion": "analyze",
  "programas": {
    "es": "SubProceso Suspendible Work(callback Como SubProceso() Como Entero)\nFinSubProceso\nAlgoritmo Main\nDefinir captured Como Entero <- 7;\nDefinir callback Como SubProceso() Como Entero <- SubProceso() Como Entero\nRetornar captured;\nFinSubProceso;\nTareas\nLanzar Work(callback);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(callback as subroutine() as integer)\nendSubroutine\nalgorithm Main\ndefine captured as integer <- 7;\ndefine callback as subroutine() as integer <- subroutine() as integer\nreturn captured;\nendSubroutine;\ntasks\nspawn Work(callback);\nendTasks\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskArgumentNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```
```caso
{
  "id": "C16",
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
  "operacion": "analyze",
  "programas": {
    "es": "Clase FirstNode\nDefinir next Como SecondNode;\nFinClase\nClase SecondNode\nDefinir previous Como FirstNode;\nFinClase\nRegistro Request\nDefinir node Como FirstNode;\nFinRegistro\nAlgoritmo Main\nDefinir stream Como Canal<Request> <- Canal(1);\nstream.Cerrar();\nFinAlgoritmo\n",
    "en": "class FirstNode\ndefine next as SecondNode;\nendClass\nclass SecondNode\ndefine previous as FirstNode;\nendClass\nrecord Request\ndefine node as FirstNode;\nendRecord\nalgorithm Main\ndefine stream as channel<Request> <- channel(1);\nstream.close();\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "channelElementNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```
```caso
{
  "id": "C17",
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
  "operacion": "analyze",
  "programas": {
    "es": "SubProceso Suspendible Work(value Como Entero Por Referencia)\nFinSubProceso\nAlgoritmo Main\nDefinir Mutable value Como Entero <- 1;\nTareas\nLanzar Work(value);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work(value as integer by reference)\nendSubroutine\nalgorithm Main\ndefine mutable value as integer <- 1;\ntasks\nspawn Work(value);\nendTasks\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskByReferenceArgument",
        "severidad": "error"
      }
    ]
  }
}
```
```caso
{
  "id": "C18",
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
  "operacion": "analyze",
  "programas": {
    "es": "SubProceso Suspendible Work<T>(value Como T)\nFinSubProceso\nSubProceso Suspendible Forward<T>(value Como T)\nTareas\nLanzar Work(value);\nFinTareas\nFinSubProceso\nAlgoritmo Main\nAguardar Forward(7);\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work<T>(value as T)\nendSubroutine\nsubroutine suspendable Forward<T>(value as T)\ntasks\nspawn Work(value);\nendTasks\nendSubroutine\nalgorithm Main\nawait Forward(7);\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskArgumentNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```
```caso
{
  "id": "C19",
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
  "programas": {
    "es": "SubProceso Suspendible Work() Como Vector<Entero>\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nRetornar values;\nFinSubProceso\nAlgoritmo Main\nTareas\nDefinir handle Como Tarea<Vector<Entero>> <- Lanzar Work();\nDefinir values Como Vector<Entero> <- Aguardar handle;\nvalues.Agregar(9);\nEscribir values[1];\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Work() as vector<integer>\ndefine values as vector<integer> <- vector();\nvalues.append(7);\nreturn values;\nendSubroutine\nalgorithm Main\ntasks\ndefine handle as task<vector<integer>> <- spawn Work();\ndefine values as vector<integer> <- await handle;\nvalues.append(9);\nwrite values[1];\nendTasks\nendAlgorithm\n"
  },
  "espera": {
    "salida": "9\n",
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo Main\nDefinir child Como Vector<Entero> <- Vector();\nchild.Agregar(7);\nDefinir values Como Vector<Vector<Entero>> <- Vector();\nvalues.Agregar(child);\nvalues.Agregar(child);\nDefinir frozen Como Inmutable<Vector<Vector<Entero>>> <- Instantanea(values);\nchild[0] <- 9;\nPara Cada value En frozen Hacer\nEscribir value[0];\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine child as vector<integer> <- vector();\nchild.append(7);\ndefine values as vector<vector<integer>> <- vector();\nvalues.append(child);\nvalues.append(child);\ndefine frozen as immutable<vector<vector<integer>>> <- snapshot(values);\nchild[0] <- 9;\nfor each value in frozen do\nwrite value[0];\nendFor\nendAlgorithm\n"
  },
  "espera": {
    "salida": "7\n7\n",
    "terminacion": "completed"
  }
}
```
```caso
{
  "id": "C21",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Algoritmo Main\nDefinir child Como Vector<Entero> <- Vector();\nchild.Agregar(7);\nDefinir values Como Vector<Vector<Entero>> <- Vector();\nvalues.Agregar(child);\nvalues.Agregar(child);\nDefinir frozen Como Inmutable<Vector<Vector<Entero>>> <- Instantanea(values);\nchild[0] <- 9;\nPara Cada value En frozen Hacer\nvalue[0] <- 10;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine child as vector<integer> <- vector();\nchild.append(7);\ndefine values as vector<vector<integer>> <- vector();\nvalues.append(child);\nvalues.append(child);\ndefine frozen as immutable<vector<vector<integer>>> <- snapshot(values);\nchild[0] <- 9;\nfor each value in frozen do\nvalue[0] <- 10;\nendFor\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "immutableValueWrite",
        "severidad": "error"
      }
    ]
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nEscribir frozen[0];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(7);\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\nwrite frozen[0];\nendAlgorithm\n"
  },
  "espera": {
    "salida": "7\n",
    "terminacion": "completed"
  },
  "limites": {
    "celdas": 4
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
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "execute",
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(7);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nEscribir frozen[0];\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(7);\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\nwrite frozen[0];\nendAlgorithm\n"
  },
  "espera": {
    "salida": "",
    "terminacion": "failed",
    "fallo": {
      "codigo": "cellLimitExceeded"
    }
  },
  "limites": {
    "celdas": 3
  }
}
```
```caso
{
  "id": "C24",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "Clase Customer\nFinClase\nAlgoritmo Main\nDefinir value Como Customer <- Nuevo Customer();\nDefinir frozen Como Inmutable<Customer> <- Instantanea(value);\nFinAlgoritmo\n",
    "en": "class Customer\nendClass\nalgorithm Main\ndefine value as Customer <- new Customer();\ndefine frozen as immutable<Customer> <- snapshot(value);\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "snapshotNotSupported",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C26",
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
  "operacion": "analyze",
  "programas": {
    "es": "SubProceso Suspendible Fail() Como Resultado<Entero, Vector<Entero>>\nRetornar Error(Vector());\nFinSubProceso\nAlgoritmo Main\nTareas failureReport\nLanzar Fail();\nFinTareas\nDescartar failureReport;\nFinAlgoritmo\n",
    "en": "subroutine suspendable Fail() as result<integer, vector<integer>>\nreturn failure(vector());\nendSubroutine\nalgorithm Main\ntasks failureReport\nspawn Fail();\nendTasks\ndiscard failureReport;\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "taskErrorNotTransferable",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C27",
  "regla": "R7",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "origen": "derivado",
  "operacion": "analyze",
  "programas": {
    "es": "SubProceso Identity() Como Entero\nRetornar 7;\nFinSubProceso\nAlgoritmo Main\nDefinir callback Como SubProceso() Como Entero <- Identity;\nDefinir frozen Como Inmutable<SubProceso() Como Entero> <- Instantanea(callback);\nFinAlgoritmo\n",
    "en": "subroutine Identity() as integer\nreturn 7;\nendSubroutine\nalgorithm Main\ndefine callback as subroutine() as integer <- Identity;\ndefine frozen as immutable<subroutine() as integer> <- snapshot(callback);\nendAlgorithm\n"
  },
  "espera": {
    "arbol": "presente",
    "diagnosticos": [
      {
        "codigo": "snapshotNotSupported",
        "severidad": "error"
      }
    ]
  }
}
```

```caso
{
  "id": "C28",
  "regla": "R6",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Clase Inner\nPublico Definir value Como Entero;\nFinClase\nClase Outer\nPublico Definir inner Como Inner;\nFinClase\nAlgoritmo Main\nDefinir shared Como Inner <- Nuevo Inner();\nshared.value <- 1;\nDefinir first Como Outer <- Nuevo Outer();\nfirst.inner <- shared;\nDefinir second Como Outer <- Copiar(first);\nshared.value <- 9;\nEscribir second.inner.value;\nFinAlgoritmo\n",
    "en": "class Inner\npublic define value as integer;\nendClass\nclass Outer\npublic define inner as Inner;\nendClass\nalgorithm Main\ndefine shared as Inner <- new Inner();\nshared.value <- 1;\ndefine first as Outer <- new Outer();\nfirst.inner <- shared;\ndefine second as Outer <- copy(first);\nshared.value <- 9;\nwrite second.inner.value;\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "9\n",
    "terminacion": "completed"
  }
}
```

```caso
{
  "id": "C29",
  "regla": "R5",
  "perfiles": [
    "es",
    "en"
  ],
  "rigor": [
    "estricto",
    "flexible"
  ],
  "programas": {
    "es": "Algoritmo Main\nDefinir values Como Vector<Entero> <- Vector();\nvalues.Agregar(3);\nvalues.Agregar(4);\nDefinir frozen Como Inmutable<Vector<Entero>> <- Instantanea(values);\nPara Cada item En frozen Hacer\nEscribir item;\nFinPara\nFinAlgoritmo\n",
    "en": "algorithm Main\ndefine values as vector<integer> <- vector();\nvalues.append(3);\nvalues.append(4);\ndefine frozen as immutable<vector<integer>> <- snapshot(values);\nfor each item in frozen do\nwrite item;\nendFor\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "3\n4\n",
    "terminacion": "completed"
  }
}
```

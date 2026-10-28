---
{
  "formato": "see/1",
  "id": "ENG.TASK.MEMORY",
  "titulo": "Memoria y persistencia de tareas suspendidas",
  "dominio": "motor",
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
  "resumen": "Memoria y persistencia de tareas suspendidas",
  "edicion": {
    "introducida_en": "2026"
  },
  "depende_de": [
    {
      "id": "ENG.TASK.AGENDA",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "requiere"
    }
  ]
}
---

# Memoria y persistencia de tareas suspendidas

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La continuación de un marco suspendible usa una disposición única: cabecera, función, estado de reanudación, enlace padre, ranura de resultado y segmentos escalar y de referencias con capacidad máxima de vivos de sus puntos de suspensión. Se crea en su primera suspensión y cuesta una celda más sus ranuras.",
  "verificacion": [
    "C1",
    "C3"
  ]
}
```
```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "El recolector recorre los marcos activos y, en orden de identidad de tarea, continuaciones, resultados pendientes y emisores. Los canales y sus mensajes conservan alcanzabilidad. Las imágenes y diferencias guardan agenda, canales, tareas, continuaciones y pendientes, de modo que restaurar o seek conserva exactamente la ejecución posterior.",
  "verificacion": [
    "C2"
  ]
}
```
```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "ejecucion",
  "texto": "La recolección en cada asignación conserva los observables, incluso con tareas suspendidas, mensajes referenciales y copias cíclicas.",
  "verificacion": [
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
    "es": "SubProceso Suspendible Hold(name Como Cadena, stream Como Canal<Entero>)\nDefinir label Como Cadena <- name + \"-x\";\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir label;\nNada: Escribir label;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Closer(stream Como Canal<Entero>)\nstream.Cerrar();\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nDefinir Mutable index Como Entero <- 0;\nTareas\nPara index <- 1 Hasta 100 Con Paso 1 Hacer\nLanzar Hold(\"tk\", stream);\nFinPara\nLanzar Closer(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Hold(name as string, stream as channel<integer>)\ndefine label as string <- name + \"-x\";\nswitch await stream.receive() do\nsome(value): write label;\nnone: write label;\nendSwitch\nendSubroutine\nsubroutine suspendable Closer(stream as channel<integer>)\nstream.close();\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ndefine mutable index as integer <- 0;\ntasks\nfor index <- 1 to 100 step 1 do\nspawn Hold(\"tk\", stream);\nendFor\nspawn Closer(stream);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "tk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\ntk-x\n",
    "terminacion": "completed"
  }
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
  "programas": {
    "es": "SubProceso Suspendible Produce(stream Como Canal<Cadena>, base Como Cadena)\nAguardar stream.Enviar(base + \"-1\");\nAguardar stream.Enviar(base + \"-2\");\nAguardar stream.Enviar(base + \"-3\");\nstream.Cerrar();\nFinSubProceso\nSubProceso Suspendible Consume(stream Como Canal<Cadena>)\nRepetir\nSegun Aguardar stream.Recibir() Hacer\nAlgo(text): Escribir text;\nNada: Salir;\nFinSegun\nHasta Que Falso\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Cadena> <- Canal(8);\nTareas\nLanzar Produce(stream, \"msg\");\nLanzar Consume(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Produce(stream as channel<string>, base as string)\nawait stream.send(base + \"-1\");\nawait stream.send(base + \"-2\");\nawait stream.send(base + \"-3\");\nstream.close();\nendSubroutine\nsubroutine suspendable Consume(stream as channel<string>)\nrepeat\nswitch await stream.receive() do\nsome(text): write text;\nnone: break;\nendSwitch\nuntil false\nendSubroutine\nalgorithm Main\ndefine stream as channel<string> <- channel(8);\ntasks\nspawn Produce(stream, \"msg\");\nspawn Consume(stream);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "msg-1\nmsg-2\nmsg-3\n",
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
    "es": "SubProceso Suspendible Run(stream Como Canal<Entero>)\nDefinir captured Como Cadena <- \"kept\" + \"-v\";\nDefinir callback Como SubProceso() Como Cadena <- SubProceso() Como Cadena\nRetornar captured;\nFinSubProceso;\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir callback();\nNada: Escribir callback();\nFinSegun\nFinSubProceso\nSubProceso Suspendible Closer(stream Como Canal<Entero>)\nstream.Cerrar();\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Run(stream);\nLanzar Closer(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Run(stream as channel<integer>)\ndefine captured as string <- \"kept\" + \"-v\";\ndefine callback as subroutine() as string <- subroutine() as string\nreturn captured;\nendSubroutine;\nswitch await stream.receive() do\nsome(value): write callback();\nnone: write callback();\nendSwitch\nendSubroutine\nsubroutine suspendable Closer(stream as channel<integer>)\nstream.close();\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Run(stream);\nspawn Closer(stream);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "kept-v\n",
    "terminacion": "completed"
  }
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
  "programas": {
    "es": "SubProceso Suspendible Hold(name Como Cadena, stream Como Canal<Entero>)\nDefinir label Como Cadena <- name + \"-y\";\nSegun Aguardar stream.Recibir() Hacer\nAlgo(value): Escribir label;\nNada: Escribir label;\nFinSegun\nFinSubProceso\nSubProceso Suspendible Closer(stream Como Canal<Entero>)\nstream.Cerrar();\nFinSubProceso\nAlgoritmo Main\nDefinir stream Como Canal<Entero> <- Canal(1);\nTareas\nLanzar Hold(\"ta\", stream);\nLanzar Hold(\"tb\", stream);\nLanzar Hold(\"tc\", stream);\nLanzar Closer(stream);\nFinTareas\nFinAlgoritmo\n",
    "en": "subroutine suspendable Hold(name as string, stream as channel<integer>)\ndefine label as string <- name + \"-y\";\nswitch await stream.receive() do\nsome(value): write label;\nnone: write label;\nendSwitch\nendSubroutine\nsubroutine suspendable Closer(stream as channel<integer>)\nstream.close();\nendSubroutine\nalgorithm Main\ndefine stream as channel<integer> <- channel(1);\ntasks\nspawn Hold(\"ta\", stream);\nspawn Hold(\"tb\", stream);\nspawn Hold(\"tc\", stream);\nspawn Closer(stream);\nendTasks\nendAlgorithm\n"
  },
  "origen": "derivado",
  "operacion": "execute",
  "espera": {
    "salida": "ta-y\ntb-y\ntc-y\n",
    "terminacion": "completed"
  }
}
```

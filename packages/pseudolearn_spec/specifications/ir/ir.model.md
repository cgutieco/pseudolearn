---
{
  "formato": "see/1",
  "id": "IR.MODEL",
  "titulo": "Modelo de la representación intermedia",
  "dominio": "ri",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine",
    "aot"
  ],
  "resumen": "Módulo, funciones, bloques, valores, tipos, clases de valor y celdas.",
  "depende_de": [
    {
      "id": "MEM.IDENTITY",
      "version": ">=0.1.0, <1.0.0",
      "tipo": "usa"
    },
    {
      "id": "ENG.EXEC.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Intermediate representation model",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Modelo de la representación intermedia

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Un módulo tiene nombre, vocabulario del programa, una tabla de clases y funciones. Hay una función por algoritmo principal, subprograma, método y constructor declarado, con espacios de nombres separados por prefijo: @main, @sub.<nombre>, @method.<Clase>.<método> y @ctor.<Clase>. Cada clase declara su superclase opcional y sus campos propios con tipo.",
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
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nclass C { valor: i64 }\nfunc @sub.inc(%0: cell<i64>) -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %1 = cell.load %0 @2:6-2:7\n  %2 = const.i64 1\n  %3 = int.add %1, %2 @2:6-2:11\n  cell.store %0, %3\n  stmt.exit @2:1-2:12\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @6:6-6:17\n  %1 = cell.field %0, valor\n  %2 = const.i64 0\n  cell.store %1, %2\n  call @sub.inc(%1) @7:1-7:9\n  return\n}\n"
}
```

```regla
{
  "id": "R2",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una función tiene parámetros tipados y bloques básicos; el primer bloque es la entrada y no tiene parámetros. Cada bloque declara parámetros tipados, una masa de sentencia y una secuencia de instrucciones que termina en exactamente un terminador. Los valores siguen asignación única estática: se definen una vez y sus usos están dominados por su definición; las variables del programa que cambian se representan con parámetros de bloque o con celdas.",
  "verificacion": [
    "C2"
  ]
}
```

```caso
{
  "id": "C2",
  "regla": "R2",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Los tipos son i64, f64, bool, char, str, unit, array<T, n>, obj<Clase> y cell<T>. La clase de valor escalar agrupa i64, f64, bool y char; la clase referencia agrupa str, array, obj y cell. unit no tiene valores. Cada valor tiene una clase conocida al traducir y nunca lleva etiqueta de tipo en ejecución.",
  "verificacion": [
    "C3"
  ]
}
```

```caso
{
  "id": "C3",
  "regla": "R3",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n"
}
```

```regla
{
  "id": "R4",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Una celda denota una ubicación: una variable local, un elemento de arreglo fijado una vez o un campo. Dos celdas de la misma ubicación son alias: una escritura por una es visible por la otra. El paso por referencia se representa con celdas.",
  "verificacion": [
    "C4"
  ]
}
```

```caso
{
  "id": "C4",
  "regla": "R4",
  "perfiles": [
    "es"
  ],
  "rigor": [
    "estricto"
  ],
  "origen": "derivado",
  "operacion": "ir",
  "espera": {
    "ri": {
      "aceptada": true
    }
  },
  "programa_ri": "module P es\nclass C { valor: i64 }\nfunc @sub.inc(%0: cell<i64>) -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %1 = cell.load %0 @2:6-2:7\n  %2 = const.i64 1\n  %3 = int.add %1, %2 @2:6-2:11\n  cell.store %0, %3\n  stmt.exit @2:1-2:12\n  return\n}\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = object.new C @6:6-6:17\n  %1 = cell.field %0, valor\n  %2 = const.i64 0\n  cell.store %1, %2\n  call @sub.inc(%1) @7:1-7:9\n  return\n}\n"
}
```

## Perfil de los casos

Los casos ir no dependen del vocabulario ni del rigor del programa fuente; declaran un perfil y un rigor únicos porque el texto de la RI ya fija el vocabulario en la cabecera del módulo.

---
{
  "formato": "see/1",
  "id": "IR.TEXT-FORMAT",
  "titulo": "Formato textual de la RI",
  "dominio": "ri",
  "estado": "estable",
  "version": "1.0.0",
  "duenos": [
    "responsable-motor"
  ],
  "sujetos": [
    "engine"
  ],
  "resumen": "Gramática del texto de la RI e ida y vuelta exacta.",
  "depende_de": [
    {
      "id": "IR.MODEL",
      "version": ">=1.0.0, <2.0.0",
      "tipo": "usa"
    }
  ],
  "titulo_en": "Intermediate representation text format",
  "revisado_por": [
    "revision-independiente-automatizada-r9"
  ]
}
---

# Formato textual de la RI

```definicion
{
  "id": "D1",
  "termino": "gramática textual",
  "texto": "module = 'module' nombre vocabulario NL {clase} {función}. clase = 'class' nombre [':' nombre] '{' [campo {',' campo}] '}' NL; campo = nombre ':' tipo. función = 'func' @nombre '(' [valor ':' tipo {',' valor ':' tipo}] ')' '->' tipo '{' NL bloque {bloque} '}' NL. bloque = b<n> '(' [valor ':' tipo {',' ...}] ')' 'mass' entero ':' NL {instrucción NL}. instrucción = [valor '='] operación [operando {',' operando}] ['@' línea ':' columna '-' línea ':' columna]. valor = %<n>. Un operando es un valor, un destino b<n>(valores), una función @nombre(valores), un literal, un tipo, un predicado o un nombre de campo, clase o método. Los literales de cadena usan comillas dobles con los escapes \\n, \\t, \\r, \\\\ y \\\"."
}
```

```regla
{
  "id": "R1",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "El texto de la RI sigue la gramática D1, en UTF-8, con líneas terminadas en LF. Se admiten espacios y tabulaciones extra entre símbolos y líneas en blanco; no hay comentarios.",
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
  "texto": "La forma canónica separa los símbolos con un espacio, sangra las instrucciones con dos espacios, no tiene líneas en blanco ni espacios finales, numera los valores desde %0 por orden de definición dentro de cada función, empezando por los parámetros, y los bloques desde b0 por orden de aparición.",
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
      "reimpresion": "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb3() mass 1:\n  stmt.enter @2:1-2:12\n  %7   =  const.i64   1\n  out.write %7, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n\n"
}
```

```regla
{
  "id": "R3",
  "fuerza": "DEBE",
  "clase": "semantica",
  "texto": "Imprimir la RI de un texto canónico reproduce exactamente ese texto; imprimir la RI de un texto aceptado no canónico produce su forma canónica, que es estable.",
  "verificacion": [
    "C3",
    "C4"
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
      "reimpresion": "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 1:\n  stmt.enter @2:1-2:12\n  %0 = const.i64 1\n  out.write %0, newline @2:1-2:12\n  stmt.exit @2:1-2:12\n  return\n}\n"
}
```

```caso
{
  "id": "C4",
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
      "reimpresion": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n"
    }
  },
  "programa_ri": "module P es\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 0\n  jump b1(%0)\nb1(%1: i64) mass 1:\n  stmt.enter @4:1-6:12\n  %2 = const.i64 3\n  %3 = int.cmp lt, %1, %2\n  decide.bool %3 @4:10-4:15\n  branch %3, b2(), b3()\nb2() mass 0:\n  %4 = const.i64 1\n  %5 = int.add %1, %4 @5:6-5:11\n  jump b1(%5)\nb3() mass 0:\n  stmt.exit @4:1-6:12\n  return\n}\n"
}
```

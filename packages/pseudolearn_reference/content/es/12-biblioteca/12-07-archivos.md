---
id: biblioteca.archivos
numero: "12.7"
tipo: concepto
titulo: Archivos y carpetas
anclas: [LIB.IO#R1, LIB.IO#R2, LIB.IO#R3, LIB.IO#R4, LIB.IO#R5, LIB.IO#R6, LIB.IO#R7, LIB.IO#R8, LIB.IO#R9, LIB.IO#R10, LIB.IO#R11, LIB.IO#R12, LIB.IO#R13, LIB.IO#R14, LIB.IO#R15, LIB.IO#R16]
fichas: [construction.bytes_io, construction.environment_date_time]
diagnosticos: [incompatiblePropagationType]
terminos: [archivo, directorio, ErrorES]
---

::: frase
Para leer o escribir archivos se pide la capacidad de una carpeta, se abre el archivo con ella y cada operación devuelve un `Resultado` que puede traer un `ErrorES`.
:::

## Cómo funciona {#funciona}

El camino es siempre el mismo:

1. `SolicitarDirectorio(ruta)` da una `DirectorioCap` para esa carpeta.
2. `carpeta.Abrir(nombre, modo)` da una `ArchivoCap`. Con `"lectura"` solo se lee; `"escritura"` crea o vacía el archivo; `"lectura_escritura"` lo crea si falta y conserva lo que tenía.
3. `LeerTexto`, `EscribirTexto`, `AgregarTexto` y sus versiones con `Bytes` hacen el trabajo.

Cada paso puede fallar, así que devuelve `Resultado<…, ErrorES>`. Con `Propagar`, un fallo se devuelve a quien llamó sin escribir el `Segun` a mano.

```figura id=archivo-capas
pie: De la carpeta al archivo y del archivo al contenido. Cada flecha es una operación que puede fallar con un `ErrorES`.
```

```programa id=nota titulo="Guardar y releer una nota" ejecutar
SubProceso GuardarNota() Como Resultado<Cadena, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("nota.txt", "escritura");
  Definir cantidad Como Entero <- Propagar archivo.EscribirTexto("Comprar pan");
  Escribir "Bytes: ", cantidad;
  Definir lector Como ArchivoCap <- Propagar carpeta.Abrir("nota.txt", "lectura");
  Retornar lector.LeerTexto();
FinSubProceso

Algoritmo Notas
  Segun GuardarNota() Hacer
    Exito(texto): Escribir texto;
    Error(problema): Escribir problema.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{}
```

```salida
Bytes: 11
Comprar pan
```

Un archivo que no existe no detiene el programa: llega como `Error` cuyo `Codigo` es `"no_encontrado"`, y el programa decide qué hacer.

```programa id=no-existe titulo="Un archivo que no está" ejecutar
SubProceso LeerConfig() Como Resultado<Cadena, ErrorES>
  Definir carpeta Como DirectorioCap <- Propagar SolicitarDirectorio(".");
  Definir archivo Como ArchivoCap <- Propagar carpeta.Abrir("config.txt", "lectura");
  Retornar archivo.LeerTexto();
FinSubProceso

Algoritmo Config
  Segun LeerConfig() Hacer
    Exito(texto): Escribir texto;
    Error(problema): Escribir "No se pudo leer: ", problema.Codigo;
  FinSegun
FinAlgoritmo
```

```anfitrion
{}
```

```salida
No se pudo leer: no_encontrado
```

Las carpetas también se consultan y se modifican: `Existe`, `EsDirectorio`, `Listar` (ordenado), `CrearDirectorio`, `Renombrar` y `Borrar` (nunca recursivo). `Subdirectorio` da una capacidad confinada que no puede salir de su carpeta.

::: limite
- El texto se lee y se escribe en UTF-8 estricto: un contenido inválido es `Utf8Invalido`, nunca se sustituye en silencio.
- `ErrorES` tiene variantes fijas —`NoEncontrado`, `PermisoDenegado`, `YaExiste`, `RutaInvalida`, `CapacidadCerrada` y otras— y su `Codigo` es un texto estable como `"no_encontrado"`.
- Una limpieza con `Diferir` que cierra un archivo nunca oculta el error principal.
:::

::: resumen
- Carpeta, archivo y contenido: tres pasos, cada uno falible.
- Los fallos llegan como `ErrorES` dentro de un `Resultado`.
- `Propagar` devuelve el error a quien llamó.
:::

::: vease
- [Efectos y capacidades](#tareas.efectos)
- [Opcional y Resultado](#tipos.opcional-resultado)
- [Bytes](#tipos.bytes)
- [JSON](#biblioteca.json)
:::

---
id: tareas.efectos
numero: "11.4"
tipo: concepto
titulo: Efectos y capacidades
anclas: [LANG.CAPABILITY.MODEL#R1, LANG.CAPABILITY.MODEL#R2, LANG.CAPABILITY.MODEL#R3, LANG.CAPABILITY.MODEL#R4]
fichas: [construction.capabilities, help.pg501.request_console, help.pg501.console_write, help.pgs07.console_set_exit_code, help.pgs07.console_write_error]
diagnosticos: [incompatiblePropagationType]
terminos: [capacidad, efecto, anfitrión]
---

::: frase
Para tocar el mundo exterior —la consola, los archivos, el reloj, la red— un programa pide una **capacidad**: una llave que da acceso a una sola cosa.
:::

## Cómo funciona {#funciona}

Una **capacidad** es un valor opaco que representa un permiso concreto. Hay una familia por recurso:

| Capacidad | Para qué |
|---|---|
| `Consola` | escribir en la salida y en la salida de errores, fijar el código de salida |
| `Argumentos` | leer los argumentos del programa |
| `Entorno` | leer variables de entorno |
| `DirectorioCap`, `ArchivoCap` | carpetas y archivos |
| `Reloj`, `Temporizador` | la hora y las esperas |
| `RedCap` | peticiones HTTP |

Se piden con una función `Solicitar…` y devuelven un `Resultado`: el anfitrión concede la familia si la admite, o devuelve un `ErrorES`. Con `Propagar` el error se devuelve sin más a quien llamó.

```figura id=capacidades-llaves
pie: El programa no toca el anfitrión directamente: cada recurso se usa a través de su llave, que el anfitrión entregó al pedirla.
```

```programa id=consola titulo="Avisar por la salida de errores" ejecutar
SubProceso Avisar() Como Resultado<Entero, ErrorES>
  Definir consola Como Consola <- Propagar SolicitarConsola();
  Descartar consola.EscribirError("Falta el nombre\n");
  Retornar consola.EstablecerCodigoSalida(2);
FinSubProceso

Algoritmo Revisar
  Escribir "Revisando";
  Segun Avisar() Hacer
    Exito(codigo): Escribir "Código de salida: ", codigo;
    Error(problema): Escribir problema.Codigo;
  FinSegun
FinAlgoritmo
```

```salida
Revisando
Falta el nombre
Código de salida: 2
```

Las capacidades no se pueden fabricar ni manipular: cada una lleva una ranura, una generación y unos derechos. Se pueden **restringir** —un subdirectorio, un solo origen web— pero nunca ampliar. Cerrar una capacidad la invalida: usarla después da el error `CapacidadCerrada`.

::: limite
- Los efectos solo se hacen desde `SubProceso` o el algoritmo, nunca desde una [`Funcion`](#subprogramas.pureza).
- El análisis no consulta al anfitrión: qué familias admite se descubre al ejecutar.
:::

::: resumen
- Una capacidad es la llave de un recurso exterior.
- Se pide con `Solicitar…` y llega como `Resultado`.
- Se puede restringir pero no ampliar; cerrada, deja de servir.
:::

::: vease
- [Archivos](#biblioteca.archivos)
- [Tiempo](#biblioteca.tiempo)
- [HTTP](#biblioteca.http)
- [Pureza](#subprogramas.pureza)
:::

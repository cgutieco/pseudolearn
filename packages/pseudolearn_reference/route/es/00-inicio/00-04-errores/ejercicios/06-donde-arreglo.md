---
id: inicio.errores.donde-arreglo
leccion: inicio.errores
tipo: explicar
nivel: semilla
obligatorio: false
titulo: ¿Dónde se arregla?
---

::: enunciado
El motor muestra este diagnóstico para la versión A de la calculadora de propinas. ¿Dónde se arregla?
:::

```programa rol=objeto id=diagnostico
Algoritmo Propina
  Definir cuenta Como Entero;
  Definir amigos Como Entero;
  Escribir "¿Cuánto es la cuenta?";
  Leer cuenta;
  Escribir "¿Cuántos amigos pagan?"
  Leer amigos;
FinAlgoritmo
```

```diagnosticos
missingStatementTerminator
```

```opciones
- [x] En la línea y la columna que indica el diagnóstico. | El diagnóstico apunta al final de la línea 6, donde falta el punto y coma.
- [ ] En la primera línea del programa. | El sobre del programa está bien escrito.
- [ ] En cualquier `Escribir`. | Solo uno de ellos está mal terminado.
```

::: explicacion
Un diagnóstico dice dónde mirar. A veces el error está justo antes del lugar señalado, pero nunca hay que revisar el programa entero al azar.
:::

---
id: inicio.errores.se-detiene
leccion: inicio.errores
tipo: predecir
nivel: semilla
obligatorio: false
titulo: ¿Hasta dónde llega?
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que alcanza a mostrar este programa.
:::

```programa rol=objeto id=prediccion termina=failed
Algoritmo SeDetiene
  Definir divisor Como Entero <- 0;
  Escribir "Hola";
  Escribir 10 div divisor;
  Escribir "Chau";
FinAlgoritmo
```

```salida
Hola
```

```diagnosticos
divisionByZero
```

::: explicacion
La primera instrucción muestra `Hola`. La segunda intenta dividir entre 0 y el programa se detiene ahí: la tercera nunca se ejecuta.
:::

---
id: procedimental.fallos.segun-resultado
leccion: procedimental.fallos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Éxito o motivo
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
SubProceso DividirSeguro(a Como Entero, b Como Entero) Como Resultado<Entero, Cadena>
  Si b = 0 Entonces
    Retornar Error("No se puede dividir entre 0");
  FinSi
  Retornar Exito(a div b);
FinSubProceso

Algoritmo Division
  Segun DividirSeguro(9, 3) Hacer
    Exito(cociente): Escribir cociente;
    Error(motivo): Escribir motivo;
  FinSegun
  Segun DividirSeguro(1, 0) Hacer
    Exito(cociente): Escribir cociente;
    Error(motivo): Escribir motivo;
  FinSegun
FinAlgoritmo
```

```salida
3
No se puede dividir entre 0
```

::: explicacion
La primera llamada retorna `Exito(3)` y el `Segun` muestra el cociente. La segunda retorna `Error` con el motivo, y el `Segun` muestra el motivo. El programa no se detiene en ninguna.
:::

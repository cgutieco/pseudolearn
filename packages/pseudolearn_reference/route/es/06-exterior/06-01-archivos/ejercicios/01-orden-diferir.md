---
id: exterior.archivos.orden-diferir
leccion: exterior.archivos
tipo: predecir
nivel: semilla
obligatorio: true
titulo: Tres limpiezas
---

::: enunciado
Sin ejecutarlo, escribe exactamente lo que muestra este programa.
:::

```programa rol=objeto id=prediccion
Algoritmo OrdenDiferir
  Diferir
    Escribir "1";
  FinDiferir
  Diferir
    Escribir "2";
  FinDiferir
  Diferir
    Escribir "3";
  FinDiferir
  Escribir "fin";
FinAlgoritmo
```

```salida
fin
3
2
1
```

::: explicacion
Las órdenes diferidas se guardan y se ejecutan al salir, en orden inverso: la última que se escribió es la primera que se ejecuta. Por eso «fin» sale primero.
:::

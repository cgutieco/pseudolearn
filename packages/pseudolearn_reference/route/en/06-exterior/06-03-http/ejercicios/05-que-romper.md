---
id: exterior.http.que-romper
leccion: exterior.http
tipo: romperlo
nivel: brote
obligatorio: false
titulo: Only 200
---

::: enunciado
This program says «bien» or «problema» according to the code of an answer. With 200 and with 503 it is right. Find a code it gets wrong.
:::

```programa rol=defectuoso
```

```programa rol=referencia
```

```casos
```

```rompe
```

::: pistas
1. Which codes say it went fine?
2. All those from 200 to 299, not only 200.
3. This program only accepts exactly 200.
4. With 201 it says «problema» and it went fine. Close with the variant.
:::

::: variante
Is there any code that this program marks as fine and is not?
:::

::: docentes
Any code between 201 and 299 breaks it. The variant has a negative answer: the program only says «bien» with 200, which is fine.
:::

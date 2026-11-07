---
id: procedimental.dividir.propina-partes
leccion: procedimental.dividir
tipo: modificar
nivel: brote
obligatorio: true
titulo: The tip in parts
---

::: enunciado
This program computes how much each friend pays, with the tip included. Rewrite it in two named pieces: one that computes the total with the tip and another that computes each one's share, without changing what it shows.
:::

::: restriccion
Use a subprogram `TotalConPropina` that receives the bill and another `ParteDeCadaUno` that receives the total and the friends.
:::

```programa rol=inicial
```

```programa rol=referencia
```

```casos
```

```aserciones
- declara-subprograma | TotalConPropina | 1 | The subprogram TotalConPropina, which receives the bill, is missing.
- declara-subprograma | ParteDeCadaUno | 2 | The subprogram ParteDeCadaUno, which receives the total and the friends, is missing.
```

::: pistas
1. Which sum does the program do in a single line? Into which two parts can it be cut?
2. Look at the report card in [the lesson](ruta:procedimental.dividir): each sum has its subprogram.
3. One receives the bill and returns the total; the other receives the total and the friends and returns the share.
4. `ParteDeCadaUno(TotalConPropina(cuenta), amigos)` replaces the long sum. Close with the variant.
:::

::: variante
Change the tip to 15 %. How many lines did you touch?
:::

::: docentes
The cases are those of the original calculator: what it shows does not change. The assertions check both names and how many parameters each one receives.
:::

---
id: lexico.textos
numero: "2.7"
tipo: concepto
titulo: Literales de texto y de carácter
anclas: [LANG.LEXICAL.TEXT-LITERAL#R1, LANG.LEXICAL.CHARACTER-LITERAL#R1]
diagnosticos: [invalidEscapeSequence, unterminatedString]
terminos: [cadena, carácter, escape]
---

::: frase
Un texto va entre comillas dobles o simples; si contiene exactamente un carácter es un `Caracter`, y en cualquier otro caso es una `Cadena`.
:::

## Cómo funciona {#funciona}

Los textos se escriben entre comillas. Da igual usar comillas dobles `"…"` o simples `'…'`: significan lo mismo. Lo que decide el tipo es cuántos caracteres hay dentro:

- Exactamente uno: es un **carácter** (`Caracter`).
- Ninguno, o más de uno: es una **cadena** (`Cadena`).

```figura id=cadena-caracter
pie: El número de caracteres entre comillas decide el tipo, no la clase de comillas.
```

Dentro de un texto, la barra invertida inicia una **secuencia de escape** para escribir caracteres especiales:

| Escape | Significado |
|---|---|
| `\n` | salto de línea |
| `\t` | tabulación |
| `\r` | retorno de carro |
| `\\` | una barra invertida |
| `\"` | comilla doble |
| `\'` | comilla simple |

```programa id=escapes titulo="Comillas y escapes" ejecutar
Proceso Escapes
  Definir inicial Como Caracter <- 'A';
  Escribir "Primera línea\nSegunda línea";
  Escribir "Dijo: \"hola\"";
  Escribir 'Comillas simples', " y la inicial ", inicial;
FinProceso
```

```salida
Primera línea
Segunda línea
Dijo: "hola"
Comillas simples y la inicial A
```

::: limite
Un carácter es un único punto de código de Unicode, también los que están fuera del plano básico como un emoji simple. Un grafema compuesto por varios puntos de código es una cadena. El texto se conserva tal cual, sin normalizar. Un texto no puede ocupar varias líneas: para un salto de línea se usa `\n`.
:::

::: errores
Un escape que no existe y unas comillas sin cerrar se detectan antes de ejecutar:

```programa id=mal-escape titulo="Un escape inventado" ejecutar
Proceso MalEscape
  Escribir "a\q";
FinProceso
```

```diagnosticos
invalidEscapeSequence
```

```programa id=sin-cerrar titulo="Comillas sin cerrar" ejecutar
Proceso SinCerrar
  Escribir "hola;
FinProceso
```

```diagnosticos
unterminatedString
```
:::

::: resumen
- Comillas dobles o simples: significan lo mismo.
- Un carácter dentro: `Caracter`. Cero o varios: `Cadena`.
- Escapes: `\n`, `\t`, `\r`, `\\`, `\"` y `\'`.
:::

::: vease
- [Tipos primitivos](#tipos.primitivos)
- [Texto](#biblioteca.texto)
:::

---
id: programas.modulos
numero: "8.2"
tipo: concepto
titulo: Módulos y proyectos
anclas: [LANG.MODULE.MODEL#R1, LANG.MODULE.MODEL#R2, LANG.MODULE.MODEL#R3, LANG.MODULE.MODEL#R4, LANG.MODULE.IMPORT#R1, LANG.MODULE.IMPORT#R2, LANG.MODULE.IMPORT#R3, LANG.MODULE.IMPORT#R4, LANG.MODULE.IMPORT#R5, LANG.MODULE.IMPORT#R6, LANG.MODULE.IMPORT#R7, LANG.MODULE.IMPORT#R8]
fichas: [help.module-import, help.module-export, help.visibility, help.pgl02.public_signature, help.pgl02.type_import, help.pgl02.type_visibility]
diagnosticos: [moduleSyntaxOutsideProject, unresolvedModule, unresolvedImport, privateImport, privateReexport, importNameCollision, ambiguousReexport, importCycle, reservedImportNeedsAlias, privateTypeInPublicSignature, expectedModuleName, entryMissingAlgorithm, algorithmOutsideEntry]
terminos: [módulo, paquete, proyecto, importación, visibilidad]
---

::: frase
Cuando un programa crece, se reparte en archivos: cada archivo es un **módulo**, y un módulo usa lo que otro hace **público** importándolo.
:::

## Cómo funciona {#funciona}

Un **proyecto** agrupa **paquetes**. Cada paquete tiene un nombre y una carpeta raíz, y cada archivo dentro de esa raíz es un módulo. El nombre del módulo es su ruta dentro de la raíz con puntos en lugar de barras.

```figura id=paquete-modulos
pie: Un paquete con dos módulos. `principal` importa `formas.geometria` y usa su subprograma público.
```

Un paquete puede ser:

- **de aplicación**: declara una o varias **entradas**, módulos con un algoritmo; al ejecutar se elige una;
- **de biblioteca**: no tiene entradas ni algoritmos; solo ofrece unidades a otros paquetes.

Solo el módulo de entrada contiene un algoritmo. Los demás contienen subprogramas, clases y el resto de unidades.

Los fallos de la configuración del proyecto —una entrada que no existe, un módulo fuera de toda raíz, un ciclo entre paquetes— no son diagnósticos del código: son **errores de proyecto**, con un código estable como `entryNotFound` o `packageCycle` y la ruta afectada.

## Visibilidad {#visibilidad}

Toda unidad de nivel superior es **privada** de su módulo, salvo que lleve el prefijo `Publico`. Solo lo público se puede importar.

```programa id=geometria titulo="formas/geometria.psl"
Publico SubProceso AreaCirculo(radio Como Real) Como Real
  Retornar 3.14159 * radio * radio;
FinSubProceso

SubProceso Ayudante()
FinSubProceso
```

## Importar {#importar}

`Importar` nombra un módulo o un símbolo por su ruta, empezando por el nombre del paquete. Un módulo importado se usa con su último segmento, o con el alias de `Como`:

```programa id=principal-modulos titulo="principal.psl"
Importar tienda.formas.geometria;

Algoritmo Principal
  Escribir geometria.AreaCirculo(2.0);
FinAlgoritmo
```

Con `Exportar`, un módulo vuelve a ofrecer como propio un símbolo público de otro, sin crear un nombre local. Importar y exportar **no ejecutan nada**: un import que no se usa no cambia el resultado.

::: limite
- No hay comodines: después de un punto de la ruta va siempre un nombre.
- El grafo de importaciones no puede tener ciclos: un ciclo es `importCycle` y no se analiza ningún cuerpo.
- Dos nombres locales iguales con orígenes distintos son `importNameCollision`.
- Una firma pública no puede nombrar un tipo privado del módulo: `privateTypeInPublicSignature`.
:::

::: errores
En un texto suelto, sin proyecto, `Importar` y `Publico` no tienen sentido:

```programa id=importar-suelto titulo="Importar fuera de un proyecto" ejecutar
Importar geometria;
Algoritmo Suelto
  Escribir 1;
FinAlgoritmo
```

```diagnosticos
moduleSyntaxOutsideProject
```
:::

::: resumen
- Cada archivo es un módulo; los módulos forman paquetes y los paquetes, un proyecto.
- Solo lo marcado `Publico` se puede importar.
- `Importar` usa rutas que empiezan por el paquete; `Como` da un alias.
- No se admiten ciclos de importación.
:::

::: vease
- [Estructura de un programa](#programas.estructura)
- [Declarar subprogramas](#subprogramas.declaracion)
:::

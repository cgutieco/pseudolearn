---
id: programas.modulos
numero: "8.2"
tipo: concepto
titulo: Modules and projects
anclas: [LANG.MODULE.MODEL#R1, LANG.MODULE.MODEL#R2, LANG.MODULE.MODEL#R3, LANG.MODULE.MODEL#R4, LANG.MODULE.IMPORT#R1, LANG.MODULE.IMPORT#R2, LANG.MODULE.IMPORT#R3, LANG.MODULE.IMPORT#R4, LANG.MODULE.IMPORT#R5, LANG.MODULE.IMPORT#R6, LANG.MODULE.IMPORT#R7, LANG.MODULE.IMPORT#R8]
fichas: [help.module-import, help.module-export, help.visibility, help.pgl02.public_signature, help.pgl02.type_import, help.pgl02.type_visibility]
diagnosticos: [moduleSyntaxOutsideProject, unresolvedModule, unresolvedImport, privateImport, privateReexport, importNameCollision, ambiguousReexport, importCycle, reservedImportNeedsAlias, privateTypeInPublicSignature, expectedModuleName, entryMissingAlgorithm, algorithmOutsideEntry]
terminos: [module, package, project, import, visibility]
---

::: frase
When a program grows, it is split into files: every file is a **module**, and a module uses what another one makes **public** by importing it.
:::

## How it works {#funciona}

A **project** groups **packages**. Every package has a name and a root folder, and every file inside that root is a module. The module's name is its path inside the root with dots instead of slashes.

```figura id=paquete-modulos
pie: A package with two modules. `principal` imports `formas.geometria` and uses its public subprogram.
```

A package can be:

- an **application**: it declares one or more **entries**, modules with an algorithm; one is chosen when running;
- a **library**: it has no entries or algorithms; it only offers units to other packages.

Only the entry module contains an algorithm. The others contain subprograms, classes and the remaining units.

Failures in the project configuration —an entry that does not exist, a module outside every root, a cycle between packages— are not code diagnostics: they are **project errors**, with a stable code such as `entryNotFound` or `packageCycle` and the affected path.

## Visibility {#visibilidad}

Every top-level unit is **private** to its module unless it carries the `Public` prefix. Only what is public can be imported.

```programa id=geometria titulo="formas/geometria.psl"
```

## Importing {#importar}

`Import` names a module or a symbol by its path, starting with the package name. An imported module is used through its last segment, or through the alias given by `As`:

```programa id=principal-modulos titulo="principal.psl"
```

With `Export`, a module offers a public symbol of another module as its own, without creating a local name. Importing and exporting **run nothing**: an unused import does not change the result.

::: limite
- There are no wildcards: a name always follows a dot in the path.
- The import graph cannot have cycles: a cycle is `importCycle` and no body is analysed.
- Two equal local names with different origins are `importNameCollision`.
- A public signature cannot name a private type of the module: `privateTypeInPublicSignature`.
:::

::: errores
In a loose text, without a project, `Import` and `Public` make no sense:

```programa id=importar-suelto titulo="Import outside a project"
```
:::

::: resumen
- Every file is a module; modules form packages and packages, a project.
- Only what is marked `Public` can be imported.
- `Import` uses paths that start with the package; `As` gives an alias.
- Import cycles are not allowed.
:::

::: vease
- [Structure of a program](#programas.estructura)
- [Declaring subprograms](#subprogramas.declaracion)
:::

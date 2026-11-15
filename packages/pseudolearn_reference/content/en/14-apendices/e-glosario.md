---
id: apendice.glosario
numero: "E.1"
tipo: apendice
titulo: Glossary
---

The book's technical terms with a short definition and the section where they are explained.

| Term | Definition |
|---|---|
| algorithm | The main unit of a program; every text has exactly one. [Structure](#programas.estructura) |
| argument | The value passed in a call. [Parameters](#subprogramas.parametros) |
| assignment | Storing a new value in a place with `<-`. [Assignment](#declaraciones.asignacion) |
| base case | The case of a recursion that is solved without calling itself again. [Recursion](#subprogramas.recursion) |
| capability | An opaque key that gives access to an outside resource. [Effects and capabilities](#tareas.efectos) |
| class | A type that groups attributes and methods; its values are objects. [Classes](#objetos.clase) |
| constant | A name for a fixed value computed during analysis. [Constants](#declaraciones.constante) |
| designator | An expression that names a place to store into: variable, cell or attribute. [Designators](#declaraciones.designadores) |
| diagnostic | An engine notice with a code, class, severity and position. [Anatomy](#diagnosticos.anatomia) |
| dispatch | Choosing the method by the object's real class. [Inheritance](#objetos.herencia) |
| effect | Any action towards the outside of the program: writing, reading, opening a file. [Effect order](#motor.efectos) |
| expression | A combination of values and operators that is computed. [Arithmetic](#expresiones.aritmeticos) |
| frame | The space of its own every call has for its parameters and variables. [Calls](#subprogramas.llamada) |
| handle | The `Task` value that keeps a spawned task to wait for its result. [Task scopes](#tareas.ambitos) |
| heap | The memory where objects, arrays and texts created at run time live. [Memory](#motor.memoria) |
| host | Whoever runs the program —the app, the terminal or an executable— and gives it input, output and capabilities. [Effects](#tareas.efectos) |
| identity | An object's or array's creation number; it never changes and is never reused. [Copies and identity](#objetos.copia) |
| interface | A list of signatures a class promises to fulfil. [Interfaces](#objetos.interfaces) |
| intermediate representation | The form of simple instructions the engine translates the program into. [Layers](#motor.capas) |
| module | A file in a project. [Modules](#programas.modulos) |
| object | A class-typed value, created with `New`. [Constructors](#objetos.constructor) |
| pass by reference | Passing the variable itself, not a copy. [By reference](#subprogramas.referencia) |
| precedence | The order in which operators group. [Precedence](#expresiones.precedencia) |
| profile | The language of the program's words: Spanish or English. [Profiles](#lectura.perfiles) |
| pure function | A `Function`, which only computes and has no effects. [Purity](#subprogramas.pureza) |
| receiver | The object a method is called on, named `This` inside it. [Methods](#objetos.metodos) |
| scope | The stretch of text where a name exists, from its declaration to the end of its block. [Scopes](#subprogramas.ambito) |
| severity | A diagnostic's consequence: error, warning or information. [Severity](#diagnosticos.severidad) |
| short circuit | Leaving the right side of `And` or `Or` uncomputed when the left side already decides. [Logical](#expresiones.logicos) |
| suspendible | A unit that can pause at `Await`. [Suspendible units](#tareas.suspendible) |
| tape | The record of a run's effects, which allows replaying it. [Effects and tape](#motor.efectos) |
| task | A run that progresses alongside others inside a `Tasks` scope. [Task scopes](#tareas.ambitos) |
| trace | The list of a run's events, step by step. [Observing execution](#motor.observacion) |
| trap | A failure during execution that stops the program. [Errors](#vision.errores) |
| variable | A name bound to a place in memory whose value can change. [Define](#declaraciones.definir) |

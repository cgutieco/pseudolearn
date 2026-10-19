use pseudolearn_lexicon::{KeywordKind, Profile};

const GENERIC: (&str, &str) = ("Palabra clave del lenguaje.", "Language keyword.");

const DESCRIPTIONS: &[(KeywordKind, &str, &str)] = &[
    (
        KeywordKind::Algorithm,
        "Inicia el algoritmo principal.",
        "Starts the main algorithm.",
    ),
    (
        KeywordKind::EndAlgorithm,
        "Cierra el algoritmo principal.",
        "Ends the main algorithm.",
    ),
    (
        KeywordKind::Subroutine,
        "Declara un subproceso o una funcion.",
        "Declares a subroutine or a function.",
    ),
    (
        KeywordKind::EndSubroutine,
        "Cierra un subproceso.",
        "Ends a subroutine.",
    ),
    (
        KeywordKind::ClassKeyword,
        "Declara una clase.",
        "Declares a class.",
    ),
    (KeywordKind::EndClass, "Cierra una clase.", "Ends a class."),
    (
        KeywordKind::Method,
        "Declara un metodo de la clase.",
        "Declares a class method.",
    ),
    (
        KeywordKind::EndMethod,
        "Cierra un metodo.",
        "Ends a method.",
    ),
    (
        KeywordKind::Declare,
        "Declara variables con su tipo.",
        "Declares typed variables.",
    ),
    (
        KeywordKind::Dimension,
        "Declara un arreglo.",
        "Declares an array.",
    ),
    (
        KeywordKind::Write,
        "Escribe valores en la salida.",
        "Writes values to the output.",
    ),
    (
        KeywordKind::Read,
        "Lee valores de la entrada.",
        "Reads values from the input.",
    ),
    (
        KeywordKind::IfKeyword,
        "Ejecuta segun una condicion.",
        "Branches on a condition.",
    ),
    (
        KeywordKind::ElseKeyword,
        "Rama alternativa de la condicion.",
        "Alternative branch.",
    ),
    (
        KeywordKind::EndIf,
        "Cierra una condicion.",
        "Ends a conditional.",
    ),
    (
        KeywordKind::WhileKeyword,
        "Repite mientras la condicion sea verdadera.",
        "Repeats while the condition holds.",
    ),
    (
        KeywordKind::EndWhile,
        "Cierra un ciclo Mientras.",
        "Ends a While loop.",
    ),
    (
        KeywordKind::ForKeyword,
        "Repite con un contador.",
        "Repeats with a counter.",
    ),
    (
        KeywordKind::EndFor,
        "Cierra un ciclo Para.",
        "Ends a For loop.",
    ),
    (
        KeywordKind::Repeat,
        "Repite hasta que la condicion sea verdadera.",
        "Repeats until the condition holds.",
    ),
    (
        KeywordKind::Until,
        "Condicion de salida del ciclo Repetir.",
        "Exit condition of Repeat.",
    ),
    (
        KeywordKind::SwitchKeyword,
        "Selecciona una rama por valor.",
        "Selects a branch by value.",
    ),
    (
        KeywordKind::EndSwitch,
        "Cierra una seleccion.",
        "Ends a switch.",
    ),
    (
        KeywordKind::DefaultCase,
        "Rama por defecto de la seleccion.",
        "Default branch.",
    ),
    (
        KeywordKind::ReturnKeyword,
        "Devuelve un valor.",
        "Returns a value.",
    ),
    (
        KeywordKind::NewInstance,
        "Crea un objeto de una clase.",
        "Creates an object.",
    ),
    (
        KeywordKind::ThisObject,
        "Objeto actual.",
        "The current object.",
    ),
    (
        KeywordKind::ByValue,
        "Paso de parametro por valor.",
        "Pass by value.",
    ),
    (
        KeywordKind::ByReference,
        "Paso de parametro por referencia.",
        "Pass by reference.",
    ),
];

pub fn keyword_description(kind: KeywordKind, profile: Profile) -> &'static str {
    let (spanish, english) = DESCRIPTIONS
        .iter()
        .find(|entry| entry.0 == kind)
        .map_or(GENERIC, |entry| (entry.1, entry.2));
    match profile {
        Profile::Spanish => spanish,
        Profile::English => english,
    }
}

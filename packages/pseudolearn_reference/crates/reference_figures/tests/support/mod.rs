use reference_figures::FigureContext;
use std::collections::BTreeMap;

pub fn strings() -> BTreeMap<String, String> {
    [
        ("titulo", "Una caja"),
        ("descripcion", "Una caja con su nombre"),
        ("nombre", "edad"),
    ]
    .into_iter()
    .map(|(key, value)| (key.to_owned(), value.to_owned()))
    .collect()
}

pub fn lexeme(identity: &str) -> Option<String> {
    (identity == "ifKeyword").then(|| "Si".to_owned())
}

pub fn code(fragment: &str) -> String {
    fragment.replace("Escribir", "Write")
}

pub fn context<'context>(strings: &'context BTreeMap<String, String>) -> FigureContext<'context> {
    FigureContext {
        id: "prueba",
        strings,
        lexeme: &lexeme,
        code: &code,
    }
}

use reference_model::{ExerciseDocument, LessonDocument, TermDefinition};
use std::collections::BTreeMap;

fn read(relative: &str) -> String {
    let path = format!(
        "{}/../../fixtures/route/{relative}",
        env!("CARGO_MANIFEST_DIR")
    );
    std::fs::read_to_string(&path).unwrap_or_default()
}

pub fn lesson(relative: &str) -> LessonDocument {
    lesson_text(relative, &read(relative))
}

pub fn lesson_text(relative: &str, text: &str) -> LessonDocument {
    let parsed = reference_format::parse_lesson(relative, text);
    assert!(parsed.is_ok(), "{relative} must parse: {parsed:?}");
    parsed.unwrap_or_else(|_| empty_lesson())
}

pub fn exercise_text(relative: &str, text: &str) -> ExerciseDocument {
    let parsed = reference_format::parse_exercise(relative, text);
    assert!(parsed.is_ok(), "{relative} must parse: {parsed:?}");
    parsed.unwrap_or_else(|_| empty_exercise())
}

pub fn exercise(relative: &str) -> ExerciseDocument {
    exercise_text(relative, &read(relative))
}

pub fn exercises_for_valid() -> Vec<ExerciseDocument> {
    let base = read("valid/ejercicio.md");
    [
        ("uno", "resolver", "semilla"),
        ("dos", "resolver", "brote"),
        ("tres", "modificar", "semilla"),
        ("cuatro", "encontrar-error", "semilla"),
        ("cinco", "resolver", "semilla"),
    ]
    .iter()
    .map(|(name, kind, level)| {
        let text = base
            .replace("inicio.base.uno", &format!("inicio.base.{name}"))
            .replace("tipo: resolver", &format!("tipo: {kind}"))
            .replace("nivel: semilla", &format!("nivel: {level}"));
        exercise_text(&format!("{name}.md"), &text)
    })
    .collect()
}

pub fn terms() -> BTreeMap<String, TermDefinition> {
    serde_json::from_str(&read("terminos.json")).unwrap_or_default()
}

fn empty_lesson() -> LessonDocument {
    lesson_text(
        "empty.md",
        "---\nid: x.y\nnumero: \"0\"\ntipo: leccion\ntitulo: X\nduracion: 1\nproblema_breve: X\n---\n",
    )
}

fn empty_exercise() -> ExerciseDocument {
    exercise_text(
        "empty.md",
        "---\nid: x.y.z\nleccion: x.y\ntipo: resolver\nnivel: semilla\ntitulo: X\n---\n",
    )
}

pub fn corpus() -> reference_corpus::Corpus {
    reference_corpus::Corpus::from_export(r#"{"resources": {}, "specifications": []}"#)
        .unwrap_or_default()
}

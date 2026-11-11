use reference_corpus::Corpus;
use reference_model::{ProgramSource, RuleId, SourceBlock};
use reference_verify::check_program_parity;

fn corpus() -> Corpus {
    let entries = [
        ("ifKeyword", "if", "Si"),
        ("thenKeyword", "then", "Entonces"),
        ("endIf", "endIf", "FinSi"),
        ("writeKeyword", "write", "Escribir"),
        ("whileKeyword", "while", "Mientras"),
        ("doKeyword", "do", "Hacer"),
    ];
    let vocabulary: Vec<String> = entries
        .iter()
        .map(|(identity, english, spanish)| {
            format!(
                r#""{identity}": {{"alias": {{"en": [], "es": []}}, "lexemas": {{"en": "{english}", "es": "{spanish}"}}}}"#
            )
        })
        .collect();
    let export = format!(
        r#"{{"resources": {{"vocabulary": {{{}}}}}, "specifications": []}}"#,
        vocabulary.join(",")
    );
    Corpus::from_export(&export).unwrap_or_default()
}

fn program(id: &str, code: &str) -> SourceBlock {
    SourceBlock::Program(ProgramSource {
        id: id.to_owned(),
        code: code.to_owned(),
        ..ProgramSource::default()
    })
}

fn problems(spanish: &[SourceBlock], english: &[SourceBlock]) -> usize {
    let found = check_program_parity(&corpus(), "leccion.md", (spanish, english));
    assert!(
        found
            .iter()
            .all(|violation| violation.rule == RuleId::RouteParity)
    );
    found.len()
}

const SPANISH: &str = "Si edad > 18 Entonces\n  Escribir \"Mayor de edad\", 7;\nFinSi\n";

#[test]
fn renamed_identifiers_and_texts_keep_the_structure() {
    let english = "Si age > 18 Entonces\n  Escribir \"Adult\", 7;\nFinSi\n";
    assert_eq!(
        problems(&[program("a", SPANISH)], &[program("a", english)]),
        0
    );
}

#[test]
fn an_empty_english_body_reuses_the_spanish_program() {
    assert_eq!(problems(&[program("a", SPANISH)], &[program("a", "")]), 0);
}

#[test]
fn a_changed_number_a_missing_statement_or_a_new_keyword_differ() {
    for changed in [
        "Si age > 19 Entonces\n  Escribir \"Adult\", 7;\nFinSi\n",
        "Si age > 18 Entonces\nFinSi\n",
        "Mientras age > 18 Hacer\n  Escribir \"Adult\", 7;\nFinSi\n",
    ] {
        assert_eq!(
            problems(&[program("a", SPANISH)], &[program("a", changed)]),
            1,
            "{changed}"
        );
    }
}

#[test]
fn a_program_without_a_spanish_counterpart_is_reported() {
    assert_eq!(
        problems(&[program("a", SPANISH)], &[program("b", SPANISH)]),
        1
    );
    assert_eq!(problems(&[], &[program("a", SPANISH)]), 1);
}

#[test]
fn a_quote_inside_a_text_does_not_end_the_text() {
    let spanish = "Escribir \"di \"\"hola\"\"\";\n";
    let english = "Escribir \"say \"\"hello\"\"\";\n";
    assert_eq!(
        problems(&[program("a", spanish)], &[program("a", english)]),
        0
    );
}

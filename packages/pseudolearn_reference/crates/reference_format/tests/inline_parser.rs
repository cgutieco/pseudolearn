use reference_format::parse_inline;
use reference_model::Inline;

#[test]
fn parses_every_inline_kind() {
    let runs = parse_inline(
        "Usa `Si` con **cuidado**, *siempre*, «condición», [la tabla](#tipos.primitivos) y [[bucle|bucles]].",
    );
    assert_eq!(
        runs,
        Ok(vec![
            Inline::Text("Usa ".to_owned()),
            Inline::Code("Si".to_owned()),
            Inline::Text(" con ".to_owned()),
            Inline::Strong("cuidado".to_owned()),
            Inline::Text(", ".to_owned()),
            Inline::Emphasis("siempre".to_owned()),
            Inline::Text(", ".to_owned()),
            Inline::Slot("condición".to_owned()),
            Inline::Text(", ".to_owned()),
            Inline::Link {
                section: "tipos.primitivos".to_owned(),
                text: "la tabla".to_owned()
            },
            Inline::Text(" y ".to_owned()),
            Inline::Term {
                term: "bucle".to_owned(),
                text: "bucles".to_owned()
            },
            Inline::Text(".".to_owned()),
        ])
    );
}

#[test]
fn keeps_plain_brackets_that_are_not_links() {
    let runs = parse_inline("Los índices [0, 9] y [ver](#otra)");
    assert_eq!(runs.map(|runs| runs.len()), Ok(2),);
}

#[test]
fn rejects_unclosed_code() {
    assert!(parse_inline("Usa `Si sin cerrar").is_err());
}

#[test]
fn rejects_empty_code() {
    assert!(parse_inline("vacío ``").is_err());
}

#[test]
fn accepts_empty_text() {
    assert_eq!(parse_inline(""), Ok(Vec::new()));
}

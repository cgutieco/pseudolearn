use reference_format::parse_document;
use reference_model::{AnatomySource, Inline, SourceBlock};

fn anatomy_document(body: &str) -> String {
    format!("---\nid: a\nnumero: \"1\"\ntipo: concepto\ntitulo: A\n---\n```anatomia\n{body}\n```\n")
}

fn parts(body: &str) -> Option<Vec<AnatomySource>> {
    let document = parse_document("a.md", &anatomy_document(body)).ok()?;
    match document.blocks.into_iter().next() {
        Some(SourceBlock::Anatomy(parts)) => Some(parts),
        _ => None,
    }
}

#[test]
fn parses_each_line_as_code_and_label() {
    let parsed = parts("Dimension | palabra clave\n\nnotas[4] | nombre y `Como`");
    assert!(parsed.is_some());
    let Some(parsed) = parsed else {
        return;
    };
    assert_eq!(parsed.len(), 2);
    assert_eq!(
        parsed.first().map(|part| part.code.as_str()),
        Some("Dimension")
    );
    assert_eq!(
        parsed.get(1).map(|part| part.code.as_str()),
        Some("notas[4]")
    );
    assert!(parsed.get(1).is_some_and(|part| {
        part.label
            .iter()
            .any(|inline| matches!(inline, Inline::Code(_)))
    }));
}

#[test]
fn keeps_brackets_and_commas_inside_the_code() {
    let parsed = parts("[3, 5] | dos tamaños\nComo Real | tipo");
    assert_eq!(
        parsed.and_then(|parts| parts.first().map(|part| part.code.clone())),
        Some("[3, 5]".to_owned())
    );
}

#[test]
fn rejects_a_line_without_separator() {
    assert!(parse_document("a.md", &anatomy_document("Dimension\nnotas | nombre")).is_err());
}

#[test]
fn rejects_an_empty_code_or_label() {
    assert!(parse_document("a.md", &anatomy_document(" | palabra\nnotas | nombre")).is_err());
    assert!(parse_document("a.md", &anatomy_document("Dimension |\nnotas | nombre")).is_err());
}

#[test]
fn rejects_an_anatomy_with_fewer_than_two_parts() {
    assert!(parse_document("a.md", &anatomy_document("")).is_err());
    assert!(parse_document("a.md", &anatomy_document("Dimension | palabra clave")).is_err());
}

use reference_format::parse_document;
use reference_model::SourceBlock;

fn figure_document(body: &str) -> String {
    format!(
        "---\nid: a\nnumero: \"1\"\ntipo: concepto\ntitulo: A\n---\n```figura id=caja\n{body}\n```\n"
    )
}

#[test]
fn parses_caption_steps_and_panels() {
    let text = figure_document("pie: Una caja.\npaso: Se crea.\npanel Memoria 1: edad: 3");
    let parsed = parse_document("a.md", &text);
    assert!(parsed.is_ok());
    let Ok(document) = parsed else {
        return;
    };
    let first = document.blocks.first();
    assert!(matches!(first, Some(SourceBlock::Figure(_))));
    let Some(SourceBlock::Figure(figure)) = first else {
        return;
    };
    assert_eq!(figure.steps.len(), 1);
    assert_eq!(
        figure.panels.first().map(|panel| panel.zone.as_str()),
        Some("Memoria")
    );
    assert_eq!(figure.panels.first().map(|panel| panel.from_step), Some(1));
}

#[test]
fn rejects_a_figure_without_caption() {
    assert!(parse_document("a.md", &figure_document("paso: x")).is_err());
}

#[test]
fn rejects_an_invalid_panel_step() {
    let text = figure_document("pie: A.\npanel Memoria uno: x");
    assert!(parse_document("a.md", &text).is_err());
}

mod support;

use reference_figures::render_figure;
use reference_model::RuleId;

fn rules(source: &str) -> Vec<RuleId> {
    let strings = support::strings();
    match render_figure(source, &support::context(&strings)) {
        Ok(_) => Vec::new(),
        Err(violations) => violations.iter().map(|violation| violation.rule).collect(),
    }
}

#[test]
fn renders_roles_strings_lexemes_and_code() {
    let strings = support::strings();
    let source = "<svg viewBox=\"0 0 340 80\"><rect x=\"1\" y=\"1\" width=\"9\" height=\"9\" fill=\"@acento-estructurado\"/><text x=\"5\" y=\"40\" font-size=\"14\">{{t:nombre}} {{lex:ifKeyword}} {{codigo:Escribir 1}} ← 128</text></svg>";
    let rendered = render_figure(source, &support::context(&strings));
    assert!(rendered.is_ok());
    let svg = rendered.unwrap_or_default().svg;
    assert!(svg.contains("fill=\"#FF0003\""));
    assert!(svg.contains("edad Si Write 1 ← 128"));
    assert!(svg.contains("<title>Una caja</title>"));
    assert!(svg.contains("font-family=\"IBMPlexSans\""));
}

#[test]
fn rejects_free_hexadecimal_colors() {
    let source = "<svg viewBox=\"0 0 340 80\"><rect x=\"1\" y=\"1\" width=\"9\" height=\"9\" fill=\"#ff0000\"/></svg>";
    assert_eq!(rules(source), vec![RuleId::FigureContract]);
}

#[test]
fn rejects_wide_figures() {
    let source = "<svg viewBox=\"0 0 760 80\"></svg>";
    assert_eq!(rules(source), vec![RuleId::FigureNarrow]);
}

#[test]
fn rejects_small_text() {
    let source = "<svg viewBox=\"0 0 340 80\"><text x=\"1\" y=\"1\" font-size=\"10\">{{t:nombre}}</text></svg>";
    assert_eq!(rules(source), vec![RuleId::FigureNarrow]);
}

#[test]
fn rejects_visible_text_outside_strings() {
    let source = "<svg viewBox=\"0 0 340 80\"><text x=\"1\" y=\"1\">Hola</text></svg>";
    assert_eq!(rules(source), vec![RuleId::FigureContract]);
}

#[test]
fn rejects_forbidden_elements_attributes_and_comments() {
    let source = "<svg viewBox=\"0 0 340 80\"><marker/><rect onclick=\"x\" fill=\"none\"/><!-- nota --></svg>";
    assert_eq!(rules(source).len(), 3);
}

#[test]
fn rejects_shapes_without_fill() {
    let source = "<svg viewBox=\"0 0 340 80\"><path d=\"M0 0 L5 5\"/></svg>";
    assert_eq!(rules(source), vec![RuleId::FigureContract]);
}

#[test]
fn rejects_missing_view_box_and_malformed_xml() {
    assert_eq!(rules("<svg></svg>"), vec![RuleId::FigureContract]);
    assert_eq!(rules("<svg"), vec![RuleId::FigureContract]);
    assert_eq!(
        rules("<g viewBox=\"0 0 340 1\"/>"),
        vec![RuleId::FigureContract]
    );
}

#[test]
fn rejects_unknown_placeholders() {
    let source = "<svg viewBox=\"0 0 340 80\"><text x=\"1\" y=\"1\">{{t:nada}}</text><text x=\"1\" y=\"1\">{{lex:nada}}</text><text x=\"1\" y=\"1\">{{otro:x}}</text></svg>";
    assert_eq!(rules(source).len(), 3);
}

#[test]
fn accepts_an_empty_figure() {
    assert!(rules("<svg viewBox=\"0 0 340 0\"/>").is_empty());
}

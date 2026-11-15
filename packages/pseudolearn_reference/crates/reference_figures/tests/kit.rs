mod support;

use reference_figures::render_figure;

fn render(source: &str) -> Result<String, usize> {
    let strings = support::strings();
    render_figure(source, &support::context(&strings))
        .map(|figure| figure.svg)
        .map_err(|violations| violations.len())
}

#[test]
fn expands_a_box_with_centered_lines() {
    let svg = render(
        "<svg viewBox=\"0 0 340 80\"><caja x=\"10\" y=\"10\" ancho=\"100\" alto=\"40\" rol=\"numero\" texto=\"{{t:nombre}}¶128\" fuente=\"mono\" negrita=\"\"/></svg>",
    );
    assert!(svg.is_ok());
    let svg = svg.unwrap_or_default();
    assert!(svg.contains("<rect x=\"10\" y=\"10\" width=\"100\" height=\"40\""));
    assert_eq!(svg.matches("<text").count(), 2);
    assert!(svg.contains("font-family=\"IBMPlexMono\""));
}

#[test]
fn expands_an_arrow_with_its_head() {
    let svg = render("<svg viewBox=\"0 0 340 80\"><flecha puntos=\"0,0 0,50 100,50\"/></svg>");
    assert!(svg.is_ok());
    let svg = svg.unwrap_or_default();
    assert!(svg.contains("<polyline points=\"0,0 0,50 92,50\""));
    assert!(svg.contains("<polygon points=\"100,50 92,54.5 92,45.5\""));
}

#[test]
fn rejects_incomplete_kit_pieces() {
    assert_eq!(
        render("<svg viewBox=\"0 0 340 80\"><caja x=\"1\"/></svg>"),
        Err(3)
    );
    assert_eq!(
        render("<svg viewBox=\"0 0 340 80\"><flecha puntos=\"0,0\"/></svg>"),
        Err(1)
    );
    assert_eq!(
        render("<svg viewBox=\"0 0 340 80\"><flecha puntos=\"0,0 2,0\"/></svg>"),
        Err(1)
    );
}

#[test]
fn rejects_unknown_roles_and_small_kit_text() {
    let source = "<svg viewBox=\"0 0 340 80\"><caja x=\"1\" y=\"1\" ancho=\"9\" alto=\"9\" rol=\"rojo\" texto=\"1\" tamano=\"9\"/></svg>";
    assert_eq!(render(source), Err(2));
}

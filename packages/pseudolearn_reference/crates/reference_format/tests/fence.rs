use reference_format::parse_fence_opening;

#[test]
fn parses_quoted_attributes_and_flags() {
    let opening = parse_fence_opening("```programa id=uno titulo=\"Con espacios\" ejecutar");
    assert_eq!(
        opening.as_ref().map(|opening| opening.name.as_str()),
        Some("programa")
    );
    assert_eq!(
        opening
            .as_ref()
            .and_then(|opening| opening.attribute("titulo")),
        Some("Con espacios")
    );
    assert_eq!(opening.map(|opening| opening.flag("ejecutar")), Some(true));
}

#[test]
fn rejects_a_closing_fence_as_opening() {
    assert_eq!(parse_fence_opening("```"), None);
}

#[test]
fn ignores_ordinary_lines() {
    assert_eq!(parse_fence_opening("texto"), None);
}

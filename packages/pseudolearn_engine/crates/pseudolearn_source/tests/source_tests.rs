use pseudolearn_source::{IdentifierNormalizer, SourceText, Span};

#[test]
fn detects_byte_order_mark_and_preserves_content() {
    let raw = "\u{FEFF}programa\nfin";
    let source = SourceText::new(raw.to_owned());
    assert_eq!(source.bom_prefix_length(), 3);
    assert_eq!(source.as_str(), raw);
}

#[test]
fn computes_accurate_line_and_column_positions() {
    let source = SourceText::new("uno\r\ndos\ntres".to_owned());
    assert_eq!(source.line_and_column(0), (1, 1));
    assert_eq!(source.line_and_column(5), (2, 1));
    assert_eq!(source.line_and_column(10), (3, 2));
}

#[test]
fn normalizes_identifiers_with_nfc_equality() {
    let decomposed = "a\u{0301}";
    let composed = "\u{00E1}";
    assert!(IdentifierNormalizer::equals(decomposed, composed));
    assert_eq!(
        IdentifierNormalizer::normalize(decomposed),
        IdentifierNormalizer::normalize(composed)
    );
}

#[test]
fn extracts_valid_spans_without_panic() {
    let source = SourceText::new("variable".to_owned());
    let span = Span::new(0, 4);
    assert_eq!(source.slice(span), Some("vari"));
    assert_eq!(span.length(), 4);
}

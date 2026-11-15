use pseudolearn_source::{
    SourceId, SourceText, Span, byte_offset_from_line_column, byte_offset_from_scalar,
    byte_offset_from_utf16, is_valid_span, line_and_column_utf16, scalar_offset,
    source_text_with_source_id, utf16_offset,
};

#[test]
fn scalar_and_utf16_offsets_round_trip_supplementary_characters() -> Result<(), String> {
    let source = SourceText::new("😀\r\né".to_owned());
    assert_eq!(scalar_offset(&source, 0), Some(0));
    assert_eq!(scalar_offset(&source, 4), Some(1));
    assert_eq!(utf16_offset(&source, 4), Some(2));
    assert_eq!(byte_offset_from_scalar(&source, 1), Some(4));
    assert_eq!(byte_offset_from_utf16(&source, 2), Some(4));
    assert_eq!(byte_offset_from_utf16(&source, 1), None);
    assert_eq!(source.line_and_column(4), (1, 2));
    assert_eq!(line_and_column_utf16(&source, 4), Some((1, 3)));
    assert_eq!(byte_offset_from_line_column(&source, 1, 3, true), Some(4));
    assert_eq!(byte_offset_from_line_column(&source, 1, 2, true), None);
    assert_eq!(source.line_and_column(6), (2, 1));
    assert_eq!(line_and_column_utf16(&source, 6), Some((2, 1)));
    assert_eq!(line_and_column_utf16(&source, 1), None);
    assert_eq!(line_and_column_utf16(&source, u32::MAX), None);
    Ok(())
}

#[test]
fn bom_is_counted_and_empty_text_has_a_valid_origin() {
    let source = SourceText::new("\u{FEFF}x".to_owned());
    assert_eq!(source.bom_prefix_length(), 3);
    assert_eq!(scalar_offset(&source, 3), Some(1));
    assert_eq!(source.line_and_column(3), (1, 2));
    assert!(is_valid_span(&source, Span::new(0, 0)));
    let empty = SourceText::new(String::new());
    assert_eq!(empty.line_and_column(0), (1, 1));
    assert_eq!(byte_offset_from_line_column(&empty, 1, 1, false), Some(0));
    assert_eq!(byte_offset_from_line_column(&empty, 2, 1, false), None);
}

#[test]
fn ranges_require_ordered_utf8_boundaries_in_their_own_source() {
    let source = SourceText::new("é".to_owned());
    assert!(is_valid_span(&source, Span::new(0, 2)));
    assert!(!is_valid_span(&source, Span::new(1, 2)));
    assert!(!is_valid_span(&source, Span::new(2, 1)));
    let foreign = source_text_with_source_id(SourceId::new(1), "é".to_owned());
    assert!(!is_valid_span(&foreign, Span::new(0, 2)));
    assert_eq!(
        Span::new(0, 1).cover(Span::in_source(pseudolearn_source::SourceId::new(1), 1, 2)),
        None
    );
}

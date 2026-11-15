use pseudolearn_service::Position;
use pseudolearn_service::positions::{
    lsp_position_at, lsp_position_at_with_index, offset_at, offset_at_with_index, offset_from_lsp,
    offset_from_lsp_with_index, position_at,
};
use pseudolearn_source::LineIndex;

#[test]
fn scalar_offsets_round_trip_across_crlf_and_unicode() {
    let source = "a\r\nñ😀x\r\nz";
    let position = Position { line: 2, column: 3 };
    let offset = offset_at(source, position);
    assert_eq!(position_at(source, offset), position);
    assert_eq!(source.get(offset..), Some("x\r\nz"));
}

#[test]
fn utf16_offsets_round_trip_across_crlf_and_non_bmp_scalars() {
    let source = "a\r\nñ😀x\r\nz";
    let offset = offset_from_lsp(source, 1, 3);
    assert_eq!(source.get(offset..), Some("x\r\nz"));
    assert_eq!(lsp_position_at(source, offset), (1, 3));
    assert_eq!(position_at(source, offset), Position { line: 2, column: 3 });
}

#[test]
fn utf16_surrogate_interiors_do_not_round_trip_as_valid_positions() {
    let source = "a\r\nñ😀x\r\nz";
    let offset = offset_from_lsp(source, 1, 2);
    assert_eq!(lsp_position_at(source, offset), (1, 1));
}

#[test]
fn empty_text_has_a_stable_origin_position() {
    assert_eq!(offset_at("", Position { line: 1, column: 1 }), 0);
    assert_eq!(position_at("", 0), Position { line: 1, column: 1 });
    assert_eq!(lsp_position_at("", 0), (0, 0));
}

#[test]
fn indexed_variants_match_the_index_building_variants() {
    let source = "a\r\nñ😀x\r\nz";
    let index = LineIndex::build(source);
    let position = Position { line: 2, column: 3 };
    assert_eq!(
        offset_at_with_index(source, position, &index),
        offset_at(source, position)
    );
    assert_eq!(
        offset_from_lsp_with_index(source, 1, 3, &index),
        offset_from_lsp(source, 1, 3)
    );
    let offset = offset_from_lsp(source, 1, 3);
    assert_eq!(
        lsp_position_at_with_index(source, offset, &index),
        lsp_position_at(source, offset)
    );
}

#[test]
fn indexed_variants_clamp_positions_beyond_the_text() {
    let index = LineIndex::build("ab");
    assert_eq!(offset_from_lsp_with_index("ab", 9, 9, &index), 2);
    assert_eq!(
        offset_at_with_index("ab", Position { line: 9, column: 9 }, &index),
        2
    );
    assert_eq!(lsp_position_at_with_index("ab", 99, &index), (0, 2));
}

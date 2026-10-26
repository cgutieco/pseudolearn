use pseudolearn_abi::VectorLayout;

#[test]
fn checked_layout_counts_separate_banks_and_empty_values() {
    let layout = VectorLayout {
        scalar_words: 2,
        reference_words: 1,
        type_identity: 3,
    };
    assert_eq!(layout.element_words(), Some(3));
    assert_eq!(layout.storage_words(4), Some(12));
    assert_eq!(layout.logical_cells(4), Some(13));
    let empty = VectorLayout {
        scalar_words: 0,
        reference_words: 0,
        type_identity: 0,
    };
    assert_eq!(empty.logical_cells(4), Some(5));
}

#[test]
fn malformed_layout_rejects_width_overflow() {
    let layout = VectorLayout {
        scalar_words: u32::MAX,
        reference_words: 1,
        type_identity: 0,
    };
    assert_eq!(layout.element_words(), None);
    assert_eq!(layout.storage_words(1), None);
    assert_eq!(layout.logical_cells(1), None);
}

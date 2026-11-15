use pseudolearn_abi::{
    ARRAY_DEFINITION_MAP_WORD_OFFSET, ARRAY_DENSE_BOUNDARY_WORD_OFFSET,
    ARRAY_DIMENSION_EXTENTS_START_OFFSET, ARRAY_HEADER_WORDS, ARRAY_KIND_STATUS_MASK,
    ARRAY_KIND_STATUS_SHIFT, ARRAY_RANK_STATUS_MASK, ARRAY_RANK_STATUS_SHIFT,
    ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, COMMON_HEADER_BYTES, COMMON_HEADER_WORDS,
    CONTROL_FRAME_BYTES, CONTROL_FRAME_WORDS, CommonHeader, ControlFrame, Handle,
    LITERAL_STATUS_MASK, OBJECT_FIELDS_START_OFFSET_WITH_MASK,
    OBJECT_FIELDS_START_OFFSET_WITHOUT_MASK, OBJECT_HEADER_WORDS, OBJECT_INTEGER_MASK_WORD_OFFSET,
    OBJECT_PAYLOAD_STATUS_MASK, STRING_ARENA_BYTE_COUNT_WORD_OFFSET,
    STRING_ARENA_BYTE_OFFSET_WORD_OFFSET, STRING_BREADCRUMBS_HANDLE_WORD_OFFSET,
    STRING_FIXED_WORDS_COUNT, STRING_HEADER_WORDS, TEXT_ASCII_STATUS_MASK, Word,
    array_elements_start_offset, boolean_absent_word, character_absent_word, is_boolean_absent,
    is_character_absent, is_real_absent, is_reference_absent, real_absent_word,
    reference_absent_handle,
};

#[test]
fn verifies_primitive_sizes_and_alignments() {
    assert_eq!(std::mem::size_of::<Word>(), 8);
    assert_eq!(std::mem::align_of::<Word>(), 8);
    assert_eq!(std::mem::size_of::<Handle>(), 4);
    assert_eq!(std::mem::align_of::<Handle>(), 4);
    assert_eq!(std::mem::size_of::<ControlFrame>(), CONTROL_FRAME_BYTES);
    assert_eq!(
        std::mem::size_of::<ControlFrame>(),
        CONTROL_FRAME_WORDS * std::mem::size_of::<Word>()
    );
    assert_eq!(std::mem::size_of::<CommonHeader>(), COMMON_HEADER_BYTES);
    assert_eq!(
        std::mem::size_of::<CommonHeader>(),
        COMMON_HEADER_WORDS * std::mem::size_of::<Word>()
    );
}

#[test]
fn verifies_word_bit_conversions() {
    let integer_word = Word::from_i64(-42);
    assert_eq!(integer_word.as_i64(), -42);

    let float_value = 1.23456789_f64;
    let float_word = Word::from_f64_bits(float_value);
    assert_eq!(float_word.as_f64_bits(), float_value);
}

#[test]
fn verifies_absence_sentinels() {
    assert!(is_real_absent(real_absent_word()));
    assert!(!is_real_absent(Word::from_f64_bits(0.0)));
    assert!(!is_real_absent(Word::from_f64_bits(-1.5)));

    assert!(is_boolean_absent(boolean_absent_word()));
    assert!(!is_boolean_absent(Word::from_u64(0)));
    assert!(!is_boolean_absent(Word::from_u64(1)));

    assert!(is_character_absent(character_absent_word()));
    assert!(!is_character_absent(Word::from_u64(65)));
    assert!(!is_character_absent(Word::from_u64(0x10_FFFF)));

    let absent_handle = reference_absent_handle();
    assert!(is_reference_absent(absent_handle));
    assert!(absent_handle.is_absent());
    assert!(!absent_handle.is_present());

    let present_handle = Handle::from_u32(128);
    assert!(!is_reference_absent(present_handle));
    assert!(!present_handle.is_absent());
    assert!(present_handle.is_present());
}

#[test]
fn verifies_common_header_roundtrip() {
    let header = CommonHeader::new(42, 7, 999_999);
    let words = header.to_words();
    let reconstructed = CommonHeader::from_words(words);
    assert_eq!(reconstructed, Some(header));
}

#[test]
fn verifies_common_header_status_fields() {
    assert_eq!(ARRAY_KIND_STATUS_SHIFT, 0);
    assert_eq!(ARRAY_KIND_STATUS_MASK, 0x0000_00FF);
    assert_eq!(ARRAY_RANK_STATUS_SHIFT, 8);
    assert_eq!(ARRAY_RANK_STATUS_MASK, 0x0000_FF00);
    assert_eq!(OBJECT_PAYLOAD_STATUS_MASK, 0x0000_FFFF);
    assert_eq!(TEXT_ASCII_STATUS_MASK, 0x0000_0001);
    assert_eq!(LITERAL_STATUS_MASK, 0x0001_0000);
}

#[test]
fn verifies_control_frame_roundtrip() {
    let frame = ControlFrame::new(10, 256, 32, 64);
    let words = frame.to_words();
    let reconstructed = ControlFrame::from_words(words);
    assert_eq!(reconstructed, Some(frame));
}

#[test]
fn verifies_structural_offsets() {
    assert_eq!(OBJECT_HEADER_WORDS, 2);
    assert_eq!(OBJECT_INTEGER_MASK_WORD_OFFSET, 2);
    assert_eq!(OBJECT_FIELDS_START_OFFSET_WITH_MASK, 3);
    assert_eq!(OBJECT_FIELDS_START_OFFSET_WITHOUT_MASK, 2);

    assert_eq!(ARRAY_HEADER_WORDS, 2);
    assert_eq!(ARRAY_TOTAL_ELEMENTS_WORD_OFFSET, 2);
    assert_eq!(ARRAY_DENSE_BOUNDARY_WORD_OFFSET, 3);
    assert_eq!(ARRAY_DEFINITION_MAP_WORD_OFFSET, 4);
    assert_eq!(ARRAY_DIMENSION_EXTENTS_START_OFFSET, 5);
    assert_eq!(array_elements_start_offset(1), 5);
    assert_eq!(array_elements_start_offset(2), 7);
    assert_eq!(array_elements_start_offset(3), 8);

    assert_eq!(STRING_HEADER_WORDS, 2);
    assert_eq!(STRING_ARENA_BYTE_OFFSET_WORD_OFFSET, 2);
    assert_eq!(STRING_ARENA_BYTE_COUNT_WORD_OFFSET, 3);
    assert_eq!(STRING_BREADCRUMBS_HANDLE_WORD_OFFSET, 4);
    assert_eq!(STRING_FIXED_WORDS_COUNT, 5);
}

#[test]
fn object_masks_cover_every_field_and_reject_size_overflow() {
    assert_eq!(
        pseudolearn_abi::object_fields_start_offset(64, false),
        Some(3)
    );
    assert_eq!(
        pseudolearn_abi::object_fields_start_offset(65, false),
        Some(4)
    );
    assert_eq!(
        pseudolearn_abi::object_fields_start_offset(130, true),
        Some(2)
    );
    assert_eq!(
        pseudolearn_abi::object_fields_start_offset(usize::MAX, false),
        None
    );
}

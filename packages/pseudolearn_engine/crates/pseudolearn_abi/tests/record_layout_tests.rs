use pseudolearn_abi::{
    RECORD_MAXIMUM_LEAVES, RecordBank, RecordLayout, RecordLayoutError, RecordLeaf,
};

fn layout(banks: &[RecordBank]) -> RecordLayout {
    RecordLayout::from_banks(banks).unwrap_or_default()
}

#[test]
fn separates_scalar_and_reference_areas() {
    let layout = layout(&[
        RecordBank::Scalar,
        RecordBank::Reference,
        RecordBank::Scalar,
        RecordBank::Reference,
        RecordBank::Reference,
    ]);
    assert_eq!(layout.leaf_count(), 5);
    assert_eq!(layout.scalar_words(), 2);
    assert_eq!(layout.reference_words(), 3);
    assert_eq!(
        layout.leaf(2),
        Some(RecordLeaf {
            bank: RecordBank::Scalar,
            offset: 1
        })
    );
    assert_eq!(
        layout.leaf(4),
        Some(RecordLeaf {
            bank: RecordBank::Reference,
            offset: 2
        })
    );
}

#[test]
fn single_field_record_has_one_word() {
    let layout = layout(&[RecordBank::Scalar]);
    assert_eq!(layout.leaf_count(), 1);
    assert_eq!(layout.scalar_words(), 1);
    assert_eq!(layout.reference_words(), 0);
}

#[test]
fn empty_layout_has_no_words() {
    let layout = layout(&[]);
    assert_eq!(layout.leaf_count(), 0);
    assert_eq!(layout.scalar_words(), 0);
    assert_eq!(layout.reference_words(), 0);
    assert_eq!(layout.leaf(0), None);
}

#[test]
fn flattens_nested_records_in_declaration_order() {
    let point = layout(&[RecordBank::Scalar, RecordBank::Scalar]);
    let label = layout(&[RecordBank::Reference]);
    let outer = RecordLayout::from_parts(&[label, point.clone(), point]).unwrap_or_default();
    assert_eq!(outer.leaf_count(), 5);
    assert_eq!(outer.scalar_words(), 4);
    assert_eq!(outer.reference_words(), 1);
    assert_eq!(
        outer.leaf(0),
        Some(RecordLeaf {
            bank: RecordBank::Reference,
            offset: 0
        })
    );
    assert_eq!(
        outer.leaf(4),
        Some(RecordLeaf {
            bank: RecordBank::Scalar,
            offset: 3
        })
    );
}

#[test]
fn rejects_records_beyond_the_operand_limit() {
    let banks = vec![RecordBank::Scalar; RECORD_MAXIMUM_LEAVES.saturating_add(1)];
    assert_eq!(
        RecordLayout::from_banks(&banks),
        Err(RecordLayoutError::TooManyLeaves)
    );
    let boundary = vec![RecordBank::Scalar; RECORD_MAXIMUM_LEAVES];
    assert!(RecordLayout::from_banks(&boundary).is_ok());
}

#[test]
fn rejects_nested_parts_that_exceed_the_limit() {
    let wide = layout(&vec![RecordBank::Scalar; RECORD_MAXIMUM_LEAVES]);
    let extra = layout(&[RecordBank::Scalar]);
    assert_eq!(
        RecordLayout::from_parts(&[wide, extra]),
        Err(RecordLayoutError::TooManyLeaves)
    );
}

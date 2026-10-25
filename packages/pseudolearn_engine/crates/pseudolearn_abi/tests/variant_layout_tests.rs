use pseudolearn_abi::{RecordBank, RecordLayout, VariantLayout, VariantLayoutError};

fn payload(banks: &[RecordBank]) -> RecordLayout {
    RecordLayout::from_banks(banks).unwrap_or_default()
}

#[test]
fn overlays_payloads_within_each_bank() {
    let layout = VariantLayout::tagged(&[
        payload(&[RecordBank::Scalar, RecordBank::Reference]),
        payload(&[RecordBank::Scalar, RecordBank::Scalar]),
    ]);
    assert!(layout.is_ok());
    if let Ok(layout) = layout {
        assert_eq!(layout.scalar_words(), 3);
        assert_eq!(layout.reference_words(), 1);
        assert!(!layout.uses_reference_niche());
    }
}

#[test]
fn optional_reference_uses_null_niche() {
    let layout = VariantLayout::optional(payload(&[RecordBank::Reference]));
    assert!(layout.is_ok());
    if let Ok(layout) = layout {
        assert_eq!(layout.scalar_words(), 0);
        assert_eq!(layout.reference_words(), 1);
        assert!(layout.uses_reference_niche());
        let mut references = [7];
        assert_eq!(layout.clear_inactive_references(0, &mut references), Ok(()));
        assert_eq!(references, [0]);
    }
}

#[test]
fn inactive_reference_slots_are_cleared_without_touching_active_slots() {
    let layout = VariantLayout::tagged(&[
        payload(&[RecordBank::Reference]),
        payload(&[RecordBank::Reference, RecordBank::Reference]),
    ]);
    if let Ok(layout) = layout {
        let mut references = [4, 9, 13];
        assert_eq!(layout.clear_inactive_references(0, &mut references), Ok(()));
        assert_eq!(references, [4, 0, 13]);
        assert_eq!(
            layout.clear_inactive_references(2, &mut references),
            Err(VariantLayoutError::InvalidVariant)
        );
        assert_eq!(
            layout.clear_inactive_references(0, &mut []),
            Err(VariantLayoutError::ReferenceBufferTooSmall)
        );
    } else {
        assert!(layout.is_ok());
    }
}

#[test]
fn rejects_empty_variants_and_checks_discriminant_at_operand_boundary() {
    assert_eq!(
        VariantLayout::tagged(&[]),
        Err(VariantLayoutError::EmptyVariants)
    );
    let alternatives = vec![RecordLayout::default(); 65_536];
    assert_eq!(
        VariantLayout::tagged(&alternatives),
        Err(VariantLayoutError::TooManyWords)
    );
    let maximum = payload(&vec![RecordBank::Scalar; 65_535]);
    assert_eq!(
        VariantLayout::tagged(&[maximum]),
        Err(VariantLayoutError::TooManyWords)
    );
    let boundary = payload(&vec![RecordBank::Scalar; 65_534]);
    assert!(VariantLayout::tagged(&[boundary]).is_ok());
}

#[test]
fn nested_optional_requires_a_distinct_outer_discriminant() {
    let inner = VariantLayout::optional(payload(&[RecordBank::Reference]));
    assert!(inner.is_ok());
    let outer =
        VariantLayout::tagged(&[RecordLayout::default(), payload(&[RecordBank::Reference])]);
    if let Ok(outer) = outer {
        assert_eq!(outer.scalar_words(), 1);
        assert!(!outer.uses_reference_niche());
    } else {
        assert!(outer.is_ok());
    }
}

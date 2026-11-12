use pseudolearn_abi::continuation_layout::{CONTINUATION_HEADER_WORDS, ContinuationLayout};

#[test]
fn splits_scalar_and_reference_segments_and_counts_cells() {
    let layout = ContinuationLayout::new(3, 2);
    assert!(layout.is_some());
    if let Some(layout) = layout {
        assert_eq!(layout.scalar_offset(0), Some(CONTINUATION_HEADER_WORDS));
        assert_eq!(
            layout.reference_offset(0),
            Some(CONTINUATION_HEADER_WORDS.saturating_add(3))
        );
        assert_eq!(layout.logical_cells(), 6);
        assert_eq!(layout.scalar_offset(3), None);
        assert_eq!(layout.reference_offset(2), None);
    }
}

#[test]
fn accepts_empty_and_maximum_layouts_and_rejects_overflow() {
    assert_eq!(
        ContinuationLayout::new(0, 0).map(|layout| layout.logical_cells()),
        Some(1)
    );
    assert!(ContinuationLayout::new(u32::from(u16::MAX), 0).is_some());
    assert!(ContinuationLayout::new(u32::from(u16::MAX), 1).is_none());
    assert!(ContinuationLayout::new(u32::MAX, 1).is_none());
}

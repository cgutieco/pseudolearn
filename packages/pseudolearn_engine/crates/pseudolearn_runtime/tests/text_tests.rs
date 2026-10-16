use pseudolearn_runtime::{
    Heap, MemoryError, MemoryOptions, concat_text, new_text, text_character, text_content,
    text_length,
};

#[test]
fn shared_appends_preserve_prefixes_and_branched_results() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let right = new_text(&mut heap, "🦀", true, &[])?;
    let prefix = new_text(&mut heap, "a", false, &[right])?;
    let first = concat_text(&mut heap, prefix, right, &[prefix, right])?;
    let second = concat_text(&mut heap, prefix, right, &[prefix, right, first])?;
    let doubled = concat_text(&mut heap, first, first, &[prefix, first, second])?;
    assert_eq!(text_content(&heap, prefix), Ok("a"));
    assert_eq!(text_content(&heap, first), Ok("a🦀"));
    assert_eq!(text_content(&heap, second), Ok("a🦀"));
    assert_eq!(text_content(&heap, doubled), Ok("a🦀a🦀"));
    heap.collect(&[prefix, first, second, doubled])?;
    assert_eq!(text_content(&heap, first), Ok("a🦀"));
    assert_eq!(text_content(&heap, doubled), Ok("a🦀a🦀"));
    Ok(())
}

#[test]
fn unicode_breadcrumbs_observe_code_points_without_normalization() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let text = "e\u{301}🦀".repeat(65);
    let handle = new_text(&mut heap, &text, false, &[])?;
    assert_eq!(text_length(&heap, handle), Ok(195));
    for position in [0, 63, 64, 127, 128, 194] {
        let expected = usize::try_from(position)
            .ok()
            .and_then(|index| text.chars().nth(index));
        assert_eq!(text_character(&mut heap, handle, position).ok(), expected);
    }
    assert_eq!(
        text_character(&mut heap, handle, 195),
        Err(MemoryError::StringPositionOutOfRange)
    );
    assert_eq!(
        text_character(&mut heap, handle, -1),
        Err(MemoryError::StringPositionOutOfRange)
    );
    Ok(())
}

#[test]
fn breadcrumb_extension_and_compaction_keep_shared_prefix_indices() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let suffix = new_text(&mut heap, "🦀", true, &[])?;
    let mut current = new_text(&mut heap, &"é".repeat(64), false, &[suffix])?;
    let prefix = current;
    assert_eq!(text_character(&mut heap, prefix, 63), Ok('é'));
    for _ in 0..130 {
        current = concat_text(&mut heap, current, suffix, &[prefix, current, suffix])?;
        let last = i64::try_from(
            text_length(&heap, current)?
                .checked_sub(1)
                .ok_or(MemoryError::Internal)?,
        )
        .map_err(|_| MemoryError::Internal)?;
        assert_eq!(text_character(&mut heap, current, last), Ok('🦀'));
    }
    let before = text_content(&heap, current)?.to_owned();
    heap.collect(&[prefix, current])?;
    assert_eq!(text_content(&heap, current), Ok(before.as_str()));
    assert_eq!(text_character(&mut heap, prefix, 63), Ok('é'));
    assert_eq!(text_character(&mut heap, current, 64), Ok('🦀'));
    assert_eq!(text_character(&mut heap, current, 193), Ok('🦀'));
    Ok(())
}

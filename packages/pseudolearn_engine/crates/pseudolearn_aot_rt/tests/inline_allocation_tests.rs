use pseudolearn_aot_rt::{
    INLINE_MAXIMUM_PHYSICAL, KIND_BOOLEAN, KIND_INTEGER, KIND_REAL, KIND_REFERENCE,
    inline_object_image,
};

#[test]
fn a_sparse_class_image_has_mask_words_and_absent_fields() -> Result<(), &'static str> {
    let image = inline_object_image(0, &[KIND_INTEGER, KIND_REAL, KIND_BOOLEAN], false)
        .ok_or("image expected")?;
    assert_eq!(image.physical, 6);
    assert_eq!(image.cells, 4);
    assert_eq!(image.header & 0xFFFF_FFFF, 3);
    assert_eq!(image.header >> 32, 3);
    assert_eq!(image.words.len(), 4);
    assert_eq!(image.words.first(), Some(&u64::MAX));
    assert_eq!(image.words.get(1), Some(&0));
    Ok(())
}

#[test]
fn a_dense_class_image_has_no_mask_word() -> Result<(), &'static str> {
    let image = inline_object_image(2, &[KIND_REFERENCE], true).ok_or("image expected")?;
    assert_eq!(image.physical, 3);
    assert_eq!(image.header & 0xFFFF_FFFF, 5);
    assert_eq!(image.words, vec![0]);
    Ok(())
}

#[test]
fn an_empty_class_still_has_a_header_and_one_cell() -> Result<(), &'static str> {
    let image = inline_object_image(1, &[], true).ok_or("image expected")?;
    assert_eq!(image.physical, 2);
    assert_eq!(image.cells, 1);
    assert!(image.words.is_empty());
    Ok(())
}

#[test]
fn oversized_or_unknown_shapes_have_no_inline_image() {
    let wide = vec![KIND_INTEGER; INLINE_MAXIMUM_PHYSICAL];
    assert!(inline_object_image(0, &wide, false).is_none());
    assert!(inline_object_image(0, &[99], false).is_none());
    assert!(inline_object_image(u32::MAX, &[KIND_INTEGER], false).is_none());
}

use pseudolearn_runtime::{
    CollectionPolicy, Heap, MemoryError, MemoryOptions, ObjectLayout, ValueKind, copy_object,
    new_array, new_object, read_field, write_field,
};

fn layout() -> ObjectLayout {
    ObjectLayout {
        class: 0,
        fields: vec![ValueKind::Integer, ValueKind::Reference],
        dense: false,
        references: vec![1],
    }
}

#[test]
fn collection_preserves_cycles_and_never_reuses_identity() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let first = new_object(&mut heap, layout(), &[])?;
    assert_eq!(
        write_field(&mut heap, first, (1, u64::from(first.0))),
        Ok(())
    );
    let ordinal = heap.identity(first);
    assert_eq!(heap.reachable_cells(&[first, first]), Ok(3));
    assert_eq!(heap.collect(&[first]), Ok(()));
    assert_eq!(read_field(&heap, first, 1), Ok(u64::from(first.0)));
    assert_eq!(heap.collect(&[]), Ok(()));
    let second = new_object(&mut heap, layout(), &[]).ok();
    assert!(second.is_some());
    if let Some(second) = second {
        assert!(heap.identity(second).ok() > ordinal.ok());
    }
    Ok(())
}

#[test]
fn reused_handle_receives_a_new_identity_ordinal() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let first = new_array(&mut heap, ValueKind::Integer, &[2], &[])?;
    assert_eq!(heap.identity(first), Ok(1));
    heap.collect(&[])?;
    let second = new_array(&mut heap, ValueKind::Integer, &[2], &[])?;
    assert_eq!(first, second);
    assert_eq!(heap.identity(second), Ok(2));
    Ok(())
}

#[test]
fn copy_preserves_absence_and_shared_references() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let source = new_object(&mut heap, layout(), &[])?;
    assert_eq!(
        write_field(&mut heap, source, (1, u64::from(source.0))),
        Ok(())
    );
    let target = copy_object(&mut heap, source, &[source])?;
    assert_eq!(
        read_field(&heap, target, 0),
        Err(MemoryError::Uninitialized)
    );
    assert_eq!(read_field(&heap, target, 1), Ok(u64::from(source.0)));
    assert_ne!(heap.identity(source), heap.identity(target));
    Ok(())
}

#[test]
fn exact_limit_includes_new_value_before_overwrite_in_every_policy() -> Result<(), MemoryError> {
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut heap = Heap::new(MemoryOptions {
            cells: 5,
            collection,
        });
        let first = new_object(&mut heap, layout(), &[])?;
        assert_eq!(
            new_object(&mut heap, layout(), &[first]),
            Err(MemoryError::CellLimit)
        );
        assert!(new_object(&mut heap, layout(), &[]).is_ok());
    }
    Ok(())
}

#[test]
fn exact_array_limit_counts_the_new_array_before_overwrite() -> Result<(), MemoryError> {
    for collection in [
        CollectionPolicy::Automatic,
        CollectionPolicy::Forced,
        CollectionPolicy::Disabled,
    ] {
        let mut heap = Heap::new(MemoryOptions {
            cells: 3,
            collection,
        });
        let first = new_array(&mut heap, ValueKind::Integer, &[2], &[])?;
        assert_eq!(heap.reachable_cells(&[first]), Ok(3));
        assert_eq!(
            new_array(&mut heap, ValueKind::Integer, &[0], &[first]),
            Err(MemoryError::CellLimit)
        );
    }
    Ok(())
}

#[test]
fn allocation_rejects_addresses_outside_handle_space() {
    let options = MemoryOptions {
        cells: u64::MAX,
        collection: CollectionPolicy::Disabled,
    };
    let mut heap = Heap::new(options);
    assert_eq!(
        new_array(&mut heap, ValueKind::Reference, &[4_294_967_295], &[]),
        Err(MemoryError::Resource)
    );
}

#[test]
fn integer_masks_span_multiple_words_without_changing_field_offsets() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let source = new_object(
        &mut heap,
        ObjectLayout {
            class: 9,
            fields: vec![ValueKind::Integer; 130],
            dense: false,
            references: Vec::new(),
        },
        &[],
    )?;
    for index in [0, 63, 64, 127, 128, 129] {
        assert_eq!(
            read_field(&heap, source, index),
            Err(MemoryError::Uninitialized)
        );
        write_field(&mut heap, source, (index, u64::MAX))?;
        assert_eq!(read_field(&heap, source, index), Ok(u64::MAX));
    }
    let copy = copy_object(&mut heap, source, &[source])?;
    assert_eq!(read_field(&heap, copy, 64), Ok(u64::MAX));
    assert_eq!(read_field(&heap, copy, 65), Err(MemoryError::Uninitialized));
    assert_eq!(heap.reachable_cells(&[source, copy]), Ok(262));
    Ok(())
}

#[test]
fn text_and_derived_indices_do_not_consume_identity_ordinals() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let text = pseudolearn_runtime::new_text(&mut heap, &"é".repeat(130), true, &[])?;
    assert_eq!(
        pseudolearn_runtime::text_character(&mut heap, text, 129),
        Ok('é')
    );
    let object = new_object(&mut heap, layout(), &[text])?;
    assert_eq!(heap.identity(object), Ok(1));
    heap.collect(&[text])?;
    let next = new_object(&mut heap, layout(), &[text])?;
    assert_eq!(heap.identity(next), Ok(2));
    Ok(())
}

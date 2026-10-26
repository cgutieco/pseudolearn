use pseudolearn_abi::VectorLayout;
use pseudolearn_runtime::{
    CollectionWords, Heap, MemoryOptions, collection_length, collection_version, new_vector,
    vector_get, vector_insert, vector_remove,
};

#[test]
fn growth_preserves_handle_and_order() -> Result<(), pseudolearn_runtime::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let handle = new_vector(
        &mut heap,
        VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
        &[],
    )?;
    let identity = heap.identity(handle)?;
    for value in 0..20 {
        vector_insert(
            &mut heap,
            handle,
            (
                value,
                CollectionWords {
                    scalars: vec![
                        u64::try_from(value)
                            .map_err(|_| pseudolearn_runtime::MemoryError::Internal)?,
                    ],
                    references: vec![],
                },
            ),
            &[],
        )?;
    }
    assert_eq!(collection_length(&heap, handle)?, 20);
    assert_eq!(heap.identity(handle)?, identity);
    assert_eq!(vector_get(&heap, handle, 19)?.scalars, vec![19]);
    vector_remove(&mut heap, handle, 0)?;
    assert_eq!(vector_get(&heap, handle, 0)?.scalars, vec![1]);
    assert_eq!(collection_version(&heap, handle)?, 21);
    Ok(())
}

#[test]
fn invalid_index_leaves_structure_unchanged() -> Result<(), pseudolearn_runtime::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let handle = new_vector(
        &mut heap,
        VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
        &[],
    )?;
    assert!(vector_remove(&mut heap, handle, 0).is_err());
    assert!(vector_get(&heap, handle, -1).is_err());
    assert_eq!(collection_version(&heap, handle)?, 0);
    assert_eq!(collection_length(&heap, handle)?, 0);
    Ok(())
}

#[test]
fn replacement_keeps_version_and_removed_references_are_collectable()
-> Result<(), pseudolearn_runtime::MemoryError> {
    use pseudolearn_runtime::{
        collection_check_version, live_allocation_handles, new_text, vector_set,
    };
    let mut heap = Heap::new(MemoryOptions::default());
    let handle = new_vector(
        &mut heap,
        VectorLayout {
            scalar_words: 0,
            reference_words: 1,
            type_identity: 0,
        },
        &[],
    )?;
    let text = new_text(&mut heap, "retained", false, &[handle])?;
    vector_insert(
        &mut heap,
        handle,
        (
            0,
            CollectionWords {
                scalars: vec![],
                references: vec![text],
            },
        ),
        &[handle, text],
    )?;
    let version = collection_version(&heap, handle)?;
    heap.collect(&[handle])?;
    assert!(live_allocation_handles(&heap).contains(&text));
    vector_set(
        &mut heap,
        handle,
        (
            0,
            CollectionWords {
                scalars: vec![],
                references: vec![text],
            },
        ),
    )?;
    assert_eq!(collection_check_version(&heap, handle, version), Ok(()));
    vector_remove(&mut heap, handle, 0)?;
    assert_eq!(
        collection_check_version(&heap, handle, version),
        Err(pseudolearn_runtime::MemoryError::CollectionModified)
    );
    heap.collect(&[handle])?;
    assert!(!live_allocation_handles(&heap).contains(&text));
    Ok(())
}

#[test]
fn failed_growth_preserves_contents_and_delta_restores_structure() -> Result<(), String> {
    use pseudolearn_runtime::{advance_heap, revert_heap};
    let mut heap = Heap::new(MemoryOptions {
        cells: 6,
        ..MemoryOptions::default()
    });
    let handle = new_vector(
        &mut heap,
        VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
        &[],
    )
    .map_err(|error| format!("{error:?}"))?;
    let before = heap.clone();
    let mut tip = before.clone();
    for index in 0..5 {
        vector_insert(
            &mut heap,
            handle,
            (
                index,
                CollectionWords {
                    scalars: vec![7],
                    references: vec![],
                },
            ),
            &[handle],
        )
        .map_err(|error| format!("{error:?}"))?;
    }
    let delta = advance_heap(&mut tip, &heap);
    revert_heap(&mut tip, &delta).map_err(|error| format!("{error:?}"))?;
    assert_eq!(tip, before);
    let version = collection_version(&heap, handle).map_err(|error| format!("{error:?}"))?;
    let result = vector_insert(
        &mut heap,
        handle,
        (
            5,
            CollectionWords {
                scalars: vec![9],
                references: vec![],
            },
        ),
        &[handle],
    );
    assert!(result.is_err());
    assert_eq!(collection_length(&heap, handle), Ok(5));
    assert_eq!(collection_version(&heap, handle), Ok(version));
    Ok(())
}

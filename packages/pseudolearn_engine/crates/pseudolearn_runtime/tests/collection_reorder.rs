use pseudolearn_runtime::{
    CollectionWords, Heap, MemoryError, MemoryOptions, VectorLayout, collection_version,
    new_vector, vector_begin_sort, vector_clone, vector_commit, vector_get, vector_insert,
    vector_reverse, vector_set,
};

fn vector(heap: &mut Heap) -> Result<pseudolearn_runtime::Handle, MemoryError> {
    let handle = new_vector(
        heap,
        VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
        &[],
    )?;
    for index in 0..3 {
        vector_insert(
            heap,
            handle,
            (
                index,
                CollectionWords {
                    scalars: vec![u64::try_from(index).map_err(|_| MemoryError::Internal)?],
                    references: Vec::new(),
                },
            ),
            &[handle],
        )?;
    }
    Ok(handle)
}

#[test]
fn reorder_preserves_aliases_and_confirms_complete_copies() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let original = vector(&mut heap)?;
    let identity = heap.identity(original)?;
    let copy = vector_clone(&mut heap, original, &[original])?;
    vector_reverse(&mut heap, copy)?;
    assert_eq!(vector_get(&heap, original, 0)?.scalars, vec![0]);
    vector_begin_sort(&mut heap, original)?;
    let value = CollectionWords {
        scalars: vec![9],
        references: Vec::new(),
    };
    assert_eq!(
        vector_set(&mut heap, original, (0, value)),
        Err(MemoryError::CollectionModified)
    );
    vector_commit(&mut heap, original, copy)?;
    assert_eq!(heap.identity(original)?, identity);
    assert_eq!(vector_get(&heap, original, 0)?.scalars, vec![2]);
    assert_eq!(collection_version(&heap, original)?, 4);
    vector_reverse(&mut heap, original)?;
    Ok(())
}

#[test]
fn incompatible_commit_leaves_the_receiver_unchanged() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let original = vector(&mut heap)?;
    let empty = new_vector(
        &mut heap,
        VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
        &[original],
    )?;
    assert_eq!(
        vector_commit(&mut heap, original, empty),
        Err(MemoryError::Internal)
    );
    assert_eq!(collection_version(&heap, original)?, 3);
    assert_eq!(vector_get(&heap, original, 0)?.scalars, vec![0]);
    Ok(())
}

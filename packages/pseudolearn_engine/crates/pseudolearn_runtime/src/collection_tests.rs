use crate::{
    CollectionWords, Heap, MemoryError, MemoryOptions, VectorLayout, collection_length,
    collection_version, new_vector, vector_insert, vector_set,
};
use pseudolearn_abi::vector_layout::COLLECTION_VERSION_OFFSET;

#[test]
fn exhausted_version_rejects_structure_but_allows_replacement() -> Result<(), MemoryError> {
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
    vector_insert(
        &mut heap,
        handle,
        (
            0,
            CollectionWords {
                scalars: vec![3],
                references: vec![],
            },
        ),
        &[handle],
    )?;
    heap.store(handle, COLLECTION_VERSION_OFFSET, u64::from(u32::MAX))?;
    let before = heap.clone();
    assert_eq!(
        vector_insert(
            &mut heap,
            handle,
            (
                1,
                CollectionWords {
                    scalars: vec![4],
                    references: vec![]
                }
            ),
            &[handle]
        ),
        Err(MemoryError::CollectionVersion)
    );
    assert_eq!(heap, before);
    vector_set(
        &mut heap,
        handle,
        (
            0,
            CollectionWords {
                scalars: vec![5],
                references: vec![],
            },
        ),
    )?;
    assert_eq!(collection_length(&heap, handle)?, 1);
    assert_eq!(collection_version(&heap, handle)?, u32::MAX);
    Ok(())
}

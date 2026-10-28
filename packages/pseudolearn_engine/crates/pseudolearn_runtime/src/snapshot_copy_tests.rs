use crate::{
    CollectionWords, Heap, MemoryOptions, collection_load_word, new_vector, snapshot_copy,
};
use pseudolearn_abi::VectorLayout;

fn layout(references: u32) -> VectorLayout {
    VectorLayout {
        scalar_words: u32::from(references == 0),
        reference_words: references,
        type_identity: 1,
    }
}

#[test]
fn copies_nested_aliases_independently_of_the_original() -> Result<(), crate::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let child = new_vector(&mut heap, layout(0), &[])?;
    vector_append(
        &mut heap,
        child,
        &CollectionWords {
            scalars: vec![7],
            references: vec![],
        },
        &[],
    )?;
    let parent = new_vector(&mut heap, layout(1), &[child])?;
    for _ in 0..2 {
        vector_append(
            &mut heap,
            parent,
            &CollectionWords {
                scalars: vec![],
                references: vec![child],
            },
            &[parent, child],
        )?;
    }
    let copied = snapshot_copy(&mut heap, parent, &[parent])?;
    let first = collection_load_word(&heap, copied, (0, 0))?;
    let second = collection_load_word(&heap, copied, (1, 0))?;
    assert_eq!(first, second);
    assert_ne!(first, u64::from(child.0));
    crate::vector_set(
        &mut heap,
        child,
        (
            0,
            CollectionWords {
                scalars: vec![9],
                references: vec![],
            },
        ),
    )?;
    let first = crate::Handle(u32::try_from(first).map_err(|_| crate::MemoryError::Internal)?);
    assert_eq!(collection_load_word(&heap, first, (0, 0))?, 7);
    Ok(())
}

#[test]
fn preserves_cycles_without_recursion() -> Result<(), crate::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let original = new_vector(&mut heap, layout(1), &[])?;
    vector_append(
        &mut heap,
        original,
        &CollectionWords {
            scalars: vec![],
            references: vec![original],
        },
        &[original],
    )?;
    let copied = snapshot_copy(&mut heap, original, &[original])?;
    assert_ne!(copied, original);
    assert_eq!(
        collection_load_word(&heap, copied, (0, 0))?,
        u64::from(copied.0)
    );
    Ok(())
}

#[test]
fn copies_empty_vectors_and_rejects_an_exceeded_cell_budget() -> Result<(), crate::MemoryError> {
    let mut heap = Heap::new(MemoryOptions {
        cells: 2,
        ..MemoryOptions::default()
    });
    let original = new_vector(&mut heap, layout(0), &[])?;
    let copied = snapshot_copy(&mut heap, original, &[original])?;
    assert_eq!(crate::collection_length(&heap, copied)?, 0);
    assert_eq!(
        snapshot_copy(&mut heap, original, &[original, copied]),
        Err(crate::MemoryError::CellLimit)
    );
    Ok(())
}

fn vector_append(
    heap: &mut Heap,
    handle: crate::Handle,
    value: &CollectionWords,
    roots: &[crate::Handle],
) -> Result<(), crate::MemoryError> {
    let index = i64::from(crate::collection_length(heap, handle)?);
    crate::vector_insert(heap, handle, (index, value.clone()), roots)
}

#[test]
fn array_copies_preserve_independent_definition_masks() -> Result<(), crate::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let original = crate::new_array(&mut heap, crate::ValueKind::Integer, &[2], &[])?;
    crate::write_element(&mut heap, original, (&[0], 7))?;
    let copied = snapshot_copy(&mut heap, original, &[original])?;
    crate::write_element(&mut heap, original, (&[1], 9))?;
    assert_eq!(crate::read_element(&heap, copied, &[0])?, 7);
    assert_eq!(
        crate::read_element(&heap, copied, &[1]),
        Err(crate::MemoryError::Uninitialized)
    );
    Ok(())
}

#[test]
fn dictionary_copies_ignore_removed_string_keys() -> Result<(), crate::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let removed = crate::new_text(&mut heap, "removed", false, &[])?;
    let kept = crate::new_text(&mut heap, "kept", false, &[removed])?;
    let dictionary = crate::new_dictionary(
        &mut heap,
        pseudolearn_abi::DictionaryLayout {
            value: layout(0),
            key: pseudolearn_abi::DictionaryKeyKind::String,
        },
        &[removed, kept],
    )?;
    insert_dictionary(&mut heap, dictionary, removed, 1)?;
    insert_dictionary(&mut heap, dictionary, kept, 2)?;
    crate::dictionary_remove(&mut heap, dictionary, u64::from(removed.0))?;
    heap.collect(&[dictionary])?;
    let copied = snapshot_copy(&mut heap, dictionary, &[dictionary])?;
    let expected = crate::dictionary_get(&heap, dictionary, u64::from(kept.0))?;
    assert_eq!(
        crate::dictionary_get(&heap, copied, u64::from(kept.0))?,
        expected
    );
    Ok(())
}

fn insert_dictionary(
    heap: &mut Heap,
    dictionary: crate::Handle,
    key: crate::Handle,
    value: u64,
) -> Result<(), crate::MemoryError> {
    crate::dictionary_set(
        heap,
        dictionary,
        (
            u64::from(key.0),
            CollectionWords {
                scalars: vec![value],
                references: Vec::new(),
            },
        ),
        &[dictionary, key],
    )
}

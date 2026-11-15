use pseudolearn_abi::{DictionaryKeyKind, DictionaryLayout, VectorLayout};
use pseudolearn_runtime::{
    CollectionWords, Heap, MemoryOptions, collection_version, dictionary_entry, dictionary_find,
    dictionary_remove, dictionary_set, new_dictionary,
};

#[test]
fn replacement_and_reinsertion_preserve_insertion_order()
-> Result<(), pseudolearn_runtime::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let layout = DictionaryLayout {
        key: DictionaryKeyKind::Integer,
        value: VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
    };
    let handle = new_dictionary(&mut heap, layout, &[])?;
    for (key, value) in [(1, 3), (2, 4), (1, 5)] {
        dictionary_set(
            &mut heap,
            handle,
            (
                key,
                CollectionWords {
                    scalars: vec![value],
                    references: vec![],
                },
            ),
            &[],
        )?;
    }
    assert_eq!(collection_version(&heap, handle)?, 2);
    assert_eq!(
        dictionary_find(&heap, handle, 1)?.map(|value| value.scalars),
        Some(vec![5])
    );
    dictionary_remove(&mut heap, handle, 1)?;
    dictionary_set(
        &mut heap,
        handle,
        (
            1,
            CollectionWords {
                scalars: vec![9],
                references: vec![],
            },
        ),
        &[],
    )?;
    assert_eq!(
        dictionary_entry(&heap, handle, 0)?.map(|entry| entry.0),
        Some(2)
    );
    assert_eq!(
        dictionary_entry(&heap, handle, 1)?.map(|entry| entry.0),
        Some(1)
    );
    assert!(dictionary_remove(&mut heap, handle, 99)?.is_none());
    Ok(())
}

#[test]
fn colliding_keys_survive_compaction_and_string_keys_remain_exact()
-> Result<(), pseudolearn_runtime::MemoryError> {
    use pseudolearn_runtime::{collection_length, dictionary_get, new_text};
    let mut heap = Heap::new(MemoryOptions::default());
    let layout = DictionaryLayout {
        key: DictionaryKeyKind::String,
        value: VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
    };
    let handle = new_dictionary(&mut heap, layout, &[])?;
    let first = new_text(&mut heap, "é", false, &[handle])?;
    let second = new_text(&mut heap, "e\u{301}", false, &[handle, first])?;
    for (key, value) in [(first, 1), (second, 2)] {
        dictionary_set(
            &mut heap,
            handle,
            (
                u64::from(key.0),
                CollectionWords {
                    scalars: vec![value],
                    references: vec![],
                },
            ),
            &[handle, first, second],
        )?;
    }
    assert_eq!(collection_length(&heap, handle)?, 2);
    assert_eq!(
        dictionary_get(&heap, handle, u64::from(first.0))?.scalars,
        vec![1]
    );
    assert_eq!(
        dictionary_get(&heap, handle, u64::from(second.0))?.scalars,
        vec![2]
    );
    heap.collect(&[handle])?;
    assert_eq!(
        dictionary_get(&heap, handle, u64::from(second.0))?.scalars,
        vec![2]
    );
    Ok(())
}

#[test]
fn deletions_and_rebuilds_keep_all_survivors_in_order()
-> Result<(), pseudolearn_runtime::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let layout = DictionaryLayout {
        key: DictionaryKeyKind::Integer,
        value: VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 0,
        },
    };
    let handle = new_dictionary(&mut heap, layout, &[])?;
    for key in 0..64 {
        dictionary_set(
            &mut heap,
            handle,
            (
                key,
                CollectionWords {
                    scalars: vec![key],
                    references: vec![],
                },
            ),
            &[handle],
        )?;
    }
    for key in 0..48 {
        dictionary_remove(&mut heap, handle, key)?;
    }
    for (ordinal, key) in (48..64).enumerate() {
        assert_eq!(
            dictionary_entry(
                &heap,
                handle,
                u32::try_from(ordinal).map_err(|_| pseudolearn_runtime::MemoryError::Internal)?
            )?
            .map(|entry| entry.0),
            Some(key)
        );
    }
    Ok(())
}

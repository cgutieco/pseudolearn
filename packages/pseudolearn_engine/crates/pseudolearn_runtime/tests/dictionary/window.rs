use pseudolearn_runtime::{
    CollectionWords, DictionaryKeyKind, DictionaryLayout, Heap, MemoryOptions, VectorLayout,
};

#[test]
fn reads_only_the_requested_insertion_window() -> Result<(), pseudolearn_runtime::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let layout = DictionaryLayout {
        key: DictionaryKeyKind::Integer,
        value: VectorLayout {
            scalar_words: 1,
            reference_words: 0,
            type_identity: 1,
        },
    };
    let dictionary = pseudolearn_runtime::new_dictionary(&mut heap, layout, &[])?;
    for key in 0..10_u64 {
        let value = CollectionWords {
            scalars: vec![key],
            references: Vec::new(),
        };
        pseudolearn_runtime::dictionary_set(&mut heap, dictionary, (key, value), &[dictionary])?;
    }
    pseudolearn_runtime::dictionary_remove(&mut heap, dictionary, 2)?;
    let window = pseudolearn_runtime::dictionary_window(&heap, dictionary, (2, 2))?;
    assert_eq!(
        window.iter().map(|entry| entry.0).collect::<Vec<_>>(),
        [3, 4]
    );
    assert_eq!(window.len(), 2);
    assert!(pseudolearn_runtime::dictionary_window(&heap, dictionary, (9, 0))?.is_empty());
    assert!(pseudolearn_runtime::dictionary_window(&heap, dictionary, (10, 1)).is_err());
    Ok(())
}

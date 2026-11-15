use pseudolearn_runtime::{
    CollectionPolicy, CollectionWords, EffectValueKind, Handle, Heap, HostValue, MemoryError,
    MemoryOptions, VectorLayout, decode_host_value, maximum_text_points, new_text, new_vector,
    vector_insert,
};

fn heap_with_cells(cells: u64) -> Heap {
    Heap::new(MemoryOptions {
        cells,
        collection: CollectionPolicy::Disabled,
        collection_minimum: 4096,
    })
}

fn shared_text_vector(heap: &mut Heap, text: &str, count: i64) -> Result<Handle, MemoryError> {
    let layout = VectorLayout {
        scalar_words: 0,
        reference_words: 1,
        type_identity: 0,
    };
    let vector = new_vector(heap, layout, &[])?;
    let shared = new_text(heap, text, false, &[vector])?;
    for index in 0..count {
        let words = CollectionWords {
            scalars: Vec::new(),
            references: vec![shared],
        };
        vector_insert(heap, vector, (index, words), &[vector, shared])?;
    }
    Ok(vector)
}

fn decode_list(heap: &Heap, vector: Handle) -> Result<HostValue, MemoryError> {
    decode_host_value(heap, EffectValueKind::TextList, u64::from(vector.0))
}

#[test]
fn maximum_text_points_follows_the_cell_budget() {
    assert_eq!(maximum_text_points(&heap_with_cells(0)), 0);
    assert_eq!(maximum_text_points(&heap_with_cells(1)), 0);
    assert_eq!(maximum_text_points(&heap_with_cells(2)), 8);
    assert_eq!(maximum_text_points(&heap_with_cells(u64::MAX)), u64::MAX);
}

#[test]
fn decodes_a_list_within_the_text_budget() -> Result<(), MemoryError> {
    let mut heap = heap_with_cells(1 << 10);
    let vector = shared_text_vector(&mut heap, "abcd", 3)?;
    assert_eq!(
        decode_list(&heap, vector)?,
        HostValue::TextList(vec!["abcd".to_owned(); 3])
    );
    Ok(())
}

#[test]
fn decodes_an_empty_list() -> Result<(), MemoryError> {
    let mut heap = heap_with_cells(1 << 10);
    let vector = shared_text_vector(&mut heap, "abcd", 0)?;
    assert_eq!(decode_list(&heap, vector)?, HostValue::TextList(Vec::new()));
    Ok(())
}

#[test]
fn rejects_aliased_elements_whose_copies_exceed_the_budget() -> Result<(), MemoryError> {
    let mut heap = heap_with_cells(64);
    let text = "x".repeat(64);
    let vector = shared_text_vector(&mut heap, &text, 20)?;
    assert_eq!(decode_list(&heap, vector), Err(MemoryError::CellLimit));
    Ok(())
}

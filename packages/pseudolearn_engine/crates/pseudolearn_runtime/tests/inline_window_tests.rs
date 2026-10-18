use pseudolearn_runtime::{
    CollectionPolicy, Handle, Heap, InlineBlock, MemoryError, MemoryOptions, heap_allocated_cells,
    heap_ordinal, heap_used_words,
};

fn automatic() -> Heap {
    Heap::new(MemoryOptions {
        cells: 10_000,
        collection: CollectionPolicy::Automatic,
    })
}

#[test]
fn a_fresh_window_has_slack_and_full_collection_room() -> Result<(), MemoryError> {
    let mut heap = automatic();
    let window = heap.inline_window()?;
    assert_eq!(window.used, 1);
    assert_eq!(window.ordinal, 0);
    assert!(window.limit >= window.used + 16_384);
    assert_eq!(window.room_cells, 10_000);
    assert_eq!(window.room_threshold, 4_096);
    assert_eq!(window.free_size_mask, 0);
    Ok(())
}

#[test]
fn forced_collection_closes_the_window() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions {
        cells: 10_000,
        collection: CollectionPolicy::Forced,
    });
    let window = heap.inline_window()?;
    assert_eq!((window.room_cells, window.room_threshold), (0, 0));
    Ok(())
}

#[test]
fn adopted_blocks_advance_the_heap_counters() -> Result<(), MemoryError> {
    let mut heap = automatic();
    let window = heap.inline_window()?;
    let block = InlineBlock {
        handle: Handle(1),
        physical: 8,
        cells: 6,
    };
    heap.adopt_inline((window.used + 8, window.ordinal + 1), &[block])?;
    assert_eq!(heap_used_words(&heap), 9);
    assert_eq!(heap_ordinal(&heap), 1);
    assert_eq!(heap_allocated_cells(&heap), 6);
    let after = heap.inline_window()?;
    assert_eq!(after.room_cells, 10_000 - 6);
    assert_eq!(after.room_threshold, 4_096 - 6);
    Ok(())
}

#[test]
fn adoption_rejects_a_regressing_or_out_of_range_window() -> Result<(), MemoryError> {
    let mut heap = automatic();
    let window = heap.inline_window()?;
    assert_eq!(
        heap.adopt_inline((window.limit + 1, 0), &[]),
        Err(MemoryError::Internal)
    );
    assert_eq!(heap.adopt_inline((0, 0), &[]), Err(MemoryError::Internal));
    heap.adopt_inline((window.used, window.ordinal + 5), &[])?;
    assert_eq!(
        heap.adopt_inline((window.used, 1), &[]),
        Err(MemoryError::Internal)
    );
    Ok(())
}

#[test]
fn a_duplicated_block_is_an_internal_error() -> Result<(), MemoryError> {
    let mut heap = automatic();
    let window = heap.inline_window()?;
    let block = InlineBlock {
        handle: Handle(1),
        physical: 8,
        cells: 6,
    };
    heap.adopt_inline((window.used + 8, window.ordinal + 1), &[block])?;
    assert_eq!(
        heap.adopt_inline((window.used + 16, window.ordinal + 2), &[block]),
        Err(MemoryError::Internal)
    );
    Ok(())
}

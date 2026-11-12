use pseudolearn_runtime::{
    ChannelLayout, Heap, MemoryError, MemoryOptions, heap_live_cells, new_channel_storage,
};

#[test]
fn channel_storage_charges_declared_capacity_before_publication() -> Result<(), MemoryError> {
    let layout = ChannelLayout::new(2, 3).ok_or(MemoryError::Internal)?;
    let mut exact = Heap::new(MemoryOptions {
        cells: 7,
        ..Default::default()
    });
    let storage = new_channel_storage(&mut exact, layout, &[])?;
    assert_ne!(storage.0, 0);
    assert_eq!(exact.reachable_cells(&[storage]), Ok(7));
    let mut insufficient = Heap::new(MemoryOptions {
        cells: 6,
        ..Default::default()
    });
    assert_eq!(
        new_channel_storage(&mut insufficient, layout, &[]),
        Err(MemoryError::CellLimit)
    );
    assert_eq!(heap_live_cells(&insufficient), 0);
    Ok(())
}

#[test]
fn channel_masks_trace_only_occupied_reference_slots() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = pseudolearn_runtime::new_array(
        &mut heap,
        pseudolearn_runtime::ValueKind::Integer,
        &[2],
        &[],
    )?;
    let storage = new_channel_storage(
        &mut heap,
        ChannelLayout::new(2, 1).ok_or(MemoryError::Internal)?,
        &[array],
    )?;
    pseudolearn_runtime::channel_references::store_channel_slot(
        &mut heap,
        storage,
        0,
        &[(u64::from(array.0), true)],
    )?;
    let retained = heap.reachable_cells(&[storage])?;
    heap.collect(&[storage])?;
    assert_eq!(heap.reachable_cells(&[storage])?, retained);
    pseudolearn_runtime::channel_references::store_channel_slot(&mut heap, storage, 0, &[])?;
    assert_eq!(heap.reachable_cells(&[storage])?, 3);
    assert!(
        pseudolearn_runtime::channel_references::store_channel_slot(&mut heap, storage, 2, &[])
            .is_err()
    );
    heap.collect(&[])?;
    assert_eq!(heap.reachable_cells(&[])?, 0);
    Ok(())
}

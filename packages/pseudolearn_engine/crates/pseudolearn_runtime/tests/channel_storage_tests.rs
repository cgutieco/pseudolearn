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

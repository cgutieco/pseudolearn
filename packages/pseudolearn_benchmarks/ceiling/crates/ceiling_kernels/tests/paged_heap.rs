use ceiling_kernels::paged_heap::PagedHeap;

#[test]
fn shared_pages_remain_immutable_after_writes() -> Result<(), String> {
    let mut heap = PagedHeap::default();
    let address = heap.allocate(8193).map_err(|error| format!("{error:?}"))?;
    heap.store(address, 17)
        .map_err(|error| format!("{error:?}"))?;
    let snapshot = heap.checkpoint();
    heap.store(address, 29)
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(heap.dirty_pages(&snapshot), 1);
    assert_eq!(heap.load(address), Ok(29));
    assert_eq!(heap.load(8192), Ok(0));
    assert!(heap.load(12288).is_err());
    Ok(())
}

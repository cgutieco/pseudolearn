use ceiling_kernels::flat_heap::FlatHeap;
use ceiling_kernels::machine::Trap;

#[test]
fn allocation_grows_in_zeroed_blocks_without_invalidating_handles() -> Result<(), Trap> {
    let mut heap = FlatHeap::default();
    heap.reset();
    let first = heap.allocate(7, 2)?;
    assert_eq!(first.0, 1);
    heap.store(2, 42)?;
    let _large = heap.allocate(9, 5000)?;
    assert_eq!(heap.load(2), Ok(42));
    assert_eq!(heap.load(3), Ok(0));
    assert_eq!(heap.words.len() % 4096, 0);
    assert_eq!(heap.load(usize::MAX), Err(Trap::InvalidHandle));
    assert_eq!(heap.allocate(0, u64::MAX), Err(Trap::CellLimit));
    heap.reset();
    let reused = heap.allocate(3, 2)?;
    assert_eq!(reused, first);
    assert_eq!(heap.load(2), Ok(0));
    Ok(())
}

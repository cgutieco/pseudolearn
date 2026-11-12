#![cfg(feature = "telemetry")]

use pseudolearn_runtime::{Heap, MemoryError, MemoryOptions, ValueKind, new_array};

#[test]
fn statistics_count_allocations_growth_and_collections() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    assert_eq!(heap.statistics().allocations, 0);
    let array = new_array(&mut heap, ValueKind::Integer, &[4], &[])?;
    assert_eq!(heap.statistics().allocations, 1);
    assert!(heap.statistics().heap_growths > 0);
    heap.collect(&[array])?;
    assert_eq!(heap.statistics().collections, 1);
    assert_eq!(heap.statistics().reachability_walks, 1);
    assert!(new_array(&mut heap, ValueKind::Integer, &[-1], &[]).is_err());
    assert_eq!(heap.statistics().allocations, 1);
    Ok(())
}

#[test]
fn allocation_pressure_reuses_the_limit_marking_for_collection() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let retained = new_array(&mut heap, ValueKind::Integer, &[4095], &[])?;
    let _second = new_array(&mut heap, ValueKind::Integer, &[1], &[retained])?;
    assert_eq!(heap.statistics().collections, 1);
    assert_eq!(heap.statistics().reachability_walks, 1);
    Ok(())
}

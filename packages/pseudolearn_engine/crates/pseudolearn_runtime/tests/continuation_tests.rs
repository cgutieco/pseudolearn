use pseudolearn_runtime::continuation::{ContinuationValues, new_continuation, read_continuation};
use pseudolearn_runtime::{Handle, Heap, MemoryError, MemoryOptions, ValueKind, new_array};

#[test]
fn continuation_chains_trace_references_and_release_unreachable_segments() -> Result<(), MemoryError>
{
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[2], &[])?;
    let parent = new_continuation(
        &mut heap,
        ContinuationValues {
            function: 1,
            state: 2,
            parent: Handle(0),
            scalars: &[u64::MAX],
            references: &[array],
        },
        &[array],
    )?;
    let child = new_continuation(
        &mut heap,
        ContinuationValues {
            function: 2,
            state: 3,
            parent,
            scalars: &[],
            references: &[],
        },
        &[parent],
    )?;
    let cells = heap.reachable_cells(&[child])?;
    heap.collect(&[child])?;
    assert_eq!(heap.reachable_cells(&[child])?, cells);
    assert_eq!(
        read_continuation(&heap, parent)?,
        (vec![u64::MAX], vec![array])
    );
    heap.collect(&[])?;
    assert_eq!(heap.reachable_cells(&[])?, 0);
    assert!(read_continuation(&heap, child).is_err());
    Ok(())
}

#[test]
fn empty_continuations_obey_exact_cell_limits() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions {
        cells: 1,
        ..Default::default()
    });
    let value = new_continuation(
        &mut heap,
        ContinuationValues {
            function: 0,
            state: 0,
            parent: Handle(0),
            scalars: &[],
            references: &[],
        },
        &[],
    )?;
    assert_eq!(heap.reachable_cells(&[value])?, 1);
    assert_eq!(
        new_continuation(
            &mut heap,
            ContinuationValues {
                function: 0,
                state: 0,
                parent: value,
                scalars: &[],
                references: &[],
            },
            &[value]
        ),
        Err(MemoryError::CellLimit)
    );
    assert!(read_continuation(&heap, Handle(0)).is_err());
    Ok(())
}

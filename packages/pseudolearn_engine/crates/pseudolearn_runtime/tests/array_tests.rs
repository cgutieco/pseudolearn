use pseudolearn_runtime::{
    Heap, MemoryError, MemoryOptions, ValueKind, new_array, read_element, write_element,
};

#[test]
fn arrays_validate_each_dimension_and_track_integer_definition() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[2, 3], &[])?;
    assert_eq!(
        read_element(&heap, array, &[0, 0]),
        Err(MemoryError::Uninitialized)
    );
    assert_eq!(
        write_element(&mut heap, array, (&[0, 3], 1)),
        Err(MemoryError::IndexOutOfRange)
    );
    for row in 0..2 {
        for column in 0..3 {
            assert_eq!(
                write_element(&mut heap, array, (&[row, column], u64::MAX)),
                Ok(())
            );
        }
    }
    assert_eq!(read_element(&heap, array, &[1, 2]), Ok(u64::MAX));
    assert_eq!(
        read_element(&heap, array, &[-1, 2]),
        Err(MemoryError::IndexOutOfRange)
    );
    assert_eq!(
        new_array(&mut heap, ValueKind::Integer, &[-1], &[array]),
        Err(MemoryError::NegativeSize)
    );
    Ok(())
}

#[test]
fn empty_arrays_are_valid_but_have_no_valid_index() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Reference, &[0], &[]).ok();
    assert!(array.is_some());
    if let Some(array) = array {
        assert_eq!(
            read_element(&heap, array, &[0]),
            Err(MemoryError::IndexOutOfRange)
        );
    }
    Ok(())
}

#[test]
fn zero_extents_override_product_overflow_but_not_negative_dimensions() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let empty = new_array(&mut heap, ValueKind::Integer, &[i64::MAX, i64::MAX, 0], &[])?;
    assert_eq!(heap.reachable_cells(&[empty]), Ok(1));
    assert_eq!(
        new_array(&mut heap, ValueKind::Integer, &[0, -1], &[empty]),
        Err(MemoryError::NegativeSize)
    );
    assert_eq!(
        new_array(
            &mut heap,
            ValueKind::Integer,
            &[i64::MAX, i64::MAX],
            &[empty]
        ),
        Err(MemoryError::Resource)
    );
    Ok(())
}

#[test]
fn stable_element_cells_survive_growth_and_dense_transition() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[65], &[])?;
    let cell = pseudolearn_runtime::element_cell(&heap, array, &[64])?;
    let other = new_array(&mut heap, ValueKind::Real, &[20000], &[array])?;
    assert_eq!(
        pseudolearn_runtime::read_memory_cell(&heap, cell),
        Err(MemoryError::Uninitialized)
    );
    for index in 0..65 {
        write_element(&mut heap, array, (&[index], 23))?;
    }
    heap.collect(&[array, other])?;
    assert_eq!(pseudolearn_runtime::read_memory_cell(&heap, cell), Ok(23));
    pseudolearn_runtime::write_memory_cell(&mut heap, cell, u64::MAX)?;
    assert_eq!(read_element(&heap, array, &[64]), Ok(u64::MAX));
    Ok(())
}

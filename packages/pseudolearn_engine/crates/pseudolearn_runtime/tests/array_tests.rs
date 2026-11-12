use pseudolearn_runtime::{
    Heap, MemoryError, MemoryOptions, ValueKind, array_dimensions, new_array, read_element,
    read_element_1d, write_element, write_element_1d,
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
fn direct_one_dimensional_access_checks_definition_and_bounds() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[2], &[])?;
    assert_eq!(
        read_element_1d(&heap, array, 0),
        Err(MemoryError::Uninitialized)
    );
    assert_eq!(write_element_1d(&mut heap, array, 1, 42), Ok(()));
    assert_eq!(read_element_1d(&heap, array, 1), Ok(42));
    assert_eq!(
        read_element_1d(&heap, array, -1),
        Err(MemoryError::IndexOutOfRange)
    );
    assert_eq!(
        write_element_1d(&mut heap, array, 2, 42),
        Err(MemoryError::IndexOutOfRange)
    );
    let matrix = new_array(&mut heap, ValueKind::Integer, &[1, 2], &[array])?;
    assert_eq!(
        read_element_1d(&heap, matrix, 0),
        Err(MemoryError::Internal)
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
fn integer_definition_masks_track_word_boundaries() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[130], &[])?;
    for index in [0, 63, 64, 127, 128, 129] {
        assert_eq!(
            read_element(&heap, array, &[index]),
            Err(MemoryError::Uninitialized)
        );
    }
    for index in [0, 63, 64, 127, 128, 129] {
        let value = u64::try_from(index).map_err(|_| MemoryError::Internal)?;
        write_element(&mut heap, array, (&[index], value))?;
        assert_eq!(read_element(&heap, array, &[index]), Ok(value));
    }
    assert_eq!(
        read_element(&heap, array, &[65]),
        Err(MemoryError::Uninitialized)
    );
    Ok(())
}

#[test]
fn in_band_dimensions_cover_rank_one_empty_and_multiple_dimensions() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let single = new_array(&mut heap, ValueKind::Real, &[4], &[])?;
    let matrix = new_array(&mut heap, ValueKind::Integer, &[2, 3], &[])?;
    let empty = new_array(&mut heap, ValueKind::Integer, &[0], &[])?;
    assert_eq!(array_dimensions(&heap, single), Ok(&[4][..]));
    assert_eq!(array_dimensions(&heap, matrix), Ok(&[2, 3][..]));
    assert_eq!(array_dimensions(&heap, empty), Ok(&[0][..]));
    assert_eq!(
        array_dimensions(&heap, pseudolearn_runtime::Handle(0)),
        Err(MemoryError::Internal)
    );
    let excessive_rank = vec![1; 256];
    assert_eq!(
        new_array(&mut heap, ValueKind::Integer, &excessive_rank, &[]),
        Err(MemoryError::Resource)
    );
    Ok(())
}

#[test]
fn sparse_integer_writes_do_not_define_lower_indices() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[4], &[])?;
    write_element(&mut heap, array, (&[3], 91))?;
    assert_eq!(read_element(&heap, array, &[3]), Ok(91));
    assert_eq!(
        read_element(&heap, array, &[0]),
        Err(MemoryError::Uninitialized)
    );
    Ok(())
}

#[test]
fn array_access_rejects_wrong_rank_and_preserves_reference_absence() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let matrix = new_array(&mut heap, ValueKind::Integer, &[2, 3], &[])?;
    assert_eq!(
        read_element(&heap, matrix, &[0]),
        Err(MemoryError::Internal)
    );
    assert_eq!(
        write_element(&mut heap, matrix, (&[0, 1, 2], 1)),
        Err(MemoryError::Internal)
    );
    let target = new_array(&mut heap, ValueKind::Integer, &[1], &[matrix])?;
    let references = new_array(&mut heap, ValueKind::Reference, &[1], &[matrix, target])?;
    assert_eq!(
        read_element(&heap, references, &[0]),
        Err(MemoryError::Uninitialized)
    );
    write_element(&mut heap, references, (&[0], u64::from(target.0)))?;
    assert_eq!(
        read_element(&heap, references, &[0]),
        Ok(u64::from(target.0))
    );
    Ok(())
}

#[test]
fn stable_element_cells_survive_growth_and_dense_transition() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let array = new_array(&mut heap, ValueKind::Integer, &[65], &[])?;
    assert_eq!(heap.identity(array), Ok(1));
    let cell = pseudolearn_runtime::element_cell(&heap, array, &[64])?;
    let other = new_array(&mut heap, ValueKind::Real, &[20000], &[array])?;
    assert_eq!(heap.identity(array), Ok(1));
    assert_eq!(heap.identity(other), Ok(2));
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

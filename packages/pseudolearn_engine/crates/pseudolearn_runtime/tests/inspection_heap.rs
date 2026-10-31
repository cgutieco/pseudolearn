use pseudolearn_runtime::{Heap, MemoryOptions, ValueKind};

#[test]
fn bounds_a_heap_copy_without_altering_the_original() -> Result<(), pseudolearn_runtime::MemoryError>
{
    let mut original = Heap::new(MemoryOptions::default());
    let array = pseudolearn_runtime::new_array(&mut original, ValueKind::Integer, &[2], &[])?;
    pseudolearn_runtime::write_element(&mut original, array, (&[0], 7))?;
    let mut copied = pseudolearn_runtime::clone_heap_bounded(&original, 2)?;
    pseudolearn_runtime::write_element(&mut copied, array, (&[0], 9))?;
    assert_eq!(
        pseudolearn_runtime::read_element(&original, array, &[0])?,
        7
    );
    assert_eq!(pseudolearn_runtime::read_element(&copied, array, &[0])?, 9);
    assert!(
        pseudolearn_runtime::new_array(&mut copied, ValueKind::Integer, &[1], &[array]).is_err()
    );
    Ok(())
}

#[test]
fn rejects_an_existing_heap_larger_than_the_capture_budget()
-> Result<(), pseudolearn_runtime::MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    pseudolearn_runtime::new_array(&mut heap, ValueKind::Integer, &[2], &[])?;
    assert!(pseudolearn_runtime::clone_heap_bounded(&heap, 1).is_err());
    Ok(())
}

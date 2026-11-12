use pseudolearn_runtime::{
    Heap, MemoryError, MemoryOptions, bytes_at, bytes_content, bytes_length, new_bytes,
};

#[test]
fn managed_binary_bytes_survive_collection_and_bounds_are_checked() -> Result<(), String> {
    let mut heap = Heap::new(MemoryOptions::default());
    let bytes =
        new_bytes(&mut heap, &[0, 255, 128, 42], &[]).map_err(|error| format!("{error:?}"))?;
    heap.collect(&[bytes])
        .map_err(|error| format!("{error:?}"))?;
    assert_eq!(bytes_content(&heap, bytes), Ok(vec![0, 255, 128, 42]));
    assert_eq!(
        bytes_at(&heap, bytes, -1),
        Err(MemoryError::IndexOutOfRange)
    );
    assert_eq!(bytes_at(&heap, bytes, 4), Err(MemoryError::IndexOutOfRange));
    let empty = new_bytes(&mut heap, &[], &[bytes]).map_err(|error| format!("{error:?}"))?;
    assert_eq!(bytes_length(&heap, empty), Ok(0));
    assert_eq!(bytes_at(&heap, empty, 0), Err(MemoryError::IndexOutOfRange));
    Ok(())
}

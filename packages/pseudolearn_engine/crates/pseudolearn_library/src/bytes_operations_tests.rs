use crate::{bytes_from_text, bytes_join, bytes_segment};
use pseudolearn_runtime::MemoryError;

#[test]
fn encodes_utf8_and_copies_complete_ranges() {
    let source = bytes_from_text("😀");
    assert_eq!(source, vec![240, 159, 152, 128]);
    assert_eq!(bytes_segment(&source, 0, 4), Ok(source.clone()));
    assert_eq!(bytes_segment(&source, 4, 0), Ok(Vec::new()));
}

#[test]
fn joins_with_empty_inputs() {
    assert_eq!(bytes_join(&[], &[1, 2]), vec![1, 2]);
    assert_eq!(bytes_join(&[3], &[]), vec![3]);
}

#[test]
fn rejects_ranges_outside_the_sequence() {
    assert_eq!(
        bytes_segment(&[1], 1, 1),
        Err(MemoryError::BytesRangeOutOfBounds)
    );
    assert_eq!(
        bytes_segment(&[1], -1, 0),
        Err(MemoryError::BytesRangeOutOfBounds)
    );
}

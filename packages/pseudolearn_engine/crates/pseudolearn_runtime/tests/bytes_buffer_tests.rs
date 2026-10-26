use pseudolearn_abi::IoErrorKind;
use pseudolearn_runtime::{BytesBuffer, IoError};

#[test]
fn bytes_buffer_empty_and_size() {
    let buffer = BytesBuffer::new();
    assert!(buffer.is_empty());
    assert_eq!(buffer.byte_count(), 0);
}

#[test]
fn bytes_buffer_cell_count_calculation() {
    let buffer = BytesBuffer::from_vec(vec![0; 64]);
    assert_eq!(buffer.cells(), 4);
}

#[test]
fn bytes_buffer_strict_utf8_separation() {
    let raw = vec![0xFF, 0xFE, 0xFD];
    let buffer = BytesBuffer::from_vec(raw);
    let lossy = String::from_utf8_lossy(buffer.as_slice());
    assert!(lossy.contains('\u{FFFD}'));
    let valid_raw = "pseudolearn".as_bytes().to_vec();
    let valid_buffer = BytesBuffer::from_vec(valid_raw);
    assert_eq!(
        std::str::from_utf8(valid_buffer.as_slice()),
        Ok("pseudolearn")
    );
}

#[test]
fn io_error_variants_and_uncertainty() {
    let failure = IoError::permission_denied();
    assert_eq!(failure.kind, IoErrorKind::PermissionDenied);
    assert!(!failure.uncertain);
    let uncertain_failure = IoError::new(IoErrorKind::EndOfFile, true);
    assert_eq!(uncertain_failure.kind, IoErrorKind::EndOfFile);
    assert!(uncertain_failure.uncertain);
}

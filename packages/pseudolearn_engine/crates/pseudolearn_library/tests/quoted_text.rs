use pseudolearn_runtime::{Heap, MemoryOptions, new_text, text_content};

#[test]
fn quoting_preserves_unicode_and_escapes_delimiters() -> Result<(), pseudolearn_runtime::MemoryError>
{
    let mut heap = Heap::new(MemoryOptions::default());
    let original = new_text(&mut heap, "á\n\"\\", false, &[])?;
    let quoted = pseudolearn_library::quote_text(&mut heap, original, &[])?;
    assert_eq!(text_content(&heap, quoted)?, "\"á\\n\\\"\\\\\"");
    Ok(())
}

#[test]
fn quoting_an_absent_reference_is_an_error() {
    let mut heap = Heap::new(MemoryOptions::default());
    assert!(
        pseudolearn_library::quote_text(&mut heap, pseudolearn_runtime::Handle(0), &[]).is_err()
    );
}

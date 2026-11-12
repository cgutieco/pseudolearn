use crate::{LocalOperationRequest, local_operation, local_text_query};
use pseudolearn_runtime::{
    EffectOperation, Handle, Heap, HostValue, MemoryError, MemoryOptions, decode_host_value,
};

fn operation(identity: &str) -> Result<&'static EffectOperation, MemoryError> {
    pseudolearn_runtime::effect_operation(identity).ok_or(MemoryError::Internal)
}

fn text_word(heap: &mut Heap, text: &str) -> Result<u64, MemoryError> {
    pseudolearn_runtime::new_text(heap, text, false, &[]).map(|handle| u64::from(handle.0))
}

fn integer_word(value: i64) -> u64 {
    u64::from_ne_bytes(value.to_ne_bytes())
}

fn copied_result(
    heap: &Heap,
    operation: &EffectOperation,
    words: &[u64],
) -> Result<Option<HostValue>, MemoryError> {
    let arguments = operation
        .parameters
        .iter()
        .zip(words)
        .map(|(kind, word)| decode_host_value(heap, *kind, *word))
        .collect::<Result<Vec<_>, _>>()?;
    local_operation(LocalOperationRequest {
        heap,
        receiver: Handle(0),
        operation,
        arguments: &arguments,
        maximum_json_depth: 64,
    })
}

#[test]
fn borrowed_queries_answer_like_the_copying_path() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let text = text_word(&mut heap, "a😀bé😀")?;
    let probes = [
        ("contains", vec![text, text_word(&mut heap, "bé")?]),
        ("positionOf", vec![text, text_word(&mut heap, "😀")?]),
        ("positionOf", vec![text, text_word(&mut heap, "zz")?]),
        ("startsWith", vec![text, text_word(&mut heap, "a😀")?]),
        ("endsWith", vec![text, text_word(&mut heap, "é😀")?]),
        ("endsWith", vec![text, text_word(&mut heap, "a")?]),
        ("substring", vec![text, integer_word(1), integer_word(3)]),
        ("substring", vec![text, integer_word(5), integer_word(4)]),
    ];
    for (identity, words) in probes {
        let operation = operation(identity)?;
        let borrowed = local_text_query(&heap, operation, &words)?;
        assert!(borrowed.is_some(), "{identity}");
        assert_eq!(
            borrowed,
            copied_result(&heap, operation, &words)?,
            "{identity}"
        );
    }
    Ok(())
}

#[test]
fn empty_texts_and_empty_ranges_are_answered() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let empty = text_word(&mut heap, "")?;
    let contains = local_text_query(&heap, operation("contains")?, &[empty, empty])?;
    assert_eq!(contains, Some(HostValue::Boolean(true)));
    let position = local_text_query(&heap, operation("positionOf")?, &[empty, empty])?;
    assert_eq!(position, Some(HostValue::OptionalInteger(Some(0))));
    let words = [empty, integer_word(0), integer_word(-1)];
    let slice = local_text_query(&heap, operation("substring")?, &words)?;
    assert_eq!(slice, Some(HostValue::Text(String::new())));
    Ok(())
}

#[test]
fn an_out_of_range_substring_defers_to_the_copying_path() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let text = text_word(&mut heap, "abc")?;
    for (first, last) in [(-1, 0), (0, 3), (3, 1), (4, 3), (i64::MAX, i64::MAX)] {
        let words = [text, integer_word(first), integer_word(last)];
        assert_eq!(
            local_text_query(&heap, operation("substring")?, &words)?,
            None
        );
    }
    Ok(())
}

#[test]
fn other_operations_are_not_answered() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let text = text_word(&mut heap, "a,b")?;
    let separator = text_word(&mut heap, ",")?;
    for identity in ["split", "trim", "json_element"] {
        let answer = local_text_query(&heap, operation(identity)?, &[text, separator])?;
        assert_eq!(answer, None, "{identity}");
    }
    Ok(())
}

#[test]
fn malformed_argument_words_are_internal_errors() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let text = text_word(&mut heap, "abc")?;
    let contains = operation("contains")?;
    assert_eq!(
        local_text_query(&heap, contains, &[text]),
        Err(MemoryError::Internal)
    );
    assert_eq!(
        local_text_query(&heap, contains, &[text, u64::MAX]),
        Err(MemoryError::Internal)
    );
    assert_eq!(
        local_text_query(&heap, operation("substring")?, &[text, 0]),
        Err(MemoryError::Internal)
    );
    Ok(())
}

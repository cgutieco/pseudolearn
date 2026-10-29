use pseudolearn_runtime::{Heap, MemoryError, MemoryOptions};

#[test]
fn stores_json_nodes_and_serializes_the_document_root() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let document = pseudolearn_runtime::json_document::new_json_document(
        &mut heap,
        r#"{"name":"value","items":[1,true]}"#,
        &[],
    )?;
    assert_eq!(
        pseudolearn_runtime::json_document::json_document_text(&heap, document)?,
        r#"{"name":"value","items":[1,true]}"#
    );
    Ok(())
}

#[test]
fn preserves_number_lexemes_and_canonical_string_escaping() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let document = pseudolearn_runtime::json_document::new_json_document(
        &mut heap,
        r#"[-0,1e400,"\u0061"]"#,
        &[],
    )?;
    assert_eq!(
        pseudolearn_runtime::json_document::json_document_text(&heap, document)?,
        r#"[-0,1e400,"a"]"#
    );
    Ok(())
}

#[test]
fn rejects_json_documents_beyond_the_flat_table_depth_limit() {
    let mut heap = Heap::new(MemoryOptions::default());
    let accepted = format!("{}0{}", "[".repeat(64), "]".repeat(64));
    let rejected = format!("{}0{}", "[".repeat(65), "]".repeat(65));
    assert!(
        pseudolearn_runtime::json_document::new_json_document(&mut heap, &accepted, &[]).is_ok()
    );
    assert_eq!(
        pseudolearn_runtime::json_document::new_json_document(&mut heap, &rejected, &[]),
        Err(MemoryError::Resource)
    );
}

#[test]
fn child_values_are_views_into_the_same_node_block() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let document = pseudolearn_runtime::json_document::new_json_document(
        &mut heap,
        r#"{"items":[1,{"name":"value"}]}"#,
        &[],
    )?;
    let items = pseudolearn_runtime::json_document::json_field_view(
        &mut heap,
        document,
        "items",
        &[document],
    )?
    .ok_or(MemoryError::Internal)?;
    let element = pseudolearn_runtime::json_document::json_element_view(
        &mut heap,
        items,
        1,
        &[document, items],
    )?
    .ok_or(MemoryError::Internal)?;
    let (document_block, document_node) =
        pseudolearn_runtime::json_document::json_view_parts(&heap, document)?;
    let (element_block, element_node) =
        pseudolearn_runtime::json_document::json_view_parts(&heap, element)?;
    assert_eq!(document_block, element_block);
    assert_ne!(document_node, element_node);
    assert_eq!(
        pseudolearn_runtime::json_document::json_document_text(&heap, element)?,
        r#"{"name":"value"}"#
    );
    Ok(())
}

#[test]
fn a_child_view_keeps_its_node_block_alive_after_collection() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let document = pseudolearn_runtime::json_document::new_json_document(
        &mut heap,
        r#"{"child":[2,3]}"#,
        &[],
    )?;
    let child = pseudolearn_runtime::json_document::json_field_view(
        &mut heap,
        document,
        "child",
        &[document],
    )?
    .ok_or(MemoryError::Internal)?;
    heap.collect(&[child])?;
    assert_eq!(
        pseudolearn_runtime::json_document::json_document_text(&heap, child)?,
        "[2,3]"
    );
    Ok(())
}

#[test]
fn rejects_invalid_document_handles() {
    let heap = Heap::new(MemoryOptions::default());
    assert!(
        pseudolearn_runtime::json_document::json_document_text(
            &heap,
            pseudolearn_runtime::Handle(u32::MAX)
        )
        .is_err()
    );
}

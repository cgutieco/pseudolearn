use crate::{LocalJsonViewCall, local_json_view};
use pseudolearn_runtime::{Handle, Heap, MemoryError, MemoryOptions, json_document};

#[test]
fn local_element_and_field_returns_keep_node_block_views() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let document =
        json_document::new_json_document(&mut heap, r#"{"items":[7],"name":"value"}"#, &[])?;
    let items = json_document::json_field_view(&mut heap, document, "items", &[document])?
        .ok_or(MemoryError::Internal)?;
    let element_operation =
        pseudolearn_runtime::effect_operation("json_element").ok_or(MemoryError::Internal)?;
    let element_arguments = [0];
    let element_roots = [document, items];
    let element_call =
        LocalJsonViewCall::new(items, element_operation, &element_arguments, &element_roots);
    let element = local_json_view(&mut heap, element_call)?.ok_or(MemoryError::Internal)?;
    let element = Handle(u32::try_from(element).map_err(|_| MemoryError::Internal)?);
    let (document_block, _) = json_document::json_view_parts(&heap, document)?;
    let (element_block, _) = json_document::json_view_parts(&heap, element)?;
    let (items_block, _) = json_document::json_view_parts(&heap, items)?;
    assert_eq!(items_block, element_block);
    assert_eq!(json_document::json_document_text(&heap, element)?, "7");

    let name = pseudolearn_runtime::new_text(&mut heap, "name", false, &[document])?;
    let field_operation =
        pseudolearn_runtime::effect_operation("json_field").ok_or(MemoryError::Internal)?;
    let field_arguments = [u64::from(name.0)];
    let field_roots = [document, name];
    let field_call =
        LocalJsonViewCall::new(document, field_operation, &field_arguments, &field_roots);
    let field = local_json_view(&mut heap, field_call)?.ok_or(MemoryError::Internal)?;
    let field = Handle(u32::try_from(field).map_err(|_| MemoryError::Internal)?);
    let (field_block, _) = json_document::json_view_parts(&heap, field)?;
    assert_eq!(document_block, field_block);
    assert_eq!(
        json_document::json_document_text(&heap, field)?,
        "\"value\""
    );
    Ok(())
}

#[test]
fn local_view_operation_returns_absence_for_missing_children() -> Result<(), MemoryError> {
    let mut heap = Heap::new(MemoryOptions::default());
    let document = json_document::new_json_document(&mut heap, "[]", &[])?;
    let operation =
        pseudolearn_runtime::effect_operation("json_element").ok_or(MemoryError::Internal)?;
    let arguments = [4];
    let roots = [document];
    let call = LocalJsonViewCall::new(document, operation, &arguments, &roots);
    assert_eq!(local_json_view(&mut heap, call)?, Some(0));
    Ok(())
}

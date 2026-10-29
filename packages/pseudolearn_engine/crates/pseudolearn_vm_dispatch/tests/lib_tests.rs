use std::path::{Path, PathBuf};

use pseudolearn_vm_dispatch::generate;

const EXPORT: &str = "../../../pseudolearn_spec/specifications/export.json";
const FORMS: &str = "../pseudolearn_vm/data/dispatch_forms.json";

fn manifest_path(relative: &str) -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR")).join(relative)
}

fn real_forms() -> serde_json::Value {
    let text = std::fs::read_to_string(manifest_path(FORMS)).unwrap_or_default();
    serde_json::from_str(&text).unwrap_or(serde_json::Value::Null)
}

fn generate_with(forms: &serde_json::Value, name: &str) -> Result<String, String> {
    let path = std::env::temp_dir().join(format!("pseudolearn_vm_dispatch_{name}.json"));
    std::fs::write(&path, forms.to_string()).map_err(|error| error.to_string())?;
    let result = generate(&manifest_path(EXPORT), &path).map_err(|error| error.to_string());
    let _ = std::fs::remove_file(&path);
    result
}

#[test]
fn generates_every_form_from_the_real_tables() {
    let generated = generate(&manifest_path(EXPORT), &manifest_path(FORMS));
    assert!(generated.is_ok());
    let source = generated.unwrap_or_default();
    assert!(source.contains("IntAddRegisterImmediate { destination: u16, left: u16, right: u64 }"));
    assert!(source.contains("IntLessBranchRegisterRegister"));
    assert!(source.contains("pseudolearn_bytecode::Opcode::IntAdd => DispatchKind::Scalar"));
    assert!(source.contains("pseudolearn_bytecode::Opcode::Jump => DispatchKind::Control"));
    assert!(source.contains("pseudolearn_bytecode::Opcode::TextConcat => DispatchKind::Memory"));
    assert!(source.contains("CompactOp::Jump { edge } => machine.jump::<TASK_RUNTIME>(edge)"));
    assert!(source.contains("CompactOp::ReturnUnit => machine.return_unit::<TASK_RUNTIME>()"));
    assert!(source.contains(
        "if TASK_RUNTIME && let Some(task) = machine.current.task_operation(position, probed)"
    ));
    assert!(source.contains("TaskOp::Channel { site } => machine.channel_operation(site)"));
    assert!(source.contains("Task(TaskOp)"));
    assert!(source.contains("enum CompactOp {"));
    assert!(!source.contains("CompactOp::Task"));
    assert!(
        source.contains("Op::Task(task) => { let index = u32::try_from(task_operations.len())")
    );
}

#[test]
fn unary_rows_have_no_fused_form() {
    let source = generate(&manifest_path(EXPORT), &manifest_path(FORMS)).unwrap_or_default();
    assert!(source.contains("IntNegImmediate"));
    assert!(!source.contains("IntNegBranch"));
}

#[test]
fn rejects_scalar_instruction_without_a_form() {
    let mut forms = real_forms();
    if let Some(operations) = forms
        .get_mut("operations")
        .and_then(serde_json::Value::as_array_mut)
    {
        operations
            .retain(|row| row.get("opcode").and_then(serde_json::Value::as_str) != Some("int.add"));
    }
    let result = generate_with(&forms, "coverage");
    assert!(result.is_err_and(|error| error.contains("int.add")));
}

#[test]
fn rejects_unsupported_arity() {
    let mut forms = real_forms();
    if let Some(row) = forms.pointer_mut("/operations/0") {
        row["arity"] = serde_json::json!(3);
    }
    assert!(generate_with(&forms, "arity").is_err());
}

#[test]
fn rejects_special_form_without_handler() {
    let mut forms = real_forms();
    if let Some(row) = forms
        .pointer_mut("/special/0")
        .and_then(serde_json::Value::as_object_mut)
    {
        row.remove("handler");
    }
    let result = generate_with(&forms, "handler");
    assert!(result.is_err_and(|error| error.contains("handler")));
}

#[test]
fn rejects_missing_forms_file() {
    let missing = manifest_path("data/does_not_exist.json");
    assert!(generate(&manifest_path(EXPORT), &missing).is_err());
}

#[test]
fn rejects_empty_table() {
    assert!(generate_with(&serde_json::json!({}), "empty").is_err());
}

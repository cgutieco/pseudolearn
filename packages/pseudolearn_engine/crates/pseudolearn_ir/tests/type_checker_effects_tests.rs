use pseudolearn_ir::{parse_module, verify_module};

#[test]
fn accepts_json_result_references_in_the_canonical_cell_bank() -> Result<(), String> {
    let source = json_result_module("str");
    let module = parse_module(&source).map_err(|error| error.to_string())?;
    assert_eq!(verify_module(&module), Ok(()));
    Ok(())
}

#[test]
fn rejects_json_result_references_in_the_scalar_cell_bank() -> Result<(), String> {
    let source = json_result_module("i64");
    let module = parse_module(&source).map_err(|error| error.to_string())?;
    assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R3"));
    Ok(())
}

#[test]
fn accepts_optional_json_references_in_the_canonical_cell_bank() -> Result<(), String> {
    let source = optional_json_module("str");
    let module = parse_module(&source).map_err(|error| error.to_string())?;
    assert_eq!(verify_module(&module), Ok(()));
    Ok(())
}

#[test]
fn rejects_optional_json_references_in_the_scalar_cell_bank() -> Result<(), String> {
    let source = optional_json_module("i64");
    let module = parse_module(&source).map_err(|error| error.to_string())?;
    assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R3"));
    Ok(())
}

#[test]
fn accepts_optional_real_payload_in_the_word_bank() -> Result<(), String> {
    let source = optional_real_module("i64");
    let module = parse_module(&source).map_err(|error| error.to_string())?;
    assert_eq!(verify_module(&module), Ok(()));
    Ok(())
}

#[test]
fn rejects_optional_real_payload_outside_the_word_bank() -> Result<(), String> {
    let source = optional_real_module("f64");
    let module = parse_module(&source).map_err(|error| error.to_string())?;
    assert_eq!(verify_module(&module), Err("IR.WELL-FORMEDNESS#R3"));
    Ok(())
}

fn json_result_module(reference_type: &str) -> String {
    format!(
        "module P es\nclass \"$effect:JsonValue\" {{}}\nfunc suspendible @main() -> unit {{\nb0() mass 0:\n  %0 = value.undefined str\n  %1 = const.str \"1\"\n  %2 = cell.local i64\n  %3 = cell.local i64\n  %4 = cell.local i64\n  %5 = cell.local i64\n  %6 = cell.local {reference_type}\n  %7 = effect_call %0, json_parse, obj<\"$effect:JsonValue\">, n1, %1, %2, %3, %4, %5, %6 @1:1-1:2\n  return\n}}\n"
    )
}

fn optional_json_module(reference_type: &str) -> String {
    format!(
        "module P es\nclass \"$effect:JsonValue\" {{}}\nfunc suspendible @main() -> unit {{\nb0() mass 0:\n  %0 = value.undefined obj<\"$effect:JsonValue\">\n  %1 = const.str \"field\"\n  %2 = cell.local {reference_type}\n  %3 = effect_call %0, json_field, obj<\"$effect:JsonValue\">, n1, %1, %2 @1:1-1:2\n  return\n}}\n"
    )
}

fn optional_real_module(payload_type: &str) -> String {
    format!(
        "module P es\nclass \"$effect:JsonValue\" {{}}\nfunc suspendible @main() -> unit {{\nb0() mass 0:\n  %0 = value.undefined obj<\"$effect:JsonValue\">\n  %1 = cell.local i64\n  %2 = cell.local {payload_type}\n  %3 = effect_call %0, json_as_real, f64, n1, %1, %2 @1:1-1:2\n  return\n}}\n"
    )
}

use pseudolearn_bytecode::compile_module;
use pseudolearn_ir::{parse_module, print_canonical, verify_module};

const POINT: &str = "record Point\ndefine x, y as integer;\nendRecord\n";

fn lowered_text(body: &str) -> Result<(pseudolearn_ir::Module, String), String> {
    let program = format!("{POINT}algorithm P\n{body}endAlgorithm\n");
    let module = pseudolearn_api::compile_source_to_module(&program, "en")
        .map_err(|errors| format!("{errors:?}\n{program}"))?;
    verify_module(&module).map_err(|error| format!("{error:?}"))?;
    let text = print_canonical(&module);
    Ok((module, text))
}

fn count(text: &str, operation: &str) -> usize {
    text.matches(&format!("{operation} ")).count()
}

#[test]
fn a_record_array_declaration_allocates_one_array_per_leaf() -> Result<(), String> {
    let (_, text) = lowered_text("dimension a[3] as Point;\n")?;
    assert_eq!(count(&text, "array.new"), 2, "{text}");
    Ok(())
}

#[test]
fn reading_one_leaf_loads_one_element_and_reading_the_record_loads_all_leaves() -> Result<(), String>
{
    let (_, leaf_text) = lowered_text("dimension a[3] as Point;\na[1].x <- 4;\nwrite a[1].x;\n")?;
    assert_eq!(count(&leaf_text, "array.load"), 1, "{leaf_text}");
    assert_eq!(count(&leaf_text, "array.store"), 1, "{leaf_text}");
    let (_, record_text) = lowered_text(
        "dimension a[3] as Point;\na[1] <- Point(1, 2);\ndefine q as Point <- a[1];\nwrite q.y;\n",
    )?;
    assert_eq!(count(&record_text, "array.store"), 2, "{record_text}");
    assert_eq!(count(&record_text, "array.load"), 2, "{record_text}");
    Ok(())
}

#[test]
fn a_single_field_record_array_lowers_to_a_single_array() -> Result<(), String> {
    let program = "record One\ndefine v as integer;\nendRecord\nalgorithm P\ndimension a[2] as One;\nendAlgorithm\n";
    let module = pseudolearn_api::compile_source_to_module(program, "en")
        .map_err(|errors| format!("{errors:?}"))?;
    verify_module(&module).map_err(|error| format!("{error:?}"))?;
    assert_eq!(count(&print_canonical(&module), "array.new"), 1);
    Ok(())
}

#[test]
fn lowered_record_arrays_compile_to_verified_bytecode() -> Result<(), String> {
    let (module, _) = lowered_text(
        "dimension a[3] as Point;\na[2] <- Point(1, 2);\ndefine q as Point <- a[2];\nwrite q.x;\n",
    )?;
    compile_module(&module).map_err(|error| format!("{error:?}"))?;
    Ok(())
}

#[test]
fn loading_an_element_from_a_non_array_is_rejected_by_the_ir_verifier() {
    let text = "module P en\nfunc @main() -> unit {\nb0() mass 0:\n  %0 = const.i64 1\n  %1 = array.load %0, %0\n  return\n}\n";
    let parsed = parse_module(text);
    assert!(parsed.is_ok(), "{parsed:?}");
    let Some(module) = parsed.ok() else {
        return;
    };
    assert!(verify_module(&module).is_err());
}
